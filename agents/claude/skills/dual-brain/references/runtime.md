# Runtime and model guidance

Read this when adapting delegation or settings to a host. Inspect the tools exposed in the current session; names, schemas, concurrency limits, and availability can change independently of the installed client version.

## Orchestration

| Capability | How to use it |
|---|---|
| Native subagents | Use the host's actual spawn, follow-up, message, wait, and lifecycle tools. Codex may expose `collaboration.spawn_agent`; other hosts may expose `spawn_agent` or `Agent`. Never call a name merely because this document mentions it. |
| Existing agents | Check role, task scope, status, and usable context. A message may only queue input; use a follow-up/resume operation when an idle agent needs a new turn. Avoid repeating work already in flight. |
| Missing slots/tools | Run sequentially within limits, or complete the missing perspective locally. Do not invent handles or launch nested CLIs to bypass limits. |
| Waiting | Do useful independent work first, then use a bounded wait. Avoid rapid status polling and repeating unchanged progress. |
| User-owned chats | Creating a sidebar chat is not a substitute for a subagent. Do so only when the user requested a separate chat. |

Agent handles belong only to the live session. After compaction, use available session state to recover valid handles; if unavailable, rebuild a concise brief from files and evidence. Never save runtime IDs in project memory. Replace a reused agent if irrelevant or stale context would outweigh reuse savings.

When user steering changes the goal or implementation, send affected agents the updated brief and identify which earlier findings need rechecking. Interrupt superseded work when supported. Confirm an old writer has stopped, or agree on non-overlapping ownership, before a replacement edits its files. If stopping it cannot be confirmed, continue independent work without competing writes. Match returned findings to the brief and file state they actually checked.

## Models and context

Inherit the active model and reasoning effort unless the user or applicable configuration requests a different choice. Read live support before any override; a model available to the parent or in public docs may not be available to a particular spawn tool. Do not silently switch the parent, change global configuration, or install an upgrade.

For Codex tools exposing `fork_turns`, follow their schema: full-history forks may disallow model/effort overrides. A fresh-context fork needs a self-contained task brief and evidence paths. Use one when it removes substantial irrelevant history; inherit context when it contains essential constraints that are costly to reconstruct.

Keep model selection separate from this protocol. Use the model selected in the host, and override it only when requested and supported. Do not transplant Codex model IDs, effort values, configuration files, or agent tool names into Claude Code, Grok, Grok Bot, Muse, or another host. Public model availability does not prove access in the active session.

## Capability modes

- **Native delegation + files:** use actual reviewer tools and the authorized project filesystem; isolate writers.
- **Files but no delegation:** perform macro and micro passes locally, and describe that coverage accurately.
- **Conversation only:** inspect supplied code/text. Produce a patch or explanation if warranted, never fictitious file writes, tool results, or independent reviewers. An attachment must actually be readable before claiming to have reviewed it.

Check capabilities once per session or when they change. Do not turn platform detection into a repeated setup ritual. A provider's API tool support is not evidence that its chat UI exposes the same tools. Never create accounts, install CLIs, alter global instruction files, or call a paid API just to simulate missing capabilities.

Increase reasoning effort only for unresolved complexity that could change the outcome. Maximum effort and more agents are not automatic improvements. A completed review with no supported changes needs no escalation to another model.
