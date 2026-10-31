import Observation
import Testing
@testable import NotchPet

@Observable
private final class Model {
    var value = 0
}

@MainActor
struct ObservationLoopTests {
    private func settle() async throws {
        try await Task.sleep(for: .milliseconds(40))
    }

    @Test func sendsTheStartingValueThenEachSeparateChange() async throws {
        let model = Model()
        var seen: [Int] = []
        let loop = ObservationLoop({ model.value }) { seen.append($0) }
        defer { loop.cancel() }
        #expect(seen == [0])
        model.value = 1
        try await settle()
        // A second change fails if the loop did not re-arm after the first.
        model.value = 2
        try await settle()
        #expect(seen == [0, 1, 2])
    }

    @Test func skipsChangesThatLeaveTheValueEqual() async throws {
        let model = Model()
        var seen: [Bool] = []
        let loop = ObservationLoop({ model.value > 0 }) { seen.append($0) }
        defer { loop.cancel() }
        model.value = 1
        try await settle()
        model.value = 2
        try await settle()
        #expect(seen == [false, true])
    }

    @Test func staysSilentAfterCancel() async throws {
        let model = Model()
        var seen: [Int] = []
        let loop = ObservationLoop({ model.value }) { seen.append($0) }
        loop.cancel()
        model.value = 1
        try await settle()
        #expect(seen == [0])
    }
}
