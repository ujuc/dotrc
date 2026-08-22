# Unified Workflow Contract and Superpowers Integration — Design

Date: 2026-08-22
Status: Implemented and verified

## 1. Context

The shared Rust `workflow-hooks` runtime and the managed skills currently describe
different workflow surfaces. Hooks restore and archive `.research/` and `.plans/`,
while the planning pipeline also uses `spec.md` and `.sprint/contract.md`. The
`multi-agent-orchestrator` introduces a second `.harness/` hierarchy that the
hooks do not restore or archive.

The installed Superpowers 6.3.0 plugin creates additional specifications, plans,
execution ledgers, worktrees, and branch-finishing state when its complete
workflow is used. Those mechanisms overlap the managed `spec-planner`,
`annotate-plan`, and `implement-plan` skills and can conflict with repository
instructions that require direct work on `main`.

The workflow needs one harness-neutral contract shared by Claude, Codex, Amp,
Pi, the Rust runtime, and portable managed skills.

## 2. Goals

- Define one machine-readable workflow contract under `agents/`.
- Remove `.harness/` from the active managed workflow.
- Give every artifact type one writer and one lifecycle.
- Restore all active workflow context consistently across harnesses.
- Archive the exact specification, contract, research, plan, and final evaluation
  used by a completed workflow.
- Keep managed plan creation and execution portable across harnesses.
- Reuse stable Superpowers planning principles without creating a second plan or
  execution state machine.
- Invoke Superpowers only for optional, cross-cutting engineering disciplines
  when the active harness provides them.

## 3. Non-Goals

- Modifying files inside the installed Superpowers plugin cache.
- Reimplementing Superpowers' SDD ledger, branch finishing, or worktree manager.
- Automatically moving or deleting existing `.harness/` directories.
- Supporting multiple simultaneous active workflows in one project checkout.
- Making every harness expose lifecycle events that it does not natively support.
- Overriding repository-specific Git instructions with a global workflow policy.

## 4. Source of Truth

Add `agents/workflow-contract.json` as the canonical machine-readable contract.
It owns:

- schema and contract versions;
- active artifact paths and filename patterns;
- writer and reader ownership;
- context-restoration eligibility;
- transient state paths;
- archive destinations and cleanup behavior;
- the single plan writer and execution engine;
- optional discipline providers and their managed fallbacks;
- the `skill-improver` cadence interval and timestamp path;
- the pinned Superpowers version from which managed principles were adapted.

The Rust binary embeds this file at build time and exposes the effective embedded
value through `workflow-hooks contract`. Skills obtain the current contract from
that command rather than referencing a path outside the `claude/` tree. This
preserves the `claude/` symlink boundary and ensures that every harness observes
the same contract as the installed binary.

The contract does not contain prose instructions or plan contents. It defines
interfaces, ownership, and paths; skills remain responsible for stage-specific
reasoning.

### 4.1 Contract shape

The initial schema has these top-level sections:

```json
{
  "schema_version": 1,
  "contract_version": "1.0.0",
  "workflow": {
    "single_active": true,
    "plan_writer": "annotate-plan",
    "execution_engine": "implement-plan",
    "git_policy": "project-instructions"
  },
  "artifacts": {},
  "transient": {},
  "archive": {},
  "maintenance": {},
  "superpowers": {}
}
```

Rust validates all required sections, relative paths, filename patterns, unique
writers, and archive destinations before executing a policy action. Invalid
embedded contracts are fatal for the requested policy action and produce a clear
diagnostic.

## 5. Canonical Artifact Lifecycle

One project checkout has at most one active workflow:

```text
spec.md
  -> .sprint/contract.md
  -> .research/research-*.md
  -> .plans/plan-{feature}.md
  -> implementation and evaluation
  -> docs/{specs,contracts,research,plans,reports}/
```

Multi-sprint work runs as sequential workflow cycles. The current cycle must be
completed or explicitly abandoned before the next cycle creates a new active
specification or contract.

### 5.1 Active durable inputs

| Artifact | Writer | Active path |
| --- | --- | --- |
| Product specification | `spec-planner` | `spec.md` |
| Sprint contract | `sprint-contract-negotiator` | `.sprint/contract.md` |
| Research | `deep-read` | `.research/research-*.md` |
| Implementation plan | `annotate-plan` | `.plans/plan-{feature}.md` |

`annotate-plan` records exact associations in a mandatory section:

```markdown
## Workflow Sources
- Product Spec: `spec.md` or `None`
- Sprint Contract: `.sprint/contract.md` or `None`
- Research:
  - `.research/research-example.md`
```

The Rust archive policy parses this section. It accepts `None` for workflows that
legitimately do not use a product specification, sprint contract, or research.

### 5.2 Transient implementation state

| Purpose | Path |
| --- | --- |
| Implementation flag | `.plans/.implementing` |
| Item verification | `.plans/.verify-*.md` |
| Blocker report | `.plans/.blocker-*.md` |
| Debug report | `.plans/.debug-*.md` |
| QA round | `.plans/.qa-{feature}-r{round}.md` |
| Design round | `.plans/.design-{feature}-r{round}.md` |
| Synthesized evaluation | `.plans/.evaluation-{feature}-r{round}.md` |
| Context handoff | `.plans/.handoff-{feature}.md` |
| Annotation baseline/cycle | Existing `.plans/.plan-*` sidecars |

`qa-evaluator` writes only QA reports. `frontend-design-evaluator` writes only
design reports. `multi-agent-orchestrator` is the sole writer of synthesized
evaluation reports. This preserves the one-writer invariant.

### 5.3 Context restoration

`workflow-hooks context` reads the embedded contract and reports concise paths,
titles, and the active phase for:

- the active specification and sprint contract;
- active research and implementation plan;
- the latest synthesized evaluation;
- the current handoff and implementation state.

Claude and Codex restore this after compact-session start. Pi restores it through
its compaction/context events. Amp receives the same concise context at each agent
start because it has no equivalent compaction event.

### 5.4 Completion and archive

After every plan item, final verification, and every selected evaluator pass,
`implement-plan` invokes `workflow-hooks archive` with the active plan, verified
item slugs, and optional final synthesized report.

The Rust runtime performs an all-or-nothing preflight before moving anything:

1. Validate the plan path and feature slug.
2. Parse and validate every `Workflow Sources` entry.
3. Validate the optional final report and its writer-owned pattern.
4. Ensure every source exists and every destination is absent.
5. Create destination directories only after successful preflight.
6. Move associated files and roll back prior moves if a later move fails.
7. Remove only workflow-owned transient files for the completed feature.

| Active artifact | Archive destination |
| --- | --- |
| `spec.md` | `docs/specs/spec-{feature}.md` |
| `.sprint/contract.md` | `docs/contracts/contract-{feature}.md` |
| `.research/research-*.md` | `docs/research/` preserving names |
| `.plans/plan-{feature}.md` | `docs/plans/` preserving names |
| Final synthesized evaluation | `docs/reports/report-{feature}.md` |

Failure, cancellation, RESET, destination collision, missing source, or failed
verification leaves active artifacts in place. Existing `.harness/` directories
are reported as legacy state but are never moved, overwritten, or deleted
automatically.

## 6. Managed Skill Ownership

| Stage | Owner | Contract change |
| --- | --- | --- |
| Product scope | `spec-planner` | Always writes canonical `spec.md` |
| Acceptance criteria | `sprint-contract-negotiator` | Uses only `.sprint/` |
| Research | `deep-read` | Uses canonical research pattern |
| Plan creation and annotation | `annotate-plan` | Sole plan writer; writes `Workflow Sources` |
| Implementation | `implement-plan` | Sole execution engine and archive caller |
| Functional QA | `qa-evaluator` | Writes only QA round report |
| Design QA | `frontend-design-evaluator` | Writes only design round report |
| Pipeline coordination | `multi-agent-orchestrator` | Uses canonical artifacts; no `.harness/` |
| Maintenance | `skill-improver` | Uses cadence values from the contract |

`multi-agent-orchestrator` coordinates existing skills; it does not create a
parallel specification, plan, handoff tree, or evaluation report owner.

## 7. Superpowers Integration

The managed pipeline does not invoke Superpowers skills that own competing
artifacts or execution state.

### 7.1 Adapt, do not invoke

Stable, harness-neutral principles are adapted and version-pinned:

- From `brainstorming@6.3.0`: spike/bounded/architectural classification, a
  single approval gate scaled to task size, scope decomposition, and design
  self-review.
- From `writing-plans@6.3.0`: no placeholders, exact file paths, explicit
  consumes/produces interfaces, test commands, small verification units, full
  spec/contract coverage, and type/signature consistency review.

`spec-planner` and `annotate-plan` own the resulting behavior. They do not create
`docs/superpowers/` artifacts or invoke the Superpowers execution handoff.

### 7.2 Invoke as optional disciplines

When the active harness provides them, `implement-plan` may invoke:

- `test-driven-development` for behavior-changing implementation;
- `systematic-debugging` after a reproducible failure;
- `verification-before-completion` before any successful state transition;
- `requesting-code-review` and `receiving-code-review` for independent review;
- `dispatching-parallel-agents` for genuinely independent domains.

These skills may produce evidence but do not own managed plan or workflow state.
When unavailable, `implement-plan` applies equivalent concise fallback invariants
defined in its own procedure. Optional discipline availability never changes the
canonical artifact paths.

### 7.3 Excluded from the managed pipeline

- `writing-plans`
- `subagent-driven-development`
- `executing-plans`
- `using-git-worktrees`, unless project instructions explicitly permit it
- `finishing-a-development-branch`

The exclusions prevent duplicate plans, `.superpowers/sdd` state, competing
execution controllers, and branch/PR behavior that can violate project policy.
Repository instructions always take precedence over generic plugin workflows.

`skill-improver` compares the installed Superpowers version with the adaptation
pin. A mismatch produces a review notice; it never copies or merges plugin text
automatically.

## 8. Migration

The migration updates managed sources only:

1. Add and validate `agents/workflow-contract.json`.
2. Embed and expose the contract in the Rust runtime.
3. Expand context and archive policies to the canonical lifecycle.
4. Refactor pipeline skills and references to remove `.harness/`.
5. Update evaluator ownership and report paths.
6. Add shared cross-harness priority guidance under `agents/rules/`.
7. Update the skill catalog and prior hook design documentation.

No automatic migration of project-local `.harness/` data occurs. A managed
pipeline encountering it stops before creating conflicting canonical artifacts,
reports the legacy files, and asks the user to preserve, manually translate, or
remove them.

## 9. Error Handling

- Missing or malformed contracts fail closed for state-changing actions.
- Context and annotation notices remain advisory when contract loading fails.
- Unknown schema versions produce an upgrade diagnostic.
- A missing optional Superpowers provider selects the managed fallback.
- Multiple active plans, an existing active contract, or legacy `.harness/`
  artifacts block creation of another active workflow.
- Archive operations never overwrite destination files.
- Partial archive moves are rolled back before returning failure.

## 10. Verification

1. Validate JSON structure, path safety, ownership uniqueness, and schema version
   in Rust unit tests.
2. Snapshot `workflow-hooks contract` output from the embedded contract.
3. Expand black-box hook tests for spec, contract, reports, handoff, legacy
   `.harness/` detection, complete archive, rollback, and collisions.
4. Run Rust formatting, tests, Clippy, and a release build.
5. Validate every changed managed skill with `validate-skill`.
6. Run `skill-improver` after the skill changes.
7. Verify no active pipeline skill or current catalog references `.harness/` or
   `docs/superpowers/plans/` as a managed output.
8. Load Claude/Codex hook configuration, the Amp plugin, and the Pi extension.
9. Install the verified Rust binary and rerun the installed-binary contract suite.
10. Run `git diff --check` and inspect the final diff.

## 11. Rollout

1. Land the contract and Rust runtime changes together so the binary never embeds
   an undefined schema.
2. Land managed skill and documentation changes against that contract.
3. Install the rebuilt binary at `~/.local/bin/workflow-hooks`.
4. Verify all four harness loaders and one end-to-end canonical workflow fixture.
5. Leave existing project `.harness/` directories untouched and report them on
   first managed use.
