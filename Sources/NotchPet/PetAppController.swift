import AppKit
import Darwin
import Pet

/// Presentation and optional service lifetime belong to the app, not its views.
@MainActor
final class PetAppController: NSObject, NSApplicationDelegate {
    private var pet: PetPanelController?
    private var settings: PetSettingsController?
    private lazy var agents = AgentServiceOwner { AgentServices() }
    private var focusBefore: pid_t = -1

    func applicationDidFinishLaunching(_ notification: Notification) {
        focusBefore = NSWorkspace.shared.frontmostApplication?.processIdentifier ?? -1
        let defaults = getenv("NOTCH_PET_PREFERENCES_SUITE")
            .flatMap { UserDefaults(suiteName: String(cString: $0)) } ?? .standard
        let preferences = PetPreferences(defaults: defaults)
        pet = PetPanelController(size: preferences.size)
        pet?.show()
        settings = PetSettingsController(defaults: defaults) { [weak self] size in
            self?.pet?.setSize(size)
        }
        if !defaults.bool(forKey: "pet.setupComplete") {
            settings?.show(activate: false)
        }
        // A future approved Connect flow owns this opt-in preference. Never infer
        // consent from installed agents or an empty observed-session list.
        agents.setEnabled(defaults.bool(forKey: "agentMonitoringEnabled"))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            self.pet?.writeEvidence(phase: "launched", agentsEnabled: self.agents.isEnabled,
                                    focusBefore: self.focusBefore)
        }
    }

    func showPet() {
        pet?.show()
    }

    func showSettings() {
        settings?.show()
    }

    func applicationWillTerminate(_ notification: Notification) {
        agents.setEnabled(false)
        pet?.writeEvidence(phase: "terminated", agentsEnabled: agents.isEnabled, focusBefore: focusBefore)
    }
}
