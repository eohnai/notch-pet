import EventBridge
import Foundation
import Testing
@testable import SessionState

struct HookGroupEditsTests {
    private let group = Data(#"{"hooks":[{"command":"'/example/NotchPetHook' --agent codex","timeout":3,"type":"command"}]}"#.utf8)
    private let events = ["SessionStart", "Stop"]

    @Test func missingConfigurationCreatesOnlyTheRequestedGroups() throws {
        let data = try HookGroupEdits.initialConfiguration(nil, events: events, group: group, helperName: "NotchPetHook")
        let document = try HookConfigurationJSON(data: data)
        #expect(document.members(at: []) == [.key("hooks")])
        #expect(document.members(at: [.key("hooks")]) == events.map(JSONPathComponent.key))
        for event in events {
            #expect(document.rawValue(at: [.key("hooks"), .key(event), .index(0)]) == group)
        }
    }

    @Test func unrelatedBytesAndHandlerOrderSurviveAppending() throws {
        let original = Data(#"{ "number":90071992547409931234567890, "statusLine":{"command":"fictional user command"},"hooks":{"SessionStart":[ {"hooks":[{"type":"command","command":"fictional unrelated hook"}]} ],"Other":[]}}"#.utf8)
        let before = try HookConfigurationJSON(data: original)
        let data = try HookGroupEdits.initialConfiguration(original, events: events, group: group, helperName: "NotchPetHook")
        let after = try HookConfigurationJSON(data: data)
        for path: [JSONPathComponent] in [[.key("number")], [.key("statusLine")], [.key("hooks"), .key("Other")], [.key("hooks"), .key("SessionStart"), .index(0)]] {
            #expect(after.rawValue(at: path) == before.rawValue(at: path))
        }
        #expect(after.rawValue(at: [.key("hooks"), .key("SessionStart"), .index(1)]) == group)
        #expect(after.rawValue(at: [.key("hooks"), .key("Stop"), .index(0)]) == group)
        #expect(original == before.data)
    }

    @Test func missingHooksPropertyAndEmptyContainersAreHandled() throws {
        for text in ["{}", "{ \n }", #"{"hooks":{}}"#, #"{"unrelated":true}"#, #"{"hooks":{"SessionStart":[]}}"#] {
            let data = try HookGroupEdits.initialConfiguration(Data(text.utf8), events: events, group: group, helperName: "NotchPetHook")
            let document = try HookConfigurationJSON(data: data)
            #expect(document.rawValue(at: [.key("hooks"), .key("SessionStart"), .index(0)]) == group)
            #expect(document.rawValue(at: [.key("hooks"), .key("Stop"), .index(0)]) == group)
        }
    }

    @Test func existingLookalikesAndUnsupportedShapesAreRejected() throws {
        for text in [#"{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"NotchPetHook --agent codex"}]}]}}"#,
                     #"{"hooks":{"Other":[{"hooks":[{"type":"command","command":"NotchPetHook --agent codex"}]}]}}"#,
                     #"{"hooks":[]}"#, #"{"hooks":{"SessionStart":{}}}"#,
                     #"{"hooks":{"SessionStart":[null]}}"#,
                     #"{"hooks":{"SessionStart":[{"hooks":{}}]}}"#] {
            #expect(throws: (any Error).self) {
                try HookGroupEdits.initialConfiguration(Data(text.utf8), events: events, group: group, helperName: "NotchPetHook")
            }
        }
    }

    @Test func malformedInputAndOversizedOutputCannotProduceCandidate() throws {
        for text in [#"{"hooks":{},"hooks":{}}"#, #"{"x":{"a":1,"a":2}}"#, "[]", "{" ] {
            #expect(throws: (any Error).self) {
                try HookGroupEdits.initialConfiguration(Data(text.utf8), events: events, group: group, helperName: "NotchPetHook")
            }
        }
        let boundary = Data("{}".utf8) + Data(repeating: 32, count: 262142)
        #expect(throws: HookPlanningFailure.resourceLimit) {
            try HookGroupEdits.initialConfiguration(boundary, events: events, group: group, helperName: "NotchPetHook")
        }
    }
}
