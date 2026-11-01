public enum AllowanceColor: Equatable, Sendable {
    case green, yellow, red, gray
}

public struct NotchAllowanceEntry: Equatable, Sendable {
    public let provider: IntegrationAgent
    public let source: UsageSnapshot?
    public let window: UsageWindow?

    public var windowLabel: String {
        window?.durationMinutes == 10_080 ? "7d" : "5h"
    }

    public var percentLeft: Int? {
        window.map { Int((100 - $0.usedPercent).rounded(.down)) }
    }

    public var color: AllowanceColor {
        guard source?.isStale == false, let percentLeft else { return .gray }
        if percentLeft > 50 { return .green }
        return percentLeft >= 20 ? .yellow : .red
    }

    public var accountUnverified: Bool {
        guard let source else { return false }
        return source.observation.accountID == nil
    }
}

public enum NotchAllowancePresentation {
    public static func entries(activeProviders: Set<IntegrationAgent>,
                               snapshots: [UsageSnapshot]) -> [NotchAllowanceEntry] {
        activeProviders.sorted { $0.rawValue < $1.rawValue }.map { provider in
            let source = snapshots.filter { $0.observation.provider == provider.rawValue }.sorted { left, right in
                if left.isStale != right.isStale { return !left.isStale }
                if left.observation.receivedAtMs != right.observation.receivedAtMs {
                    return left.observation.receivedAtMs > right.observation.receivedAtMs
                }
                return left.observation.sourceID.utf8.lexicographicallyPrecedes(right.observation.sourceID.utf8)
            }.first
            return NotchAllowanceEntry(provider: provider, source: source,
                                       window: selectedWindow(source?.observation.windows ?? [], provider: provider))
        }
    }

    private static func selectedWindow(_ windows: [UsageWindow], provider: IntegrationAgent) -> UsageWindow? {
        let fiveHour = windows.filter { $0.durationMinutes == 300 }
        let matches = fiveHour.isEmpty ? windows.filter { $0.durationMinutes == 10_080 } : fiveHour
        if provider == .codex {
            let codex = matches.filter { $0.id.hasPrefix("codex/") }
            if !codex.isEmpty { return codex.count == 1 ? codex.first : nil }
        }
        // Ambiguous buckets cannot establish one provider-wide allowance.
        return matches.count == 1 ? matches.first : nil
    }
}
