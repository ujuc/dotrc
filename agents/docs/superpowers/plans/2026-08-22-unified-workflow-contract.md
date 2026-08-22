# Unified Workflow Contract Implementation Plan

Status: Implemented and verified (2026-08-22)

> **For managed execution:** Use `implement-plan`. Superpowers planning/execution controllers are excluded; optional TDD, debugging, verification, review, and parallel-dispatch disciplines may assist the canonical owner. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make one machine-readable contract govern workflow artifacts, hooks, managed planning skills, archival, and optional Superpowers integration across Claude, Codex, Amp, and Pi.

**Architecture:** `agents/workflow-contract.json` is embedded in the Rust `workflow-hooks` binary and exposed through a `contract` command. Hooks consume the embedded contract for cadence, artifact detection, context restoration, and atomic archival; managed skills query the same binary and retain one writer per artifact. Superpowers planning and execution controllers remain outside the managed pipeline, while stable planning principles and optional engineering disciplines are integrated explicitly.

**Tech Stack:** Rust 2024 (MSRV 1.85), serde/serde_json, JSON, POSIX shell contract tests, Markdown Agent Skills.

**Spec:** `agents/docs/superpowers/specs/2026-08-22-unified-workflow-contract-design.md`

## Global Constraints

- Work directly on `main`; do not create branches or PRs.
- Do not modify `agents/claude/settings.json`, `agents/amp/settings.json`, or installed plugin cache files.
- Keep Amp and Pi adapters limited to native event/result translation; they require load checks but no source changes.
- Keep `agents/workflow-contract.json` harness-neutral and free of machine-specific absolute paths.
- Preserve existing project artifacts under `.harness/`; report them but never migrate or delete them automatically.
- Keep managed skill bodies and technical documentation in English.
- `annotate-plan` remains the only plan writer and `implement-plan` the only managed execution engine.
- Do not add `docs/superpowers/` or `.superpowers/sdd/` as active managed workflow state.
- Repository Git instructions override generic Superpowers worktree, branch, commit, and PR behavior.
- Do not commit implementation changes unless the user explicitly requests a commit after review.

---

### Task 1: Add and Embed the Canonical Contract

**Files:**
- Create: `agents/workflow-contract.json`
- Create: `agents/tools/workflow-hooks/src/contract.rs`
- Modify: `agents/tools/workflow-hooks/src/main.rs:1-56,588-608`
- Modify: `agents/tools/workflow-hooks/Cargo.toml`
- Modify: `agents/tools/workflow-hooks/Cargo.lock`

**Interfaces:**
- Consumes: the checked-in JSON contract at Rust compile time.
- Produces: a validated `WorkflowContract`, path/template lookup helpers, and `workflow-hooks contract` JSON output without requiring stdin.

- [ ] **Step 1: Add the machine-readable contract fixture**

Create `agents/workflow-contract.json` with this exact initial ownership and lifecycle:

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
  "artifacts": {
    "spec": {
      "path": "spec.md",
      "writer": "spec-planner",
      "context": true
    },
    "contract": {
      "path": ".sprint/contract.md",
      "writer": "sprint-contract-negotiator",
      "context": true
    },
    "research": {
      "pattern": ".research/research-*.md",
      "writer": "deep-read",
      "context": true
    },
    "plan": {
      "pattern": ".plans/plan-*.md",
      "writer": "annotate-plan",
      "context": true
    },
    "qa_report": {
      "pattern": ".plans/.qa-{feature}-r{round}.md",
      "writer": "qa-evaluator",
      "context": false
    },
    "design_report": {
      "pattern": ".plans/.design-{feature}-r{round}.md",
      "writer": "frontend-design-evaluator",
      "context": false
    },
    "evaluation_report": {
      "pattern": ".plans/.evaluation-{feature}-r{round}.md",
      "writer": "multi-agent-orchestrator",
      "context": true
    },
    "handoff": {
      "pattern": ".plans/.handoff-{feature}.md",
      "writer": "multi-agent-orchestrator",
      "context": true
    }
  },
  "transient": {
    "implementation_flag": ".plans/.implementing",
    "verification_pattern": ".plans/.verify-*.md",
    "blocker_pattern": ".plans/.blocker-*.md",
    "debug_pattern": ".plans/.debug-*.md",
    "plan_baseline_pattern": ".plans/.plan-*.md.prev",
    "plan_cycle_pattern": ".plans/.plan-*.cycle"
  },
  "archive": {
    "spec": "docs/specs/spec-{feature}.md",
    "contract": "docs/contracts/contract-{feature}.md",
    "research_directory": "docs/research",
    "plan_directory": "docs/plans",
    "evaluation_report": "docs/reports/report-{feature}.md"
  },
  "maintenance": {
    "skill_improver": {
      "interval_days": 7,
      "timestamp": "~/.claude/.last_skill_improver_run"
    }
  },
  "superpowers": {
    "adapted_from": {
      "brainstorming": "6.3.0",
      "writing_plans": "6.3.0"
    },
    "optional_disciplines": [
      "test-driven-development",
      "systematic-debugging",
      "verification-before-completion",
      "requesting-code-review",
      "receiving-code-review",
      "dispatching-parallel-agents"
    ],
    "excluded_workflow_skills": [
      "writing-plans",
      "subagent-driven-development",
      "executing-plans",
      "using-git-worktrees",
      "finishing-a-development-branch"
    ]
  }
}
```

Validate the file immediately:

```bash
jq -e '.schema_version == 1 and .workflow.single_active == true' agents/workflow-contract.json
```

Expected: exit 0.

- [ ] **Step 2: Add failing Rust contract tests**

In `src/contract.rs`, define tests before implementation:

```rust
#[test]
fn embedded_contract_is_valid() {
    let contract = load().expect("embedded workflow contract must be valid");
    assert_eq!(contract.schema_version, 1);
    assert_eq!(contract.artifact("plan").unwrap().writer, "annotate-plan");
}

#[test]
fn rejects_absolute_and_parent_paths() {
    let invalid = include_str!("../../../workflow-contract.json")
        .replace("spec.md", "../spec.md");
    assert!(parse(&invalid).is_err());
}

#[test]
fn templates_match_feature_and_round() {
    let contract = load().unwrap();
    assert!(contract.matches_artifact(
        "evaluation_report",
        ".plans/.evaluation-auth-r2.md"
    ));
    assert!(!contract.matches_artifact(
        "evaluation_report",
        ".plans/.qa-auth-r2.md"
    ));
}
```

Run:

```bash
cargo test contract --manifest-path agents/tools/workflow-hooks/Cargo.toml
```

Expected: compile failure because `contract.rs` has no implementation.

- [ ] **Step 3: Implement the typed contract module**

Add `serde = { version = "1", features = ["derive"] }` and define:

```rust
#[derive(Debug, Deserialize, Serialize)]
pub struct WorkflowContract {
    pub schema_version: u64,
    pub contract_version: String,
    pub workflow: WorkflowPolicy,
    pub artifacts: BTreeMap<String, Artifact>,
    pub transient: BTreeMap<String, String>,
    pub archive: BTreeMap<String, String>,
    pub maintenance: Maintenance,
    pub superpowers: Superpowers,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Artifact {
    pub path: Option<String>,
    pub pattern: Option<String>,
    pub writer: String,
    pub context: bool,
}
```

Implement `parse`, `load`, `artifact`, `transient`, `archive`,
`matches_artifact`, and `render_archive`. Validation must enforce:

- schema version 1 and non-empty contract version;
- all required artifact/transient/archive keys from Step 1;
- exactly one of `path` or `pattern` per artifact;
- relative paths with no `..`, root, or platform prefix;
- `~/` only for the maintenance timestamp;
- supported template tokens limited to `*`, `{feature}`, and `{round}`;
- non-empty writer names and non-empty Superpowers version pins.

Use `include_str!("../../../workflow-contract.json")`; no runtime file lookup is allowed.

- [ ] **Step 4: Expose the embedded contract through the CLI**

Refactor `main` so `workflow-hooks contract` does not read stdin:

```rust
let input = if action == "contract" {
    json!({})
} else {
    read_input().unwrap_or_else(|_| usage())
};
let contract = contract::load();

let result = match action.as_str() {
    "contract" => contract.and_then(|value| {
        serde_json::to_value(value).map_err(|error| error.to_string())
    }),
    // existing actions
};
```

Add `contract` to the usage string and pass `&WorkflowContract` into policy functions that consume shared paths.

- [ ] **Step 5: Run contract tests and inspect output**

```bash
cargo fmt --manifest-path agents/tools/workflow-hooks/Cargo.toml
cargo test contract --manifest-path agents/tools/workflow-hooks/Cargo.toml
cargo run --quiet --manifest-path agents/tools/workflow-hooks/Cargo.toml -- contract |
  jq -e '.contract_version == "1.0.0" and .artifacts.plan.writer == "annotate-plan"'
```

Expected: all tests pass and the command emits the embedded contract.

### Task 2: Make Cadence, Annotation, and Context Contract-Driven

**Files:**
- Modify: `agents/tools/workflow-hooks/src/main.rs:101-241,346-386`
- Modify: `agents/tools/workflow-hooks/src/contract.rs`
- Modify: `agents/hooks/test-workflow-hooks.sh:21-85`

**Interfaces:**
- Consumes: canonical artifact definitions and cadence values from `WorkflowContract`.
- Produces: the existing hook result shape with complete active-workflow context and a legacy `.harness/` warning.

- [ ] **Step 1: Add failing black-box context fixtures**

Extend the shell suite:

```bash
result=$("$BIN" contract)
assert_jq "$result" '.artifacts.spec.path == "spec.md"' "contract is embedded"

mkdir -p "$context_fixture/.sprint" "$context_fixture/.research" "$context_fixture/.plans"
printf '# Product Demo\n' > "$context_fixture/spec.md"
printf '# Contract Demo\n' > "$context_fixture/.sprint/contract.md"
printf '# Research Demo\n' > "$context_fixture/.research/research-demo.md"
printf '# Plan: demo\n' > "$context_fixture/.plans/plan-demo.md"
printf '# Evaluation Demo\n' > "$context_fixture/.plans/.evaluation-demo-r2.md"
printf '# Handoff Demo\n' > "$context_fixture/.plans/.handoff-demo.md"
touch "$context_fixture/.plans/.implementing"
```

Assert that `context` reports all six titled artifacts and an active implementation marker. Add `.harness/legacy.md` and assert that the same result warns that legacy state must be resolved manually.

Run `bash agents/hooks/test-workflow-hooks.sh` and expect the new assertions to fail.

- [ ] **Step 2: Read cadence settings from the contract**

Change `cadence` to accept `&WorkflowContract`, expand the configured `~/` timestamp against `HOME`, and compare against `maintenance.skill_improver.interval_days`. Preserve the existing success/decline timestamp semantics and Korean user message.

- [ ] **Step 3: Match written artifacts through the contract**

Change `annotation` to receive the full input plus contract. Normalize absolute paths relative to `cwd`, then match only contract artifacts whose active path is a Markdown file. The reminder should cover specification, contract, research, and plan writes; evaluator/transient report writes must not trigger the user plan-review gate.

- [ ] **Step 4: Collect active context through contract entries**

Replace hard-coded `.research` and `.plans` collectors with:

```rust
fn collect_contract_artifact(
    cwd: &Path,
    name: &str,
    artifact: &Artifact,
    files: &mut Vec<PathBuf>,
) -> Result<(), String>
```

For exact paths, inspect that one file. For patterns, scan only the pattern's direct parent directory and call `matches_artifact`. Include only artifacts with `context: true`; report `.plans/.implementing` as state, not as a Markdown title. Sort and deduplicate entries.

If `.harness/` exists, append:

```text
Legacy .harness workflow state detected. Managed workflow creation must stop until the user preserves, manually translates, or removes it; never migrate it automatically.
```

- [ ] **Step 5: Verify direct and native-hook behavior**

```bash
cargo test --manifest-path agents/tools/workflow-hooks/Cargo.toml
cargo build --manifest-path agents/tools/workflow-hooks/Cargo.toml
WORKFLOW_HOOKS_BIN="$PWD/agents/tools/workflow-hooks/target/debug/workflow-hooks" \
  bash agents/hooks/test-workflow-hooks.sh
```

Expected: context, annotation, cadence, and native compact-session restoration assertions pass.

### Task 3: Archive the Complete Workflow Atomically

**Files:**
- Create: `agents/tools/workflow-hooks/src/archive.rs`
- Modify: `agents/tools/workflow-hooks/src/main.rs:418-585`
- Modify: `agents/tools/workflow-hooks/src/contract.rs`
- Modify: `agents/hooks/test-workflow-hooks.sh:87-172`

**Interfaces:**
- Consumes: `{ "cwd", "plan", "item_slugs", "final_report"? }` and the plan's `## Workflow Sources` section.
- Produces: `{ "moved": [relative paths...] }`, complete durable documentation, and cleanup limited to the completed feature.

- [ ] **Step 1: Replace the success fixture with full provenance**

Create this active plan in the black-box fixture:

```markdown
# Plan: demo

## Workflow Sources
- Product Spec: `spec.md`
- Sprint Contract: `.sprint/contract.md`
- Research:
  - `.research/research-demo.md`
```

Also create `.plans/.evaluation-demo-r2.md` and pass it as `final_report`. Assert these destinations:

```text
docs/specs/spec-demo.md
docs/contracts/contract-demo.md
docs/research/research-demo.md
docs/plans/plan-demo.md
docs/reports/report-demo.md
```

Assert that `.verify-*`, `.blocker-*`, `.debug-*`, `.qa-demo-r*.md`,
`.design-demo-r*.md`, `.evaluation-demo-r*.md`, `.handoff-demo.md`, baseline,
cycle, and `.implementing` are removed only after success.

- [ ] **Step 2: Add failure fixtures before implementation**

Cover these independent cases:

- `Product Spec: None`, `Sprint Contract: None`, `Research: None` archives only the plan.
- A legacy `## Research Sources` plan archives research and plan only.
- Missing declared spec, contract, research, or final report leaves every source in place.
- Invalid source path outside its canonical contract path fails.
- A collision in each of `docs/specs`, `docs/contracts`, `docs/research`, `docs/plans`, and `docs/reports` fails before any move.
- A malformed `Workflow Sources` section fails with the exact required syntax.
- An invalid item slug or mismatched final report feature fails.

Run the shell suite and expect failure until the new archive implementation exists.

- [ ] **Step 3: Implement `WorkflowSources` parsing**

In `archive.rs`, define:

```rust
struct WorkflowSources {
    spec: Option<String>,
    contract: Option<String>,
    research: Vec<String>,
}

pub fn run(
    input: &Value,
    contract: &WorkflowContract,
) -> Result<Value, String>
```

Require the exact labels `Product Spec`, `Sprint Contract`, and `Research`.
Accept a backticked canonical path or `None`; research accepts inline `None` or
one or more indented backticked bullets. If `## Workflow Sources` is absent,
parse the current `## Research Sources` legacy format and set spec/contract to
`None`.

- [ ] **Step 4: Preflight and move the complete source set**

Render destination templates with the plan feature. Validate all source paths with their contract artifact definitions. Validate `final_report` against `evaluation_report` and the same feature before creating destination directories.

Represent moves as one ordered vector:

```rust
struct Move {
    source: PathBuf,
    destination: PathBuf,
    relative_destination: String,
}
```

Preflight every destination, create only required parent directories, move in order with the plan last, and roll back completed moves in reverse order on any rename error. Return durable destination paths only after every move succeeds.

- [ ] **Step 5: Clean feature-owned transient state**

After a successful move, remove exact item verifier/blocker/debug files and direct `.plans/` entries matching the completed feature's QA, design, evaluation, handoff, baseline, cycle, final verifier, and implementation flag. Do not remove sibling feature files or unknown files.

- [ ] **Step 6: Run archive tests**

```bash
cargo fmt --manifest-path agents/tools/workflow-hooks/Cargo.toml
cargo test archive --manifest-path agents/tools/workflow-hooks/Cargo.toml
cargo build --manifest-path agents/tools/workflow-hooks/Cargo.toml
WORKFLOW_HOOKS_BIN="$PWD/agents/tools/workflow-hooks/target/debug/workflow-hooks" \
  bash agents/hooks/test-workflow-hooks.sh
```

Expected: every complete, legacy, no-source, missing-source, collision, malformed, and rollback assertion passes.

### Task 4: Align Planning and Execution Skills with the Contract

**Files:**
- Modify: `agents/claude/skills/spec-planner/SKILL.md`
- Modify: `agents/claude/skills/sprint-contract-negotiator/SKILL.md`
- Modify: `agents/claude/skills/deep-read/SKILL.md`
- Modify: `agents/claude/skills/annotate-plan/SKILL.md`
- Modify: `agents/claude/skills/annotate-plan/references/annotation-guide.md`
- Modify: `agents/claude/skills/implement-plan/SKILL.md`

**Interfaces:**
- Consumes: `workflow-hooks contract`, canonical predecessors, and repository instructions.
- Produces: one active `spec.md`, `.sprint/contract.md`, `.research/research-*.md`, and `.plans/plan-{feature}.md` with complete provenance.

- [ ] **Step 1: Add a common contract preflight to pipeline skills**

Each writer invokes the active harness equivalent of:

```bash
"${WORKFLOW_HOOKS_BIN:-$HOME/.local/bin/workflow-hooks}" contract
```

The writer verifies its `artifacts.<name>.writer` and active path before creating files. Add Bash to `allowed-tools` where absent; add `Write` to `deep-read`. If the command is unavailable, stop with the install command rather than inventing fallback paths.

All creation preflights stop on legacy `.harness/` or a conflicting active artifact. They report the conflict and never delete it.

- [ ] **Step 2: Adapt stable brainstorming principles into `spec-planner`**

Replace fixed feature/sprint minimums with task classification:

- spike: recommendation only, no managed artifact;
- bounded: short approved design, no product specification;
- architectural: one approval gate, scope decomposition, and canonical `spec.md`.

For the architectural path, write only `spec.md`, select one active workflow cycle, and self-review placeholders, contradictions, scope, and ambiguity. Record that these principles are adapted from the contract's Superpowers pin; do not invoke `brainstorming` or create `docs/superpowers/specs/` from this managed skill.

- [ ] **Step 3: Make sprint negotiation canonical**

Remove caller-supplied workspaces and every `.harness/` exception. Use only `.sprint/`; preserve immutable `contract.md` and draft/review/escalation files. Require the user to archive or explicitly abandon the active cycle before starting another contract.

- [ ] **Step 4: Replace plan provenance and improve plan quality**

In `annotate-plan`, replace `## Research Sources` with:

```markdown
## Workflow Sources
- Product Spec: `spec.md` or `None`
- Sprint Contract: `.sprint/contract.md` or `None`
- Research:
  - `.research/research-example.md`
```

Retain all existing plan headings and add these requirements:

- every todo names exact affected and test paths;
- `Dependencies & Ordering` records `Consumes` and `Produces` interfaces;
- every behavior change names its test and verification command;
- no placeholder instructions;
- Phase A self-review checks spec/contract coverage, placeholders, and type/signature consistency;
- all substantive user-edited diff ranges count as annotations, even without an explicit marker;
- scope-changing edits return to canonical `.sprint/`, not an arbitrary archived workspace.

Update the annotation guide to match marker-free direct edits.

- [ ] **Step 5: Make `implement-plan` the sole policy-aware executor**

Parse `Workflow Sources` and query the contract before creating `.implementing`.
Respect project Git instructions before selecting any worktree mode; on this repository, use sequential direct-main execution.

Document the optional Superpowers disciplines from the contract:

- use TDD for behavior changes when available, otherwise preserve red/green/refactor as an inline invariant;
- use systematic debugging after reproducible failure, otherwise preserve root-cause/hypothesis/regression-test steps;
- require fresh verification before marking an item or workflow complete;
- use code-review skills only for independent review, not plan or execution ownership;
- use parallel dispatch only for disjoint domains.

Explicitly exclude `writing-plans`, SDD, `executing-plans`, and branch finishing
from this managed execution. Standalone execution with no selected evaluator
archives immediately after the final verifier. When the orchestrator selected an
evaluator, return `AWAITING_EVALUATION` after final verification and retain the
active workflow state. After the orchestrator writes a PASS synthesis, it
re-invokes `implement-plan` with the exact `final_report`; this finalization path
validates the existing final verifier and calls archive without reimplementing
completed items. A FAIL synthesis returns to implementation and requires a fresh
final verifier before another evaluation. Report all five durable documentation
categories when a final report exists and the four non-report categories for a
standalone run.

- [ ] **Step 6: Validate the changed core skills**

```bash
for skill in spec-planner sprint-contract-negotiator deep-read annotate-plan implement-plan; do
  bash agents/claude/skills/generate-skills/scripts/validate-skill \
    "agents/claude/skills/$skill"
done
```

Expected: every validator prints `PASS` and exits 0.

### Task 5: Remove `.harness/` and Separate Evaluator Ownership

**Files:**
- Modify: `agents/claude/skills/qa-evaluator/SKILL.md`
- Modify: `agents/claude/skills/frontend-design-evaluator/SKILL.md`
- Modify: `agents/claude/skills/multi-agent-orchestrator/SKILL.md`
- Modify: `agents/claude/skills/multi-agent-orchestrator/references/communication-protocol.md`
- Modify: `agents/claude/skills/multi-agent-orchestrator/references/architecture.md`
- Rename: `agents/claude/skills/multi-agent-orchestrator/references/harness-tuning-guide.md` → `workflow-tuning-guide.md`

**Interfaces:**
- Consumes: canonical spec, contract, plan, current implementation, and per-evaluator reports.
- Produces: separate QA/design reports and one orchestrator-owned synthesized evaluation under `.plans/`.

- [ ] **Step 1: Give each evaluator one output type**

Add `Write` to both evaluators. Require `workflow-hooks contract` preflight and canonical `.sprint/contract.md`/`spec.md` inputs.

Use:

```text
.plans/.qa-{feature}-r{round}.md
.plans/.design-{feature}-r{round}.md
```

QA overall PASS requires no Critical/Major issue and every contracted criterion to pass; numerical scores alone cannot override severity. Design evaluation owns visual usability, not functional acceptance already assigned to QA. Standalone runs may print stdout without writing a managed report.

- [ ] **Step 2: Rewrite orchestrator stages around canonical writers**

Replace direct Generator behavior with the managed sequence:

```text
spec-planner -> sprint-contract-negotiator -> deep-read when needed
-> annotate-plan -> user approval -> implement-plan
-> optional QA/design -> synthesized evaluation -> implement-plan finalization
```

The orchestrator invokes stage owners but never writes their artifact types. It writes only `.plans/.evaluation-{feature}-r{round}.md` and `.plans/.handoff-{feature}.md`. Remove the default technology stack, unsupported cost/context claims, `.gitignore` mutation, custom workspace selection, and `.harness/` setup.

Before invoking `implement-plan`, pass the selected evaluator set. If that set is
non-empty, require `AWAITING_EVALUATION` instead of archive after implementation.
After synthesis, pass the report path back to `implement-plan` for the sole
archive call. This preserves evaluator independence without creating a second
completion owner.

- [ ] **Step 3: Replace the communication protocol**

Document exact canonical files, writers/readers, one-writer rules, report round naming, synthesis format, handoff fields, stale-state handling, and the one-active-workflow invariant. The synthesized report must reference exact QA/design source report paths and state each active acceptance criterion as PASS or FAIL.

- [ ] **Step 4: Align tuning and architecture references**

Replace `.harness/evaluation-report.md` with separate contract report patterns. Remove fixed model cost estimates and categorical context-window claims. Keep only evaluator selection, fresh-agent anti-leniency guidance, severity thresholds, and component revalidation.

- [ ] **Step 5: Validate evaluator and orchestrator skills**

```bash
for skill in qa-evaluator frontend-design-evaluator multi-agent-orchestrator; do
  bash agents/claude/skills/generate-skills/scripts/validate-skill \
    "agents/claude/skills/$skill"
done
rg -n '\.harness|docs/superpowers/plans' \
  agents/claude/skills/{qa-evaluator,frontend-design-evaluator,multi-agent-orchestrator}
```

Expected: validators pass and the search returns no active output reference.

### Task 6: Align Maintenance, Shared Rules, and Documentation

**Files:**
- Modify: `agents/claude/skills/skill-improver/SKILL.md`
- Modify: `agents/claude/skills/CLAUDE.md`
- Modify: `agents/claude/skills/README.md`
- Modify: `agents/AGENTS.md`
- Modify: `agents/rules/AGENTS.md`
- Modify: `agents/README.md`
- Modify: `agents/docs/superpowers/specs/2026-08-22-cross-harness-workflow-hooks-design.md`
- Modify: `agents/docs/superpowers/plans/2026-08-22-cross-harness-workflow-hooks.md`

**Interfaces:**
- Consumes: the embedded contract and installed plugin registry when available.
- Produces: shared priority rules, accurate lifecycle documentation, and a non-destructive Superpowers pin notice.

- [ ] **Step 1: Make `skill-improver` consume cadence and pins**

In Phase 0, run `workflow-hooks contract` and read:

```text
maintenance.skill_improver.interval_days
maintenance.skill_improver.timestamp
superpowers.adapted_from
```

When `~/.claude/plugins/installed_plugins.json` exists, compare
`superpowers@claude-plugins-official[0].version` with both adaptation pins. A
mismatch is a WARN requiring manual review; never read or edit plugin cache files.
Other harnesses skip the registry comparison when that file is absent. Preserve
the successful Phase 6 timestamp write using the contract-provided path.

- [ ] **Step 2: Add shared workflow priority guidance**

Add concise harness-neutral rules to `agents/rules/AGENTS.md`:

- `workflow-hooks contract` is authoritative for managed artifact paths.
- `annotate-plan` replaces Superpowers `writing-plans` inside the managed pipeline.
- `implement-plan` replaces SDD/`executing-plans` inside the managed pipeline.
- Superpowers cross-cutting disciplines are optional providers, not state owners.
- repository Git instructions override generic worktree/branch flows.

Keep the file under 8 KB and do not change Agent Identity or `SOUL.md`.

- [ ] **Step 3: Update repository and skill authoring guidance**

Document `agents/workflow-contract.json` in `agents/AGENTS.md` and
`agents/README.md`. Update `skills/CLAUDE.md` and `skills/README.md` with the
canonical lifecycle, evaluator ownership, Superpowers boundary, and archive
destinations. Remove the inconsistent direct Generator path from the catalog.

- [ ] **Step 4: Mark historical documents as superseded where necessary**

Add a short banner to the previous cross-harness design and implementation record
linking to the new design/plan. Keep their historical content intact; do not
rewrite completed implementation history.

- [ ] **Step 5: Validate maintenance and shared documentation**

```bash
bash agents/claude/skills/generate-skills/scripts/validate-skill \
  agents/claude/skills/skill-improver
test "$(wc -c < agents/rules/AGENTS.md)" -lt 8192
rg -n '\.harness' agents/claude/skills agents/claude/skills/README.md
git diff --check
```

Expected: validation and size checks pass; `.harness` appears only in explicit legacy-detection or migration warnings, not as an active output.

### Task 7: Run the Required Skill Review and Full Deployment Verification

**Files:**
- Modify only if verification exposes a defect in files already listed above.
- Install externally: `~/.local/bin/workflow-hooks`

**Interfaces:**
- Consumes: the complete source diff and rebuilt binary.
- Produces: a verified installed contract/policy surface with unchanged adapter APIs.

- [ ] **Step 1: Run the complete Rust gate**

```bash
cargo fmt --check --manifest-path agents/tools/workflow-hooks/Cargo.toml
cargo test --manifest-path agents/tools/workflow-hooks/Cargo.toml
cargo clippy --manifest-path agents/tools/workflow-hooks/Cargo.toml -- -D warnings
cargo build --release --manifest-path agents/tools/workflow-hooks/Cargo.toml
```

Expected: all commands exit 0 on Rust 1.85+.

- [ ] **Step 2: Run every changed skill through validator and skill-improver**

```bash
for skill in \
  spec-planner sprint-contract-negotiator deep-read annotate-plan implement-plan \
  qa-evaluator frontend-design-evaluator multi-agent-orchestrator skill-improver; do
  bash agents/claude/skills/generate-skills/scripts/validate-skill \
    "agents/claude/skills/$skill"
done
```

Invoke `skill-improver` for exactly those nine skills. Apply only findings that
preserve the approved contract; rerun validators after any edit.

- [ ] **Step 3: Install and test the verified binary**

```bash
cargo install --locked --path agents/tools/workflow-hooks --root "$HOME/.local"
WORKFLOW_HOOKS_BIN="$HOME/.local/bin/workflow-hooks" \
  bash agents/hooks/test-workflow-hooks.sh
"$HOME/.local/bin/workflow-hooks" contract |
  jq -e '.contract_version == "1.0.0"'
```

Expected: installation, the installed-binary suite, and contract inspection pass.

- [ ] **Step 4: Load-check all harness surfaces without editing adapters**

Verify Claude/Codex hook JSON still calls `workflow-hooks hook`, load the Amp
plugin source through Amp's plugin loader, and start Pi with its configured
extension in a no-inference mode. Confirm adapters still need only
`cadence|clarify|annotation|context|typecheck`; `contract` and `archive` are skill
and CLI actions, not adapter events.

- [ ] **Step 5: Run final consistency checks**

```bash
jq empty agents/workflow-contract.json agents/claude/settings.json agents/codex/hooks.json
git diff --check
git status --short
rg -n '\.harness|docs/superpowers/plans|\.superpowers/sdd' \
  agents/claude/skills agents/claude/skills/README.md agents/rules/AGENTS.md
```

Expected: JSON and diff checks pass; remaining search matches are explicit
legacy/exclusion statements only. Review the full diff and report any checks that
could not be run. Do not push, publish, or alter shared external state beyond the
requested local binary installation.
