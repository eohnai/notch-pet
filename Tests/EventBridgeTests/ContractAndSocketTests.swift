import Darwin
import Foundation
import Testing
@testable import EventBridge

private final class Observations: @unchecked Sendable {
    private let lock = NSLock()
    private var values: [ReceivedHookEnvelope] = []
    let signal = DispatchSemaphore(value: 0)
    func append(_ value: ReceivedHookEnvelope) {
        lock.withLock { values.append(value) }
        signal.signal()
    }
    var count: Int { lock.withLock { values.count } }
}

private enum FragmentedInputResult: Equatable {
    case closedDespiteInput, stayedOpen, inconclusive
}

struct ContractAndSocketTests {
    private func endpoint() -> BridgeEndpoint {
        BridgeEndpoint(directory: "/private/tmp/notch-pet-test-\(UUID().uuidString)")
    }
    private func envelope() throws -> HookEnvelopeV1 {
        try HookEnvelopeV1.project(rawHook: Data("{\"session_id\":\"fictional\",\"hook_event_name\":\"SessionStart\"}".utf8), agent: "codex")
    }
    private func connect(_ endpoint: BridgeEndpoint) throws -> Int32 {
        let fd = try makeSocket()
        do { try connectSocket(fd, path: endpoint.socketPath, until: deadline(after: 50)) }
        catch { close(fd); throw error }
        return fd
    }

    @Test func allContractMessageCases() throws {
        // Python serializes independent fixtures; production Swift validates the frames.
        // This preserves integer versus float values and invalid surrogate escapes.
        let process = Process(), output = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        let fixture = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().appendingPathComponent("docs/contracts/agent-events-v1-cases.json")
        process.arguments = ["-c", """
        import base64,json,sys
        result=[]
        for case in json.load(open(sys.argv[1]))['messages']:
            if 'message' in case:
                frame=(json.dumps(case['message'],ensure_ascii=True,sort_keys=True,separators=(',',':'))+'\\n').encode()
            elif 'raw' in case:
                frame=case['raw'].encode()
            else:
                frame=bytes.fromhex(case['hex'])
            if 'pad_to_bytes' in case:
                frame=frame[:-1]+b' '*(case['pad_to_bytes']-len(frame))+frame[-1:]
            result.append(dict(name=case['name'],frame=base64.b64encode(frame).decode(),valid=case['expect']=='valid'))
        print(json.dumps(result))
        """, fixture.path]
        process.standardOutput = output
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        #expect(process.terminationStatus == 0)
        struct Case: Decodable { let name: String; let frame: Data; let valid: Bool }
        let cases = try JSONDecoder().decode([Case].self, from: data)
        #expect(cases.count == 68)
        for item in cases {
            #expect(((try? HookEnvelopeV1.decode(frame: item.frame)) != nil) == item.valid, "\(item.name)")
        }
    }

    @Test func projectionExcludesPrivateFieldsAndMapsClaudeTurn() throws {
        let raw = Data("""
        {"session_id":"fictional","hook_event_name":"PermissionRequest","prompt_id":"turn-a",
         "turn_id":"wrong-provider-turn","tool_name":"Write","tool_use_id":"tool-a","cwd":"/example",
         "prompt":"private prompt","transcript_path":"/must/not/open","tool_input":{"command":"private command"}}
        """.utf8)
        let envelope = try HookEnvelopeV1.project(rawHook: raw, agent: "claude", paneSelector: "unverified")
        #expect(envelope.turnID == "turn-a")
        #expect(envelope.terminal?.paneSelector == "unverified")
        let wire = String(decoding: try envelope.frame(), as: UTF8.self)
        for forbidden in ["private", "transcript", "tool_input", "wrong-provider-turn"] {
            #expect(!wire.contains(forbidden))
        }
        #expect(throws: (any Error).self) {
            try HookEnvelopeV1.project(rawHook: Data(repeating: 32, count: 262_145), agent: "claude")
        }
    }

    @Test func rawHookBoundaryPreservesJSONWhitespaceRules() throws {
        let minimal = Data("{\"session_id\":\"fictional\",\"hook_event_name\":\"SessionStart\"}".utf8)
        for agent in ["codex", "claude"] {
            for byte in [UInt8(9), 10, 13, 32] {
                let padding = Data(repeating: byte, count: HookEnvelopeV1.rawHookLimit - minimal.count)
                for raw in [minimal + padding, padding + minimal] {
                    #expect(try HookEnvelopeV1.project(rawHook: raw, agent: agent).sessionID == "fictional")
                    #expect(throws: BridgeError.invalidMessage) {
                        try HookEnvelopeV1.project(rawHook: raw + Data([32]), agent: agent)
                    }
                }
            }
            for text in ["\u{0b}", "\u{0c}", "\u{a0}"] {
                for raw in [minimal + Data(text.utf8), Data(text.utf8) + minimal] {
                    #expect(throws: BridgeError.invalidMessage) {
                        try HookEnvelopeV1.project(rawHook: raw, agent: agent)
                    }
                }
            }
            #expect(throws: BridgeError.invalidMessage) {
                try HookEnvelopeV1.project(rawHook: minimal + Data(" {}".utf8), agent: agent)
            }
        }
    }

    @Test func fragmentedFrameAndPeerIdentity() throws {
        let endpoint = endpoint(), observations = Observations()
        defer { try? FileManager.default.removeItem(atPath: endpoint.directory) }
        let server = EventBridgeServer(endpoint: endpoint)
        try server.start { observations.append($0) }
        defer { server.stop() }
        let fd = try connect(endpoint)
        defer { close(fd) }
        try requireSameUser(fd)
        #expect(throws: BridgeError.self) { try requireSameUser(fd, expectedUID: getuid() + 1) }
        let frame = try envelope().frame()
        try writeAll(fd, data: Data(frame.prefix(17)), until: deadline(after: 50))
        Thread.sleep(forTimeInterval: 0.01)
        try writeAll(fd, data: Data(frame.dropFirst(17)), until: deadline(after: 50))
        #expect(observations.signal.wait(timeout: .now() + 2) == .success)
        #expect(observations.count == 1)
    }

    @Test func invalidFramesNeverReachCallback() throws {
        let endpoint = endpoint(), observations = Observations()
        defer { try? FileManager.default.removeItem(atPath: endpoint.directory) }
        let server = EventBridgeServer(endpoint: endpoint)
        try server.start { observations.append($0) }
        defer { server.stop() }
        let message = try envelope(), valid = try message.frame()
        let text = String(decoding: valid, as: UTF8.self)
        let padded = Data(valid.dropLast()) + Data(repeating: 32, count: 16_384 - valid.count) + Data([10, 32])
        let frames = [Data("{}\n".utf8), valid + valid, Data(valid.dropLast()),
                      Data([255, 10]), Data(repeating: 32, count: 16_385), padded,
                      Data(text.replacingOccurrences(of: String(message.observedAtMs), with: "0").utf8),
                      Data(text.replacingOccurrences(of: String(message.observedAtMs), with: "9007199254740991").utf8)]
        for frame in frames {
            let fd = try connect(endpoint)
            try? writeAll(fd, data: frame, until: deadline(after: 50))
            close(fd)
        }
        try EventBridgeClient(endpoint: endpoint).send(envelope())
        #expect(observations.signal.wait(timeout: .now() + 2) == .success)
        #expect(observations.count == 1)
    }

    @Test func receiverDeadlineDoesNotResetForEachByte() throws {
        let endpoint = endpoint(), observations = Observations()
        defer { try? FileManager.default.removeItem(atPath: endpoint.directory) }
        let server = EventBridgeServer(endpoint: endpoint)
        try server.start { observations.append($0) }
        defer { server.stop() }
        // A paused test thread can leave a correct receiver no byte to time out against.
        // Such an attempt proves nothing either way, so only it is retried.
        var result = FragmentedInputResult.inconclusive
        var attempts = 0
        while result == .inconclusive && attempts < 5 {
            attempts += 1
            result = try sendFragmentedInput(endpoint)
        }
        #expect(result == .closedDespiteInput, "the deadline must expire despite ongoing fragmented input")
        #expect(observations.count == 0)
        try EventBridgeClient(endpoint: endpoint).send(envelope())
        #expect(observations.signal.wait(timeout: .now() + 2) == .success)
    }

    /// Sends one byte every 15 ms until the receiver closes or 250 ms pass.
    private func sendFragmentedInput(_ endpoint: BridgeEndpoint) throws -> FragmentedInputResult {
        // Mirrors the per-connection read deadline in `EventBridgeServer.receiveLoop`.
        let receiverDeadline: UInt64 = 100_000_000
        let connectStart = monotonicNanoseconds()
        let fd = try connect(endpoint)
        defer { close(fd) }
        let end = deadline(after: 250)
        var lastSendStart: UInt64?
        while monotonicNanoseconds() < end {
            // Timed before the write: a pause after the byte leaves must not shorten the gap.
            let sendStart = monotonicNanoseconds()
            do {
                try writeAll(fd, data: Data([32]), until: deadline(after: 50))
                lastSendStart = sendStart
            } catch BridgeError.unavailable {
                // The receiver closed. The read below observes that.
            } catch BridgeError.timeout {
                // Only a paused sender misses a 50 ms limit for one byte.
                return .inconclusive
            }
            var byte: UInt8 = 0
            let count = recv(fd, &byte, 1, MSG_DONTWAIT)
            if count == 0 || (count < 0 && errno == ECONNRESET) {
                let closedAt = monotonicNanoseconds()
                // A correct receiver never closes before its deadline, which starts after connect.
                #expect(closedAt - connectStart >= receiverDeadline)
                // A resetting receiver closes at least one deadline after the last byte.
                // Closure seen sooner proves that byte did not reset it.
                guard let lastSendStart, closedAt - lastSendStart < receiverDeadline else { return .inconclusive }
                return .closedDespiteInput
            }
            #expect(count < 0 && [EAGAIN, EWOULDBLOCK].contains(errno))
            Thread.sleep(forTimeInterval: 0.015)
        }
        return .stayedOpen
    }

    @Test func refusesUnsafePathsAndKeepsUnrelatedFiles() throws {
        let endpoint = endpoint()
        defer { try? FileManager.default.removeItem(atPath: endpoint.directory) }
        let directory = try directoryFD(endpoint, create: true)
        defer { close(directory) }
        let server = EventBridgeServer(endpoint: endpoint)
        try Data("unrelated".utf8).write(to: URL(fileURLWithPath: endpoint.socketPath))
        #expect(throws: (any Error).self) { try server.start { _ in } }
        #expect(try String(contentsOfFile: endpoint.socketPath, encoding: .utf8) == "unrelated")
        try FileManager.default.removeItem(atPath: endpoint.socketPath)
        #expect(symlink("/private/tmp/nonexistent-fictional-target", endpoint.socketPath) == 0)
        #expect(throws: (any Error).self) { try server.start { _ in } }
        var info = stat()
        #expect(lstat(endpoint.socketPath, &info) == 0)
        #expect(info.st_mode & S_IFMT == S_IFLNK)
        #expect(chmod(endpoint.directory, 0o755) == 0)
        #expect(throws: (any Error).self) { try server.start { _ in } }
        #expect(chmod(endpoint.directory, 0o700) == 0)
        let link = endpoint.directory + "-link"
        defer { unlink(link) }
        #expect(symlink(endpoint.directory, link) == 0)
        #expect(throws: (any Error).self) { try directoryFD(BridgeEndpoint(directory: link), create: false) }
    }

    @Test func recoversOnlyAnOwnedSocketWithoutAListener() throws {
        let endpoint = endpoint()
        defer { try? FileManager.default.removeItem(atPath: endpoint.directory) }
        let directory = try directoryFD(endpoint, create: true)
        defer { close(directory) }
        let fd = try makeSocket()
        #expect(try withAddress(endpoint.socketPath) { bind(fd, $0, $1) } == 0)
        close(fd)
        let server = EventBridgeServer(endpoint: endpoint)
        try server.start { _ in }
        #expect((try socketInfo(directory))!.st_mode & 0o777 == 0o600)
        server.stop()
        #expect(!FileManager.default.fileExists(atPath: endpoint.socketPath))
    }

    @Test func doesNotRemoveAnActiveUncooperativeListener() throws {
        let endpoint = endpoint()
        defer { try? FileManager.default.removeItem(atPath: endpoint.directory) }
        let directory = try directoryFD(endpoint, create: true)
        defer { close(directory) }
        let fd = try makeSocket()
        defer { close(fd) }
        #expect(try withAddress(endpoint.socketPath) { bind(fd, $0, $1) } == 0)
        #expect(listen(fd, 2) == 0)
        let before = try #require(try socketInfo(directory))
        #expect(throws: (any Error).self) { try EventBridgeServer(endpoint: endpoint).start { _ in } }
        let after = try #require(try socketInfo(directory))
        #expect(sameFile(before, after))
    }

    @Test func cleanupLeavesAReplacedPathUntouched() throws {
        let endpoint = endpoint()
        defer { try? FileManager.default.removeItem(atPath: endpoint.directory) }
        let server = EventBridgeServer(endpoint: endpoint)
        try server.start { _ in }
        #expect(unlink(endpoint.socketPath) == 0)
        try Data("replacement".utf8).write(to: URL(fileURLWithPath: endpoint.socketPath))
        server.stop()
        #expect(try String(contentsOfFile: endpoint.socketPath, encoding: .utf8) == "replacement")
    }

    @Test func totalDeadlineAndWriteBackpressure() throws {
        #expect(throws: BridgeError.self) {
            try EventBridgeClient(endpoint: endpoint()).send(envelope(), until: monotonicNanoseconds())
        }
        var pair: [Int32] = [0, 0]
        #expect(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
        defer { close(pair[0]); close(pair[1]) }
        #expect(fcntl(pair[0], F_SETFL, O_NONBLOCK) == 0)
        var enabled: Int32 = 1
        #expect(setsockopt(pair[0], SOL_SOCKET, SO_NOSIGPIPE, &enabled, 4) == 0)
        let start = monotonicNanoseconds()
        #expect(throws: BridgeError.self) {
            try writeAll(pair[0], data: Data(repeating: 32, count: 1_048_576), until: deadline(after: 50))
        }
        #expect(monotonicNanoseconds() - start < 250_000_000)
    }

    @Test func brokenSocketDoesNotRaiseSIGPIPE() throws {
        var pair: [Int32] = [0, 0]
        #expect(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
        defer { close(pair[0]) }
        var enabled: Int32 = 1
        #expect(setsockopt(pair[0], SOL_SOCKET, SO_NOSIGPIPE, &enabled, 4) == 0)
        close(pair[1])
        #expect(throws: BridgeError.self) {
            try writeAll(pair[0], data: Data([32]), until: deadline(after: 50))
        }
    }

    @Test func clientRefusesSocketWithUnexpectedPermissions() throws {
        let endpoint = endpoint(), observations = Observations()
        defer { try? FileManager.default.removeItem(atPath: endpoint.directory) }
        let server = EventBridgeServer(endpoint: endpoint)
        try server.start { observations.append($0) }
        defer { server.stop() }
        #expect(chmod(endpoint.socketPath, 0o666) == 0)
        #expect(throws: BridgeError.self) { try EventBridgeClient(endpoint: endpoint).send(envelope()) }
        #expect(observations.count == 0)
    }

    @Test func stopClosesStalledConnectionAndReleasesOwnership() throws {
        let endpoint = endpoint()
        defer { try? FileManager.default.removeItem(atPath: endpoint.directory) }
        let server = EventBridgeServer(endpoint: endpoint)
        try server.start { _ in Issue.record("stalled connection produced a message") }
        let fd = try connect(endpoint)
        defer { close(fd) }
        Thread.sleep(forTimeInterval: 0.01)
        let start = monotonicNanoseconds()
        server.stop()
        #expect(monotonicNanoseconds() - start < 250_000_000)
        #expect(!FileManager.default.fileExists(atPath: endpoint.socketPath))
        try server.start { _ in }
        server.stop()
    }
}
