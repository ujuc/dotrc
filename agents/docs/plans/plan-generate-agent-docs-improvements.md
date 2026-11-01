# Plan: generate-agent-docs-improvements

## Goal

Improve the reliability of `generate-agent-docs` without changing project documentation during this review. The user's `generate-agent-doc` refers to the existing plural-named skill.

Working directory: /Users/ujuc/.config/dotrc/agents. Implementation is pending user review. Preserve surgical updates and concise documentation; prioritize conflicting instructions and false verification claims over cosmetic shortening.

## Approach

1. P0: make cache ownership, selected targets, and reference dependencies consistent.
2. P0: supply evidence to the checklist verifier and define honest final verification states.
3. P1: reuse existing authorization, support available harness capabilities, and distinguish upstream guidance from local policy.
4. P1: replace placeholder evaluation coverage with named behavior scenarios.

Use AGENTS.md as the primary source for shared Claude/Codex project instructions. Create or update shared content there first, then create or update CLAUDE.md with an initial `@AGENTS.md` import and only Claude-specific additions. Do not duplicate shared rules or place general project instructions in CLAUDE.md. If no Claude-specific additions are needed, the import alone is sufficient.

For the user's joint Claude/Codex workflow, AGENTS.md and CLAUDE.md form the default target pair; this preference already authorizes including the prerequisite AGENTS.md in the planned generation workflow. When updating existing documents, move shared instructions from CLAUDE.md into AGENTS.md while preserving their meaning and existing user edits. Finish shared referenced documents and AGENTS.md before writing the importing CLAUDE.md. A later explicit file restriction still takes precedence: if CLAUDE.md alone is selected and AGENTS.md is missing, explain the required prerequisite and resolve that scope conflict instead of producing a standalone fallback or broken import. Existing AGENTS.md-only updates do not require touching CLAUDE.md when its import remains valid.

Keep the blind reviewer limited to properties observable from supplied documentation. Repository facts, approved team exceptions, and preservation of original text belong to the evidence-bearing checklist verifier. Blind findings requiring unavailable context are UNVERIFIED, not grounds for automatic deletion.

## Acceptance Criteria

No active contract

Proposed completion checks for this change:

- C1: project-doc runs never modify global skill references or maintenance dates.
- C2: normalize the shared AGENTS.md / Claude-specific CLAUDE.md target pair and dependencies before mode routing. Create/update AGENTS.md first; CLAUDE.md imports it and contains only Claude-specific additions. Shared rules have a single source, existing content receives surgical edits, and references resolve. Honor any later explicit file restriction without silently expanding it.
- C3: prior explicit authorization remains effective; ask again only for material ambiguity, scope expansion, destructive changes, or applicable explicit approval requirements.
- C4: available native tools are mapped by capability; unavailable independent review is reported accurately.
- C5: verification receives confirmed facts, decisions, original content/diff, selected scope, and the guidance actually used; no unsupported PASS or policy deletion.
- C6: official recommendations, model-specific findings, and local defaults are separately labeled; explicit project requirements survive default pruning.
- C7: all behavior scenarios below have recorded evidence; mock/structural success is never reported as behavioral success.

Exclusions: no project-doc generation, runtime-state edits, global settings changes, SOUL changes, workflow-contract changes, new harness directory, commit, push, or periodic skill-improver execution in this planning task.

## Workflow Sources

- Product Spec: None
- Sprint Contract: None
- Research: None

## Reference Implementations

All relative paths in this plan resolve beneath /Users/ujuc/.config/dotrc/agents.

- `claude/skills/generate-agent-docs/SKILL.md:74` forbids incidental cache writes; `claude/skills/generate-agent-docs/references/claude-code-best-practices.md:29` directs immediate cache updates. These conflict.
- `claude/skills/generate-agent-docs/SKILL.md:98` routes before target selection at line 117; `references/stage3-generator.md:74` forbids writes outside selected targets while line 142 mandates an AGENTS.md import. Reference paths in this bullet are beneath the target skill.
- `claude/skills/generate-agent-docs/references/update-mode.md:118` asks for scope selection; its U3 section asks again before every file.
- `claude/skills/generate-agent-docs/references/stage4-verifier.md:20` passes only target paths and update mode, but line 41 requires confirmed facts and line 176 requires original-change evidence.
- `claude/skills/generate-agent-docs/references/stage4-verifier.md:117` permits fast-mode review skipping; `claude/skills/generate-agent-docs/references/eval-criteria.md:55` does not represent that exception.
- `claude/skills/generate-agent-docs/references/claude-code-best-practices.md:72` quotes a per-file size target; lines 75–81 strengthen it to a combined hard cap.
- `claude/evals/generate-agent-docs/eval.yaml:9` uses a mock executor. Its three task files test keywords rather than edits, references, preservation, or verification evidence.
- `claude/skills/generate-skills/scripts/validate-skill:15` invokes the existing Rust validator; `tools/skill-core/src/validate.rs:130` performs structural validation.
- `claude/agents/waza-runner.md:10` owns waza invocation; missing prerequisites produce no-score skips.
- `AGENTS.md:6` requires structural validation and skill-improver after future skill edits. Read the applicable authoring/maintenance skills during implementation; do not infer consent to the separate periodic maintenance prompt.

Upstream checked during this review:

- [Claude Code memory guidance](https://code.claude.com/docs/en/memory): the 200-line statement is a per-file recommendation; imports still add context. A combined hard cap is this skill's policy, not an official hard limit.
- [AGENTS.md guidance](https://agents.md/): supports build/test commands and nested AGENTS.md files. The skill's stricter pruning rules are local choices.
- The two Claude Code `.md` URLs failed with unsupported content type in the available web tool; their HTML counterparts loaded. Add an equivalent-fetch fallback before declaring the source unavailable.

## File Changes

Existing skill files to edit:

- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/SKILL.md
- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/references/update-mode.md
- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/references/claude-code-best-practices.md
- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/references/agents-md-best-practices.md
- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/references/stage1-analyzer.md
- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/references/stage3-generator.md
- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/references/stage4-verifier.md
- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/references/eval-criteria.md
- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/references/model-prompting-guides.md
- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/references/context-engineering-claude5.md
- /Users/ujuc/.config/dotrc/agents/claude/skills/generate-agent-docs/references/tdd-agent-loop.md

Existing evaluation files to revise:

- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/eval.yaml
- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/tasks/positive-trigger-1.yaml
- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/tasks/positive-trigger-2.yaml
- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/tasks/negative-trigger-1.yaml

New test specifications:

- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/behavior-cases.md
- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/tasks/target-scope.yaml
- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/tasks/cache-ownership.yaml
- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/tasks/authorization.yaml
- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/tasks/tool-fallback.yaml
- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/tasks/verification-evidence.yaml
- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/tasks/policy-preservation.yaml
- /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/tasks/workflow-boundary.yaml

The Markdown behavior specification records exact fixture contents, expected write sets, decision traces, and artifact assertions. Use supported runner/grader schemas only; do not invent fields or silently treat text assertions as filesystem verification. If artifact assertions are unavailable, run documented scenarios in temporary fixtures through the active harness and record the limitation.

## Code Snippets

Proposed verifier input contract (prompt fields, not a new runtime API):

```text
Selected targets and authorized changes:
Confirmed facts with source locations:
User decisions and preserved exceptions:
Original contents and proposed/final diff:
Effective guidance and source status:
Files to verify:
```

Report states: PASS, FAIL, SKIP, UNVERIFIED. Required FAIL or UNVERIFIED prevents an overall verification PASS. An explicitly skipped blind review is disclosed as partial verification.

Retain the three-pass checklist limit. After blind-review edits, perform a bounded check of changed references, scope, size, and affected criteria; do not start another open-ended review cycle.

## Dependencies & Ordering

| Step | Consumes | Produces | Predecessors / parallel safety |
| --- | --- | --- | --- |
| 1 | Existing skill, runner contract, seven criteria | behavior-cases.md and supported evaluation design | First; read-only source checks may run independently |
| 2 | C1–C3, target and authorization cases | AGENTS.md-first routing, cache ownership, authorization rules | 1; sole writer due to shared SKILL.md; shared referenced docs → AGENTS.md → importing CLAUDE.md |
| 3 | C4/C6, upstream evidence, fallback/preservation cases | Capability mapping and scoped policy defaults | 2; shares generation/verifier references |
| 4 | C5, evidence cases, decisions from 2–3 | Evidence-aware verification and final states | 3; sole writer |
| 5 | Final behavior contracts, supported grader schema | Updated suite and evaluation evidence | 4; independent evaluation may read frozen changes |
| 6 | Structural and behavior results | Final review handoff and managed archival when applicable | 5; implement-plan owns execution/archive |

## Risk Assessment

- These skill files affect user-global behavior across harnesses immediately. Edit repository paths only.
- Migrating shared rules from existing CLAUDE.md into AGENTS.md can lose exceptions or change meaning. Preserve existing constraints and verify shared coverage through AGENTS.md plus nonduplicating Claude-specific additions. Never substitute a standalone CLAUDE.md for the agreed shared source.
- Moving common rules to Claude-only rules/ merely to meet a size target can hide instructions from other harnesses; retain common content in shared documents.
- Model/research findings are context-dependent. Preserve explicit team testing and safety requirements; do not upgrade an unverified cached claim into a universal prohibition.
- A blind reviewer cannot infer user approval or repository facts from documentation alone. Route such questions to the evidence verifier.
- Mock evaluations may not exercise tools. Require transcripts/artifact evidence for P0 cases, or report behavior verification incomplete.
- New tests must use disposable fixtures and cannot write live global documentation or maintenance state.

## Open Questions

No user decision blocks this plan. The user explicitly selected AGENTS.md-first shared management for Claude and Codex, followed by Claude-specific additions in CLAUDE.md. This replaces the earlier standalone CLAUDE.md proposal. Reuse of prior authorization and document-only blind review remain unchanged.

Implementation must confirm the installed runner's support for real tool execution and artifact graders before selecting evaluation configuration. This is a technical check, not grounds for a speculative permission request. If unavailable, retain the suite as scaffolding and record active-harness fixture results separately.

## Todo

Verification alias V: from /Users/ujuc/.config/dotrc, run
`bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/generate-agent-docs` and `git diff --check`.

Verification alias E: dispatch the documented waza-runner role with
`eval /Users/ujuc/.config/dotrc/agents/claude/evals/generate-agent-docs/eval.yaml --label candidate`.
Do not invoke waza directly. E alone is insufficient while the executor is mock.

- [x] 1 — Create `claude/evals/generate-agent-docs/behavior-cases.md`; inspect `claude/agents/waza-runner.md` and supported graders. Specify cases for all C1–C7 before edits. Verification: `git diff --check`; review each case against its criterion and required artifact evidence.
- [x] 2 — Edit SKILL.md, update-mode.md, claude-code-best-practices.md, and stage3-generator.md under the target skill. Tests: `tasks/target-scope.yaml`, `tasks/cache-ownership.yaml`, `tasks/authorization.yaml` under the target eval. Include empty-repository generation of AGENTS.md before CLAUDE.md; migration of shared rules from existing CLAUDE.md; an existing AGENTS.md plus missing CLAUDE.md; import-only CLAUDE.md when no Claude-specific rules exist; explicit CLAUDE-only restriction with missing AGENTS.md; mixed new/existing files; unrelated existing targets; approved update; and fetch drift with unchanged global cache. Verification: V + E + matching behavior-cases.md fixture transcripts/diffs.
- [x] 3 — Edit SKILL.md and stage1-analyzer.md, stage3-generator.md, claude-code-best-practices.md, agents-md-best-practices.md, model-prompting-guides.md, context-engineering-claude5.md, tdd-agent-loop.md under the target references. Tests: `tasks/tool-fallback.yaml`, `tasks/policy-preservation.yaml`. Cover missing tools, HTML fetch fallback, explicit TDD/nondefault conventions, and common rules retained outside Claude-only files. Verification: V + E + corresponding fixture evidence.
- [x] 4 — Edit SKILL.md, references/stage4-verifier.md, references/update-mode.md, and references/eval-criteria.md. Tests: `tasks/verification-evidence.yaml`, `tasks/workflow-boundary.yaml`. Cover missing fact evidence, unchanged sentinel text, shared-instruction coverage in AGENTS.md, no duplicated shared rules or general project content in CLAUDE.md, valid import-first CLAUDE.md, fast skip, persistent FAIL, post-review broken reference, active implementation, and legacy state. Verification: V + E + corresponding fixture evidence.
- [x] 5 — Update eval.yaml and the three existing trigger tasks; add all seven named behavior tasks. Include README-only and skill-review anti-triggers. Verify every C1–C7 maps to a scenario and evidence; run V and E, and record mock/skip limitations separately.
- [x] 6 — After approved implementation, follow generate-skills authoring guidance and required skill validation/skill-improver workflow. No periodic maintenance was authorized in this review. Verification: V, scenario evidence review, `git status --short`, and implement-plan's final verification/archive protocol.

## Review Evidence

- Branch: main; initial tracked worktree clean.
- No active spec, sprint, research, plan, or legacy workflow was found in the working directory or parent repository root.
- Installed workflow-hooks contract identifies annotate-plan as sole plan writer and implement-plan as executor.
- Existing validate-skill run: PASS; all 12 references resolve; SKILL.md body 342 lines within 500.
- Initial dependency download failed under the sandbox; an approved retry completed validation.
- No behavioral eval or project-document generation was run. No target skill file was modified.

## Implementation Result

Completed the approved AGENTS.md-first implementation on main, without a commit.
All six implementation items received independent verification. Final structural
validator PASS: 12 reference paths, 333 body lines. Shared content migration,
import-only output and sentinel preservation were checked in temporary files;
independent pair-empty writes occurred AGENTS.md then CLAUDE.md. Fresh-context
A–E interpretation checks passed; the original missing-evidence and completion
state defects are resolved. Full Claude/Codex end-to-end pipeline execution was
not performed and remains UNVERIFIED, not inferred from these checks.

Waza parsed all 10 candidate tasks without errors, but mock keyword scoring
(4/10) is not behavior evidence. The baseline had 3 tasks, so raw score changes
are not a regression metric. Actual fixture and decision evidence are separate.
Targeted skill-improver validation passed with no additional behavioral proposals;
its privacy-sensitive report remains in /private/tmp/skill-improver-Twig4e8c.

Final independent review found and then confirmed repairs to three stale
references; W3 now explicitly keeps shared path-scoped rules in AGENTS.md.
No applicable FAIL remains in the implementation verification. Source settings,
SOUL, workflow contract and production project documents were not changed.

## Next Updates (2026-11-01)

Status: N1-N7 applied on 2026-11-01. Final result on `claude-sonnet-5-5`: 39/39
tasks before, 37/39 after, 31/39 without the skill, 116,791 to 112,070 tokens per
run, `score` exit 0. The eval folder is
`~/.claude/data/skill-diet/generate-agent-docs-20261101`. Timeouts in earlier
rounds came from the `ls` alias (`eza --git`) stalling the Bash tool, so the adapter
now runs Claude with `SHELL=/bin/bash`.
Findings come from the 2026-11-01 skill-improver audit and reference refresh. The sections above record the finished 2026-10 work and
still name removed pieces (`claude/agents/waza-runner.md`, annotate-plan,
implement-plan, workflow hooks); use the `waza` skill launcher instead.

| Step | Change | Why first / depends on |
| --- | --- | --- |
| N1 | Replace the mock suite in `claude/evals/generate-agent-docs/eval.yaml` with a real executor and record a 3-trial baseline through `claude/skills/waza/scripts/waza-run.sh`. Suite authoring goes through `generate-skills`. | Every later step needs a regression guard; the mock engine never loads SKILL.md, so its scores prove nothing. |
| N2 | Fix `SKILL.md:19-20`: Pi has no workflow hooks. Say Pi reads only its untracked `~/.pi/agent/AGENTS.md`. | N1 |
| N3 | Point cache maintenance at `/generate-skills <skill> 업데이트`: `SKILL.md:107-108`, `references/model-prompting-guides.md:53`, and `generate-skills/references/openai-models.md` Freshness. `skill-improver` has no cache step. | N1 |
| N4 | Correct the `/init` statements in `SKILL.md:85-89` and `references/claude-code-best-practices.md:257-260`. `/init` is reachable through the Skill tool (skills docs: *"A few built-in commands are also available through the Skill tool, including `/init`"*), so "user-only" is wrong; decide whether the skill should run it or keep consuming its output. The quoted *"then refine over time"* is gone upstream; the closest wording is *"Run `/init` to generate a starter `CLAUDE.md`, then `/memory` to refine it."* | N1 |
| N5 | Apply the N5 checklist below: add checks 9 and 10 to `references/roles/verifier.md`, change "eight-item checklist" in `references/stage4-verifier.md`, mirror both checks in `references/stage3-generator.md` Common Writing Rules so the writer meets them first, map them in `references/eval-criteria.md`, and add a Red Flags row in `SKILL.md`. The prune test and include/exclude table in `references/claude-code-best-practices.md` were already updated on 2026-11-01. | N1; add one fixture per row of the stop-list to the N1 suite. |
| N6 | Add three user-selected authoring rules. (a) Promote the tool-discouraging lines from S1 to a [W] rule: generated docs must not carry "only use tools when strictly necessary" or "minimize tool calls" (Sonnet 5.5 guide, "check your prompt for language that discourages tool use"). (b) In `references/stage3-generator.md`, ask for language context when a repository uses a lesser-known language (Fable 5.1 guide: *"Give the model context about what the language is and how it works"*). (c) In `references/stage3-generator.md`, add the general techniques from the prompting best-practices page: the colleague test, 3-5 examples, and XML tags for mixed content. | N1; each rule needs an eval case in the N1 suite. |
| N7 | Run the first full diet (`/generate-skills generate-agent-docs 다이어트`). The skill is 22 KB with no diet baseline; the `diet-baseline` waza JSONs from 2026-10-28 predate N1, so do not reuse them. | Last, so the diet cuts settled text and N1 guards it. |

Verification per step: run `validate-skill` and `skill-diet-eval check` on the
skill, rerun the N1 suite with the same `--trials` against the baseline, then
run a targeted `skill-improver generate-agent-docs`. Put SKILL.md's size before
and after in the commit message.

Read this suite by trial pass rate, not weighted score. Text graders score the
share of matching patterns, so the skill and no-skill runs differ by only 0.04
in weighted score, under the launcher's 0.1 regression threshold. The N1 baseline
on `claude-haiku-5-5` is 28/33 trials with the skill and 13/33 without it
(`generate-agent-docs-haiku-baseline-*.json`, `generate-agent-docs-haiku-control-*.json`
under `~/.claude/data/waza/results/`). The control is a scratch copy of the suite
with `inject_skill_body: false`.

Open findings from the grader work, for N7 or a later step:

- `SKILL.md:320` does not say what form a surviving team TDD decision takes; runs
  split between keeping the mandate and rewording it as an outcome.
- The body hands review and README requests to "their owning workflow" without
  naming one.

### N5 checklist

User decisions from 2026-11-01: the gate is upstream's two questions with no
local rewording, because a simple test stays stable; the stop-list becomes
verifier criteria; rules that cannot have exceptions get an enforcement
proposal. Add this text to `references/roles/verifier.md` after check 8.

```text
9. **Prune test and stop-list**: every added or retained line passes the prune
   test in claude-code-best-practices.md: if Claude could find it by reading the
   code and would actually go and look, it is cut. FAIL a line that matches a
   stop-list row. A line preserved by a user decision or team requirement is
   PASS with a note, never removed.

   | Stop-list row | Fails | Still allowed |
   | --- | --- | --- |
   | Context anxiety | Telling Claude to conserve or manage the context window | `/clear` between unrelated tasks as user guidance |
   | Emphasis | IMPORTANT, ALL CAPS or MUST used to make a line stick | The same rule in plain words |
   | Subagents for context | Delegating to protect the context window | Parallel work, noisy output, independent review |
   | Subagents for quality | Delegating to get a better answer | A fresh reviewer that has not seen the reasoning |
   | Thinking phrases | "think hard", "think harder", "be thorough" | Effort settings outside the document |
   | Persistence lines | "keep going", "loop until done", "don't be lazy" | A concrete check that must pass |
   | Repo description | Architecture, file layout or dependency summaries Claude can read | Decisions, misleading code, what the repo cannot show |

10. **Enforcement fit**: a line stating a rule with no exceptions (a path never
    edited, a file never read, a step that must always run) gets a recommendation
    for a hook, deny rule or managed setting, naming which. Keep the line until an
    authorized replacement exists. A preference with exceptions stays in the
    document. This check reports a recommendation; it fails only when a required
    no-exception rule was dropped without a replacement. SKIP when no such line
    exists.
```

Each row comes from upstream's "What you can stop doing" table, so when that
table changes, update this check with it.
