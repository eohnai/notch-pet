import AppKit
import Pet
import SwiftUI

@MainActor
final class PetSettingsController {
    private let window: PetSettingsWindow
    private let defaults: UserDefaults
    private let onSizeChange: (Double) -> Void

    init(defaults: UserDefaults, onSizeChange: @escaping (Double) -> Void) {
        self.defaults = defaults
        self.onSizeChange = onSizeChange
        window = PetSettingsWindow(contentRect: NSRect(x: 0, y: 0, width: 360, height: 400),
                                   styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.tabbingMode = .disallowed
        window.appearance = NSAppearance(named: .darkAqua)
    }

    func show(activate: Bool = true) {
        guard let presentation = PetArtwork.presentation() else { return }
        let firstUse = !defaults.bool(forKey: "pet.setupComplete")
        let size = PetPreferences(defaults: defaults).size
        window.title = firstUse ? "Set up your rabbit" : "Pet settings"
        window.contentView = NSHostingView(rootView: PetWindowPlayback(window: window) { [weak self] visible, sleeping in
            PetSettingsView(
            presentation: presentation, size: size, firstUse: firstUse,
            isVisible: visible, isSleeping: sleeping,
            onSizeChange: { [weak self] size in
                guard let self else { return }
                var preferences = PetPreferences(defaults: self.defaults)
                preferences.size = size
                self.onSizeChange(preferences.size)
            },
            onDone: { [weak self] in
                guard let self else { return }
                self.defaults.set(true, forKey: "pet.setupComplete")
                self.close()
            },
            onClose: { [weak self] in self?.close() })
        })
        if !window.isVisible { window.center() }
        window.orderFrontRegardless()
        if activate {
            NSApplication.shared.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        }
    }

    func close() {
        window.close()
    }
}
