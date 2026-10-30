import Foundation
import Testing
@testable import EventBridge

struct AgentAdapterTests {
    @Test func builtInCatalogDescribesOnlyImplementedObservation() throws {
        let catalog = AgentCatalog.builtIn
        #expect(catalog.descriptors.map(\.id) == ["codex", "claude"])
        let codex = try #require(catalog.descriptor(for: "codex"))
        let claude = try #require(catalog.descriptor(for: "claude"))
        #expect(codex.displayName == "Codex")
        #expect(claude.displayName == "Claude Code")
        #expect(codex.questionTools == ["request_user_input"])
        #expect(claude.questionTools == ["AskUserQuestion"])
        #expect(codex.eventNames == HookEnvelopeV1.hooks)
        #expect(claude.eventNames == HookEnvelopeV1.hooks)
        #expect(codex.capabilities == [.observation])
        #expect(claude.capabilities == [.observation])
    }

    @Test func duplicateOrInvalidRegistrationsAreRejected() throws {
        let valid = try #require(AgentCatalog.builtIn.descriptor(for: "codex"))
        #expect(throws: BridgeError.invalidMessage) { try AgentCatalog([valid, valid]) }
        for id in ["", "Codex", "third agent", "../codex", "cödex", String(repeating: "x", count: 65)] {
            let descriptor = AgentDescriptor(id: id, displayName: "Example", eventNames: [], questionTools: [], capabilities: [])
            #expect(throws: BridgeError.invalidMessage) { try AgentCatalog([descriptor]) }
        }
        for label in ["", "Example\nAgent", String(repeating: "x", count: 81)] {
            let descriptor = AgentDescriptor(id: "example", displayName: label, eventNames: [], questionTools: [], capabilities: [])
            #expect(throws: BridgeError.invalidMessage) { try AgentCatalog([descriptor]) }
        }
        let tooMany = (0..<33).map {
            AgentDescriptor(id: "example-\($0)", displayName: "Example", eventNames: [], questionTools: [], capabilities: [])
        }
        #expect(throws: BridgeError.invalidMessage) { try AgentCatalog(tooMany) }
    }

    @Test func thirdDescriptorUsesTheSameCatalogWithoutInventingCapabilities() throws {
        let third = AgentDescriptor(id: "example", displayName: "Example Agent", eventNames: [],
                                    questionTools: [], capabilities: [.usage])
        let catalog = try AgentCatalog(AgentCatalog.builtIn.descriptors + [third])
        #expect(catalog.descriptors.map(\.displayName) == ["Codex", "Claude Code", "Example Agent"])
        #expect(catalog.descriptor(for: "example") == third)
        #expect(!third.capabilities.contains(.observation))
        #expect(!third.capabilities.contains(.setup))
        #expect(!third.capabilities.contains(.actions))
        #expect(AgentCatalog.builtIn.descriptor(for: "example") == nil)
    }

    @Test func unknownAndNonexactProviderIdentifiersDoNotFallBack() throws {
        for id in ["unsupported", "Codex", "claude ", "", "cödex"] {
            #expect(AgentCatalog.builtIn.descriptor(for: id) == nil)
            #expect(throws: BridgeError.invalidMessage) {
                try HookEnvelopeV1.project(rawHook: Data(#"{"session_id":"example","hook_event_name":"SessionStart"}"#.utf8), agent: id)
            }
        }
        #expect(try AgentCatalog([]).descriptors.isEmpty)
    }

    @Test func descriptorMetadataIsBoundedBeforeRegistration() throws {
        for descriptor in [
            AgentDescriptor(id: "example", displayName: "Example", eventNames: [String(repeating: "x", count: 129)], questionTools: [], capabilities: []),
            AgentDescriptor(id: "example", displayName: "Example", eventNames: [], questionTools: ["bad\ntool"], capabilities: []),
            AgentDescriptor(id: "example", displayName: "Example", eventNames: Set((0..<33).map { "Event\($0)" }), questionTools: [], capabilities: [])
        ] {
            #expect(throws: BridgeError.invalidMessage) { try AgentCatalog([descriptor]) }
        }
    }
}
