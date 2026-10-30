import EventBridge
import Testing
@testable import SessionState

struct AgentConnectionRowsTests {
    @Test func missingEvidenceDoesNotClaimConfigurationOrActivity() {
        let rows = AgentConnectionRows.make(enabledAgents: [], health: [])
        #expect(rows.map(\.id) == ["codex", "claude"])
        #expect(rows.map(\.descriptor.displayName) == ["Codex", "Claude Code"])
        #expect(rows.allSatisfy { !$0.isMonitoringEnabled && $0.health == nil })
    }

    @Test func injectedThirdProviderUsesTheSameRows() throws {
        let third = AgentDescriptor(id: "example", displayName: "Example Agent", eventNames: [],
                                    questionTools: [], capabilities: [])
        let catalog = try AgentCatalog(AgentCatalog.builtIn.descriptors + [third])
        let rows = AgentConnectionRows.make(catalog: catalog, enabledAgents: ["example"], health: [])
        #expect(rows.map(\.id) == ["codex", "claude", "example"])
        #expect(rows.last?.descriptor == third)
        #expect(rows.last?.isMonitoringEnabled == false)
        #expect(rows.last?.health == nil)
    }

    @Test func monitoringPreferencesRemainIndependentAndBoundedByCapability() {
        for enabled: Set<String> in [[], ["codex"], ["claude"], ["codex", "claude", "unsupported"]] {
            let rows = AgentConnectionRows.make(enabledAgents: enabled, health: [])
            #expect(rows.map(\.isMonitoringEnabled) == [enabled.contains("codex"), enabled.contains("claude")])
            #expect(rows.count == 2)
            #expect(rows.allSatisfy { $0.health == nil })
        }
    }

    @Test func healthKeepsConfigurationReceiverAndDeliverySeparateFromEnabled() throws {
        let evidence = IntegrationHealthEvidence(agent: .codex, configuration: .missing,
                                                receiver: .listening,
                                                lastDelivery: .init(wallMs: 100, monotonicNs: 200))
        let snapshot = IntegrationHealth.evaluate(evidence)
        let rows = AgentConnectionRows.make(enabledAgents: [], health: [snapshot])
        let row = try #require(rows.first)
        #expect(!row.isMonitoringEnabled)
        #expect(row.health == snapshot)
        #expect(row.health?.configuration == .missing)
        #expect(row.health?.receiver == .listening)
        #expect(row.health?.lastDelivery?.wallMs == 100)
    }

    @Test func catalogOrderDoesNotChangeWhenHealthArrivesInAnotherOrder() {
        let codex = IntegrationHealth.evaluate(.init(agent: .codex))
        let claude = IntegrationHealth.evaluate(.init(agent: .claude, receiver: .failed(.receiverUnavailable)))
        let rows = AgentConnectionRows.make(enabledAgents: ["claude"], health: [claude, codex])
        #expect(rows.map(\.id) == ["codex", "claude"])
        #expect(rows.first?.health == codex)
        #expect(rows.last?.health == claude)
        #expect(rows.last?.isMonitoringEnabled == true)
    }
}
