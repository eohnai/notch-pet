import AppKit
import Darwin
import EventBridge
import Observation
import SessionState
import SwiftUI

@main
struct NotchPetApp: App {
    @NSApplicationDelegateAdaptor(PetAppController.self) private var delegate

    var body: some Scene {
        MenuBarExtra("Notch Pet", systemImage: "pawprint.fill") {
            CompanionMenu(onShowPet: { delegate.showPet() }, onOpenSettings: { delegate.showSettings() })
        }
        .menuBarExtraStyle(.menu)
    }
}

/// App-owned health evidence. Probes run only when an explicit future Check action calls refresh.
@MainActor
@Observable
private final class IntegrationHealthController {
    private(set) var evidence: [IntegrationAgent: IntegrationHealthEvidence] =
        Dictionary(uniqueKeysWithValues: IntegrationAgent.allCases.map {
            ($0, IntegrationHealthEvidence(agent: $0))
        })
    private var refreshing: Set<IntegrationAgent> = []

    var snapshots: [IntegrationHealthSnapshot] {
        IntegrationAgent.allCases.compactMap { agent in
            evidence[agent].map { IntegrationHealth.evaluate($0) }
        }
    }

    func refresh(agent: IntegrationAgent) async {
        guard !Task.isCancelled, refreshing.insert(agent).inserted else { return }
        ServiceStartLedger.record(.configurationProbe)
        defer { refreshing.remove(agent) }
        let manager = FileManager.default
        // Access only these path settings; do not inventory the environment or read auth files.
        let searchPath = getenv("PATH").map { String(cString: $0) } ?? "/usr/bin:/bin:/usr/sbin:/sbin"
        let executable: URL?
        if searchPath.utf8.count <= 16_384 {
            executable = searchPath.split(separator: ":", omittingEmptySubsequences: false).prefix(64)
                .filter { $0.hasPrefix("/") }
                .map { URL(fileURLWithPath: String($0)).appendingPathComponent(agent.rawValue) }
                .first { manager.isExecutableFile(atPath: $0.path) }
        } else {
            executable = nil
        }
        let directoryOverride = getenv(agent == .codex ? "CODEX_HOME" : "CLAUDE_CONFIG_DIR")
            .map { String(cString: $0) }
        let configurationDirectory: URL?
        if let directoryOverride, !directoryOverride.isEmpty {
            configurationDirectory = directoryOverride.hasPrefix("/") && directoryOverride.utf8.count <= 4096
                ? URL(fileURLWithPath: directoryOverride) : nil
        } else {
            configurationDirectory = manager.homeDirectoryForCurrentUser
                .appendingPathComponent(agent == .codex ? ".codex" : ".claude")
        }
        let configuration = configurationDirectory?
            .appendingPathComponent(agent == .codex ? "hooks.json" : "settings.json")
        let helper = Bundle.main.executableURL?.deletingLastPathComponent()
            .appendingPathComponent("NotchPetHook")
        let result = await IntegrationHealthProbe.inspect(agent: agent, executableURL: executable,
                                                          configurationURL: configuration, helperURL: helper)
        guard !Task.isCancelled, var current = evidence[agent] else { return }
        // Receiver and delivery can change during await; never replace them with a probe's defaults.
        current.version = result.version
        current.configuration = result.configuration
        current.helper = result.helper
        evidence[agent] = current
    }

    func setReceiver(_ state: IntegrationReceiverState) {
        var updated = evidence
        for agent in IntegrationAgent.allCases {
            updated[agent]?.receiver = state
        }
        evidence = updated
    }

    func recordDeliveries(_ observations: [SessionObservationV1]) {
        guard !observations.isEmpty else { return }
        var updated = evidence
        for observation in observations {
            guard let agent = IntegrationAgent(rawValue: observation.envelope.agent) else { continue }
            updated[agent]?.lastDelivery = IntegrationDeliveryReceipt(
                wallMs: observation.receiptWallMs, monotonicNs: observation.receiptMonotonicNs)
        }
        // The inbox's receipt order, not session expiry or wall-clock sorting, determines the last receipt.
        if updated != evidence { evidence = updated }
    }
}

@MainActor
final class AgentServices: NSObject, AppAgentService {
    let sessionStore = SessionStore()
    private let integrationHealth = IntegrationHealthController()
    private let bridge = EventBridgeServer()
    private var inbox: SessionEventInbox?
    private var expiryTimer: DispatchSourceTimer?
    private var receiptCutoffNs: UInt64 = 0
    private var notchPanel: NotchPanelController?

    func start() {
        let notchPanel = NotchPanelController(sessionStore: sessionStore)
        self.notchPanel = notchPanel
        notchPanel.show()
        let inbox = SessionEventInbox { [weak self] batch, lost in
            guard let self else { return }
            // Delivery happened even when a clock cutoff prevents it from restoring session freshness.
            self.integrationHealth.recordDeliveries(batch)
            // Evidence queued before sleep or a clock change cannot establish a fresh baseline.
            let eligible = batch.filter { $0.receiptMonotonicNs >= self.receiptCutoffNs }
            self.sessionStore.applyBatch(eligible, observationsLost: lost,
                                         wallMs: self.wallMs(), monotonicNs: self.monotonicNs())
            self.scheduleExpiry()
        }
        self.inbox = inbox
        do {
            ServiceStartLedger.record(.eventReceiver)
            try bridge.start { inbox.receive($0) }
            integrationHealth.setReceiver(.listening)
        } catch BridgeError.unsafeEndpoint {
            integrationHealth.setReceiver(.failed(.unsafeEndpoint))
        } catch {
            integrationHealth.setReceiver(.failed(.receiverUnavailable))
        }
        let workspace = NSWorkspace.shared.notificationCenter
        workspace.addObserver(self, selector: #selector(invalidateObservations),
                              name: NSWorkspace.willSleepNotification, object: nil)
        workspace.addObserver(self, selector: #selector(invalidateObservations),
                              name: NSWorkspace.didWakeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateObservations),
                                               name: .NSSystemClockDidChange, object: nil)
    }

    func showNotch() { notchPanel?.show() }

    func stop() {
        notchPanel?.stop()
        bridge.stop()
        integrationHealth.setReceiver(.stopped)
        expiryTimer?.cancel()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func invalidateObservations(_ notification: Notification) {
        receiptCutoffNs = monotonicNs()
        sessionStore.invalidateClocks()
        expiryTimer?.cancel()
        expiryTimer = nil
    }

    private func scheduleExpiry() {
        expiryTimer?.cancel()
        expiryTimer = nil
        guard let next = sessionStore.nextExpiryMonotonicNs else { return }
        let now = monotonicNs()
        // Check clock continuity once per second while fresh observations exist.
        // An empty or entirely unknown store has no timer.
        let delay = min(next > now ? next - now : 0, 1_000_000_000)
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + .nanoseconds(Int(delay)), leeway: .milliseconds(5))
        timer.setEventHandler { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.sessionStore.checkClocks(wallMs: self.wallMs(), monotonicNs: self.monotonicNs())
                self.scheduleExpiry()
            }
        }
        expiryTimer = timer
        timer.resume()
    }

    private func wallMs() -> Int64 { Int64(Date().timeIntervalSince1970 * 1000) }
    private func monotonicNs() -> UInt64 { DispatchTime.now().uptimeNanoseconds }
}

private struct CompanionMenu: View {
    let onShowPet: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        Button("Show Pet", action: onShowPet)
        Button("Pet Settings…", action: onOpenSettings)
            .keyboardShortcut(",")
        Divider()
        Button("Quit Notch Pet") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
