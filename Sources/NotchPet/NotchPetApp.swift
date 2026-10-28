import AppKit
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
        }
        .menuBarExtraStyle(.menu)
    }
}

@MainActor
private final class BridgeAppDelegate: NSObject, NSApplicationDelegate {
    let sessionStore = SessionStore()
    private let bridge = EventBridgeServer()
    private var inbox: SessionEventInbox?
    private var expiryTimer: DispatchSourceTimer?
    private var receiptCutoffNs: UInt64 = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        let inbox = SessionEventInbox { [weak self] batch, lost in
            guard let self else { return }
            // Evidence queued before sleep or a clock change cannot establish a fresh baseline.
            let eligible = batch.filter { $0.receiptMonotonicNs >= self.receiptCutoffNs }
            self.sessionStore.applyBatch(eligible, observationsLost: lost,
                                         wallMs: self.wallMs(), monotonicNs: self.monotonicNs())
            self.scheduleExpiry()
        }
        self.inbox = inbox
        try? bridge.start { inbox.receive($0) }
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
