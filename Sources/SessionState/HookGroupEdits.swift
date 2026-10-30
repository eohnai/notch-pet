import EventBridge
import Foundation

public enum HookPlanningFailure: String, Error, Equatable, Sendable {
    case resourceLimit, unsupportedShape, ownershipConflict, malformedConfiguration
    case unverifiedVersion, unsupportedVersion, unsupportedProvider, hooksDisabled, helperUnavailable, unsafeTarget
}

/// Provider setup policy plus pure planning; file validation/application belongs to the installer.
public enum HookSetupPlanner {
    public static func plan(_ input: HookSetupInput) -> HookSetupPlan {
        guard input.agent == "codex" else { return .unavailable(.unsupportedProvider) }
        guard case .verified(let version, let enabled, let helperAvailable) = input.support else {
            return .unavailable(.unverifiedVersion)
        }
        guard version == "0.165.0" else { return .unavailable(.unsupportedVersion) }
        guard enabled else { return .unavailable(.hooksDisabled) }
        guard helperAvailable else { return .unavailable(.helperUnavailable) }
        for path in [input.target.configurationPath, input.target.helperPath] {
            guard path.hasPrefix("/"), !path.hasSuffix("/"), path.utf8.count <= 4096,
                  !path.unicodeScalars.contains(where: { $0.properties.generalCategory == .control }),
                  URL(fileURLWithPath: path).standardizedFileURL.path == path else {
                return .unavailable(.unsafeTarget)
            }
        }
        guard input.target.parentDevice > 0, input.target.parentInode > 0 else {
            return .unavailable(.unsafeTarget)
        }
        guard (input.configuration?.count ?? 0) <= HookEnvelopeV1.rawHookLimit,
              (input.ownership?.count ?? 0) <= HookEnvelopeV1.rawHookLimit else {
            return .unavailable(.resourceLimit)
        }
        do {
            guard let descriptor = AgentCatalog.builtIn.descriptor(for: input.agent) else {
                return .unavailable(.unsupportedProvider)
            }
            let events = descriptor.eventNames.sorted()
            let command = "'" + input.target.helperPath.replacingOccurrences(of: "'", with: "'\"'\"'") + "' --agent " + input.agent
            let group = HookManagedGroup(hooks: [HookManagedCommand(type: "command", command: command, timeout: 3)])
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            let groupData = try encoder.encode(group)
            let document = try HookConfigurationJSON(data: input.configuration ?? Data("{}".utf8))
            if let record = input.ownership {
                do {
                    let ownedDocument = try HookConfigurationJSON(data: record)
                    let keys: Set<JSONPathComponent> = Set(["version", "agent", "installationID", "target", "groups",
                                                           "createdConfiguration", "createdHooksContainer", "createdEvents"].map(JSONPathComponent.key))
                    let targetKeys: Set<JSONPathComponent> = Set(["configurationPath", "parentDevice", "parentInode", "helperPath"].map(JSONPathComponent.key))
                    let owner = try JSONDecoder().decode(HookSetupOwnership.self, from: record)
                    guard Set(ownedDocument.members(at: []) ?? []) == keys,
                          Set(ownedDocument.members(at: [.key("target")]) ?? []) == targetKeys,
                          owner.version == 1, owner.agent == input.agent,
                          owner.installationID == input.installationID, owner.target == input.target,
                          Set(owner.groups.keys) == Set(events), owner.groups.values.allSatisfy({ $0 == groupData }),
                          owner.createdEvents.count <= events.count,
                          Set(owner.createdEvents).count == owner.createdEvents.count,
                          Set(owner.createdEvents).isSubset(of: Set(events)),
                          !owner.createdHooksContainer || Set(owner.createdEvents) == Set(events),
                          !owner.createdConfiguration || owner.createdHooksContainer else {
                        return .conflict(.ownershipConflict)
                    }
                    try HookGroupEdits.verifyOwnedConfiguration(document, events: events, group: group,
                                                                helperName: URL(fileURLWithPath: input.target.helperPath).lastPathComponent)
                    return .unchanged
                } catch {
                    return .conflict(.ownershipConflict)
                }
            }
            let candidate = try HookGroupEdits.initialConfiguration(input.configuration, events: events,
                                                                  group: groupData,
                                                                  helperName: URL(fileURLWithPath: input.target.helperPath).lastPathComponent)
            let owner = HookSetupOwnership(
                version: 1, agent: input.agent, installationID: input.installationID, target: input.target,
                groups: Dictionary(uniqueKeysWithValues: events.map { ($0, groupData) }),
                createdConfiguration: input.configuration == nil,
                createdHooksContainer: document.range(at: [.key("hooks")]) == nil,
                createdEvents: events.filter { document.range(at: [.key("hooks"), .key($0)]) == nil })
            let ownership = try encoder.encode(owner)
            guard ownership.count <= HookEnvelopeV1.rawHookLimit else { return .unavailable(.resourceLimit) }
            return .update(configuration: candidate, ownership: ownership)
        } catch let failure as HookPlanningFailure {
            return failure == .resourceLimit ? .unavailable(failure) : .conflict(failure)
        } catch {
            return .conflict(.malformedConfiguration)
        }
    }
}

/// Pure byte edits shared by provider planners. No settings are read, written or executed here.
enum HookGroupEdits {
    static func initialConfiguration(_ current: Data?, events: [String], group: Data,
                                     helperName: String) throws -> Data {
        guard !helperName.isEmpty, !events.isEmpty, events.count <= 32,
              Set(events).count == events.count else { throw HookPlanningFailure.unsupportedShape }
        _ = try HookConfigurationJSON(data: group)
        let document = try HookConfigurationJSON(data: current ?? Data("{}".utf8))
        let edits = try insertions(document, events: events, group: group, helperName: helperName)
        let growth = edits.reduce(0) { $0 + $1.bytes.count }
        guard growth <= HookEnvelopeV1.rawHookLimit,
              document.data.count <= HookEnvelopeV1.rawHookLimit - growth else {
            throw HookPlanningFailure.resourceLimit
        }
        var candidate = document.data
        for edit in edits.sorted(by: { $0.offset > $1.offset }) {
            candidate.insert(contentsOf: edit.bytes, at: edit.offset)
        }
        _ = try HookConfigurationJSON(data: candidate)
        return candidate
    }

    private static func insertions(_ document: HookConfigurationJSON, events: [String], group: Data,
                                   helperName: String) throws -> [(offset: Int, bytes: Data)] {
        let hooksPath: [JSONPathComponent] = [.key("hooks")]
        let groupText = String(decoding: group, as: UTF8.self)
        var additions: [String] = []
        var edits: [(offset: Int, bytes: Data)] = []
        if document.range(at: hooksPath) != nil {
            guard document.rawValue(at: hooksPath)?.first == 123,
                  let configuredEvents = document.members(at: hooksPath), configuredEvents.count <= 256 else {
                throw HookPlanningFailure.unsupportedShape
            }
            for event in configuredEvents {
                let path = hooksPath + [event]
                guard document.rawValue(at: path)?.first == 91,
                      let groups = document.members(at: path), groups.count <= 256 else {
                    throw HookPlanningFailure.unsupportedShape
                }
                for existing in groups {
                    try rejectCollision(document, at: path + [existing], helperName: helperName)
                }
            }
        }
        for event in events {
            let key = String(decoding: try JSONEncoder().encode(event), as: UTF8.self)
            let path = hooksPath + [.key(event)]
            if let range = document.range(at: path) {
                guard document.rawValue(at: path)?.first == 91,
                      let members = document.members(at: path), members.count <= 256 else {
                    throw HookPlanningFailure.unsupportedShape
                }
                edits.append((range.upperBound - 1, Data(((members.isEmpty ? "" : ",") + groupText).utf8)))
            } else {
                additions.append(key + ":[" + groupText + "]")
            }
        }
        if let hooksRange = document.range(at: hooksPath) {
            guard document.rawValue(at: hooksPath)?.first == 123,
                  let members = document.members(at: hooksPath) else {
                throw HookPlanningFailure.unsupportedShape
            }
            if !additions.isEmpty {
                edits.append((hooksRange.upperBound - 1,
                              Data(((members.isEmpty ? "" : ",") + additions.joined(separator: ",")).utf8)))
            }
        } else {
            guard let root = document.range(at: []), let members = document.members(at: []) else {
                throw HookPlanningFailure.malformedConfiguration
            }
            let field = (members.isEmpty ? "" : ",") + "\"hooks\":{" + additions.joined(separator: ",") + "}"
            edits.append((root.upperBound - 1, Data(field.utf8)))
        }
        return edits
    }

    static func verifyOwnedConfiguration(_ document: HookConfigurationJSON, events: [String],
                                         group: HookManagedGroup, helperName: String) throws {
        let path: [JSONPathComponent] = [.key("hooks")]
        guard document.rawValue(at: path)?.first == 123,
              let configuredEvents = document.members(at: path), configuredEvents.count <= 256,
              Set(events.map(JSONPathComponent.key)).isSubset(of: Set(configuredEvents)) else {
            throw HookPlanningFailure.ownershipConflict
        }
        for event in configuredEvents {
            let eventPath = path + [event]
            guard document.rawValue(at: eventPath)?.first == 91,
                  let groups = document.members(at: eventPath), groups.count <= 256 else {
                throw HookPlanningFailure.ownershipConflict
            }
            var matches = 0
            for existing in groups {
                let groupPath = eventPath + [existing]
                if events.map(JSONPathComponent.key).contains(event) && matchesGroup(document, at: groupPath, expected: group) {
                    matches += 1
                } else {
                    try rejectCollision(document, at: groupPath, helperName: helperName)
                }
            }
            if events.map(JSONPathComponent.key).contains(event) && matches != 1 {
                throw HookPlanningFailure.ownershipConflict
            }
        }
    }

    private static func matchesGroup(_ document: HookConfigurationJSON, at path: [JSONPathComponent],
                                     expected: HookManagedGroup) -> Bool {
        let hooksPath = path + [.key("hooks")]
        guard Set(document.members(at: path) ?? []) == [.key("hooks")],
              document.members(at: hooksPath) == [.index(0)],
              Set(document.members(at: hooksPath + [.index(0)]) ?? []) == [.key("type"), .key("command"), .key("timeout")],
              let raw = document.rawValue(at: path),
              let decoded = try? JSONDecoder().decode(HookManagedGroup.self, from: raw) else { return false }
        return decoded == expected
    }

    private static func rejectCollision(_ document: HookConfigurationJSON, at path: [JSONPathComponent],
                                        helperName: String) throws {
        let handlersPath = path + [.key("hooks")]
        guard document.rawValue(at: path)?.first == 123,
              document.rawValue(at: handlersPath)?.first == 91,
              let handlers = document.members(at: handlersPath), handlers.count <= 256 else {
            throw HookPlanningFailure.unsupportedShape
        }
        let decoder = JSONDecoder()
        if let matcher = document.rawValue(at: path + [.key("matcher")]),
           (try? decoder.decode(String.self, from: matcher)) == nil {
            throw HookPlanningFailure.unsupportedShape
        }
        for handler in handlers {
            let handlerPath = handlersPath + [handler]
            guard document.rawValue(at: handlerPath)?.first == 123 else {
                throw HookPlanningFailure.unsupportedShape
            }
            if let raw = document.rawValue(at: handlerPath + [.key("command")]) {
                guard let command = try? decoder.decode(String.self, from: raw) else {
                    throw HookPlanningFailure.unsupportedShape
                }
                // Conservatively reject lookalikes. This never adopts or deletes a user's entry.
                if command.contains(helperName) { throw HookPlanningFailure.ownershipConflict }
            }
        }
    }
}
