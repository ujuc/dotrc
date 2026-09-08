# Condense one Claude Code session JSONL into a scorable digest.
#
# Invoked as: jq -rR --arg sidechains 0 -f condense.jq <session>.jsonl
# Raw-string input (-R) so a single malformed line is skipped instead of
# aborting the whole file; transcripts are appended live and can be truncated.
#
# One output line per meaningful event, tagged so the efficiency rubric can
# read the run's shape without loading megabytes of tool output:
#   USR  a human turn            CMD  a slash-command turn
#   AST  assistant prose         USE  a tool call + its target
#   ERR  a failed tool result    (thinking and successful results are dropped)

def clip($n):
  tostring | gsub("\\s+"; " ")
  | if length > $n then .[0:$n] + "…" else . end;

# The one identifying argument of a tool call, by tool.
def tool_arg:
  .name as $n | (.input // {}) as $i |
  if   $n == "Bash"  then ($i.command // "")
  elif $n == "Skill" then ($i.skill // "")
  elif $n == "Agent" then ($i.subagent_type // $i.description // "")
  elif ($i.file_path // null) != null then $i.file_path
  elif ($i.pattern   // null) != null then (($i.pattern) + " " + ($i.path // ""))
  elif ($i.url       // null) != null then $i.url
  elif ($i.query     // null) != null then $i.query
  else ($i.description // "") end;

def text_of:
  if type == "array" then (map(.text? // "") | join(" ")) else (. // "") end;

# Harness plumbing, not conversation: dropping it keeps the digest readable.
def is_noise:
  test("^\\s*<(local-command-stdout|system-reminder|command-message|command-args)")
  or test("^\\s*Caveat: The messages below were generated");

def user_text:
  if is_noise then empty
  elif test("<command-name>") then
    "CMD " + ([scan("<command-name>/?([^<]*)</command-name>")]
      | flatten | join(" ") | clip(120))
  else "USR " + clip(400) end;

def user_event:
  if type == "string" then user_text
  else
    .[]?
    | if .type == "tool_result" and .is_error == true then
        "ERR " + (.content | text_of | clip(240))
      elif .type == "text" and ((.text // "") | is_noise | not) then
        "USR " + (.text | clip(400))
      else empty end
  end;

def assistant_event:
  .[]?
  | if .type == "text" then "AST " + (.text | clip(240))
    elif .type == "tool_use" then "USE " + .name + " | " + (tool_arg | clip(160))
    else empty end;

fromjson? // empty
| select(.type == "user" or .type == "assistant")
| select($sidechains == "1" or .isSidechain != true)
| if .type == "user" then .message.content | user_event
  else .message.content | assistant_event end
