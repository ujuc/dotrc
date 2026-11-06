# Summarize one Claude Code session JSONL into a single JSON object.
#
# Invoked as: jq -nR -f inventory.jq <session>.jsonl
# Raw-string input for the same reason as condense.jq: a truncated or
# malformed line must not abort the file.
#
# The counts here are what Dimension E scores against — turns, tool volume,
# failed calls — plus skills_used (Skill tool dispatch) and commands_used (slash
# invocations, which include built-in CLI commands the caller must filter out).

def conversation:
  select((.type == "user" or .type == "assistant") and .isSidechain != true);

def tool_uses:
  select(.type == "assistant")
  | .message.content[]?
  | select(.type == "tool_use");

def tool_errors:
  select(.type == "user")
  | .message.content
  | select(type == "array")
  | .[]?
  | select(.type == "tool_result" and .is_error == true);

def command_names:
  .message.content
  | select(type == "string")
  | [scan("<command-name>/?([^<]*)</command-name>")]
  | flatten[];

def nonempty_names:
  map(select(. != null and . != "")) | unique;

[inputs | fromjson? // empty] as $rows
| ($rows | map(conversation)) as $conv
| ($conv | map(tool_uses)) as $uses
| {
    session_id:  ($rows  | map(.sessionId? // empty) | first // ""),
    cwd:         ($rows  | map(.cwd?       // empty) | first // ""),   # launch dir: a session cds around
    git_branch:  ($rows  | map(.gitBranch? // empty) | last  // ""),
    started_at:  ($conv  | map(.timestamp? // empty) | first // ""),
    ended_at:    ($conv  | map(.timestamp? // empty) | last  // ""),
    user_turns:  ($conv  | map(select(.type == "user" and (.message.content | type) == "string")) | length),
    tool_calls:  ($uses  | length),
    tool_errors: ($conv  | map(tool_errors) | length),
    tools:       ($uses  | map(.name) | unique),
    skills_used: ($uses | map(select(.name == "Skill") | .input.skill? // empty)
                       | nonempty_names),
    commands_used: ($conv | map(command_names) | nonempty_names)
  }
