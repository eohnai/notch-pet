import AppKit
import Testing
@testable import NotchPet

@MainActor
struct PetWindowPlaybackTests {
    private final class Visibility {
        var value = false
        var reads = 0
    }

    private func makeWindow() -> NSWindow {
        _ = NSApplication.shared
        let window = NSWindow(contentRect: .zero, styleMask: [.borderless],
                              backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        return window
    }

    private func settle() async throws {
        try await Task.sleep(for: .milliseconds(40))
    }

    @Test func initialVisibilityIsSampledAndStartsAwake() {
        let window = makeWindow()
        let state = PetWindowPlaybackState(window: window, windowNotifications: NotificationCenter(),
                                           workspaceNotifications: NotificationCenter(), readVisibility: { _ in true })
        #expect(state.isVisible)
        #expect(!state.isSleeping)
    }

    @Test func visibilityChangesAndClosingRefreshPlaybackInputs() async throws {
        let window = makeWindow()
        let notifications = NotificationCenter()
        let visibility = Visibility()
        let state = PetWindowPlaybackState(window: window, windowNotifications: notifications,
                                           workspaceNotifications: NotificationCenter(),
                                           readVisibility: { _ in visibility.value })
        #expect(!state.isVisible)
        visibility.value = true
        notifications.post(name: NSWindow.didChangeOcclusionStateNotification, object: window)
        try await settle()
        #expect(state.isVisible)
        visibility.value = false
        notifications.post(name: NSWindow.didMiniaturizeNotification, object: window)
        try await settle()
        #expect(!state.isVisible)
        visibility.value = true
        notifications.post(name: NSWindow.didDeminiaturizeNotification, object: window)
        try await settle()
        #expect(state.isVisible)
        // willClose can precede the native isVisible change.
        notifications.post(name: NSWindow.willCloseNotification, object: window)
        try await settle()
        #expect(!state.isVisible)
        notifications.post(name: NSWindow.didChangeOcclusionStateNotification, object: window)
        try await settle()
        #expect(state.isVisible)
    }

    @Test func workspaceSleepAndWakePreserveHiddenSurface() async throws {
        let window = makeWindow()
        let workspace = NotificationCenter()
        let visibility = Visibility()
        visibility.value = true
        let state = PetWindowPlaybackState(window: window, windowNotifications: NotificationCenter(),
                                           workspaceNotifications: workspace,
                                           readVisibility: { _ in visibility.value })
        workspace.post(name: NSWorkspace.willSleepNotification, object: nil)
        try await settle()
        #expect(state.isSleeping)
        visibility.value = false
        workspace.post(name: NSWorkspace.didWakeNotification, object: nil)
        try await settle()
        #expect(!state.isSleeping)
        #expect(!state.isVisible)
        visibility.value = true
        workspace.post(name: NSWorkspace.willSleepNotification, object: nil)
        workspace.post(name: NSWorkspace.didWakeNotification, object: nil)
        try await settle()
        #expect(!state.isSleeping)
        #expect(state.isVisible)
    }

    @Test func otherWindowsCannotChangeBoundSurface() async throws {
        let window = makeWindow()
        let other = makeWindow()
        let notifications = NotificationCenter()
        let visibility = Visibility()
        let state = PetWindowPlaybackState(window: window, windowNotifications: notifications,
                                           workspaceNotifications: NotificationCenter(),
                                           readVisibility: { _ in visibility.value })
        visibility.value = true
        notifications.post(name: NSWindow.didChangeOcclusionStateNotification, object: other)
        notifications.post(name: NSWindow.willCloseNotification, object: other)
        try await settle()
        #expect(!state.isVisible)
    }

    @Test func releasingStateCancelsSubscriptions() async throws {
        let window = makeWindow()
        let notifications = NotificationCenter()
        let workspace = NotificationCenter()
        let visibility = Visibility()
        var state: PetWindowPlaybackState? = PetWindowPlaybackState(
            window: window, windowNotifications: notifications, workspaceNotifications: workspace,
            readVisibility: { _ in visibility.reads += 1; return visibility.value })
        weak var released = state
        #expect(state != nil)
        state = nil
        #expect(released == nil)
        let readsBefore = visibility.reads
        notifications.post(name: NSWindow.didChangeOcclusionStateNotification, object: window)
        workspace.post(name: NSWorkspace.didWakeNotification, object: nil)
        try await settle()
        #expect(visibility.reads == readsBefore)
    }
}
