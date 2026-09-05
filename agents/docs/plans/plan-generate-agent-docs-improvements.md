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
