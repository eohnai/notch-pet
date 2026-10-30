import Observation

/// `withObservationTracking` reports only the next change, so the loop re-arms after each one.
@MainActor
final class ObservationLoop<Value: Equatable & Sendable> {
    private let read: @MainActor () -> Value
    private let onChange: @MainActor (Value) -> Void
    private var last: Value?
    private var cancelled = false

    init(_ read: @escaping @MainActor () -> Value, onChange: @escaping @MainActor (Value) -> Void) {
        self.read = read
        self.onChange = onChange
        track()
    }

    func cancel() {
        cancelled = true
    }

    private func track() {
        guard !cancelled else { return }
        let value = withObservationTracking { read() } onChange: { [weak self] in
            // The callback runs before the new value is stored and off the main actor's isolation.
            Task { @MainActor [weak self] in self?.track() }
        }
        guard value != last else { return }
        last = value
        onChange(value)
    }
}
