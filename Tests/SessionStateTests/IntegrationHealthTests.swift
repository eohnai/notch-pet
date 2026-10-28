import EventBridge
import Foundation
import SessionState
import Testing

struct IntegrationHealthModelTests {
    @Test(arguments: IntegrationAgent.allCases)
    func versionAndConfigurationRemainIndependent(agent: IntegrationAgent) {
        let recorded = agent == .codex ? "0.164.0" : "2.1.306"
        var evidence = IntegrationHealthEvidence(agent: agent, version: .reported(recorded))
        evidence.configuration = .missing
        let missing = IntegrationHealth.evaluate(evidence)
        #expect(missing.version == .recordedCompatibility(recorded))
        #expect(missing.configuration == .missing)

        evidence.version = .reported("99.0.0")
        evidence.configuration = .recognizedShape(eventCount: 1, commandCount: 2)
        let unfamiliar = IntegrationHealth.evaluate(evidence)
        #expect(unfamiliar.version == .unverified("99.0.0"))
        #expect(unfamiliar.configuration == .recognizedShape(eventCount: 1, commandCount: 2))
    }

    @Test(arguments: IntegrationAgent.allCases)
    func helperAndReceiverRemainIndependent(agent: IntegrationAgent) {
        var evidence = IntegrationHealthEvidence(agent: agent, helper: .available,
                                                 receiver: .failed(.receiverUnavailable))
        let failed = IntegrationHealth.evaluate(evidence)
        #expect(failed.helper == .available)
        #expect(failed.receiver == .failed(.receiverUnavailable))
        #expect(failed.lastDelivery == nil)

        evidence.helper = .missing
        evidence.receiver = .listening
        let listening = IntegrationHealth.evaluate(evidence)
        #expect(listening.helper == .missing)
        #expect(listening.receiver == .listening)
    }

    @Test(arguments: IntegrationAgent.allCases)
    func missingDeliveryDoesNotMeanDisconnected(agent: IntegrationAgent) {
        let receivers: [IntegrationReceiverState] = [.notStarted, .listening, .stopped]
        for receiver in receivers {
            let snapshot = IntegrationHealth.evaluate(IntegrationHealthEvidence(
                agent: agent, helper: .available, receiver: receiver))
            #expect(snapshot.lastDelivery == nil)
            #expect(snapshot.receiver == receiver)
            #expect(snapshot.version == .notChecked)
            #expect(snapshot.configuration == .notChecked)
        }
    }

    @Test @MainActor
    func recordedDeliverySurvivesSessionExpiryAndIndependentStoreReplacement() throws {
        let frame = Data("""
        {"version":1,"event_id":"00000000-0000-0000-0000-000000000001","agent":"codex","session_id":"fictional-health","hook_event_name":"UserPromptSubmit","observed_at_ms":1000000,"turn_id":"a"}

        """.utf8)
        let event = try HookEnvelopeV1.decode(frame: frame)
        let receipt = IntegrationDeliveryReceipt(wallMs: 1_000_000, monotonicNs: 1_000_000_000)
        let evidence = IntegrationHealthEvidence(agent: .codex, receiver: .listening,
                                                 lastDelivery: receipt)
        let store = SessionStore()
        #expect(store.apply(SessionObservationV1(envelope: event, receiptWallMs: receipt.wallMs,
                                                 receiptMonotonicNs: receipt.monotonicNs)) == .applied)
        store.advance(monotonicNs: 121_000_000_000)
        #expect(store.sessions.first?.status == .unknown)
        #expect(IntegrationHealth.evaluate(evidence).lastDelivery == receipt)
        #expect(SessionStore().sessions.isEmpty)
        #expect(IntegrationHealth.evaluate(evidence).lastDelivery == receipt)
    }

    @Test(arguments: IntegrationAgent.allCases)
    func configurationAndReceiptNeverPromoteSupport(agent: IntegrationAgent) {
        let receipt = IntegrationDeliveryReceipt(wallMs: 1_000, monotonicNs: 2_000)
        let evidence = IntegrationHealthEvidence(
            agent: agent, version: .reported("99.0.0"),
            configuration: .recognizedShape(eventCount: 7, commandCount: 7),
            helper: .available, receiver: .listening, lastDelivery: receipt)
        let snapshot = IntegrationHealth.evaluate(evidence)
        #expect(snapshot.version == .unverified("99.0.0"))
        #expect(snapshot.lastDelivery == receipt)
        #expect(snapshot.configuration == evidence.configuration)
        #expect(snapshot.receiver == .listening)

        let invalid = IntegrationHealthEvidence(agent: agent, version: .reported("unrelated output"))
        #expect(IntegrationHealth.evaluate(invalid).version == .unavailable(.invalidOutput))
    }
}
