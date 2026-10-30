import AppKit
import Combine
import SwiftUI

/// Native lifecycle belongs to the app; PetView receives only playback inputs.
@MainActor
final class PetWindowPlaybackState: ObservableObject {
    @Published private(set) var isVisible: Bool
    @Published private(set) var isSleeping = false
    private var subscriptions: Set<AnyCancellable> = []

    init(window: NSWindow, windowNotifications: NotificationCenter = .default,
         workspaceNotifications: NotificationCenter = NSWorkspace.shared.notificationCenter,
         readVisibility: @escaping (NSWindow) -> Bool) {
        isVisible = readVisibility(window)
        let windowEvents = [NSWindow.didChangeOcclusionStateNotification,
                            NSWindow.didMiniaturizeNotification,
                            NSWindow.didDeminiaturizeNotification, NSWindow.willCloseNotification]
        Publishers.MergeMany(windowEvents.map { windowNotifications.publisher(for: $0) })
            .receive(on: DispatchQueue.main)
            .sink { [weak self, weak window] notification in
                MainActor.assumeIsolated {
                    guard let self, let window, notification.object as? NSWindow === window else { return }
                    // willClose arrives before the window's native visibility changes.
                    let visible = notification.name != NSWindow.willCloseNotification && readVisibility(window)
                    if self.isVisible != visible { self.isVisible = visible }
                }
            }
            .store(in: &subscriptions)
        Publishers.Merge(workspaceNotifications.publisher(for: NSWorkspace.willSleepNotification),
                         workspaceNotifications.publisher(for: NSWorkspace.didWakeNotification))
            .receive(on: DispatchQueue.main)
            .sink { [weak self, weak window] notification in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    let sleeping = notification.name == NSWorkspace.willSleepNotification
                    if self.isSleeping != sleeping { self.isSleeping = sleeping }
                    if !sleeping, let window {
                        let visible = readVisibility(window)
                        if self.isVisible != visible { self.isVisible = visible }
                    }
                }
            }
            .store(in: &subscriptions)
    }
}

@MainActor
struct PetWindowPlayback<Content: View>: View {
    @StateObject private var state: PetWindowPlaybackState
    private let content: (Bool, Bool) -> Content

    init(window: NSWindow, @ViewBuilder content: @escaping (Bool, Bool) -> Content) {
        // Construct outside StateObject's escaping autoclosure so it cannot retain
        // the window through its initializer and form a hosting-view/window cycle.
        let state = PetWindowPlaybackState(window: window, readVisibility: {
            $0.isVisible && !$0.isMiniaturized && $0.occlusionState.contains(.visible)
        })
        _state = StateObject(wrappedValue: state)
        self.content = content
    }

    var body: some View {
        content(state.isVisible, state.isSleeping)
    }
}
