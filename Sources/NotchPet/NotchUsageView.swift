import Darwin
import SessionState
import SwiftUI

struct NotchUsageView: View {
    @ObservedObject var store: UsageStore
    let activeProviders: Set<IntegrationAgent>
    @State private var codexStatus = "Reading allowance…"

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            let now = Int64(context.date.timeIntervalSince1970 * 1000)
            let snapshots = store.snapshots(activeProviders: activeProviders, nowMs: now)
            VStack(alignment: .leading, spacing: 16) {
                ForEach(activeProviders.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { provider in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(provider == .codex ? "Codex limits" : "Claude Code limits")
                            .font(.headline)
                        let observations = snapshots.filter { $0.observation.provider == provider.rawValue }
                        if observations.isEmpty {
                            Text(provider == .codex ? codexStatus : "Awaiting Claude status-line data.")
                                .font(.caption).foregroundStyle(.secondary)
                            Text("5-hour: unavailable · Weekly: unavailable")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        ForEach(Array(observations.enumerated()), id: \.element.observation.sourceID) { index, snapshot in
                            VStack(alignment: .leading, spacing: 8) {
                                if snapshot.observation.accountID == nil {
                                    Text("Source \(index + 1) · Account unverified")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                if let failure = snapshot.observation.failure {
                                    Text(failure == .timedOut ? "Source timed out." : "Allowance unavailable from this source.")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                ForEach(snapshot.observation.windows, id: \.id) { window in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(label(window.durationMinutes))
                                            Spacer()
                                            Text("\(window.usedPercent, format: .number.precision(.fractionLength(0...1)))% used")
                                                .monospacedDigit()
                                        }.font(.callout)
                                        ProgressView(value: window.usedPercent, total: 100)
                                            .tint(snapshot.isStale ? .gray : .white)
                                        if let reset = window.resetsAtMs {
                                            Text("Resets \(Date(timeIntervalSince1970: Double(reset) / 1000).formatted(date: .abbreviated, time: .shortened))")
                                                .font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                if !snapshot.observation.windows.contains(where: { $0.durationMinutes == 300 }) {
                                    Text("5-hour: not reported").font(.caption).foregroundStyle(.secondary)
                                }
                                if !snapshot.observation.windows.contains(where: { $0.durationMinutes == 10080 }) {
                                    Text("Weekly: not reported").font(.caption).foregroundStyle(.secondary)
                                }
                                Text(snapshot.isStale ? "Stale observation — awaiting a new reading." : "Received \(Date(timeIntervalSince1970: Double(snapshot.observation.receivedAtMs) / 1000).formatted(date: .omitted, time: .shortened))")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .task(id: activeProviders) { await refreshCodex() }
    }

    private func label(_ minutes: Int?) -> String {
        switch minutes {
        case 300: "5-hour"
        case 10080: "Weekly"
        case .some(let value): "\(value)-minute window"
        case nil: "Window duration not reported"
        }
    }

    @MainActor
    private func refreshCodex() async {
        guard activeProviders.contains(.codex) else { return }
        codexStatus = "Reading allowance…"
        let path = getenv("PATH").map { String(cString: $0) } ?? "/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"
        guard path.utf8.count <= 16_384 else { codexStatus = "Executable search path unavailable."; return }
        let candidates = path.split(separator: ":").prefix(64).map(String.init) +
            [FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".local/bin").path,
             "/opt/homebrew/bin", "/usr/local/bin"]
        let executable = candidates.filter { $0.hasPrefix("/") }
            .map { URL(fileURLWithPath: String($0)).appendingPathComponent("codex") }
            .first { FileManager.default.isExecutableFile(atPath: $0.path) }
        guard let executable else { codexStatus = "Codex executable unavailable."; return }
        while !Task.isCancelled {
            let observation = await CodexUsageConnection.read(executableURL: executable, sourceID: "codex-managed")
            guard !Task.isCancelled else { return }
            store.apply(observation)
            do { try await Task.sleep(for: .seconds(120)) }
            catch { return }
        }
    }
}
