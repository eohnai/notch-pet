import Foundation

/// Projects the seven Codex hook shapes covered by the recorded investigation.
/// Interactive coverage and hook installation are separate verification and setup tasks.
public enum CodexEventAdapter {
    // Provider coverage stays explicit even if a future wire contract accepts more events.
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
        for name in ["session_id", "hook_event_name", "turn_id", "tool_use_id", "tool_name", "cwd"] {
            fields[name] = source[name]
        }
        // Missing IDs remain missing. Never read a transcript or infer a turn from another field.
        return try HookEnvelopeV1.projected(fields, agent: "codex", observedAtMs: observed,
                                            paneSelector: paneSelector)
    }
}
