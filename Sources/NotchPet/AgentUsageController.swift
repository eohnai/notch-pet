import Combine
import Darwin
import Foundation
import SessionState

/// Optional app-owned usage I/O; SwiftUI only observes the resulting status/store.
@MainActor
final class AgentUsageController: ObservableObject {
    @Published private(set) var status = "Reading allowance…"
    private let store: UsageStore
    private let sessions: SessionStore
    private var subscription: AnyCancellable?
    private var task: Task<Void, Never>?

    init(store: UsageStore, sessions: SessionStore) {
        self.store = store
        self.sessions = sessions
    }

    func start() {
        guard subscription == nil else { return }
        subscription = sessions.$sessions
            .map { NotchPresentation.activeProviders($0).contains(.codex) }
            .removeDuplicates()
            .sink { [weak self] active in
                guard let self else { return }
                self.task?.cancel()
                self.task = nil
                guard active else { return }
                ServiceStartLedger.record(.agentRefresh)
                self.task = Task { @MainActor [weak self] in
                    guard let self else { return }
                    let path = getenv("PATH").map { String(cString: $0) }
                        ?? "/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"
                    guard path.utf8.count <= 16_384 else {
                        self.status = "Executable search path unavailable."
                        return
                    }
                    let candidates = path.split(separator: ":").prefix(64).map(String.init) +
                        [FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".local/bin").path,
                         "/opt/homebrew/bin", "/usr/local/bin"]
                    guard let executable = candidates.filter({ $0.hasPrefix("/") })
                        .map({ URL(fileURLWithPath: $0).appendingPathComponent("codex") })
                        .first(where: { FileManager.default.isExecutableFile(atPath: $0.path) }) else {
                        self.status = "Codex executable unavailable."
                        return
                    }
                    while !Task.isCancelled {
                        ServiceStartLedger.record(.providerProcess)
                        let observation = await CodexUsageConnection.read(executableURL: executable,
                                                                         sourceID: "codex-managed")
                        guard !Task.isCancelled else { return }
                        self.store.apply(observation)
                        do { try await Task.sleep(for: .seconds(120)) }
                        catch { return }
                    }
                }
            }
    }

    func stop() {
        subscription?.cancel()
        subscription = nil
        task?.cancel()
        task = nil
    }
}
