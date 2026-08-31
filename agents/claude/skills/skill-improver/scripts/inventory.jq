# Summarize one Claude Code session JSONL into a single JSON object.
#
# Invoked as: jq -nR -f inventory.jq <session>.jsonl
# Raw-string input for the same reason as condense.jq: a truncated or
# malformed line must not abort the file.
#
# The counts here are what Dimension E scores against — turns, tool volume,
# failed calls — plus skills_used (Skill tool dispatch) and commands_used (slash
# invocations, which include built-in CLI commands the caller must filter out).

[inputs | fromjson? // empty] as $rows
| ($rows | map(select((.type == "user" or .type == "assistant") and .isSidechain != true))) as $conv
| ($conv | map(select(.type == "assistant") | .message.content[]? | select(.type == "tool_use"))) as $uses
| {
    session_id:  ($rows  | map(.sessionId? // empty) | first // ""),
    cwd:         ($rows  | map(.cwd?       // empty) | first // ""),   # launch dir: a session cds around
    git_branch:  ($rows  | map(.gitBranch? // empty) | last  // ""),
    started_at:  ($conv  | map(.timestamp? // empty) | first // ""),
    ended_at:    ($conv  | map(.timestamp? // empty) | last  // ""),
    user_turns:  ($conv  | map(select(.type == "user" and (.message.content | type) == "string")) | length),
    tool_calls:  ($uses  | length),
    tool_errors: ($conv  | map(select(.type == "user") | .message.content | select(type == "array") | .[]? | select(.type == "tool_result" and .is_error == true)) | length),
    tools:       ($uses  | map(.name) | unique),
    skills_used:   ($uses | map(select(.name == "Skill") | .input.skill? // empty)
                    | map(select(. != null and . != "")) | unique),
    commands_used: ($conv | map(select((.message.content | type) == "string")
                          | .message.content | [scan("<command-name>/?([^<]*)</command-name>")] | flatten[])
                    | map(select(. != null and . != "")) | unique)
  }
