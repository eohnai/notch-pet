import Foundation

public enum IntegrationAgent: String, CaseIterable, Hashable, Sendable {
    case codex, claude
}

/// Bounded categories only. Raw errors, configuration values and process output are not diagnostics.
public enum IntegrationHealthFailure: String, Equatable, Sendable {
    case unreadable, malformed, unsupportedShape, resourceLimit
    case launchFailed, timedOut, nonzeroExit, invalidOutput
    case unsafeEndpoint, receiverUnavailable
}

public enum IntegrationVersionEvidence: Equatable, Sendable {
    case notChecked
    case reported(String)
    case unavailable(IntegrationHealthFailure)
}

public enum IntegrationVersionSupport: Equatable, Sendable {
    case notChecked
    /// Appears in the compatibility record, whose per-event/runtime limitations still apply.
    case recordedCompatibility(String)
    case unverified(String)
    case unavailable(IntegrationHealthFailure)
}

public enum IntegrationConfigurationEvidence: Equatable, Sendable {
    case notChecked, missing
    /// Counts describe the hook JSON shape, not app ownership, agent enablement, or hook trust.
    case recognizedShape(eventCount: Int, commandCount: Int)
    case unavailable(IntegrationHealthFailure)
}

public enum IntegrationHelperAvailability: Equatable, Sendable {
    case notChecked, available, missing, notExecutable
    case unavailable(IntegrationHealthFailure)
}

public enum IntegrationReceiverState: Equatable, Sendable {
    case notStarted, listening, stopped
    case failed(IntegrationHealthFailure)
}

/// A validated observation's receipt, independent of a session's lifecycle/freshness.
public struct IntegrationDeliveryReceipt: Equatable, Sendable {
    public let wallMs: Int64
    public let monotonicNs: UInt64

    public init(wallMs: Int64, monotonicNs: UInt64) {
        self.wallMs = wallMs
        self.monotonicNs = monotonicNs
    }
}

public struct IntegrationHealthEvidence: Equatable, Sendable {
    public let agent: IntegrationAgent
    public var version: IntegrationVersionEvidence
    public var configuration: IntegrationConfigurationEvidence
    public var helper: IntegrationHelperAvailability
    public var receiver: IntegrationReceiverState
    public var lastDelivery: IntegrationDeliveryReceipt?

    public init(agent: IntegrationAgent, version: IntegrationVersionEvidence = .notChecked,
                configuration: IntegrationConfigurationEvidence = .notChecked,
                helper: IntegrationHelperAvailability = .notChecked,
                receiver: IntegrationReceiverState = .notStarted,
                lastDelivery: IntegrationDeliveryReceipt? = nil) {
        self.agent = agent
        self.version = version
        self.configuration = configuration
        self.helper = helper
        self.receiver = receiver
        self.lastDelivery = lastDelivery
    }
}

/// No aggregate connected/disconnected flag: each observation proves only its own field.
public struct IntegrationHealthSnapshot: Equatable, Sendable {
    public let agent: IntegrationAgent
    public let version: IntegrationVersionSupport
    public let configuration: IntegrationConfigurationEvidence
    public let helper: IntegrationHelperAvailability
    public let receiver: IntegrationReceiverState
    public let lastDelivery: IntegrationDeliveryReceipt?
}

public enum IntegrationHealth {
    public static func evaluate(_ evidence: IntegrationHealthEvidence) -> IntegrationHealthSnapshot {
        let version: IntegrationVersionSupport
        switch evidence.version {
        case .notChecked:
            version = .notChecked
        case .unavailable(let reason):
            version = .unavailable(reason)
        case .reported(let value):
            let parts = value.split(separator: ".", omittingEmptySubsequences: false)
            let isVersion = value.utf8.count <= 32 && parts.count == 3 && parts.allSatisfy {
                !$0.isEmpty && $0.utf8.allSatisfy { (48...57).contains($0) }
            }
            let recorded = evidence.agent == .codex ? ["0.163.0", "0.164.0"] : ["2.1.306"]
            if !isVersion {
                version = .unavailable(.invalidOutput)
            } else if recorded.contains(value) {
                version = .recordedCompatibility(value)
            } else {
                version = .unverified(value)
            }
        }
        return IntegrationHealthSnapshot(agent: evidence.agent, version: version,
                                         configuration: evidence.configuration, helper: evidence.helper,
                                         receiver: evidence.receiver, lastDelivery: evidence.lastDelivery)
    }
}
