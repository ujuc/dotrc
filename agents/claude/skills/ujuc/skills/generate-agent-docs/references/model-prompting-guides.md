---
source_urls:
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2.md  # own guide; does not inherit 5.1
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1.md  # legacy; source of measured 5.1 findings
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5.md   # base guide inherited by 5.1
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5.md
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5.md    # base guide inherited by 5.5
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-4-8.md  # legacy; still listed in the upstream model-guide table
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5.md
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5.md  # base guide inherited by 5.5
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-haiku-5-5.md
  - https://platform.claude.com/docs/en/models/opus-5-5/migration-guide.md  # source of the S1 quote
secondary_source_url: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md
last_upstream_check: 2026-11-01
check_interval_days: 14
---

# Model Prompting Guides — Instruction-Authoring Constraints

## Scope and precedence

These cached findings are model- or study-specific evidence, not universal
rules. Apply them as local authoring defaults after explicit user/repository
requirements. Preserve confirmed team TDD, nondefault conventions, concrete test
commands and safety boundaries. Prior explicit decisions suffice; no repeated
interview is required. Missing evidence in a blind review never licenses
removing a team policy. Project-doc runs do not modify this cache or its date;
use native fetch equivalents under SKILL.md's Session capabilities.

CLAUDE.md, its imports and unconditional `.claude/rules/` load in full every session, so they
are system-prompt content: the parts of Anthropic's per-model guides on how
instructions are written are authoritative for Stage 3 (writing) and Stage 4
(verifying). The rest is out of scope (see the end of this file).

**Inheritance**: Opus 5.5, Fable 5.1 and Sonnet 5.5 say their predecessor's
prompts should perform well without changes, so they inherit their base guides
(Opus 5, Fable 5, Sonnet 5) and rules quoting those apply to the successor
unless a rule says otherwise. Haiku 5.5 inherits Haiku 4.5, which is not cached,
so only rules naming Haiku 5.5 apply to it. Fable 5.2 inherits nothing: its
guide lists instructions written for Fable 5.1 or Opus 5.5 to review, so only
rules naming Fable 5.2 apply to it. Mythos 5.2, 5.1 and 5 map onto the Fable
5.2, 5.1 and 5 guides; they are not separate sources. Never attribute a
finding to a newer model whose guide does not restate it (upstream: *"treat it
as measured on that model and re-check it"*).

**Freshness**: re-fetch `source_urls` only when `today - last_upstream_check >
check_interval_days` (`ToolSearch` `select:WebFetch` first — deferred tool).
When that gate fires, also fetch `secondary_source_url` and compare the guide
links in its "Model-specific guidance" table with `source_urls`. A guide listed
there but missing here is drift: report it in one line and route cache
maintenance to `/ujuc:generate-skills generate-agent-docs 업데이트`. Otherwise fetch
`secondary_source_url` only for a cross-model question. On any fetch failure,
use this file and say so in one line:
*"model-prompting 가이드 라이브 로드 실패, 캐시 사용 (last check: <date>)."*

Rules are tagged by consumer; do not mix them. **[W]** governs what this skill
emits into generated project docs (Stage 3 and 4). **[S]** governs how this
skill itself is written; never emit it into a project doc.

## [W] Guardrails for generated docs

### W1 — Avoid redundant self-check scaffolding

Opus 5: *"If your prompt contains explicit verification instructions
("include a final verification step for any non-trivial task," "use a
subagent to verify"), remove them: instructions like these cause
over-verification on Claude Opus 5, and removing them reduces wasted tokens
with no loss in quality. The same applies to legacy harness scaffolding that
adds separate verification steps."* Also: *"Avoid instructing re-checks it
already performs ("double-check your answer," "re-verify before
responding")."*

Omit generic lines of that shape by default. Preserve named test commands,
explicit team gates and mandated verification. Recommend hooks when appropriate
without deleting the requirement before an authorized replacement. See D1.

### W2 — Never command reasoning visibility or thinking amount

Fable 5.1: *"Prompts, skills, and tool descriptions that ask the model to write
its thinking or reasoning might be declined with the `reasoning_extraction`
category."* Fable 5, Fable 5.2, Opus 5, Opus 5.5 and Sonnet 5.5 have the same category.
Opus 5: *"If your system prompt contains a rule instructing the model not to
think or not to reason, remove it; that kind of instruction increases tag
leakage."* Opus 5.5 and Sonnet 5.5 (with `between_tools`) also say remove it.
Opus 5.5: *"Lowering effort reduces thinking ... more reliably than prompt
instructions do."* Sonnet 5.5 (think less) and Haiku 5.5 (answer directly) report
the same. Fable 5.2: a think-less line *"didn’t stop Claude Fable 5.2 from
thinking at `medium` and above. Remove these lines and lower the effort level"*.

Reasoning visibility is an application concern (structured thinking blocks) and
thinking amount, including think-harder/less lines, is effort configuration (D2):
neither is a repository doc line. Asking for the **rationale behind a
decision** ("propose alternatives with reasoning") is output content, not
internal-reasoning transcription, and stays allowed.

### W3 — State every rule's scope explicitly

Sonnet 5 and Opus 4.8: *"It does not silently generalize an instruction from
one item to another, and it does not infer requests you didn't make ... If
you need Claude to apply an instruction broadly, state the scope explicitly."*
Fable 5.2: *"delete the cautions whose reason no longer holds, and rewrite
absolute rules so that they state their scope and reason."*

Name the paths, directories or file types a rule covers. Path-bound rules prefer
`.claude/rules/` with `paths`.

### W4 — Carry the reason when the rule is not self-evident

Fable 5: the model *"tends to perform better when the prompt states the intent
behind a request"*; Fable 5.2 asks for each absolute rule's reason (W3 quote). One clause of *why*, only where the why is non-obvious.

### W5 — Never write confidence or severity filter bars

Opus 5, Sonnet 5 and Opus 4.8: *"only report high-severity issues,"
"be conservative"* (Sonnet 5 and Opus 4.8 add *"don't nitpick"*) are followed
literally and suppress real findings. Opus 5: *"ask it to report everything and
filter in a separate pass instead."* Sonnet 5 and Opus 4.8, for a single pass that must
self-filter: *"be concrete about what the reporting threshold is rather than
using qualitative terms"*. Applies whenever generated docs carry review or
triage instructions.

### W6 — Delegation guidance needs a bar, not a ban

Opus 5 *"delegates to subagents more readily than prior models ... it
multiplies cost and time when applied to small tasks"*; Fable 5 *"dispatches
parallel subagents more readily ... Use subagents frequently"*; Fable 5.2 *"delegates
readily"* where prompts invite it: *"If your system prompt, skills, or agent files
tell the model to delegate, review those lines first."* Emit an explicit
bar for when delegation is warranted through the existing conditional
orchestration guidance (stage3-generator.md Section A), never as a second,
competing policy. In update mode, propose removing standing lines that push
work to subagents without such a project condition; do not add a bar where
the doc does not invite delegation.

### W7 — Agent-memory notes: one lesson per file

Fable 5: *"Store one lesson per file with a one-line summary at the top.
Record corrections and confirmed approaches alike, including why they mattered.
Don't save what the repo or chat history already records; update an existing
note rather than creating a duplicate; delete notes that turn out to be
wrong."* Emit only when the project has an agent-memory directory; otherwise it
fails the prune test.

### W8 — Steer with a brief instruction, not an enumeration

Fable 5: *"you can steer most behaviors with a brief instruction rather than
enumerating each behavior by name"*. Write the one line that names the behavior,
with its scope (W3). Keep lists a team policy requires.

### W9 — Do not discourage tool use

Sonnet 5.5: *"check your prompt for language that discourages tool use"*, such as
*"only use tools when strictly necessary"* or *"minimize tool calls"*. Generated
docs carry neither. An explicit team limit on a named tool stays.

## [S] How this skill is maintained

### S1 — Prescriptive instructions are a liability, not a safety margin

Fable 5: *"Skills developed for prior models are often too prescriptive for
Claude Fable 5 and can degrade output quality. Review and consider removing
older instructions if default performance is better."* On every update pass, ask
of each instruction: **does the current model already do this by default?**
Opus 5.5 migration: *"Instructions tuned for Claude Opus 5's behavior might no
longer be needed"*. Fable 5.1, on narration suppressors: *"Remove lines like that
before adding anything."* Sonnet 5.5 names one more to drop: *"hold all findings
for the final response"*.

### S2 — No runtime model branching

Do not infer the executing model from this document. Use the host's reported
capabilities and [SKILL.md's model guidance](../SKILL.md#model-guidance).
Divergences land as maintainer-facing notes plus **one default that is safe
across models** — never as `if <model> then <behavior>`.

## Divergences — recorded, not resolved

### D1 — Verification scaffolding: Opus says remove; Fable 5 added it for long runs

- Opus 5 (inherited by Opus 5.5): remove explicit verification instructions;
  *"do not use subagents to verify or double-check your own work."*
- Fable 5: *"Make self-verification explicit in long-run prompts. Separate,
  fresh-context verifier subagents tend to outperform self-critique."*
- Claude Code on Fable (code.claude.com/docs/en/model-config): *"Skip the
  verification reminders"*.
- Sonnet 5.5: at `low` it *"sometimes reports a change as done without running a
  check that exercises it"* (the guide offers a run-a-real-check paragraph); at
  `xhigh`/`max` it *"can start its own rounds of review and verification,
  sometimes with subagents"* (the guide offers a stop-and-report paragraph).
- Haiku 5.5: at `low` and `medium` it *"sometimes reports a code change as done
  without running a check"* (the guide offers a run-a-real-check paragraph).
- Fable 5.2: *"Anthropic also observed Claude Fable 5.2 using subagents to review
  its own work in an agentic coding product at higher effort levels, such as
  `xhigh` and `max`. Claude Fable 5.1 didn’t do this on the same tasks."*

Generic verification lines in project docs are expendable on all four families
(W1). Independent verifier roles remain a skill/harness design choice. The
reconciliation turns on **whose work is verified**:

| Shape | Verdict |
|-------|---------|
| A fresh-context agent verifies another writer's output | The independent checklist role applies in both generate and update mode; provide its required evidence. |
| A writer checks its own output because delegation is unavailable | Direct fallback, not independent review. Report the missing role and partial verification under stage4-verifier.md. |
| A generated project doc instructs either | Apply W1's scoped default; explicit project verification requirements remain valid. |

### D2 — Effort and thinking defaults differ per model

Fable 5.2, Fable 5.1 and Opus 5.5: adaptive thinking always on (cannot be
disabled); default effort `high` on Fable 5.2 and 5.1, `medium` on Opus 5.5.
Fable 5.2 runs at `medium` by default in Claude Code (code.claude.com/docs/en/model-config); its guide: *"rerun your
effort sweep instead of carrying over a setting you tuned on Claude Fable 5.1
or Claude Opus 5.5."* Sonnet 5: adaptive,
default `high`. Sonnet 5.5: adaptive, default `high` on the Claude API but
`medium` in Claude Code; levels are *"recalibrated"* against Sonnet 5, and
`between_tools` (accepted at `high` or below) is its lowest thinking setting.
Haiku 5.5: adaptive, on by default, default `medium`; the first Haiku with effort
levels, and `disabled` is accepted only at `high` or below. Legacy Opus 5:
default `high`. *"Effort level names don't correspond to the same amount of
thinking across models"* (Opus 5.5; Fable 5.1 says the same).

These are API/harness configuration, not project knowledge: never write effort
or thinking settings into a project doc; they go stale per model.

## Out of scope — do not import

Whatever tunes an application's runtime or system prompt rather than a
repository's documentation: output style, length and narration, progress lines,
design defaults, effort and thinking configuration, token sizing, tool
(computer-use, vision, send-to-user), subagent and API wiring, tool-choice and
batching lines, output parsing, message placement and history handling, run
control and time or context budgets, and system-prompt blocks (change/test scope,
targeted edits, compaction summaries,
search, multi-app exploration, quoting, planning, open-ended requests, chatbot
adherence, pasted content).
