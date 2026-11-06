---
source_url: https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/  # claude.com redirects here; the .md variant exists only on claude.dev
last_upstream_check: 2026-11-01
check_interval_days: 90  # a published post, not a living doc page — long gate, unlike best-practices (0) and model-prompting (14)
---

# Context Engineering for Claude 5 — Additive Rules

## Scope and precedence

The cached findings below are model- or study-specific evidence, not universal
rules. Apply them as local authoring defaults after explicit
user/repository requirements. Preserve confirmed team TDD, nondefault conventions,
concrete test commands and safety boundaries. Prior explicit decisions suffice;
no repeated interview is required. Missing evidence in a blind review never
licenses removing a team policy. Project-doc runs do not modify this cache or
its date; use native fetch equivalents under SKILL.md's Session capabilities.

Consumers: roles/writer.md (writing) and roles/verifier.md (rejecting).
C1–C4 behave like model-prompting-guides.md's `[W]` rules: they govern generated
project docs, never this skill's own prose. claude-code-best-practices.md owns
gotcha weighting, the prune test, size discipline, advisory-to-hook escalation
and `/doctor`. Teaching tools through interface design is out of scope.
Applying the article to this skill's own files (progressive disclosure across
`references/`, judgment over prohibition in Red Flags) is a future skill-improver
pass, not a generator rule.

**Freshness**: re-fetch `source_url` only when `today - last_upstream_check >
check_interval_days` (`ToolSearch` `select:WebFetch` first — deferred tool).
On any fetch failure use this snapshot and say so in one line:
*"context-engineering 가이드 라이브 로드 실패, 캐시 사용 (last check: <date>)."*

## Cached snapshot (last verified 2026-11-01)

### C1 — Anchor instructions to context, not to absolute prohibitions

Anthropic deleted a system-prompt line that defaulted to no comments and banned
multi-paragraph docstrings, multi-line comment blocks and unrequested planning
documents, and replaced it with:

> "Write code that reads like the surrounding code: match its comment density,
> naming, and idiom."

Anthropic reports removing over 80% of Claude Code's system prompt for the newer
models with no measurable loss on its coding evaluations.

**Applies to**: any candidate line that forbids a behavior outright ("never write
X", "always use Y") where the right answer depends on the surrounding code.
Rewrite it to name the observable signal the agent should match, or cut it when a
linter already owns it.

Test: *can you name what the agent should do instead?* If yes, C1 requires the
positive form. If the honest answer is "nothing — just don't", it is a guard and
it stays.

- A prohibition **survives** only when it is a regression guard for a violation
  that actually happened, a safety boundary (destructive or irreversible
  actions), or has no nameable alternative behavior.
- A prohibition **fails C1** when it constrains a stylistic or structural choice
  the surrounding code already answers, or forbids something the model would not
  do anyway.

### C2 — A sometimes-relevant procedure becomes a skill, not a section

**Applies to**: Stage 1/2 findings that cluster into a coherent multi-step
procedure bound to one recurring task (release, verification, migration, review).
Recommend a skill and emit at most one reference line pointing at it.

### C3 — Never emit memory-management instructions

Anthropic no longer encourages saving memories with the `#` hotkey, which wrote
to CLAUDE.md: Claude now saves relevant memories automatically.

**Applies to**: reject any generated line telling a reader to record notes,
decisions, session logs, or learnings into CLAUDE.md, and any line
describing the `#` hotkey workflow. In update mode, flag an existing "Memory",
"Notes", "Session Log", or "Changelog" section in an agent-config file for
review. Do not infer memory support from other tools, and do not delete
intentional project policy because a section is called Notes. Avoid generating
session logs into instruction documents unless explicitly requested.

### C4 — Four context layers, not two

Use all four when deciding where a Stage 1/2 finding goes:

| Layer | Holds | This skill's stance |
| --- | --- | --- |
| System prompt / harness | What product the agent operates inside | **Out of scope** — never emitted into a project file |
| CLAUDE.md | Brief repo purpose, then mostly gotchas; nothing obvious from the file system or repo | The skill's primary output; keep lightweight |
| Skills | Sometimes-relevant procedures, team opinions — *"lightweight guides to let Claude find information when needed. Avoid making them overconstrained, except in highly important areas."* | Recommend one instead of a section (C2) |
| Linked references | In-depth material read on demand | contributing-docs/; CLAUDE.md @imports load in full, not on demand. |

Prefer specs the agent can execute or read as code (a test suite, a function
implementation, an HTML mockup, a rubric) over prose describing the same thing:
when Stage 2 surfaces a spec that already exists in executable form, reference
that file instead of paraphrasing it into a document.
