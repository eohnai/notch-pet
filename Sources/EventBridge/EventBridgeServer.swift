import Darwin
import Foundation

public struct ReceivedHookEnvelope: Sendable {
    public let envelope: HookEnvelopeV1
    public let receiptWallMs: Int64
    public let receiptMonotonicNs: UInt64
}

/// A single bounded receive worker keeps socket work off the app's main thread.
/// The callback runs on this worker and must return promptly.
public final class EventBridgeServer: @unchecked Sendable {
    private let endpoint: BridgeEndpoint
    private let lifecycle = NSLock()
    private let state = NSLock()
    private var running = false
    private let worker = DispatchQueue(label: "notch-pet.events-v1")
    private let workerKey = DispatchSpecificKey<Bool>()
    private let completion = DispatchGroup()

    public init(endpoint: BridgeEndpoint = .standard) {
        self.endpoint = endpoint
        worker.setSpecific(key: workerKey, value: true)
    }

    public func start(onEnvelope: @escaping @Sendable (ReceivedHookEnvelope) -> Void) throws {
        guard DispatchQueue.getSpecific(key: workerKey) != true else { throw BridgeError.unavailable }
        lifecycle.lock()
        defer { lifecycle.unlock() }
        guard !state.withLock({ running }) else { throw BridgeError.unavailable }
        completion.wait()
        let directory = try directoryFD(endpoint, create: true)
        var lockFD: Int32 = -1
        var listener: Int32 = -1
        var identity: stat?
        do {
            // Never remove this file: unlinking a held lock would allow a second owner.
            lockFD = openat(directory, "listener.lock", O_RDWR | O_CREAT | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK, 0o600)
            var lockInfo = stat()
            guard lockFD >= 0, fstat(lockFD, &lockInfo) == 0,
                  lockInfo.st_uid == getuid(), lockInfo.st_mode & S_IFMT == S_IFREG,
                  lockInfo.st_mode & 0o7777 == 0o600, lockInfo.st_nlink == 1,
                  flock(lockFD, LOCK_EX | LOCK_NB) == 0 else { throw BridgeError.unsafeEndpoint }

            if let existing = try socketInfo(directory) {
                let probe = try makeSocket()
                defer { close(probe) }
                // Only ECONNREFUSED proves that the owned endpoint has no listener.
                let result = try withAddress(endpoint.socketPath) { connect(probe, $0, $1) }
                guard result == -1, errno == ECONNREFUSED else { throw BridgeError.unavailable }
                guard let current = try socketInfo(directory), sameFile(existing, current),
                      unlinkat(directory, "events-v1.sock", 0) == 0 else { throw BridgeError.unsafeEndpoint }
            }
            listener = try makeSocket()
            guard try withAddress(endpoint.socketPath, { bind(listener, $0, $1) }) == 0 else {
                throw BridgeError.unavailable
            }
            identity = try socketInfo(directory)
            guard identity != nil, fchmodat(directory, "events-v1.sock", 0o600, 0) == 0,
                  listen(listener, 16) == 0 else { throw BridgeError.unavailable }
            let ownedListener = listener, ownedLock = lockFD, ownedIdentity = identity!
            state.withLock { running = true }
            completion.enter()
            worker.async { [self] in
                defer {
                    close(ownedListener)
                    removeOwnedSocket(directory, identity: ownedIdentity)
                    close(ownedLock)
                    close(directory)
                    completion.leave()
                }
                receiveLoop(ownedListener, onEnvelope: onEnvelope)
            }
        } catch {
            if listener >= 0 { close(listener) }
            if let identity { removeOwnedSocket(directory, identity: identity) }
            if lockFD >= 0 { close(lockFD) }
            close(directory)
            throw error
        }
    }

    public func stop() {
        if DispatchQueue.getSpecific(key: workerKey) == true {
            state.withLock { running = false }
            return
        }
        lifecycle.lock()
        defer { lifecycle.unlock() }
        state.withLock { running = false }
        completion.wait()
    }

    private func receiveLoop(_ listener: Int32, onEnvelope: @Sendable (ReceivedHookEnvelope) -> Void) {
        while state.withLock({ running }) {
            do { try waitFor(listener, Int16(POLLIN), until: deadline(after: 10)) }
            catch { continue }
            let fd = accept(listener, nil, nil)
            let readDeadline = deadline(after: 100)
            guard fd >= 0 else { continue }
            defer { close(fd) }
            do {
                guard fcntl(fd, F_SETFL, O_NONBLOCK) == 0, fcntl(fd, F_SETFD, FD_CLOEXEC) == 0 else {
                    throw BridgeError.unavailable
                }
                try requireSameUser(fd)
                let frame = try readBounded(fd, limit: HookEnvelopeV1.frameLimit, until: readDeadline, framed: true)
                let wall = wallMilliseconds(), monotonic = monotonicNanoseconds()
                let envelope = try HookEnvelopeV1.decode(frame: frame)
                let age = wall - envelope.observedAtMs
                guard age <= 30_000, age >= -2000, state.withLock({ running }) else { continue }
                onEnvelope(ReceivedHookEnvelope(envelope: envelope, receiptWallMs: wall, receiptMonotonicNs: monotonic))
            } catch {
                // Invalid and incomplete frames cannot reach the future store callback.
            }
        }
    }
}
