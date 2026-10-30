import EventBridge

/// Presentation evidence stays separate from the user's observation preference.
public struct AgentConnectionRow: Identifiable, Equatable, Sendable {
    public let id: String
    public let descriptor: AgentDescriptor
    public let isMonitoringEnabled: Bool
    public let health: IntegrationHealthSnapshot?

    public init(descriptor: AgentDescriptor, isMonitoringEnabled: Bool, health: IntegrationHealthSnapshot?) {
        self.id = descriptor.id
        self.descriptor = descriptor
        self.isMonitoringEnabled = isMonitoringEnabled
        self.health = health
    }
}

/// Pure value projection: no probes, configuration reads, service factories or installation.
public enum AgentConnectionRows {
    public static func make(catalog: AgentCatalog = .builtIn, enabledAgents: Set<String>,
                            health: [IntegrationHealthSnapshot]) -> [AgentConnectionRow] {
        catalog.descriptors.map { descriptor in
            AgentConnectionRow(
                descriptor: descriptor,
                isMonitoringEnabled: descriptor.capabilities.contains(.observation) && enabledAgents.contains(descriptor.id),
                health: health.first { $0.agent.rawValue == descriptor.id })
        }
    }
}
