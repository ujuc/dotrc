---
name: skill-improver
description: "스킬/에이전트 정의를 테스트 시나리오와 최근 세션 기록에서 관찰된 실패를 근거로 자동 개선한다. 공통 워크플로 계약의 주기에 따라 비차단 알림이 뜨고, 심층 최적화가 필요하면 별도 autoresearch 실행을 안내한다. /skill-improver, skill-improver, 스킬 개선해줘, 스킬 최적화, 스킬 테스트해줘, test skills 요청 시 사용한다."
group: meta
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(bash:*), Bash(git:*), Bash(date:*), Bash(jq:*), Bash(mktemp:*), Bash(diff:*), Agent, advisor
argument-hint: "[skill-name ...]"
---

# Skill Improver

Audit skills and agent definitions, fix safe structural issues, and propose
behavioral changes supported by recent sessions. Dimensions A–D check structure
and semantics; Dimension E scores observed behavior. Repairs stop after three
iterations per target.

## Scope and available capabilities

- Read [`references/quality-checks.md`](references/quality-checks.md) for authority,
  evidence, portability, and completion rules. Reuse selected targets and existing
  approval; a post-edit check is one targeted batch. Do not recursively invoke
  this skill or the authoring controller during self-maintenance.
- Use Lightweight for structural checks, Standard for bounded mechanical fixes,
  and Advanced for semantic/evidence judgments. Recommend Frontier only for
  unresolved, consequential cross-skill conflicts. Apply the
  [shared model guide](../generate-skills/references/model-selection.md), including
  its user-facing recommendation and actual-switching distinction.
- Map tool names below to available host capabilities. Independent review needs
  a separate reviewer context; a different model alone does not establish it.
  Disclose unavailable roles. A missing question tool still permits ordinary
  interactive text; it never permits assumed answers.
- Preserve explicit user/repository policy. Do not execute the target workflow
  to fill a behavior-evidence gap; this skill reviews definitions, scripts, and
  existing evidence.

## Periodic Execution

The SessionStart hook runs `$HOME/.local/bin/workflow-hooks hook`. When the
contract-configured interval is due, it offers a non-blocking full sweep.

- **Declined:** the active agent records today's date to suppress repeat prompts.
- **Accepted:** only Phase 6 records a successful audit; interrupted or failed
  runs remain due next session.

An explicit `skill-improver` invocation runs immediately, independent of cadence.

## Language Policy

When auto-editing skill or agent metadata in Phase 4, preserve the user's language conventions:

- **Skills:** `description` / `when_to_use` are Korean and SKILL.md bodies are English, except functional examples and user-visible strings.
- **Agents:** preserve the existing definition's language; do not blanket-translate English or Korean bodies.
- **Trigger keywords are functional identifiers.** Never paraphrase or translate them.

Record a target-type policy mismatch as **B.7 — language policy drift** and ask before translating.

## Phase 0 — Pre-flight Checks

1. **Shared contract**: run the installed policy surface and retain its JSON for this run:
   ```bash
   workflow_bin=${WORKFLOW_HOOKS_BIN:-$HOME/.local/bin/workflow-hooks}
   contract_json=$("$workflow_bin" contract) || exit 1
   ```
   Validate `maintenance.skill_improver.interval_days`, `maintenance.skill_improver.timestamp`, and every `superpowers.adapted_from` pin. Never hard-code local substitutes when these keys exist. Resolve the timestamp path once here; Phase 6 writes it:
   ```bash
   timestamp_path=$(jq -er '.maintenance.skill_improver.timestamp' <<<"$contract_json")
   case "$timestamp_path" in "~/"*) timestamp_path="$HOME/${timestamp_path#\~/}" ;; esac
   ```
2. **Toolchain**: check `cargo` and `jq` are installed (`validate-skill` is a Rust binary and the contract is JSON):
   ```bash
   command -v cargo &>/dev/null || { echo "cargo required: https://rustup.rs"; exit 1; }
   command -v jq &>/dev/null || { echo "jq is required to read the workflow contract"; exit 1; }
   ```
3. **Repository resolution**: resolve `repo_root` as `${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents`; verify its `AGENTS.md` and `claude/skills/`. Invocation CWD may be any project.
4. **Validator path**: confirm `<repo_root>/claude/skills/generate-skills/scripts/validate-skill` exists. Use `repo_root` for every scan and command; do not require or mutate the caller's CWD.
5. **Superpowers compatibility**: read `<repo_root>/claude/plugins/installed_plugins.json` without modifying it — entries live under `.plugins`, not at the root, and each key holds an array of per-scope installs:
   ```bash
   jq -r '.plugins["superpowers@claude-plugins-official"][] | select(.scope=="user") | .version' <file>
   ```
   Compare that version with all `superpowers.adapted_from` versions in the contract. If missing or mismatched, emit a non-blocking warning that adapted assumptions need review; do not edit the plugin cache, installed manifest, pins, or skills automatically.
6. **Spec freshness**: under `repo_root`, find sibling `generate-skills` and read `frontmatter-spec.md` from its reference directory. Compute `today - last_upstream_check`. If beyond `check_interval_days` (default 14), warn without blocking.

If any toolchain/path/repo check fails, report the issue with an actionable fix and stop — do not proceed to Phase 1.

## Phase 1 — Inventory & Intent Extraction

1. **Argument parsing**: if arguments specify skill or agent names, target those; otherwise sweep all skills in `claude/skills/` and `.claude/skills/`, plus agent definitions in `claude/agents/` and `.claude/agents/` (and actual equivalents for other hosts).
2. **Mode classification**: tag each target as `skill` (has `SKILL.md`) or `agent` (a definition under `claude/agents/` or `.claude/agents/`, excluding README and references). Mode determines which Phase 2 dimensions apply.
3. **Catalog map**: collect `name` and `group` from user-scope `claude/skills/` for B.6. Validate project-scope `.claude/skills/` structurally but never add them to the user catalog. Trigger overlap remains exclusive to `skill-engineer`.
4. **Per-target read**: for each target, parse:
   - Frontmatter: `name`, `description`, `model`, `allowed-tools`, plus optional fields per `frontmatter-spec.md`.
   - Body: core procedure steps, constraints, prohibited actions.
   - Referenced file paths in the body (`references/`, `scripts/`, agent paths).
   - Trigger keywords from the description.
   - For managed workflow skills, ownership and paths from the retained workflow contract rather than prose inferred from peer skills.
5. Summarize each target's intent in 1 line for Phase 2.
6. **Evidence collection** (run-level, once per sweep): create the run's scratch directory and condense recent sessions into it.

   ```bash
   REPORT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/skill-improver-XXXXXXXX")
   bash "<repo_root>/claude/skills/skill-improver/scripts/collect-sessions" --out "$REPORT_DIR"
   ```

   Defaults: a 45-day window, the 12 newest qualifying sessions, sidechains excluded. A manual run can narrow with `--since YYYY-MM-DD` or `--project PATH`. Do **not** derive the window from `timestamp_path` — the cadence prompt writes that file on decline as well as on completion, so it marks "last asked", not "last examined".

   `bash scripts/test-collect-sessions` self-checks the collector against a synthetic history; run it after touching `condense.jq` or `inventory.jq`.

   Start with `$REPORT_DIR/inventory.json`; Phase 2 reads the condensed digests.
   **Never read raw `.jsonl` history directly.** If collection fails or samples
   no sessions, record Dimension E as SKIP and continue A–D. Audit artifacts stay
   under `REPORT_DIR`, never in a user project.

## Phase 2 — Test Scenario Generation

Generate tests using a **test category matrix**: three skill dimensions, a mode-specific dimension D for agents, and dimension E for observed behavior in both modes.

### Dimension A — Structural (skill mode only)

Run `validate-skill <path>` (Rust binary, not the legacy `.sh`). This single execution covers all structural checks (frontmatter format, naming, size limits, **`group` field presence and slug validity**). Do not duplicate in Dimension B. **Skip for agent mode** — no equivalent validator exists yet; rely on Dimension D.

### Dimension B — Semantic (skill-improver's core value)

| Test | What it checks | How |
|------|----------------|-----|
| **B.1 Description-body alignment** | Description's WHAT clause matches actual procedure steps | Read procedure, compare with description. Flag if description claims capabilities not present in the body, or misses major capabilities |
| **B.5 Reference integrity** | All file paths in the body point to existing files | Glob/Read each referenced path. Flag broken references. **Skip for agent files** unless body explicitly mentions external paths |
| **B.6 catalog sync** | A structurally valid **user-scope** `claude/skills/` skill is listed under its group in `<repo_root>/claude/skills/README.md` | Dimension A owns group validity. Project-scope `.claude/skills/` targets are SKIP. |
| **B.7 Language policy** | Skill metadata/body follows the skill policy; agent language is preserved; triggers stay intact | Apply the target-type rules above and compare edits with the original trigger tokens |
| **B.8 Workflow ownership** | Managed skills use contract paths, one-writer ownership, lifecycle, cadence, and Superpowers boundary | Compare workflow claims with the retained contract; flag conflicts as manual design issues |
| **B.9 Authority/scope** | Approval reuse, explicit policy, side-effect ownership | Apply references/quality-checks.md |
| **B.10 Evidence contract** | Verifier inputs, evidence levels, final status | Apply references/quality-checks.md; inspect available suites without running the target |
| **B.11 Host/source integrity** | Capability fallbacks and scoped source claims | Apply references/quality-checks.md; check section/role references too |

> **Scope boundary**: trigger completeness, trigger uniqueness, and model fitness checks belong to the `skill-engineer` agent. Do not duplicate them here. To run those checks, dispatch `Agent("skill-engineer", "<target> [--check trigger|overlap|model|all]")` either inline (after Phase 5 passes) or as a standalone follow-up.

### Dimension C — Type-specific (skills)

- **Skills with scripts** (`scripts/` directory exists): for each *executable* under `scripts/`, run it directly (`./script --help`) so its shebang applies — forcing `bash` misreads a `uv run` PEP 723 script as shell and fails — and expect exit 0; when arguments are required, also run with no args and expect a clear usage error rather than a crash. Data files such as `*.jq` are not entry points — they are exercised by their launcher's self-check.
- **Pipeline skills** (skills that reference other skill names): verify referenced skill names exist as actual skill directories.

### Dimension D — Agent-specific (agent mode only)

Use the Agent Definition Mode checklist below. Model inheritance is valid;
explicit model values must follow the target host's schema and available models.

### Dimension E — Evidence (run-level, both modes)

Scored **once per sweep**, not once per target: read every digest in
`$REPORT_DIR/transcripts/` against [`references/evidence-rubric.md`](references/evidence-rubric.md), then attribute each
finding to a target using that file's attribution rules. Each target's Dimension E
row reports only the findings attributed to it — SKIP when there are none, which
is the common case and not a defect.

| Test | What it checks | How |
|------|----------------|-----|
| **E.1 Observed failure** | A session scored below 0.5 did work this target owns | Score each digest, attribute, cite session id + one-line paraphrase |
| **E.2 Coverage** | The target actually fires where its domain appears | `skills_used` / `commands_used` vs the Phase 1 catalog; a never-firing skill is a trigger finding for `skill-engineer`, never a WHEN-clause auto-fix |

E.1 findings do **not** become edits by themselves — Phase 4 puts them through
the change bar first. Record the run-level score summary
(`sessions_sampled`, failed sessions, `skill_coverage`) for the Phase 6 report.

For complex skills, use the independent consultation rules below to review
whether tests cover cross-skill interactions and intent.

Each test is a concrete check with expected outcome (PASS criteria).

## Agent Definition Mode

When the target is an agent `.md` file (not a `SKILL.md`):

| Check | Required | Notes |
|-------|----------|-------|
| `name` frontmatter field | Yes | kebab-case, matches filename |
| `description` frontmatter field | Yes | WHAT + WHEN format |
| `model` frontmatter field | Host-dependent | Omit to inherit when supported; validate explicit values against the target host, not a fixed provider list |
| `tools` field | Optional | Comma-separated list when restricted |
| Role statement in body | Yes | First non-frontmatter paragraph defines the role |
| Output format spec | Conditional | Required if the agent produces structured output |
| External path references | Optional | Validate via B.5 only when present |

**Skipped vs skill mode**: Dimension A (no agent-side validator), Dimension C (no `scripts/` siblings), B.5 by default (skip unless paths in body), B.6 by default (agents carry no skills `group:` frontmatter — SKIP).

## Phase 3 — Test Execution & Capture

Execute tests in order: Dimension A → B → C/D → E. Dimension E is scored once for the whole sweep (Phase 2) and then reported per target.

For each test:

1. Run the check (Bash command, file read, or comparison).
2. Capture output and result.
3. Classify:
   - **PASS**: result matches expectations.
   - **FAIL**: result does not match expectations.
   - **WARN**: non-critical issue detected (e.g., optional field missing).
   - **SKIP**: test not applicable to this target type, or no evidence was attributed to it.
   - **UNVERIFIED**: applicable claim lacks required evidence; never count as PASS.

**Early exit**: if Dimension A produces 3+ errors, skip remaining dimensions for that target — structural problems must be fixed first.

Display results as a table after each target completes.

## Phase 4 — Failure Analysis & Auto-Fix

Classify each failure before editing:

- **Mechanical:** only A/B/C/D failures matching the safe-fix table may be fixed
  directly. Authority, scope, evidence, and workflow decisions remain manual.
- **Behavioral:** apply [`references/change-bar.md`](references/change-bar.md).
  Write qualifying proposals under `$REPORT_DIR/proposed/<target>/`, retain a
  `diff -u`, and apply only accepted scope. If the bar is not met, explain why and
  propose nothing.

### Auto-fixable (apply with Edit tool)

| Category | Trigger | Fix |
|----------|---------|-----|
| Frontmatter corrections | Missing fields, typos, invalid format other than `group` | Add/correct fields; group presence/slug remains manual |
| Description WHAT enrichment | B.1 fails | Generate accurate WHAT clause from procedure steps. **Never modify the WHEN clause (trigger phrases) without user approval** |
| Catalog sync | B.6 fails for a user-scope skill with valid frontmatter | Align the user README group map; never register project-scope skills |
| Reference path repair | B.5 fails | Fix the path if a similarly-named file exists nearby; otherwise report as manual |

### Manual (report to user, do not attempt)

- Cross-skill dependencies, core logic, workflow changes, and structural design
  decisions.
- WHEN-clause changes and body translations (B.7); preserve triggers and language
  unless their modification is explicitly approved.
- Missing or invalid `group`: present the eight allowed slugs and obtain the
  user's choice; never infer a group from the name or description.
- Contract ownership or Superpowers pin drift (B.8): update the approved contract
  and implementation together in a separate workflow.
- E.1 proposals: evidence supports a draft, never an unattended procedure rewrite.
- E.2 coverage gaps: route suggestions to `skill-engineer`, which owns triggers.

When fixability is ambiguous, use an available advisor or independent equivalent.
If none exists, report the unresolved classification and leave the proposed
behavior change unapplied; local reasoning is not an independent review.

## Phase 5 — Re-verification (max 3 iterations)

1. After applying fixes, rerun the target's full original test matrix, including previously passing checks.
2. **Regression guard**: if a fix introduces a new failure, revert that fix and
   reclassify it as manual. For an unapplied E-track proposal, discard the draft
   under `$REPORT_DIR/proposed/`.
3. If all required audit checks PASS, with optional/inapplicable evidence clearly
   SKIP/UNVERIFIED → proceed to Phase 6. Do not claim behavior beyond its evidence.
4. If failures remain and iteration count < 3 → return to Phase 4.
5. At iteration 3, stop repairs and report remaining failures. Consult an available
   advisor once if useful; absence is disclosed. Do not start another loop or
   update the successful-run timestamp while a required failure remains.

## Phase 6 — Summary & Commit

Report each target's checks, iterations, status, and changes, with an evidence
summary and the location of `REPORT_DIR`:

```
## skill-improver Results

| Target | Tests | Iterations | Status | Changes |
|--------|-------|------------|--------|---------|
| <target> | <PASS/FAIL/SKIP/UNVERIFIED counts> | <n> | <status> | <changes or none> |

Evidence: <sampled> sessions since <date>, <failed> failed, coverage <ratio>
  - <session id> → <target>: <one-line paraphrase and disposition>
```

Include empty evidence and no-proposal outcomes. Leave the scratch directory for
inspection. Session history stays local and read-only: never upload, commit, or
quote raw history or digest lines. Cite session IDs with one-line paraphrases.

If any fixes were applied:

1. Show the full diff to the user.
2. Commit only if explicitly requested; reuse a still-applicable request rather
   than asking again. Otherwise leave the changes uncommitted.
3. Follow the repository's Korean Conventional Commit rules.

After the report (with or without fixes), update the periodic-run timestamp at `timestamp_path`, resolved in Phase 0 from the contract:

```bash
mkdir -p "$(dirname "$timestamp_path")"
date -u +%Y-%m-%d >| "$timestamp_path"   # >| : the file already exists and zsh sets noclobber
```

This signals to the session-start protocol that skill-improver has run today, preventing repeat notifications next session. **Do not write the timestamp earlier in the workflow** — failed runs (Phase 0–5 errors) should re-prompt next session.

## Independent consultation

Use an available advisor or separate reviewer context at these decision points:

| Phase | Question |
| --- | --- |
| 2 | Do tests for a complex skill cover cross-skill interactions and intent? |
| 4 | Is a failure safely mechanical or a manual design decision? |
| 4 | Does a contested E.1 finding clear the change bar? |
| 5 | After three iterations, would one optional review clarify remaining failures? Stop repairs regardless. |

Supply the relevant inputs, instructions, and evidence through the host's actual
review interface; do not assume automatic context forwarding. Choose the review
profile for the actual judgment; use inheritance only as an execution fallback.
If consultation is unavailable,
disclose it and leave unresolved behavioral proposals unapplied.

## Deep Optimization Handoff

If deeper eval-based optimization is warranted, finish this run first and recommend a separate `/autoresearch <target>` invocation. Do not launch autoresearch inside skill-improver's commit/timestamp transaction; it has its own confirmation, artifacts, validation, and commit cycle.

## Gotchas

1. `validate-skill` is a Rust launcher without a `.sh` suffix. Its first call may
   compile the workspace; a Bash-only environment is insufficient.
2. `group:` owns catalog placement in `claude/skills/README.md`; do not create a
   parallel triggers/model catalog in `claude/CLAUDE.md`.
3. `commands_used` includes built-in CLI commands. Filter against the Phase 1
   catalog before calculating coverage; see the evidence rubric.
4. Missing history can make the collector fail rather than emit an empty
   inventory. Both cases make Dimension E SKIP, never PASS or a structural FAIL.
5. Beyond target files and the catalog, writes are limited to `REPORT_DIR`, an
   explicitly requested commit, and the Phase 6 timestamp, subject to user and
   host write boundaries.

## Eval Criteria

Binary checks for autoresearch reuse. A criterion fails when its expected outcome
is violated; missing applicable evidence is UNVERIFIED, never PASS.

| ID | Scenario | Expected outcome |
| --- | --- | --- |
| 1 | `cargo` or validator launcher missing | Stop in Phase 0 with an actionable fix; no Phase 1+ work. |
| 2 | Description auto-fix | Diff preserves every original Korean trigger; only WHAT changes. |
| 3 | Fix introduces a regression | Revert the fix or discard its unapplied draft, reclassify as manual, and restore the prior result. |
| 4 | Three repair iterations exhausted | Stop, report unresolved failures and actual consultation availability; no successful-run timestamp. |
| 5 | Phase 6 completes with authorized timestamp access | Contract-configured file contains today's UTC date as YYYY-MM-DD. |
| 6 | Missing or invalid `group` | Report as manual and present the eight allowed slugs; never guess. |
| 7 | E-track proposal or a sample without attributable failures | Every proposal cites a session ID and rubric label; no failures means no E-track edit. Keep explicit user-directed authoring separate. |
| 8 | Session evidence collection and reporting | Use the collector, keep audit artifacts under mktemp `REPORT_DIR`, cite IDs plus paraphrases; no direct raw-history reads or digest quotes. |
| 9 | Waza invocation in skill/agent definitions | Only `waza-runner.md` contains direct Waza subcommands; exclude `waza-install.md` when scanning documentation. |
| 10 | Model recommendation and execution | Recommend a workload profile with supported candidates and escalation conditions; respect user choices and distinguish advice from actual switching. Inheritance is a fallback, not proof of fit. |
