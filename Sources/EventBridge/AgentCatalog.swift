import Foundation

/// Capabilities are independent. Registration never proves installation, trust or activity.
public enum AgentCapability: String, Hashable, Sendable {
    case observation, setup, usage, actions, exactPaneNavigation
}

/// Internal projection includes the helper's existing shared deadline.
protocol AgentEventAdapter: Sendable {
    static var descriptor: AgentDescriptor { get }
    static func project(rawHook: Data, paneSelector: String?, deadline: UInt64?) throws -> HookEnvelopeV1
}

public struct AgentDescriptor: Identifiable, Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let eventNames: Set<String>
    public let questionTools: Set<String>
    public let capabilities: Set<AgentCapability>

    public init(id: String, displayName: String, eventNames: Set<String>,
                questionTools: Set<String>, capabilities: Set<AgentCapability>) {
        self.id = id
        self.displayName = displayName
        self.eventNames = eventNames
        self.questionTools = questionTools
        self.capabilities = capabilities
    }
}

/// A bounded catalog of built-in integrations, not a loader for executable plugins.
public struct AgentCatalog: Sendable {
    public let descriptors: [AgentDescriptor]

    private static let eventAdapters: [String: any AgentEventAdapter.Type] = [
        "codex": CodexEventAdapter.self,
        "claude": ClaudeEventAdapter.self
    ]

    // These programmer-owned constants pass the same validation as injected catalogs.
    public static let builtIn = try! AgentCatalog([
        CodexEventAdapter.descriptor,
        ClaudeEventAdapter.descriptor
    ])

    public init(_ descriptors: [AgentDescriptor]) throws {
        guard descriptors.count <= 32, Set(descriptors.map(\.id)).count == descriptors.count else {
            throw BridgeError.invalidMessage
        }
        for descriptor in descriptors {
            let bytes = descriptor.id.utf8
            guard (1...64).contains(bytes.count), let first = bytes.first, (97...122).contains(first),
                  bytes.allSatisfy({ (97...122).contains($0) || (48...57).contains($0) || $0 == 45 }),
                  HookEnvelopeV1.validString(descriptor.displayName, limit: 80),
                  descriptor.eventNames.count <= 32, descriptor.questionTools.count <= 32,
                  descriptor.eventNames.allSatisfy({ HookEnvelopeV1.validString($0, limit: 128) }),
                  descriptor.questionTools.allSatisfy({ HookEnvelopeV1.validString($0, limit: 128) })
            else { throw BridgeError.invalidMessage }
        }
        self.descriptors = descriptors
    }

    public func descriptor(for id: String) -> AgentDescriptor? {
        descriptors.first { $0.id == id }
    }

    static func project(rawHook: Data, agent: String, paneSelector: String?, deadline: UInt64?) throws -> HookEnvelopeV1 {
        guard let adapter = eventAdapters[agent] else { throw BridgeError.invalidMessage }
        return try adapter.project(rawHook: rawHook, paneSelector: paneSelector, deadline: deadline)
    }
}
