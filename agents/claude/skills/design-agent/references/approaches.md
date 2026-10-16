# Approaches, defaults, and archetypes

Load at Step 4 (Recommend). Facts here name mechanisms, not API surfaces;
the implementer verifies field names through the `claude-api` skill or the
`claude-code-guide` agent.

## The two axes

| | You deploy | Anthropic deploys |
| --- | --- | --- |
| **You write the loop** | 1. Manual loop (Anthropic SDK) | — |
| **A harness supplies the loop** | 2. Tool Runner (Anthropic SDK)  ·  4. Claude Agent SDK | 3. Managed Agents |

Only Managed Agents supplies both the harness and the deployment. Tool Runner
and Agent SDK look alike but differ in scope: Tool Runner executes only tools
you define (Anthropic-defined bash, editor, and memory tools come as reference
implementations you wire in; server-side tools need no handler); Agent SDK is
the Claude Code harness with built-in file, shell, grep, and web tools.

## Pick and avoid signals

| Approach | Pick when | Avoid when |
| --- | --- | --- |
| 1. Manual loop | You must own the whole loop: custom transport, control flow that per-turn hooks cannot express, or no beta dependency allowed | Your reason is "I need control"; approval gates, retries, logging, result rewriting, streaming, and compaction are all available as Tool Runner hooks |
| 2. Tool Runner | Default for a custom-tool agent you host | You need a hosted sandbox, versioned configs, scheduling, dollar budgets, or long server-side sessions; a web-tool researcher on the runner must handle a paused server-tool turn itself, which the runner does not resume |
| 3. Managed Agents | You want Anthropic to run the loop and host the workspace; scheduled runs; one deliverable iterated against a rubric; work too large for one context; persisted versioned agent configs | Compute or secrets must stay on your infrastructure and a self-hosted sandbox does not satisfy that; target platform is Bedrock, Vertex, or Foundry (choose among 1, 2, 4 there; the Agent SDK is confirmed for Bedrock and Google Cloud, Foundry unconfirmed) |
| 4. Claude Agent SDK | A batteries-included coding or filesystem agent on your own infrastructure in Python or TypeScript; you accept the Claude Code harness, hooks, and permission modes as-is | You need a thin loop over your own typed tools only, or managed hosting |

"Simplest" means the least code you own. A hosted, scheduled, or
memory-backed agent is usually simplest as Managed Agents even though it is
the larger platform.

## Per-approach defaults

| Concern | 1–2. Anthropic SDK (manual, Tool Runner) | 3. Managed Agents | 4. Claude Agent SDK |
| --- | --- | --- | --- |
| Stop gate | Loop until the model stops calling tools; cap iterations or continuations; check max-tokens and refusal stop reasons before running tools | Session idle with a non-action stop reason, or terminated; outcome result satisfied, max iterations, failed, interrupted; budget-reached pauses and is not terminal | Response with no tool call; max turns; max dollar budget; result subtypes report which cap hit |
| Budget | Per-response max tokens (enforced, invisible to the model); advisory task budget the model paces against (beta, first-party API only); effort level | Hard dollar session budget enforced by the platform; deployment budgets for scheduled runs | Max turns plus max dollar budget, subagent spend included |
| Approval | Gate inside the tool handler or intercept the yielded tool call before execution | Per-tool permission policy: always allow, always ask, or auto; a paused call waits for confirmation and blocks new messages | Pre-tool-use hook or a can-use-tool callback; permission modes; hook deny wins over bypass |
| Unattended gates | Your scheduler must supply the rule | Webhook handler on session idle answers paused calls; deny unless a rule exists | Hook returns the decision; no human path |
| State | Context editing, server-side compaction, memory tool you back with storage | Session history, memory stores (self-hosted sandbox: Python, TypeScript, or Go SDK worker only; not on Claude Platform on AWS), mounted files, outputs directory | Sessions with resume and fork; transcripts on local disk; session store adapter for multi-host |
| Fan-out | Separate runs or your own subagent code | Roster starting with self, cheaper worker agents, dynamic workflows for hundreds of items | Subagent definitions |
| Credentials | Stay in your process by construction; never in the memory tool | Vault credentials substituted at egress; the sandbox never sees them (cloud sandbox only; on a self-hosted sandbox use MCP vault credentials or a host-side custom tool that holds the secret) | Your process environment |

## Archetype defaults

Use these when the interview leaves a slot open; the interview answer wins.

| Archetype | Trigger | Default approach | Default tools | Typical stop |
| --- | --- | --- | --- | --- |
| Scheduled reporter | Cron, nobody present | Managed Agents scheduled deployment; or approaches 1, 2, 4 under your own scheduler | Sandbox toolset with web tools off unless sources are named; document skills for file reports; MCP for the data source | Outcome rubric satisfied; deployment budget; unattended confirmation rule |
| Researcher | Person or event, work fans out | Managed Agents with a roster, cheaper workers for reading; or Tool Runner with web tools (server-side web tools are unavailable on Bedrock and partly on Vertex; handle the paused server-tool turn yourself) and separate worker runs | Web search and fetch with allowed domains; subagents or programmatic calls to keep reading out of context | One deliverable rubric; session budget mandatory |
| Code-change agent | Issue, bug report, or person | Managed Agents with a repository mount plus the GitHub MCP server for the PR; on own infra, Agent SDK or Tool Runner with bash and editor tools | Bash and file tools; repo mount with a token; push and PR creation as gated dedicated tools | PR exists and rubric passes; bug report as the first message, outcome second |
| Ticket or record processor | Event per ticket or a queue sweep | Managed Agents conversational kickoff; or Tool Runner with your typed tools | MCP for the ticket system; close, escalate, send as always-ask or handler-gated tools | Model stops calling tools; unattended runs need the webhook rule |
| Conversational assistant | Person, one turn at a time | Managed Agents session or Tool Runner with streaming | Documents and retrieval tools; memory when context must persist; context editing and compaction for long chats | Per turn only; no grader, checker, or re-check loop per answer |
| Bulk per-item processor | Batch of N items | Gate first: fixed per-item work is Batches API or a code-driven workflow, not an agent; Managed Agents dynamic workflows only when each item needs open-ended tool use and the count exceeds a roster | Structured outputs per item; hard budget always | Batch ended; or workflow run complete under a budget |

## Viability gate

Run before presenting, surface only the gaps:

1. Every verb in the task maps to an enabled tool or MCP server ("open a PR"
   needs the PR tool, not just a repo mount; "look it up" needs a web tool).
2. Every MCP server, repository, or API the agent touches has a credential
   plan and a place for it.
3. Every external host is reachable under the chosen networking.
4. Every file, repository, or dataset the task names is mounted or passed.
5. "Done" is checkable by the rubric or by an explicit stop condition.
