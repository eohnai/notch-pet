import Foundation

/// Projects the seven Claude hook shapes covered by the recorded investigation.
/// Hook installation and interactive coverage remain separate workflow checks.
public enum ClaudeEventAdapter: AgentEventAdapter {
    static let descriptor = AgentDescriptor(id: "claude", displayName: "Claude Code",
                                           eventNames: HookEnvelopeV1.hooks,
                                           questionTools: ["AskUserQuestion"], capabilities: [.observation])
    private static let supportedHooks: Set<String> = [
        "SessionStart", "UserPromptSubmit", "PreToolUse", "PermissionRequest",
        "PostToolUse", "Stop", "SessionEnd"
    ]

    public static func project(rawHook: Data, paneSelector: String? = nil) throws -> HookEnvelopeV1 {
        try project(rawHook: rawHook, paneSelector: paneSelector, deadline: nil)
    }

    static func project(rawHook: Data, paneSelector: String?, deadline: UInt64?) throws -> HookEnvelopeV1 {
        let observed = wallMilliseconds()
        let source = try HookEnvelopeV1.rawFields(rawHook, deadline: deadline)
        guard let hook = source["hook_event_name"]?.string, supportedHooks.contains(hook) else {
            throw BridgeError.invalidMessage
        }
        var fields: [String: JSONValue] = [:]
        for name in ["session_id", "hook_event_name", "tool_use_id", "tool_name", "cwd"] {
            fields[name] = source[name]
        }
        // Missing IDs remain missing. Claude's source turn identity is prompt_id, not turn_id.
        fields["turn_id"] = source["prompt_id"]
        return try HookEnvelopeV1.projected(fields, agent: "claude", observedAtMs: observed,
                                            paneSelector: paneSelector)
    }
}
