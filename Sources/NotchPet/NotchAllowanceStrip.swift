import SessionState
import SwiftUI

struct NotchAllowanceStrip: View {
    let store: UsageStore
    let activeProviders: Set<IntegrationAgent>
    @Environment(AgentUsageController.self) private var usageController
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone

    var body: some View {
        // The parent creates this view only while expanded. With no providers,
        // there is no allowance to age and no countdown to schedule.
        if !activeProviders.isEmpty {
            TimelineView(.periodic(from: .now, by: 30)) { context in
                let nowMs = Int64(context.date.timeIntervalSince1970 * 1_000)
                let snapshots = store.snapshots(activeProviders: activeProviders, nowMs: nowMs)
                let entries = NotchAllowancePresentation.entries(activeProviders: activeProviders,
                                                                  snapshots: snapshots)
                HStack(spacing: 5) {
                    ForEach(entries, id: \.provider) { entry in
                        if entry.provider != entries.first?.provider {
                            Rectangle().fill(.gray).frame(width: 1, height: 12)
                                .accessibilityHidden(true)
                        }
                        providerEntry(entry, snapshots: snapshots, nowMs: nowMs)
                    }
                }
                .font(.caption2.weight(.medium))
                .monospacedDigit()
            }
        }
    }

    private func providerEntry(_ entry: NotchAllowanceEntry,
                               snapshots: [UsageSnapshot], nowMs: Int64) -> some View {
        let name = entry.provider == .codex ? "Codex" : "Claude Code"
        let status = entry.provider == .codex ? usageController.status : "Awaiting Claude status-line data."
        let tooltip = NotchAllowancePresentation.tooltipText(
            for: entry.provider, snapshots: snapshots, missingSourceStatus: status,
            locale: locale, timeZone: timeZone)
        let countdown = NotchAllowancePresentation.countdownText(for: entry.window, at: nowMs)
        let summary = entry.percentLeft.map { "\(entry.windowLabel) \($0)% \(countdown)" }
            ?? "\(entry.windowLabel) —"
        let spoken = entry.percentLeft.map { "\(entry.windowLabel), \($0) percent left, resets in \(countdown)" }
            ?? "\(entry.windowLabel), allowance unavailable"
        return HStack(spacing: 3) {
            if let image = ProviderLogo.bundled[entry.provider] {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .accessibilityHidden(true)
            } else {
                Text(name).foregroundStyle(.white)
            }
            Text(summary).foregroundStyle(color(entry.color))
            if entry.accountUnverified {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.gray)
            }
        }
        .lineLimit(1)
        .help(tooltip)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name), \(spoken)\(entry.accountUnverified ? ", account unverified" : "")")
    }

    private func color(_ color: AllowanceColor) -> Color {
        switch color {
        case .green: .green
        case .yellow: .yellow
        case .red: .red
        case .gray: .gray
        }
    }
}
