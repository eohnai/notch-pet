import AppKit
import EventBridge
import SwiftUI

@main
struct NotchPetApp: App {
    @NSApplicationDelegateAdaptor(BridgeAppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra("Notch Pet", systemImage: "pawprint.fill") {
            CompanionMenu()
        }
        .menuBarExtraStyle(.menu)
    }
}

@MainActor
private final class BridgeAppDelegate: NSObject, NSApplicationDelegate {
    private let bridge = EventBridgeServer()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // The future adapters and shared store will consume this callback.
        // The shell does not retain observations or claim connected-agent state.
        try? bridge.start { _ in }
    }

    func applicationWillTerminate(_ notification: Notification) {
        bridge.stop()
    }
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
