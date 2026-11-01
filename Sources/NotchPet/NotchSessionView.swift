import SessionState
import SwiftUI

struct NotchSessionView: View {
    let sessionStore: SessionStore
    let usageStore: UsageStore
    let headerHeight: CGFloat
    let notchWidth: CGFloat
    let onExpand: (Bool) -> Void
    @State private var expanded = false
    @State private var selection: SessionKey?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Button {
                expanded.toggle()
                onExpand(expanded)
            } label: {
                HStack(spacing: 0) {
                    Image(systemName: "pawprint.fill")
                        .padding(.leading, 6)
                        .frame(maxWidth: .infinity)
                    Color.clear.frame(width: notchWidth)
                    Text("\(sessionStore.sessions.count)")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .monospacedDigit()
                        .padding(.trailing, 6)
                        .frame(maxWidth: .infinity)
                }
                .frame(height: headerHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(expanded ? "Collapse sessions" : "Expand sessions")
            .accessibilityValue("\(sessionStore.sessions.count) observed sessions")

            if expanded {
                VStack(alignment: .leading, spacing: 12) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            NotchUsageView(store: usageStore,
                                           activeProviders: NotchPresentation.activeProviders(sessionStore.sessions))
                            Text("Sessions").font(.headline)
                            if sessionStore.sessions.isEmpty {
                                Text("No sessions observed yet.").foregroundStyle(.secondary)
                            }
                            if NotchPresentation.shouldTickPromptTimers(expanded: expanded,
                                                                      sessions: sessionStore.sessions) {
                                TimelineView(.periodic(from: .now, by: 1)) { context in
                                    sessionCards(at: Int64(context.date.timeIntervalSince1970 * 1000))
                                }
                            } else {
                                sessionCards(at: Int64(Date.now.timeIntervalSince1970 * 1000))
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .foregroundStyle(.white)
        .background {
            RoundedRectangle(cornerRadius: expanded ? 24 : 16, style: .continuous)
                .fill(.black)
                // Extend the upper corners beyond the screen edge so the panel
                // joins the physical cutout and only the lower corners remain visible.
                .padding(.top, expanded ? -24 : -16)
        }
        .preferredColorScheme(.dark)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.24), value: expanded)
        .onAppear {
            selection = NotchPresentation.selection(selection, sessions: sessionStore.sessions)
        }
        .onChange(of: sessionStore.sessions) { _, sessions in
            selection = NotchPresentation.selection(selection, sessions: sessions)
        }
    }

    private func sessionCards(at nowMs: Int64) -> some View {
        LazyVStack(spacing: 10) {
            ForEach(NotchPresentation.ordered(sessionStore.sessions)) { snapshot in
                VStack(spacing: 6) {
                    NotchSessionCard(snapshot: snapshot,
                                     presentation: NotchPresentation.card(for: snapshot, among: sessionStore.sessions),
                                     nowMs: nowMs, selection: $selection)
                    ForEach(snapshot.pendingRequests, id: \.eventID) { request in
                        NotchRequestCard(request: request)
                    }
                }
            }
        }
    }
}
