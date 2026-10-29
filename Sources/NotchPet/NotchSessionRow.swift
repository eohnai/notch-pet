import SessionState
import SwiftUI

struct NotchSessionRow: View {
    let snapshot: SessionSnapshot
    @Binding var selection: SessionKey?

    private var status: String {
        switch snapshot.status {
        case .idle: "Observed idle"
        case .working: "Working"
        case .questionNeeded: "Answer needed"
        case .approvalNeeded: "Approval needed"
        case .responseReady: "Response ready"
        case .unknown: "Unknown"
        case .ended: "Ended"
        }
    }

    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { selection == snapshot.key },
            set: { selection = $0 ? snapshot.key : nil })) {
            VStack(alignment: .leading, spacing: 8) {
                Text(snapshot.projectPath ?? "Project not observed")
                    .font(.caption).lineLimit(nil)
                Text("Session: \(snapshot.key.sessionID)")
                    .font(.caption).lineLimit(nil)
                if snapshot.status == .unknown {
                    Text("Current activity is unconfirmed. Fresh session evidence is needed.")
                        .foregroundStyle(.secondary)
                }
                if let receipt = snapshot.receiptWallMs {
                    Text("State refreshed: \(Date(timeIntervalSince1970: Double(receipt) / 1000).formatted())")
                        .font(.caption).foregroundStyle(.secondary)
                }
                ForEach(snapshot.pendingRequests, id: \.eventID) { request in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(request.isConfirmed ? "Pending" : "Unconfirmed") \(request.kind == .questionNeeded ? "question" : "approval"): \(request.toolName)")
                        if let toolID = request.toolUseID {
                            Text("Tool call: \(toolID)").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .font(.callout)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(snapshot.key.agent == "codex" ? "Codex" : "Claude Code").fontWeight(.semibold)
                    Spacer()
                    Text(status).foregroundStyle(snapshot.status == .unknown ? .orange : .white)
                }
                Text(snapshot.key.sessionID).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .tint(.white)
        .padding(.vertical, 10)
    }
}
