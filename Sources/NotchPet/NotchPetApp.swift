import AppKit
import Darwin
import EventBridge
import SessionState
import SwiftUI

@main
struct NotchPetApp: App {
    @NSApplicationDelegateAdaptor(BridgeAppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra("Notch Pet", systemImage: "pawprint.fill") {
            CompanionMenu()
                .environmentObject(delegate.sessionStore)
                .environmentObject(delegate.integrationHealth)
        }
        .menuBarExtraStyle(.menu)
    }
}

/// App-owned health evidence. Probes run only when an explicit future Check action calls refresh.
@MainActor
private final class IntegrationHealthController: ObservableObject {
    @Published private(set) var evidence: [IntegrationAgent: IntegrationHealthEvidence] =
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
private final class BridgeAppDelegate: NSObject, NSApplicationDelegate {
    let sessionStore = SessionStore()
    let integrationHealth = IntegrationHealthController()
    private let bridge = EventBridgeServer()
    private var inbox: SessionEventInbox?
    private var expiryTimer: DispatchSourceTimer?
    private var receiptCutoffNs: UInt64 = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
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

    func applicationWillTerminate(_ notification: Notification) {
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
    @EnvironmentObject private var sessionStore: SessionStore

    var body: some View {
        Text("Notch Pet")

        if sessionStore.sessions.isEmpty {
            Text("No sessions observed yet.")
        } else {
            ForEach(sessionStore.sessions) { snapshot in
                SessionMenuEntry(snapshot: snapshot)
            }
        }

        Divider()

        Button("Quit Notch Pet") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

private struct SessionMenuEntry: View {
    let snapshot: SessionSnapshot

    private var statusLabel: String {
        switch snapshot.status {
        case .idle: "Observed idle"
        case .working: "Working"
        case .questionNeeded: "Answer needed"
        case .approvalNeeded: "Approval needed"
        case .responseReady: "Response ready"
        case .unknown: "Unknown"
        case .ended: "Ended"
        }
    }

    private var unknownExplanation: String {
        switch snapshot.reason {
        case .expired:
            "State observations expired after two minutes."
        case .clockOrWake:
            "Fresh evidence is needed after a clock change or sleep/wake."
        case .reusedSessionID:
            "This session identity was already observed ending."
        case .identityCapacity, .requestCapacity:
            "Observation capacity was reached. Current activity is unconfirmed."
        case .deliveryOverflow:
            "Some observations were lost. Current activity is unconfirmed."
        case .noBaseline, .missingTurnIdentity, .uncorrelatedStop,
             .uncorrelatedActivity, .uncorrelatedResolution:
            "Observations could not be matched to a confirmed current turn."
        case .eventIDConflict, .ambiguousCaptureOrder, .overlappingTurns,
             .activityAfterStop, .requestConflict:
            "Conflicting observations leave current activity unconfirmed."
        case nil:
            "Current activity is unconfirmed."
        }
    }

    var body: some View {
        let agent = snapshot.key.agent == "codex" ? "Codex" : "Claude Code"
        let project = snapshot.projectPath.map { URL(fileURLWithPath: $0).lastPathComponent }
        let projectLabel = project.flatMap { $0.isEmpty ? nil : $0 } ?? "Project not observed"

        Menu {
            Text("Agent: \(agent)")
            Text("Session: \(snapshot.key.sessionID)")
            Text("Project: \(snapshot.projectPath ?? "Not observed")")
            Text("Status: \(statusLabel)")

            if snapshot.status == .unknown {
                Text(unknownExplanation)
            }

            if let receipt = snapshot.receiptWallMs {
                let date = Date(timeIntervalSince1970: Double(receipt) / 1000)
                Text("State last refreshed: \(date.formatted(date: .abbreviated, time: .standard))")
            } else {
                Text("No confirmed state refresh recorded.")
            }

            if !snapshot.pendingRequests.isEmpty {
                Divider()

                ForEach(snapshot.pendingRequests, id: \.eventID) { request in
                    let kind = request.kind == .questionNeeded ? "Question" : "Approval"
                    if request.isConfirmed {
                        Text("\(kind) needed: \(request.toolName)")
                    } else {
                        Text("Unconfirmed \(kind.lowercased()) notice: \(request.toolName)")
                    }
                    if let toolUseID = request.toolUseID {
                        Text("Tool call: \(toolUseID)")
                    }
                }
            }
        } label: {
            Text("\(agent) · \(projectLabel) · \(snapshot.key.sessionID) — \(statusLabel)")
        }
    }
}
