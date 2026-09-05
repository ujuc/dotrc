---
name: skill-improver
description: "스킬/에이전트 정의를 테스트 시나리오와 최근 세션 기록에서 관찰된 실패를 근거로 자동 개선한다. 공통 워크플로 계약의 주기에 따라 비차단 알림이 뜨고, 심층 최적화가 필요하면 별도 autoresearch 실행을 안내한다. /skill-improver, skill-improver, 스킬 개선해줘, 스킬 최적화, 스킬 테스트해줘, test skills 요청 시 사용한다."
group: meta
model: sonnet
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(bash:*), Bash(git:*), Bash(date:*), Bash(jq:*), Bash(mktemp:*), Bash(diff:*), Agent, advisor
argument-hint: "[skill-name ...]"
---

# Skill Improver

Test-driven improvement loop for skills and agent definitions. Validates structure and semantics, scores recent real sessions for the failures those definitions caused, auto-fixes safe issues, and re-verifies — up to 3 iterations per target. Cadence and adapted Superpowers versions come from the shared workflow contract.

Dimensions A–D ask whether a skill is well-formed; **Dimension E asks whether it worked**, by scoring condensed digests of local session history. Structural findings are lint and are fixed on sight. Behavioral findings must clear the change bar in [`references/change-bar.md`](references/change-bar.md) — proposing nothing, with a stated reason, is a valid outcome.

## Scope and available capabilities

Read `references/quality-checks.md` for authority, evidence and portability
checks. Reuse selected targets and existing approval; a post-edit check is one
targeted batch, not a periodic full sweep. Self-maintenance uses this run's
bounded re-verification and must not recursively invoke either controller.

Claude tool/model names below are examples: use the active host's equivalents.
If advisor/delegation is unavailable, report it; never invent an independent
review. A missing question tool permits normal interactive text questions, not
assumed answers. Preserve explicit project policy over general model defaults.

## Periodic Execution

This skill is meant to run regularly, not just on demand.

- The SessionStart command runs `$HOME/.local/bin/workflow-hooks hook`. Its cadence policy reads the interval and timestamp path embedded from `agents/workflow-contract.json`; when due, it injects context telling the active harness to surface a non-blocking prompt offering a full sweep.
- **On decline**: the active agent writes today's date so the prompt does not repeat next session.
- **On accept**: the cadence policy does not write the timestamp; Phase 6 of this skill writes it only on successful completion. If the run crashes mid-flight (Phase 0–5 errors), the user is re-prompted next session — this is the desired "failed runs re-prompt" behavior (Gotcha #4).

To force an immediate run regardless of cadence: invoke `Skill("skill-improver")` directly.

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
   contract_json=$($workflow_bin contract) || exit 1
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

   Read `$REPORT_DIR/inventory.json` only. **Never read a raw `.jsonl`** — a single session file reaches 1.3 MB. If `sessions_sampled` is 0, or the collector fails, record Dimension E as SKIP for every target and continue; missing evidence is not a failure. Every artifact of this run stays under `REPORT_DIR`; nothing is written into a user project.

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

See "Agent Definition Mode" section below for the full check list. Quick summary: `model` field present, description follows WHAT + WHEN, body has a clear role statement, structured-output spec when applicable.

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

For complex skills (multi-agent-orchestrator, autoresearch, etc.), call `advisor()` after generating semantic tests to review whether scenarios capture the skill's intent adequately.

Each test is a concrete check with expected outcome (PASS criteria).

## Agent Definition Mode

When the target is an agent `.md` file (not a `SKILL.md`):

| Check | Required | Notes |
|-------|----------|-------|
| `name` frontmatter field | Yes | kebab-case, matches filename |
| `description` frontmatter field | Yes | WHAT + WHEN format |
| `model` frontmatter field | Yes | One of `sonnet`, `opus`, `haiku` |
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

For each FAIL result:

1. Analyze the error pattern.
2. Classify fixability and apply fixes.

**Two tracks, two bars.** Only mechanical A/B/C/D failures matching the safe
fix table are lint. Semantic authority, scope, evidence or workflow findings
require judgment and use the manual track; do not auto-rewrite them as formatting. E failures are claims about how an agent
behaves; run each through [`references/change-bar.md`](references/change-bar.md) before writing anything, and
draft into `$REPORT_DIR/proposed/<target>/` with a `diff -u` rather than editing
the target in place. If a finding does not clear the bar, propose nothing and
record why — that is the expected outcome for most findings.

### Auto-fixable (apply with Edit tool)

| Category | Trigger | Fix |
|----------|---------|-----|
| Frontmatter corrections | Missing fields, typos, invalid format other than `group` | Add/correct fields; group presence/slug remains manual |
| Description WHAT enrichment | B.1 fails | Generate accurate WHAT clause from procedure steps. **Never modify the WHEN clause (trigger phrases) without user approval** |
| Catalog sync | B.6 fails for a user-scope skill with valid frontmatter | Align the user README group map; never register project-scope skills |
| Reference path repair | B.5 fails | Fix the path if a similarly-named file exists nearby; otherwise report as manual |
| Language policy hint | B.7 fails | Report only — never auto-translate without user approval |

### Manual (report to user, do not attempt)

- Cross-skill dependency issues (e.g., referenced skill doesn't exist).
- Core logic or workflow changes.
- Description WHEN clause modifications (trigger phrases).
- Body language translations (B.7 prose drift).
- **Missing `group` field** — guessing from directory name or description risks wrong placement (e.g., a `frontend-*` skill might belong to `verify` or `build`). Surface the failure with the 8-slug list and ask the user to choose.
- Any structural issue requiring design decisions.
- Workflow-contract ownership or pinned-Superpowers drift (B.8); update the approved contract and implementation together in a separate workflow.
- Every E.1 behavioral edit: draft it, diff it, and let the user accept it. Evidence justifies a proposal, never an unattended rewrite of a procedure.
- E.2 coverage gaps: record the suggestion and route it to `skill-engineer`. A never-firing skill is a WHEN-clause problem, and the WHEN clause is out of this skill's reach.

When fixability is ambiguous, use an available advisor or independent equivalent.
If none exists, report the unresolved classification and leave the proposed
behavior change unapplied; local reasoning is not an independent review.

## Phase 5 — Re-verification (max 3 iterations)

1. After applying fixes, rerun the target's full original test matrix, including previously passing checks.
2. **Regression guard**: if a fix introduces a NEW failure, immediately revert the fix and reclassify it as manual. For an E-track edit, discard the draft under `$REPORT_DIR/proposed/` — the target file was never touched, so there is nothing to unwind.
3. If all required audit checks PASS, with optional/inapplicable evidence clearly
   SKIP/UNVERIFIED → proceed to Phase 6. Do not claim behavior beyond its evidence.
4. If failures remain and iteration count < 3 → return to Phase 4.
5. At iteration 3, stop repairs and report remaining failures. Consult an available
   advisor once if useful; absence is disclosed. Do not start another loop or
   update the successful-run timestamp while a required failure remains.

## Phase 6 — Summary & Commit

Output a changelog table:

```
## skill-improver Results

| Target | Tests | Iterations | Status | Changes |
|--------|-------|------------|--------|---------|
| commit | 6/6 PASS | 1 | Clean | no changes needed |
| generate-skills | 5/7 PASS | 2 | Improved | description enriched, group verified |

Evidence: 9 sessions sampled since 2026-08-24, 2 failed, coverage 0.44
  - aaaaaaaa → deep-read: three re-reads of the same file (cleared the bar, diff below)
  - bbbbbbbb → commit: one ordering slip (no change — the skill already states the rule)
  - qa-evaluator never fired in 9 sessions → trigger suggestion, routed to skill-engineer
```

Report the evidence block even when it is empty: `0 failed sessions` and `no
change proposed` are results. Name `$REPORT_DIR` so the user can inspect the
digests and drafts, and leave it in place — it is a `mktemp` directory the OS
reclaims.

If any fixes were applied:

1. Show the full diff to the user.
2. Commit only if explicitly requested; reuse a still-applicable request rather
   than asking again. Otherwise leave the changes uncommitted.
3. Commit following Korean conventional commit rules:
   `refactor(skills): skill-improver로 <target> 스킬을 개선하다`

After the report (with or without fixes), update the periodic-run timestamp at `timestamp_path`, resolved in Phase 0 from the contract:

```bash
mkdir -p "$(dirname "$timestamp_path")"
date -u +%Y-%m-%d >| "$timestamp_path"   # >| : the file already exists and zsh sets noclobber
```

This signals to the session-start protocol that skill-improver has run today, preventing repeat notifications next session. **Do not write the timestamp earlier in the workflow** — failed runs (Phase 0–5 errors) should re-prompt next session.

## Advisor Escalation

This skill runs on sonnet by default. Call `advisor()` (no parameters — full context is forwarded automatically) at these decision points:

1. **Phase 2 — semantic test quality review**: after generating tests for complex skills (multi-agent-orchestrator, autoresearch, etc.), review whether scenarios capture cross-skill interactions and intent adequately.
2. **Phase 4 — fixability classification ambiguity**: when a failure sits on the boundary between auto-fixable and manual.
3. **Phase 5 — failures remain after 3 iterations**: stop repairs, report failures,
   and optionally review the test scenario; do not extend the repair loop.
4. **Phase 4 — an E.1 finding sitting on the change bar**: when a behavioral edit is arguable — one occurrence, a contested attribution, or a rule that may already be stated elsewhere. Editing another agent's instructions on weak evidence is the expensive mistake here.

## Deep Optimization Handoff

If deeper eval-based optimization is warranted, finish this run first and recommend a separate `/autoresearch <target>` invocation. Do not launch autoresearch inside skill-improver's commit/timestamp transaction; it has its own confirmation, artifacts, validation, and commit cycle.

## Constraints

- Never modify a skill's core logic or workflow without user approval.
- Auto-fixes are limited to metadata, descriptions, and structural issues.
- Always show diffs before committing.
- Do not run the target skill itself (only validate its structure and content).
- Validator path is `claude/skills/generate-skills/scripts/validate-skill` from the agents configuration root (no `.sh` suffix).
- Trigger overlap, completeness, and model fitness checks belong to skill-engineer — do not duplicate.
- Treat `workflow-hooks contract` as authoritative for managed workflow ownership, maintenance cadence, and adapted Superpowers pins.
- Plugin manifests and caches are read-only compatibility evidence; never update them from this skill.
- Outside target files and the README catalog, the only side effects are a user-confirmed commit and the Phase 6 timestamp — plus the run's `mktemp` scratch directory, which is never written into a user project.
- Session history is read-only and stays local. Never upload, commit, or paste a digest, a raw `.jsonl`, or any line of either. Cite evidence as a session id plus a one-line paraphrase; the sampled sessions come from other repositories, including work ones.
- Evidence justifies a proposal, never an unattended behavioral edit. Structural lint is fixed on sight; anything Dimension E motivates is drafted, diffed, and accepted by the user.

## Gotchas

1. **cargo dependency**: `validate-skill` is a Rust binary launched via `generate-skills/scripts/validate-skill`. First invocation compiles the workspace (~6–30s). Phase 0 must check `cargo`, not `bash` or `yq`. The launcher lost its `.sh` suffix in 2026-04 — older docs may still reference `validate-skill.sh`.

2. **Description enrichment risk**: auto-generating a WHAT clause can accidentally remove trigger keywords the user placed intentionally. Always show the diff for description changes and never touch the WHEN clause.

3. **Group sync target**: `group:` frontmatter is the single source of truth; there is no per-skill triggers/model table in `claude/CLAUDE.md` to edit. When a group changes, update the group map in `claude/skills/README.md` — not a CLAUDE.md table.

4. **Periodic-run timestamp drift**: if skill-improver crashes mid-Phase 4 without reaching Phase 6, the timestamp is not updated and the user gets re-prompted next session. This is desired (failed runs re-prompt) — do not move the write earlier.

5. **Agent definition files lack `references/` siblings**: B.5 reference-integrity must skip agent files unless the body explicitly mentions external paths.

6. **Spec staleness ≠ blocker**: Phase 0's spec freshness check is informational. Stale `frontmatter-spec.md` only means new fields might be unknown; it does not invalidate existing checks. Warn the user but continue.

7. **Raw transcripts are unreadable by design**: a single `.jsonl` session reaches 1.3 MB and one malformed line aborts a plain `jq` pass. Always go through `scripts/collect-sessions`, which condenses ~50:1, reads line-by-line with `fromjson? // empty`, and caps a long digest at 400 lines with an explicit elision marker. Reading a session file directly is the one way this skill can blow its own context.

8. **`commands_used` is not `skills_used`**: the collector reads slash invocations from `<command-name>` tags, which also capture built-in CLI commands (`/clear`, `/compact`, `/model`, `/effort`). Filter against the Phase 1 catalog before computing coverage, or every session looks covered.

9. **No evidence is a SKIP, not a FAIL**: a fresh machine, a `--since` window with no sessions, or a missing `~/.claude/projects` all yield `sessions_sampled: 0`. Dimension E reports SKIP and the sweep continues on A–D. Never treat absent evidence as a passing grade either — say the sample was empty.

10. **The bar is meant to reject**: most E.1 findings should end in "no change proposed" with a stated reason. A sweep that rewrites a procedure from one bad session has done more damage than the session did.

11. **Superpowers version drift ≠ automatic upgrade**: the contract pins versions whose principles were adapted, not a command to install that version. Warn on mismatch and review upstream differences separately. Never modify `claude/plugins/` during a skill-improver run.


## Eval Criteria

Binary checks for autoresearch reuse:

```
EVAL 1: Phase 0 environment guard
  Question: When cargo or the validate-skill launcher is missing, does the
            skill stop with a clear actionable message instead of crashing
            in Phase 2?
  Pass: Stops with the install instruction; no Phase 1+ work attempted.
  Fail: Continues into Phase 1 with broken environment.

EVAL 2: Description preservation
  Question: After auto-fixing a skill's description, are all original Korean
            trigger keywords still present?
  Pass: Diff shows only WHAT clause changes; WHEN/trigger phrases intact.
  Fail: Any Korean trigger keyword removed or translated.

EVAL 3: Regression guard effectiveness
  Question: When a Phase 4 fix introduces a NEW failure, is the fix reverted
            before Phase 5 records the new failure permanently?
  Pass: Fix reverted, target reclassified as manual, original test result
        restored.
  Fail: New failure persists in final report.

EVAL 4: Iteration ceiling
  Question: Does the skill stop auto-fixing at iteration 3, report actual
            advisor availability and leave unsuccessful runs undated?
  Pass: Stops repairs at 3, reports unresolved failures and actual advisor
        availability; required failure leaves the timestamp unchanged.
  Fail: Continues past 3, invents consultation or records an unsuccessful run
        as completed.

EVAL 5: Timestamp update
  Question: After Phase 6 completes (with or without fixes), does the timestamp
            path from maintenance.skill_improver contain today's UTC date?
  Pass: The contract-configured file contains YYYY-MM-DD matching today.
  Fail: File missing, stale, or contains malformed date.

EVAL 6: Group field enforcement
  Question: When a SKILL.md is missing the local-required `group` field
            (or has a slug outside the 8 allowed values), does the run
            classify the failure as manual and surface the 8-slug choice
            list to the user?
  Pass: Phase 4 reports it as manual, no auto-fix attempted, the user
        sees the slug list for their decision.
  Fail: skill-improver auto-fills a guessed group, or treats it as a
        warning without surfacing it.

EVAL 7: Evidence-gated behavioral edits
  Question: Does every E-track behavioral proposal cite an attributable failed
            conversation, and does a sweep with zero such failures propose zero
            E-track edits? Separate explicit user-directed authoring work.
  Pass: Each E-track diff names a session id and its rubric label; with no
        failed sessions, the report says "no change proposed" and no
        procedure text was touched.
  Fail: A procedure edit lands with no cited session, or the run invents
        behavioral edits from a clean sample.

EVAL 8: Transcript containment
  Question: Does the run read session history only through
            scripts/collect-sessions, keep every artifact under the mktemp
            REPORT_DIR, and cite sessions by id plus paraphrase?
  Pass: No raw .jsonl read, nothing written into a user project, no digest
        line quoted in the report or in any committed file.
  Fail: A .jsonl is read directly, an artifact lands in a repository, or
        transcript content is quoted.

EVAL 9: Single-entry-point compliance
  Question: Across all SKILL.md / agent files, is `waza-runner.md` the
            only file that contains a direct `waza <subcommand>` call?
  Pass: rg -n "waza\s+(new|run|dev|quality|coverage)" the agents tree
        with -g '!waza-runner.md' -g '!waza-install.md' returns 0 hits.
  Fail: Any caller (skill, script, other agent) reaches the `waza` CLI
        directly.

```
