---
source_urls:
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5.md
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5.md
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-4-8.md
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5.md
secondary_source_url: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md
last_upstream_check: 2026-07-25
check_interval_days: 14
---

# Model Prompting Guides — Instruction-Authoring Constraints

CLAUDE.md, AGENTS.md, and `.claude/rules/` are long-lived instruction
documents loaded in full every session — they *are* system-prompt content.
So the subset of Anthropic's per-model prompting guides that governs **how
instructions should be written** is authoritative for Stage 3 (writing) and
Stage 4 (verifying). Everything else in those guides is out of scope; see
"Out of scope" at the bottom.

**Freshness**: re-fetch `source_urls` only when `today - last_upstream_check >
check_interval_days` (`ToolSearch` `select:WebFetch` first — deferred tool).
Fetch `secondary_source_url` only when a question is cross-model rather than
tier-specific. On any fetch failure, use this file and say so in one line:
*"model-prompting 가이드 라이브 로드 실패, 캐시 사용 (last check: <date>)."*

Every rule below is tagged by consumer. Do not mix them:

- **[W]** — writing guardrail: governs what this skill **emits into generated
  project docs**. Feeds stage3-generator.md and stage4-verifier.md.
- **[S]** — skill maintenance: governs how **this skill itself** is written.
  Never emit into a project doc.

---

## [W] Guardrails for generated docs

### W1 — Never write self-verification or double-check instructions

Opus 5: *"If your prompt contains explicit verification instructions
("include a final verification step for any non-trivial task," "use a
subagent to verify"), remove them: instructions like these cause
over-verification on Claude Opus 5, and removing them reduces wasted tokens
with no loss in quality. The same applies to legacy harness scaffolding that
adds separate verification steps."* Also: *"Avoid instructing re-checks it
already performs ("double-check your answer," "re-verify before
responding")."*

Reject candidate lines of that shape. A must-run-every-time gate belongs in a
**hook**, not a documented instruction. See D1 for the Fable 5 counterpoint.

### W2 — Never command reasoning visibility, in either direction

Fable 5: instructions that *"tell the model to echo, transcribe, or explain
its internal reasoning as response text can trigger the
`reasoning_extraction` refusal category ... causing elevated fallbacks."*
Opus 5: *"If your system prompt contains a rule instructing the model not to
think or not to reason, remove it; that kind of instruction increases tag
leakage."*

Both directions harm. Reasoning visibility is an application concern
(structured thinking blocks), never a repository doc line. Asking for the
**rationale behind a decision** ("propose alternatives with reasoning") is a
different thing — that is output content, not internal-reasoning
transcription, and stays allowed.

### W3 — State every rule's scope explicitly

Sonnet 5 and Opus 4.8: *"It does not silently generalize an instruction from
one item to another, and it does not infer requests you didn't make ... If
you need Claude to apply an instruction broadly, state the scope explicitly."*

A rule with an implied scope silently narrows. Name the paths, directories,
or file types it covers — and when the scope is path-bound, prefer a
`.claude/rules/` file with `paths` over prose scoping.

### W4 — Carry the reason when the rule is not self-evident

Fable 5: the model *"tends to perform better when it understands the intent
behind a request."* One clause of *why*, only where the why is non-obvious —
not license for prose.

### W5 — Never write confidence or severity filter bars

All four guides converge: *"only report high-severity issues," "be
conservative," "don't nitpick"* are followed literally and suppress real
findings. Opus 5: *"ask it to report everything and filter in a separate pass
instead."* Applies whenever generated docs carry review or triage
instructions.

### W6 — Delegation guidance needs a bar, not a ban

Opus 5 *"delegates to subagents more readily than prior models ... it
multiplies cost and time when applied to small tasks"*; Fable 5 *"dispatches
parallel subagents more readily ... Use subagents frequently."* Both want an
explicit bar for when delegation is warranted. Emit it through the existing
conditional Workflow Orchestration block (stage3-generator.md Section B) —
never as a second, competing policy.

### W7 — Agent-memory notes: one lesson per file

Fable 5: *"Store one lesson per file with a one-line summary at the top ...
Don't save what the repo or chat history already records; update an existing
note rather than creating a duplicate; delete notes that turn out to be
wrong."* Emit only when the project actually has an agent-memory directory;
otherwise it fails the prune test.

---

## [S] How this skill is maintained

### S1 — Prescriptive instructions are a liability, not a safety margin

Fable 5: *"Skills developed for prior models are often too prescriptive for
Claude Fable 5 and can degrade output quality. Review and consider removing
older instructions if default performance is better."* This is the upstream
justification for pruning this skill's own files. On every update pass, ask
of each instruction: **does the current model already do this by default?**

### S2 — No runtime model branching

A SKILL.md cannot detect which model is executing it (SKILL.md Gotcha 4).
Divergences land as maintainer-facing notes plus **one default that is safe
across models** — never as `if <model> then <behavior>`.

---

## Divergences — recorded, not resolved

### D1 — Verification scaffolding: Opus 5 says remove, Fable 5 says add

- Opus 5: remove explicit verification instructions; *"do not use subagents
  to verify or double-check your own work."*
- Fable 5: *"Make self-verification explicit in long-run prompts. Separate,
  fresh-context verifier subagents tend to outperform self-critique."*

The reconciliation that holds for both turns on **whose work is verified**:

| Shape | Verdict |
|-------|---------|
| An agent verifies **another agent's** output | Writer-verifier — Opus 5 endorses it (*"effective writer-verifier patterns"*). Generate mode Stage 3 → Stage 4 sits here; keep as is. |
| An agent verifies **its own** output | What Opus 5 warns about. Update mode U3 (orchestrator edits) → Stage 4 sits here; see update-mode.md U3. |
| A generated project doc instructs either | Never write it (W1). Use a hook. |

### D2 — Effort and thinking defaults differ per tier

Opus 5 (thinking on, default `high`), Sonnet 5 (adaptive thinking on),
Opus 4.8 (thinking off unless adaptive is set), Fable 5 (adaptive only).
These are API/harness configuration, not project knowledge: never write
effort or thinking settings into a project doc — they go stale per tier and
fail the staleness check.

---

## Out of scope — do not import

Verbosity and narration tuning, effort sweeps, design/frontend defaults,
computer-use resolutions, tokenizer and `max_tokens` sizing, the
send-to-user tool, refusal fallback wiring. These tune an application's
runtime, not a repository's documentation.
