/// Production start attempts, observed by the isolated real-app verification.
/// Instrument each app-owned I/O boundary before invoking it.
enum AgentServiceKind: String, CaseIterable {
    case eventReceiver, usageReceiver, providerProcess, configurationProbe, agentRefresh
}

@MainActor
enum ServiceStartLedger {
    private(set) static var starts: [AgentServiceKind: Int] = [:]

    static func record(_ kind: AgentServiceKind) {
        starts[kind, default: 0] += 1
    }
}
