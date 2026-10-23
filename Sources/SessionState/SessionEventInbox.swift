import EventBridge
import Foundation

/// A bounded handoff preserves the bridge worker's receipt order without blocking it on the UI.
public final class SessionEventInbox: @unchecked Sendable {
    public static let capacity = 128
    private let lock = NSLock()
    private var pending: [SessionObservationV1] = []
    private var scheduled = false
    private var overflow = false
    private let onBatch: @MainActor @Sendable ([SessionObservationV1], Bool) -> Void

    public init(onBatch: @escaping @MainActor @Sendable ([SessionObservationV1], Bool) -> Void) {
        self.onBatch = onBatch
    }

    public func receive(_ received: ReceivedHookEnvelope) {
        enqueue(SessionObservationV1(received: received))
    }

    public func enqueue(_ observation: SessionObservationV1) {
        let needsDrain = lock.withLock {
            if pending.count < Self.capacity { pending.append(observation) }
            else { overflow = true }
            if scheduled { return false }
            scheduled = true
            return true
        }
        if needsDrain {
            Task { @MainActor [self] in
                let batch = lock.withLock {
                    let values = pending
                    let lost = overflow
                    pending.removeAll(keepingCapacity: true)
                    overflow = false
                    scheduled = false
                    return (values, lost)
                }
                onBatch(batch.0, batch.1)
            }
        }
    }
}
