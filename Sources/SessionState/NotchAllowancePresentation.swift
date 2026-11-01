import Foundation

private extension UsageWindow {
    var allowancePercentLeft: Int {
        Int((100 - usedPercent).rounded(.down))
    }
}

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
        window?.allowancePercentLeft
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
    public static func countdownText(for window: UsageWindow?, at nowMs: Int64) -> String {
        guard let reset = window?.resetsAtMs else { return "—" }
        guard reset > nowMs else { return "0m" }
        // The positive difference between signed endpoints can exceed Int64.max.
        let remainingMs = UInt64(bitPattern: reset) &- UInt64(bitPattern: nowMs)
        let minutes = remainingMs / 60_000
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h\(minutes % 60)m" }
        return "\(hours / 24)d\(hours % 24)h"
    }

    public static func tooltipText(for provider: IntegrationAgent,
                                   snapshots: [UsageSnapshot],
                                   missingSourceStatus: String,
                                   locale: Locale,
                                   timeZone: TimeZone) -> String {
        let heading = provider == .codex ? "Codex allowance" : "Claude Code allowance"
        let sources = snapshots.filter { $0.observation.provider == provider.rawValue }.sorted {
            $0.observation.sourceID.utf8.lexicographicallyPrecedes($1.observation.sourceID.utf8)
        }
        guard !sources.isEmpty else {
            return [heading, missingSourceStatus, "5-hour: unavailable", "Weekly: unavailable"].joined(separator: "\n")
        }

        let dates = DateFormatter()
        dates.locale = locale
        dates.timeZone = timeZone
        dates.dateStyle = .medium
        dates.timeStyle = .short
        let numbers = FloatingPointFormatStyle<Double>.number.locale(locale).precision(.fractionLength(0...1))
        let descriptions = sources.enumerated().map { index, snapshot in
            let observation = snapshot.observation
            let confidence = observation.accountID == nil ? "Account unverified" : "Account known"
            var lines = [
                "Source \(index + 1) · \(confidence)",
                snapshot.isStale ? "Stale observation — awaiting a new reading." : "Fresh observation.",
                "Received: \(dateText(observation.receivedAtMs, formatter: dates))",
                "Measured: \(dateText(observation.measuredAtMs, formatter: dates))"
            ]
            if let failure = observation.failure {
                lines.append(failureText(failure))
            }
            for window in observation.windows.sorted(by: { $0.id.utf8.lexicographicallyPrecedes($1.id.utf8) }) {
                let used = window.usedPercent.formatted(numbers)
                let left = window.allowancePercentLeft.formatted(.number.locale(locale))
                lines.append("\(windowLabel(window.durationMinutes)) [\(window.id)]: \(used)% used · \(left)% left")
                lines.append("Resets: \(dateText(window.resetsAtMs, formatter: dates))")
            }
            if !observation.windows.contains(where: { $0.durationMinutes == 300 }) {
                lines.append("5-hour: not reported")
            }
            if !observation.windows.contains(where: { $0.durationMinutes == 10_080 }) {
                lines.append("Weekly: not reported")
            }
            return lines.joined(separator: "\n")
        }
        return ([heading] + descriptions).joined(separator: "\n\n")
    }

    private static func dateText(_ timestampMs: Int64?, formatter: DateFormatter) -> String {
        guard let timestampMs else { return "not reported" }
        let text = formatter.string(from: Date(timeIntervalSince1970: Double(timestampMs) / 1_000))
        return text.isEmpty ? "unavailable" : text
    }

    private static func windowLabel(_ minutes: Int?) -> String {
        switch minutes {
        case 300: "5-hour"
        case 10_080: "Weekly"
        case .some(let value): "\(value)-minute window"
        case nil: "Window duration not reported"
        }
    }

    private static func failureText(_ failure: UsageFailure) -> String {
        switch failure {
        case .awaitingSource: "Awaiting source data."
        case .signedOut: "Source signed out."
        case .unsupportedAccount: "Account does not support allowance readings."
        case .sourceUnavailable: "Allowance source unavailable."
        case .malformed: "Invalid allowance reading."
        case .timedOut: "Source timed out."
        }
    }

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
