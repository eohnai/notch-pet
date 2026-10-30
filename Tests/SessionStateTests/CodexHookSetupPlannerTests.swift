import EventBridge
import Foundation
import Testing
@testable import SessionState

struct CodexHookSetupPlannerTests {
    private func input(configuration: Data? = nil, ownership: Data? = nil,
                       support: HookSetupSupport = .verified(version: "0.165.0", hooksEnabled: true, helperAvailable: true),
                       agent: String = "codex", helperPath: String = "/example/NotchPetHook",
                       configurationPath: String = "/example/hooks.json") -> HookSetupInput {
        HookSetupInput(agent: agent, configuration: configuration, ownership: ownership,
                       target: .init(configurationPath: configurationPath, parentDevice: 1, parentInode: 2, helperPath: helperPath),
                       support: support, installationID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
    }

    @Test func initialPlanCreatesSevenOwnedGroupsAndTargetBoundRecord() throws {
        guard case .update(let data, let record) = HookSetupPlanner.plan(input()) else {
            Issue.record("expected initial candidate")
            return
        }
        let document = try HookConfigurationJSON(data: data)
        let owner = try JSONDecoder().decode(HookSetupOwnership.self, from: record)
        #expect(owner.version == 1 && owner.agent == "codex")
        #expect(owner.target.configurationPath == "/example/hooks.json")
        #expect(owner.target.parentDevice == 1 && owner.target.parentInode == 2)
        #expect(owner.installationID == input().installationID)
        let events = try #require(AgentCatalog.builtIn.descriptor(for: "codex")).eventNames
        #expect(Set(owner.groups.keys) == events)
        #expect(document.members(at: [.key("hooks")])?.count == 7)
        for event in events {
            let raw = try #require(document.rawValue(at: [.key("hooks"), .key(event), .index(0)]))
            #expect(raw == owner.groups[event])
            let group = try JSONDecoder().decode(HookManagedGroup.self, from: raw)
            #expect(group.hooks.count == 1)
            #expect(group.hooks.first?.command == "'/example/NotchPetHook' --agent codex")
            #expect(group.hooks.first?.timeout == 3)
            #expect(group.hooks.first?.type == "command")
        }
    }

    @Test func planPreservesUnrelatedValuesAndExistingHandlers() throws {
        let original = Data(#"{"number":90071992547409931234567890,"statusLine":{"command":"fictional only"},"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"fictional unrelated"}]}]}}"#.utf8)
        guard case .update(let data, _) = HookSetupPlanner.plan(input(configuration: original)) else {
            Issue.record("expected preservation candidate")
            return
        }
        let before = try HookConfigurationJSON(data: original)
        let after = try HookConfigurationJSON(data: data)
        for path: [JSONPathComponent] in [[.key("number")], [.key("statusLine")], [.key("hooks"), .key("SessionStart"), .index(0)]] {
            #expect(before.rawValue(at: path) == after.rawValue(at: path))
        }
        #expect(after.members(at: [.key("hooks"), .key("SessionStart")])?.count == 2)
    }

    @Test func versionEnablementHelperAndPathGatesPreventCandidate() {
        #expect(HookSetupPlanner.plan(input(support: .unverified)) == .unavailable(.unverifiedVersion))
        #expect(HookSetupPlanner.plan(input(support: .verified(version: "99.0.0", hooksEnabled: true, helperAvailable: true))) == .unavailable(.unsupportedVersion))
        #expect(HookSetupPlanner.plan(input(support: .verified(version: "0.165.0", hooksEnabled: false, helperAvailable: true))) == .unavailable(.hooksDisabled))
        #expect(HookSetupPlanner.plan(input(support: .verified(version: "0.165.0", hooksEnabled: true, helperAvailable: false))) == .unavailable(.helperUnavailable))
        #expect(HookSetupPlanner.plan(input(agent: "future")) == .unavailable(.unsupportedProvider))
        for path in ["relative", "/example/../hooks.json", "/example/bad\npath", String(repeating: "/", count: 4097)] {
            #expect(HookSetupPlanner.plan(input(configurationPath: path)) == .unavailable(.unsafeTarget))
        }
    }

    @Test func helperPathIsQuotedWithoutAddingUnsupportedArguments() throws {
        let path = "/example/a'b/Notch Pet.app/Contents/MacOS/NotchPetHook"
        guard case .update(let data, _) = HookSetupPlanner.plan(input(helperPath: path)) else {
            Issue.record("expected quoted helper candidate")
            return
        }
        let document = try HookConfigurationJSON(data: data)
        let raw = try #require(document.rawValue(at: [.key("hooks"), .key("Stop"), .index(0)]))
        let group = try JSONDecoder().decode(HookManagedGroup.self, from: raw)
        #expect(group.hooks.first?.command == #"'/example/a'"'"'b/Notch Pet.app/Contents/MacOS/NotchPetHook' --agent codex"#)
    }

    @Test func malformedConflictingAndOversizedInputsAreBoundedFailures() {
        for text in ["{", "[]", #"{"x":{"a":1,"a":2}}"#] {
            #expect(HookSetupPlanner.plan(input(configuration: Data(text.utf8))) == .conflict(.malformedConfiguration))
        }
        #expect(HookSetupPlanner.plan(input(configuration: Data(#"{"hooks":[]}"#.utf8))) == .conflict(.unsupportedShape))
        let lookalike = Data(#"{"hooks":{"Stop":[{"hooks":[{"command":"NotchPetHook --agent codex","type":"command"}]}]}}"#.utf8)
        #expect(HookSetupPlanner.plan(input(configuration: lookalike)) == .conflict(.ownershipConflict))
        #expect(HookSetupPlanner.plan(input(ownership: Data("{}".utf8))) == .conflict(.ownershipConflict))
        #expect(HookSetupPlanner.plan(input(configuration: Data(repeating: 32, count: 262145))) == .unavailable(.resourceLimit))
    }
}
