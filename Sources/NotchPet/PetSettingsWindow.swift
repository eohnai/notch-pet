import AppKit

final class PetSettingsWindow: NSWindow {
    override func cancelOperation(_ sender: Any?) {
        close()
    }
}
