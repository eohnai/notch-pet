import Testing
@testable import NotchPet

@MainActor
struct AgentServiceOwnerTests {
    private final class Service: AppAgentService {
        var starts = 0
        var stops = 0
        var retainedNotice = "unconfirmed approval"
        func start() { starts += 1 }
        func stop() { stops += 1 }
    }

    @Test func petOnlyStartsNoServiceFactories() {
        var creations = 0
        let owner = AgentServiceOwner {
            creations += 1
            return Service()
        }
        owner.setEnabled(false)
        #expect(creations == 0)
        #expect(!owner.isEnabled)
    }

    @Test func explicitOptInStartsExactlyOnce() {
        let service = Service()
        var creations = 0
        let owner = AgentServiceOwner { creations += 1; return service }
        owner.setEnabled(true)
        owner.setEnabled(true)
        #expect(owner.isEnabled)
        #expect(creations == 1 && service.starts == 1 && service.stops == 0)
    }

    @Test func optionalPathKeepsOneServiceAndItsRetainedState() {
        let service = Service()
        var creations = 0
        let owner = AgentServiceOwner { creations += 1; return service }
        owner.setEnabled(true)
        owner.setEnabled(false)
        owner.setEnabled(false)
        owner.setEnabled(true)
        #expect(creations == 1 && service.starts == 2 && service.stops == 1)
        #expect(service.retainedNotice == "unconfirmed approval")
    }
}
