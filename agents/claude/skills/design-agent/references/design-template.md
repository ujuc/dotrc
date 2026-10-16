# Agent design document template

Load at Step 5 (Write). Fill every section; delete a section only when its
heading does not apply and say why in one line. The implementer reads this
with `writing-plans`, so keep decisions concrete and leave API syntax out.

```markdown
# <Agent name> — <one-line purpose>

## Decision
- Tier: single call | batch | code-driven workflow | agent — <deciding criterion>
- Approach: manual loop | Tool Runner | Managed Agents | Claude Agent SDK | none (<API surface, for a non-agent tier>)
- Loop supplied by: <your code | Tool Runner | Claude Agent SDK | Managed Agents> · Deployment by: <you | Anthropic>
- Runner-up: <approach> — flips if <single constraint> (agent tier only)
- Language / runtime: <detected or chosen>

## Job
<Two or three sentences: what the agent does, for whom, and what it must never do.>

## Trigger and kickoff
- Trigger: person | event | schedule (<cron and timezone if scheduled>)
- Kickoff shape: one deliverable with rubric | record changes | conversation
- Who is present during a run: <nobody | the operator | the end user>
- Overlapping runs: <prevented by a concurrency lock | writes are idempotent | not possible>

## Tools
| Tool | Kind | Gated? | Credential |
| --- | --- | --- | --- |
| <name> | bash/files · typed · web · MCP · custom | yes/no | <where it lives> |

## Loop and stop condition
- The loop ends when: <model stops calling tools | rubric satisfied | session idle | ...>
- Hard cap: <N turns | N tokens | $N> enforced by <harness | platform | your code>
- On cap reached: <report partial | pause for budget change | fail the run>

## State and context
- Within a run: <none | context editing | compaction>
- Across runs: <none | memory tool | memory store | files>
- Fan-out: <none | subagents | roster | dynamic workflows> with budget <...>

## Success rubric (starter — tune after the first runs)
1. <Observable criterion a second person can grade>
2. ...
<5–10 items covering format, required content, and a quality floor.>

## Budget
- Per run: <tokens or dollars>, enforced by <...>
- Monthly or per-schedule ceiling: <...>

## Approval and safety
| Action | Rule when attended | Rule when unattended |
| --- | --- | --- |
| <send / post / delete / push> | ask | deny · allow · report-only |

- Untrusted input the model reads: <issue bodies, emails, web pages, ...>
- Model free text written back to external systems verbatim: <nothing | where, and why it is safe>

## Failure handling
- Tool error: <returned to the model as an error result | retried | aborts>
- Dropped connection: <reconnect and consolidate events | restart run>
- Refusal: <fallback model | report and stop>
- Budget pause: <who raises it | treated as failure>

## Hosting and secrets
- Tools execute in: <own process | Anthropic sandbox | self-hosted sandbox>
- Secrets: <vault | process environment>; never written to agent memory; never reachable from a model-driven shell (clones, logins, and remote URLs with tokens are set up by the worker before the model runs)
- Platform constraints: <none | Bedrock / Vertex / Foundry | on-premise only>

## Out of scope
- <Actions and features deliberately excluded in this version>

## Open questions
- <Anything the interview left unresolved, with the default assumed>

## Implementation references
- Manual loop, Tool Runner, Managed Agents: `claude-api` skill (Managed Agents: `managed-agents-onboard`)
- Claude Agent SDK: `claude-code-guide` agent
```
