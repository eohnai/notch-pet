import SessionState
import SwiftUI

struct NotchSessionView: View {
    @ObservedObject var sessionStore: SessionStore
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
                        .frame(maxWidth: .infinity)
                    Color.clear.frame(width: notchWidth)
                    Text("\(sessionStore.sessions.count)")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .monospacedDigit()
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
                    Text("Sessions").font(.headline)
                    if sessionStore.sessions.isEmpty {
                        Text("No sessions observed yet.")
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 0)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(NotchPresentation.ordered(sessionStore.sessions)) { snapshot in
                                    NotchSessionRow(snapshot: snapshot, selection: $selection)
                                    Divider().overlay(.white.opacity(0.12))
                                }
                            }
                        }
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
        .onChange(of: sessionStore.sessions) { sessions in
            selection = NotchPresentation.selection(selection, sessions: sessions)
        }
    }
}
