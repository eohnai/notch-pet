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
    var body: some View {
        Text("Notch Pet")
        Text("Agent connections are not set up.")

        Divider()

        Button("Quit Notch Pet") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
