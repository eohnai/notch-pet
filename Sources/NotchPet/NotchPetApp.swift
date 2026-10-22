import AppKit
import SwiftUI

@main
struct NotchPetApp: App {
    var body: some Scene {
        MenuBarExtra("Notch Pet", systemImage: "pawprint.fill") {
            CompanionMenu()
        }
        .menuBarExtraStyle(.menu)
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
