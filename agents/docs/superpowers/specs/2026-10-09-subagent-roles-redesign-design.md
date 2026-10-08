# Subagent Roles Redesign — Design

Date: 2026-10-09
Status: Approved design, not yet implemented

## 1. Context

`agents/claude/agents/` (deployed as `~/.claude/agents/`) holds 11 custom
Claude Code subagents. Each is dispatched by exactly one skill. A read of every
definition against its caller (workflow `wf_ecfc47cb-432`) found:

- The output contracts that callers actually check are already restated in the
  calling skills (`implement-plan:89`, `deep-read:44-48`, `humanizer:128,141-149`).
  The agent files add only a tools allowlist and a model-profile paragraph.
- The model-profile paragraph is pasted verbatim into all 11 files and again
  into `agents/README.md`.
- `humanize-detector` and `humanize-naturalness-reviewer` implement the same
  taxonomy scan twice with different output schemas.
- `implementer` is only reachable in worktree mode, which `implement-plan:67`
  forbids in this repository.
- `agents/README.md` is stale: it claims `subagent_type` dispatch (only
  `deep-read` does that), cites a non-existent `implement-plan` "Step 5a", and
  says `writing-plans` consumes blocker/debug files (it does not).
- The repository's `subagent-guidelines.md` says `Explore` cannot run commands.
  The current harness `Explore` has every tool except `Agent`, `Edit`, `Write`,
  `NotebookEdit` and the artifact tools, so it can run checks and reproduce
  failures while being read-only.

The user's goals, in priority order: Claude Code is the main harness; use the
released model tiers per task instead of inheriting the session model
everywhere; fewer maintenance points; less per-turn context; revisit whether
the current role splits earn their keep.

## 2. Goals and non-goals

Goals:

1. Remove `agents/claude/agents/` and its README. Role instructions move under
   the owning skill as `references/roles/<role>.md`.
2. Dispatch only the built-in `Explore` and `general-purpose` types, with
   `model` and `effort` chosen per call from one shared routing table.
3. Merge `verifier`+`debugger` and `humanize-detector`+`humanize-naturalness-reviewer`.
4. Make `commit` the first skill that routes model by task size.

Non-goals:

- Changing `workflow-contract.json`, artifact paths, or archive behavior.
- Porting the dispatch primitive to Codex, Amp, or Pi. Role files are plain
  Markdown and stay readable there; dispatch stays Claude Code only, as today.
- Pinning `model:` or `effort:` in any file.

## 3. Target structure

```
agents/claude/skills/
  implement-plan/references/roles/verifier.md       # absorbs debugger
  implement-plan/references/roles/implementer.md
  deep-read/references/roles/researcher.md
  skill-improver/references/roles/skill-engineer.md
  humanizer/references/roles/monolith.md
  humanizer/references/roles/scanner.md             # detector + naturalness reviewer
  humanizer/references/roles/rewriter.md
  humanizer/references/roles/fidelity-auditor.md
  waza/SKILL.md                                      # waza-runner becomes one paragraph
```

A role file is the current agent body minus frontmatter and minus the pasted
model-profile paragraph. Model guidance becomes one link to
`generate-skills/references/model-selection.md`. Role files keep: inputs,
output format with exact headings or JSON keys, forbidden actions, advisor
budget, and any rule the worker must follow without CLAUDE.md (citation form,
`<!-- PARTIAL: reason -->` marker).

## 4. Dispatch

Every dispatch prompt has the shape: "Read `<absolute role path>` first and
follow it. Then: `<inputs, output target, task>`." The caller resolves the
absolute path from its own skill directory.

| Type | Roles | Why |
|---|---|---|
| `Explore` | verifier, researcher, skill-engineer, commit drafter | No `Edit`/`Write`, so read-only is enforced by the harness. `Bash` is available for checks and reproduction. The worker returns the report as text; the caller writes the artifact. |
| `general-purpose` | implementer, monolith, scanner, rewriter, fidelity-auditor | Must write their own output files. `implementer` adds `isolation: "worktree"` when repository policy allows worktrees. |

Consequences the callers absorb:

- `implement-plan` writes `.plans/.verify-{slug}.md` and
  `.plans/.verify-final-{feature}.md` from the verifier's returned text.
- `deep-read` writes `.research/.partial/{structure,dataflow,risks}.md` from the
  three researchers' returned text, including any `PARTIAL` marker.
- `skill-improver` prints the skill-engineer report it receives.
- `Explore` does not load CLAUDE.md, so role files carry every rule the worker
  needs.

## 5. Model and effort routing

Add this table and procedure to `model-selection.md`. All dispatches follow it.

| Profile | model / effort | Typical work |
|---|---|---|
| Lightweight | `haiku` / `medium` | Deterministic checks, structured extraction, commits touching ≤2 files and ≤40 changed lines, waza launcher runs |
| Standard | `sonnet` / `medium` | Bounded implementation, multi-file commits, focused exploration, research partial reports |
| Advanced | `opus` / `high` | Design, semantic review, synthesis, debugging, humanizer strict verifiers |
| Frontier | `fable` / `xhigh` | Interdependent problems unresolved at Advanced |

Procedure:

1. The skill classifies the step with its own stated rule and tells the user
   in one line which profile it chose and why.
2. If the step sits between two rows, ask with `AskUserQuestion` (options are
   the two rows).
3. Call `advisor` at most once, only when the choice materially changes cost
   or outcome and the evidence does not settle it.
4. Pass `model` and `effort` as `Agent` call arguments. Never write them into
   frontmatter. An explicit user model choice for the session or task wins.

`commit` applies it first: after staging, read `git diff --cached --shortstat`;
≤2 files and ≤40 lines → Lightweight, otherwise Standard; mixed or unclear
scope → ask before staging as today. The `Explore` drafter reads the cached
diff and recent log and returns subject + body; the skill keeps the 50/72
checks, the completion test, and the commit itself.

## 6. Role merges

### verifier + debugger

One `Explore` role. The report keeps the five mandatory lines (`build:`,
`typecheck:`, `lint:`, `tests:`, `errors:` as PASS/FAIL/SKIP) and the
60-second per-check timeout. When any line is FAIL, the same worker appends
`## Diagnosis` with `Symptom`, `Hypotheses` (ranked, each cited `file:line`,
or `Insufficient evidence — ...`), `Reproduction`, and `Suggested Fix`. The
final run also lists every active acceptance criterion with PASS/FAIL, which
`implement-plan:115` already requires but the old template lacked.

`implement-plan` stops creating `.plans/.debug-*.md`. The contract's
`debug_pattern` stays so archive keeps cleaning files from earlier runs, like
`plan_baseline_pattern` after the `annotate-plan` removal.

### humanize-detector + humanize-naturalness-reviewer → scanner

One `general-purpose` role with two modes:

- `baseline`: Phase A. Writes `02_detection.json` in the detector's current
  schema (findings with `category_label`, `suggested_fix`, `related_findings`;
  `category_summary`; `meta` with sentence stats, tell density, run_id).
- `review`: Phase C-2. Writes `05_naturalness_review{_vN}.json` in the
  reviewer's current schema, with the same five verdict strings the SKILL.md
  verdict table hard-codes. Receives the round number explicitly instead of
  inferring it from the `_vN` suffix.

Strict pipeline becomes scanner(baseline) → rewriter → [fidelity-auditor ∥
scanner(review)]. Rewriter and verifiers stay in separate contexts. User-facing
wording changes from "4인 파이프라인" to "3인 파이프라인"; `scripts/check-consistency`
check #1 changes to assert 3 and the file list points at the role files.
The fast-mode `track=monolith` wording stays because the eval suite greps it.

### implementer

Kept as a role file. Not dispatched in this repository, but `implement-plan`
is a user-global skill used elsewhere.

### waza-runner

Deleted. `waza/SKILL.md` gains one paragraph: callers that want an isolated
context dispatch `general-purpose` at Lightweight with the prompt "run
`bash <abs>/waza-run.sh <dispatch>` and return stdout verbatim".

## 7. Consumers to update

- `skill-improver/SKILL.md`: remove agent mode (Phase 1 step 2 classification,
  Dimension D, "Agent Definition Mode" section, `claude/agents/` sweep); role
  files are covered by B.5 reference integrity. Eval criterion 9 drops
  `waza-runner.md`. Add the skill-engineer dispatch (Explore, Advanced).
- `generate-skills/SKILL.md:270,296` and `references/subagent-guidelines.md`:
  replace "agent file" redundancy audit with the `references/roles/` pattern;
  correct the `Explore` capability description; document the routing table.
- `humanizer/LICENSE-THIRD-PARTY`: five agent paths → four role paths, note the
  detector/reviewer merge in "Modifications applied".
- `humanizer/scripts/check-consistency`: `FILES` paths, check #1 (3 agents),
  check #4/#5 targets (`NATURAL` → scanner).
- Docs: `agents/README.md`, `agents/claude/skills/README.md`,
  `agents/CLAUDE.md:3` (waza-runner), root `README.md:296` (waza-runner),
  `agents/AGENTS.md:19` ("reusable agents" wording).
- Evals: `deep-read`, `humanizer`, `implement-plan`, `skill-improver`,
  `generate-skills`, `waza` suites are the regression set.

## 8. Verification

- `validate-skill` passes for every touched skill; every `references/roles/`
  link resolves.
- `humanizer/scripts/check-consistency` PASS.
- `agents/hooks/test-workflow-hooks.sh` PASS (contract unchanged, so this is a
  no-regression check).
- waza before/after on the regression set from section 7, three trials each.
- One live run: `commit` on a ≤2-file change drafts through a `haiku` Explore
  worker; the user sees the one-line profile notice.
- `git grep` for the 11 old agent names returns hits only under `agents/docs/`
  and `docs/`.

## 9. Risks

- `Explore` returning long reports as text costs main-context tokens that a
  file write avoided. Verifier and researcher outputs are bounded (five lines
  plus diagnosis; two H1 sections), so the cost is small.
- A `general-purpose` worker can edit source. The humanizer and implementer
  role files forbid it in prose, as the old `Write`-only allowlist did only
  partially (Write could already overwrite any path).
- Merging the scanner changes the humanizer strict trigger phrase. Users who
  type "4인 파이프라인" still reach strict through `--strict`.
- Whether `Explore` receives the `advisor` tool is harness-dependent; role
  files treat advisor as optional and never require it.
