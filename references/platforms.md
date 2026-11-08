# Platform setup and compatibility

Documentation checked 2026-11-07. Use the same `SKILL.md` and references across hosts; do not copy Codex tool names or model IDs into other products. **Documented installation, portable prompt use, and runtime verification are different claims.** This release's behavioral checks run in the available Codex harness, not all five products.

| Environment | Distribution route | Review execution |
|---|---|---|
| Codex | Native skill directory | Actual subagent tools when exposed; local passes otherwise |
| Claude Code | Native skill directory | Supported subagents with an explicit brief; local passes otherwise |
| Grok web/apps | Paste or attach `PORTABLE.md` and explicitly request its use | Review supplied material with available tools; no assumed native skill discovery |
| Grok Bot (xAI) | Supply `PORTABLE.md` and ask the Bot to save it as a named private skill | Use the Bot's actual capabilities; confirm saving/enabling before claiming installation |
| Muse | Paste the portable instructions into the intended product's task/instruction input, or attach them if supported | Capability-based local review; native installation and delegation must be confirmed in that product |

“Grokbot” here means xAI Grok Bot. For another bot, use the generic portable route until its host is identified. “Muse” can mean different products, including Meta's Muse personal agent and Muse Code; this guide does not assume an installation path or claim a tested native integration for either.

## Codex

Choose **one** location for a new installation:

```bash
# User scope
git clone https://github.com/sleeplesshan/dual-brain.git ~/.agents/skills/dual-brain
# OR project scope, from the intended project root
git clone https://github.com/sleeplesshan/dual-brain.git .agents/skills/dual-brain
```

Invoke `$dual-brain` in Codex CLI/IDE, or select the skill using the client's skill picker. Update an existing discovered `~/.codex/skills/dual-brain` checkout in place rather than adding a duplicate. [Official skill documentation](https://learn.chatgpt.com/docs/build-skills).

## Claude Code

Choose one location:

```bash
# User scope
git clone https://github.com/sleeplesshan/dual-brain.git ~/.claude/skills/dual-brain
# OR project scope
git clone https://github.com/sleeplesshan/dual-brain.git .claude/skills/dual-brain
```

Invoke `/dual-brain` followed by the task. Keep `SKILL.md` and `references/` together. We do not set Claude-specific `context: fork` in shared frontmatter: the orchestrator needs the user's task and controls delegation. Give each reviewer a self-contained brief and relevant rules; do not assume a separate subagent has loaded the skill or inherited the conversation. [Official skills](https://code.claude.com/docs/en/skills), [subagents](https://code.claude.com/docs/en/sub-agents).

## Grok

Paste the complete contents of [PORTABLE.md](../PORTABLE.md), or attach the Markdown file, then say:

```text
Use these Dual-Brain instructions for this task: [task and acceptance criteria].
Use only available tools and supplied evidence. If no actionable issue is supported,
report that result without inventing changes. Distinguish suggestions from executed work.
```

The documented upload support includes Markdown/text. Attaching instructions does not install a native skill or establish persistent memory; explicitly request their use. This repository needs no API key or integration service for that route. [Grok overview](https://docs.x.ai/grok/overview), [uploads FAQ](https://docs.x.ai/grok/faq).

## Grok Bot

For **xAI Grok Bot**, provide the portable document and ask:

```text
Save these instructions as a private skill named dual-brain. Preserve the
capability checks, evidence-before-changes rules, and no-change stopping condition.
```

Inspect the saved instructions and enable the private skill for the current Bot if required. Then request “Use dual-brain to [task].” Confirm the save through the Bot's response or UI; this repository cannot perform or verify that account operation for you. The Bot's documented private-skill flow does not establish a filesystem installation path. In particular, **Grok Build** is a different CLI; do not apply its directories to the Bot. [Official skills and routines](https://docs.x.ai/grok-bot/skills-routines-and-automations).

## Muse and other instruction-capable hosts

Paste `PORTABLE.md` with the task into the intended Muse product. If that client provides a saved-instructions or attachment feature, use it only after checking its supported format and whether the whole text was accepted. If it cannot accept the document, provide the exact product/version before attempting a native adapter. Do not invent `.muse/skills`, a tool API, or a persistent memory location.

Meta describes distinct [Muse Code](https://research.meta.ai/blog/introducing-muse-code-and-muse-spark-1-2) and [Muse personal-agent](https://about.fb.com/news/2026/09/introducing-muse-personal-ai-agent/) products. Those announcements identify possible hosts; they do not validate this package's installation or execution in a user's particular client.

## Portable file and updates

`PORTABLE.md` is a generated, self-contained prompt containing the core workflow and runtime/memory rules. It needs no Python at use time. When maintaining this repository, regenerate and check it with:

```bash
python3 scripts/export_portable.py
python3 scripts/export_portable.py --check
```

Edit the source documents, not the generated file. Native installations keep progressive loading; chat-only hosts get the complete prompt so local references are not silently missing. Check the host's input limit; do not silently truncate the rules.

For a Git installation, run `git pull --ff-only` inside that existing checkout. For a saved/pasted prompt, replace it with the current portable file explicitly; updating this repository does not update another product's account automatically.
