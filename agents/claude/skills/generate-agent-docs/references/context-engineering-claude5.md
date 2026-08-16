---
source_url: https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models
last_upstream_check: 2026-07-25
check_interval_days: 90  # a published post, not a living doc page — long gate, unlike best-practices (0) and model-prompting (14)
---

# Context Engineering for Claude 5 — Additive Rules

Anthropic's *"The new rules of context engineering for Claude 5 generation
models"* states how agent-configuration files should be shaped for the current
model generation. Most of it already governs this skill (see "Already owned
elsewhere"); this file carries **only the four rules that change what the skill
emits** and are stated nowhere else in it.

Consumers: stage3-generator.md (writing) and stage4-verifier.md (rejecting).
Rules are tagged **C1–C4** and behave like model-prompting-guides.md's `[W]`
rules — they govern generated project docs, never this skill's own prose.

**Freshness**: a published post, not a living doc page, so re-fetch `source_url`
only when `today - last_upstream_check > check_interval_days` (`ToolSearch`
`select:WebFetch` first — deferred tool). On any fetch failure use this snapshot
and say so in one line: *"context-engineering 가이드 라이브 로드 실패, 캐시 사용
(last check: <date>)."*

---

## Cached snapshot (last verified 2026-07-25)

### C1 — Anchor instructions to context, not to absolute prohibitions

The article's headline example is a system-prompt line Anthropic deleted:

> "In code: default to writing no comments. Never write multi-paragraph
> docstrings or multi-line comment blocks — one short line max."

replaced by:

> "Write code that reads like the surrounding code: match its comment density,
> naming, and idiom."

Anthropic reports removing over 80% of Claude Code's system prompt for the newer
models with no performance loss — the constraint was doing less work than the
judgment cue.

**Applies to**: any candidate line that forbids a behavior outright ("never write
X", "always use Y") where the right answer actually depends on the surrounding
code. Rewrite it to name the observable signal the agent should match, or cut it
when a linter already owns it. Which prohibitions survive: see Reconciliation.

### C2 — A sometimes-relevant procedure becomes a skill, not a section

> "Use progressive disclosure heavily, for example if you have several unique
> instructions on how to verify your work, create a verification skill and
> reference it from your CLAUDE.md."

**Applies to**: Stage 1/2 findings that cluster into a coherent multi-step
procedure bound to one recurring task (release, verification, migration, review).
Emitting it as a CLAUDE.md / AGENTS.md section spends every-session budget on
something needed occasionally. Recommend a skill and emit at most one reference
line pointing at it.

This promotes the adjacent line already in claude-code-best-practices.md — *"for
domain knowledge or workflows that are only relevant sometimes, use skills
instead"* — from an aside into the default architecture.

### C3 — Never emit memory-management instructions

> "We used to encourage users to save things to Claude's memory, by using the #
> hotkey to write to their CLAUDE.md automatically."

> "Instead, Claude now automatically saves memories that are relevant to the work
> and to you."

**Applies to**: reject any generated line telling a reader to record notes,
decisions, session logs, or learnings into CLAUDE.md / AGENTS.md, and any line
describing the `#` hotkey workflow. In update mode, flag an existing "Memory",
"Notes", "Session Log", or "Changelog" section in an agent-config file for
removal — auto-memory owns that content now, and a hand-maintained log fails the
prune test the moment it goes stale.

### C4 — Four context layers, not two

The skill's placement test currently splits two ways (AGENTS.md vs CLAUDE.md).
The article describes four layers with distinct jobs; use the full set when
deciding where a Stage 1/2 finding goes:

| Layer | Holds | This skill's stance |
| --- | --- | --- |
| System prompt / harness | What product the agent operates inside | **Out of scope** — never emitted into a project file |
| CLAUDE.md / AGENTS.md | Brief repo purpose + gotchas | The skill's primary output; keep lightweight |
| Skills | Sometimes-relevant procedures, team opinions | Recommend one instead of a section (C2) |
| References (`@`-mentions, linked files) | In-depth current material, read on demand | contributing-docs/; prefer a code-form spec over prose |

The CLAUDE.md row is the skill's existing core rule, stated upstream as:

> "Keep your CLAUDE.md lightweight and briefly describe what your repo is for,
> but spend most of the tokens on gotchas inside of the codebase."

> "Avoid stating 'the obvious' things Claude should know by looking at your file
> system or your repo."

Reference-layer detail worth carrying: the article prefers specs the agent can
execute or read as code — a test suite, a function implementation, an HTML
mockup, a rubric — over prose describing the same thing. When Stage 2 surfaces a
spec that already exists in executable form, reference that file instead of
paraphrasing it into a document.

---

## Already owned elsewhere — do not duplicate

These article points are already operative in the skill; restating them here
would only cost context:

| Article point | Owner in this skill |
| --- | --- |
| Gotcha-weighted, prune-tested CLAUDE.md | claude-code-best-practices.md (include/exclude table, prune test) |
| Size discipline / over-specified CLAUDE.md | claude-code-best-practices.md (200-line ceiling, failure pattern) |
| Advisory rule → deterministic hook | claude-code-best-practices.md |
| `/doctor` rightsizing an existing CLAUDE.md | claude-code-best-practices.md (`/init` behavior section) — the article points at it too; that entry stays authoritative for the exact command surface |
| Teach tools through interface design, not examples | **Out of scope** — this skill writes docs, not tool definitions |

---

## Reconciliation — which prohibitions survive C1

C1 collides with the Rule Authoring Policy in
`~/.config/dotrc/agents/rules/AGENTS.md`, which explicitly permits a bare "don't"
in three cases. The policy wins, narrowly:

- A prohibition **survives** when it is a regression guard for a violation that
  actually happened, a safety boundary (destructive or irreversible actions), or
  has no nameable alternative behavior.
- A prohibition **fails C1** when it constrains a stylistic or structural choice
  the surrounding code already answers, or forbids something the model would not
  do anyway.

Test to apply: *can you name what the agent should do instead?* If yes, C1
requires the positive form. If the honest answer is "nothing — just don't", it is
a guard and it stays.

---

## Note for skill upkeep (not generated output)

The article's advice also applies to this skill's own files — progressive
disclosure across `references/`, judgment over prohibition in its Red Flags
table. That is a **future upkeep pass** for skill-improver, not a rule the
generator applies; no `[S]`-class rules are defined here.
