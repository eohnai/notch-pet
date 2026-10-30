import EventBridge
import Foundation
import Testing
@testable import SessionState

struct CodexHookOwnershipTests {
    private func input(configuration: Data? = nil, ownership: Data? = nil) -> HookSetupInput {
        HookSetupInput(agent: "codex", configuration: configuration, ownership: ownership,
                       target: .init(configurationPath: "/example/hooks.json", parentDevice: 1, parentInode: 2, helperPath: "/example/NotchPetHook"),
                       support: .verified(version: "0.165.0", hooksEnabled: true, helperAvailable: true),
                       installationID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
    }

    private func installed() throws -> (Data, Data) {
        guard case .update(let data, let owner) = HookSetupPlanner.plan(input()) else {
            throw HookPlanningFailure.ownershipConflict
        }
        return (data, owner)
    }

    @Test func unchangedOwnedInstallReturnsNoCandidateOrRewrite() throws {
        let (data, owner) = try installed()
        #expect(HookSetupPlanner.plan(input(configuration: data, ownership: owner)) == .unchanged)
        let alternateFormatting = Data(" \n".utf8) + data + Data("\n".utf8)
        #expect(HookSetupPlanner.plan(input(configuration: alternateFormatting, ownership: owner)) == .unchanged)
    }

    @Test func unrelatedEditsAndGroupReorderingDoNotChangeOwnership() throws {
        let (_, record) = try installed()
        let owner = try JSONDecoder().decode(HookSetupOwnership.self, from: record)
        let fields = owner.groups.keys.sorted().reversed().map { event -> String in
            let group = String(decoding: owner.groups[event]!, as: UTF8.self)
            let unrelated = #"{"hooks":[{"type":"command","command":"fictional unrelated"}]}"#
            return "\"" + event + "\":[" + (event == "SessionStart" ? unrelated + "," : "") + group + "]"
        }
        let changed = Data(("{\"number\":90071992547409931234567890,\"hooks\":{" + fields.joined(separator: ",") + "}}").utf8)
        #expect(HookSetupPlanner.plan(input(configuration: changed, ownership: record)) == .unchanged)
        #expect(try HookConfigurationJSON(data: changed).rawValue(at: [.key("number")]) == Data("90071992547409931234567890".utf8))
    }

    @Test func editedMissingCopiedAndExtraFieldGroupsAreConflicts() throws {
        let (data, owner) = try installed()
        let document = try HookConfigurationJSON(data: data)
        let eventPath: [JSONPathComponent] = [.key("hooks"), .key("Stop")]
        let groupPath = eventPath + [.index(0)]
        let arrayRange = try #require(document.range(at: eventPath))
        let groupRange = try #require(document.range(at: groupPath))
        let group = try #require(document.rawValue(at: groupPath))
        var missing = data
        missing.removeSubrange(groupRange)
        var copied = data
        copied.insert(contentsOf: Data([44]) + group, at: arrayRange.upperBound - 1)
        var edited = data
        let timeout = try #require(document.range(at: groupPath + [.key("hooks"), .index(0), .key("timeout")]))
        edited.replaceSubrange(timeout, with: Data("4".utf8))
        var extraField = data
        extraField.insert(contentsOf: Data(",\"userEdit\":true".utf8), at: groupRange.upperBound - 1)
        var otherEvent = data
        let hooksRange = try #require(document.range(at: [.key("hooks")]))
        otherEvent.insert(contentsOf: Data(",\"Interrupt\":[".utf8) + group + Data("]".utf8), at: hooksRange.upperBound - 1)
        for changed in [missing, copied, edited, extraField, otherEvent] {
            #expect(HookSetupPlanner.plan(input(configuration: changed, ownership: owner)) == .conflict(.ownershipConflict))
        }
    }

    @Test func wrongSchemaIdentityTargetOrOwnedDescriptionIsRejected() throws {
        let (data, record) = try installed()
        let original = try #require(JSONSerialization.jsonObject(with: record) as? [String: Any])
        let variants: [(String, Any)] = [("version", 99), ("agent", "claude"),
                                      ("installationID", "00000000-0000-0000-0000-000000000002"),
                                      ("target", ["configurationPath": "/example/hooks.json", "parentDevice": 1,
                                                  "parentInode": 3, "helperPath": "/example/NotchPetHook"]),
                                      ("groups", [:]), ("createdEvents", ["Unsupported"]),
                                      ("unexpected", true)]
        for (key, value) in variants {
            var changed = original
            changed[key] = value
            let encoded = try JSONSerialization.data(withJSONObject: changed)
            #expect(HookSetupPlanner.plan(input(configuration: data, ownership: encoded)) == .conflict(.ownershipConflict))
        }
    }

    @Test func lostMalformedOrOversizedOwnershipNeverAdoptsInstalledEntries() throws {
        let (data, _) = try installed()
        #expect(HookSetupPlanner.plan(input(configuration: data)) == .conflict(.ownershipConflict))
        for record in [Data("{}".utf8), Data("{".utf8), Data(#"{"version":1,"version":1}"#.utf8)] {
            #expect(HookSetupPlanner.plan(input(configuration: data, ownership: record)) == .conflict(.ownershipConflict))
        }
        #expect(HookSetupPlanner.plan(input(configuration: data, ownership: Data(repeating: 32, count: 262145))) == .unavailable(.resourceLimit))
    }
}
