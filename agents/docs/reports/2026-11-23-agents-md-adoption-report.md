# AGENTS.md adoption — execution report

Date: 2026-11-23
Commits: `f02ae37`, `089d8b8`, `afbf91b`, `3cd1c96`, `e8d56ba` (pushed to `origin/main`)
Reverses: `29093f6` (generate-agent-docs writes CLAUDE.md only) and `173840d`
(instructions folded into CLAUDE.md), made when this repository served Claude
Code alone. Codex, omp and pi now read the same instructions.

## Outcome

- **generate-agent-docs manages AGENTS.md.** Shared rules go in AGENTS.md;
  CLAUDE.md starts with `@AGENTS.md` and keeps only Claude Code–specific lines
  (its tools, slash commands, hooks, settings, plan mode). No rule lives in
  both.
- **dotrc follows the same layout.** Root, `agents/` and
  `agents/claude/skills/` each have an AGENTS.md with a sibling CLAUDE.md that
  imports it.
- **Global guidance is shared across harnesses.**
  `agents/claude/AGENTS.global.md` holds the harness-neutral user-global rules.
  `agents/claude/CLAUDE.md` (`~/.claude/CLAUDE.md`) imports it and keeps
  advisor, Explore/Workflow, Skills and humanizer rules. `install.sh --agents`
  links the shared file to `~/.codex/AGENTS.md`, `~/.omp/agent/AGENTS.md` and
  `~/.pi/agent/AGENTS.md`.

## Research basis

| Source | Finding that shaped the design |
| --- | --- |
| [agents.md](https://agents.md/) | Plain Markdown, no required fields; the nearest file wins; nested files per package |
| [Claude Code memory](https://code.claude.com/docs/en/memory.md) | By default Claude reads AGENTS.md only when no CLAUDE.md, `.claude/CLAUDE.md` or `CLAUDE.local.md` sits at or above cwd. The `instructionFiles` setting works only in user or managed settings, so projects need the official `@AGENTS.md` + `## Claude Code` shape |
| [Codex AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md.md), `codex-rs/core/src/agents_md.rs` | Global `~/.codex/AGENTS.md`; project files from git root to cwd; `@path` is not expanded; `project_doc_max_bytes` (32 KiB default) budgets project files only, not the global file |
| [omp context files](https://github.com/can1357/oh-my-pi/blob/main/docs/context-files.md), `packages/coding-agent/src` | User-global `~/.omp/agent/AGENTS.md`. When AGENTS.md and CLAUDE.md share a directory, AGENTS.md wins and CLAUDE.md is not loaded. Task subagents drop files named AGENTS.md, so they get no project or user-global instructions |
| pi | User-global `~/.pi/agent/AGENTS.md`; AGENTS.md or CLAUDE.md in parent directories |

The cached research lives in
`agents/claude/skills/ujuc/skills/generate-agent-docs/references/agents-md-best-practices.md`
(restored from `29093f6^` and rewritten).

## User decisions

- **CLAUDE.md-only repositories**: the skill keeps writing CLAUDE.md and only
  proposes the split. It splits on approval or when the user names AGENTS.md.
  New repositories get both files from the start.
- **dotrc**: split all three project instruction files.
- **Global links**: Codex, omp and pi.
- **Global file name**: `AGENTS.global.md`, approved after the fact (see
  Deviations). A file named AGENTS.md inside `agents/claude/` would also load as
  a project-level file whenever Codex, omp or pi works under that directory.
- **omp task subagents**: no workaround (option A). The parent puts the rules
  a subagent needs into its task prompt, as omp intends. Rejected: disabling
  the `agents-md` provider for dotrc only, which lets CLAUDE.md win so the
  imported text reaches subagents but depends on an omp internal; and a
  `.omp/RULES.md`, which would duplicate AGENTS.md rules.

## Skill behavior (generate-agent-docs)

| Repository state | Behavior |
| --- | --- |
| Neither file | Run `/init` for the draft, then split it into AGENTS.md and a CLAUDE.md that imports it |
| AGENTS.md only | Update AGENTS.md. Create CLAUDE.md only for a Claude-only line or when the user names it, and report any nested AGENTS.md it would hide |
| Both, with import | Place each line by ownership |
| Both, no import | Write CLAUDE.md as if alone; propose the import |
| CLAUDE.md only | Write CLAUDE.md; propose the split once |

AGENTS.md never names a Claude tool or slash command and never uses an `@path`
import. The skill never writes `AGENTS.override.md` or `AGENTS.local.md`: Claude
Code ignores both. A rule meant for one agent goes in AGENTS.md, worded for
that agent. A path rule every agent needs goes in a nested AGENTS.md, not in
`.claude/rules/`. The verifier reports the project AGENTS.md chain's bytes and
FAILs only when the run itself adds bytes beyond 32 KiB.

Related edits: `skill-routing.md`, the commit skill's doc-update step and
scope source, skill-improver's `change-bar.md`, and `skills/README.md`.

## Verification

| Check | Result |
| --- | --- |
| `validate-skill` generate-agent-docs, commit | PASS |
| `skill-diet-eval check` (links, anchors) | PASS, 17 files |
| Waza, first run after the policy change (1 trial) | 19/21. `session-placement` failed 3 times in 6 trials across this run and a 3-trial rerun: a team rule was sent to AGENTS.md in a CLAUDE.md-only repository, and a personal preference was read as "Claude-only". Fixed in SKILL.md |
| Waza after that fix (3 trials) | 63/63 |
| Waza after trigger additions, compared with the run above | 63/63 → 63/63, no regression |
| Waza after the review fixes, new suite with 22 tasks (3 trials) | 65/66. The one miss was the model misspelling the answer key (`REMAVAL`); the verdict itself was correct |
| Waza after the refuter fixes (3 trials) | 66/66 |
| Grader regexes, Python replay | 6 correct answers pass, 7 wrong answers fail, as intended |
| Live loading of `AGENTS.global.md` | Claude Code, Codex and omp each reported the "Global Agent Guidance" heading. Codex inside dotrc listed `~/.codex/AGENTS.md` and the root `AGENTS.md`. pi 1.6.0 (`-p --no-session`) reported the heading, quoted the first Agent Identity bullet verbatim, and inside dotrc listed `~/.pi/agent/AGENTS.md` and the root `AGENTS.md` |
| `install.sh` preflight | Passes for the three existing links; stops on a regular file at the destination |
| Split preservation | Every line of the four original CLAUDE.md files is in the new pair, except 8 lines deliberately reworded for the new layout; no line appears in both files of a pair |
| omp precedence at one depth | Two throwaway repositories, one with unrelated AGENTS.md and CLAUDE.md and one with CLAUDE.md = `@AGENTS.md` + a Claude-only line: omp loaded only AGENTS.md in both. A task subagent saw neither file. Source agrees: both providers have priority 10, equal priorities keep registration order (`capability/index.ts:179`), `agents-md` registers before `claude-md` (`discovery/index.ts`), and the first item wins (`capability/index.ts:285`). This is registration order, not documented behavior |

The Waza suite contains decision probes only (the eval model answers about the
SKILL.md body; no files are written). The artifact cases below are separate.

## Artifact eval (behavior-cases.md)

Run on 2026-11-23/24 with `skill-diet-eval run` and `diet-adapter-claude`:
one isolated Claude Code session per run (`claude-opus-5-5`), the skill copy
as its only skill, a throwaway git repository per case, and a shell check on
the final files plus answer regexes. Before any session, each check was run
on the untouched fixture: every write case fails there, and the read-only
cases pass only through their answer regexes. Results live in
`~/.claude/data/skill-diet/generate-agent-docs-artifacts-20261123/`
(gitignored).

| Round | Cases × runs | Result |
| --- | --- | --- |
| 1, skill at `e8d56ba` | 19 × 3 | 54/57 |
| 2, after the fixes below, affected and short-route cases | 7 × 3 | 21/21 |
| 3, remaining cases (selected-only, stop-preserved, rare-language, colleague) | 4 × 3 | 12/12 |
| 4, after the guidance redesign below (cache-default, import-kept, pair-new) | 3 × 3 | 9/9 |

Passing in round 1 and not rerun (12 cases, 36/36): agent-specific,
agents-beside, agents-request, anti-trigger, audit-only, authorized-update,
missing-import, named-claude, nested-sibling, policy, restriction,
shared-path-rule. Rerun in round 2: pair-new, placement, import-kept,
agents-only-short, standalone-claude, codex-bytes-pre, codex-bytes-push.

The three round-1 misses and what changed:

- **standalone-claude**: correct behavior. The agent translated the Korean
  rule into English to match the file; the check looked only for `일회용`.
  The check now accepts `일회용|disposable`.
- **codex-bytes-pre** (39 KB chain, run edits only CLAUDE.md): one run gave
  the size in lines, not bytes. The short route skips U1's size inventory, and
  a run that does not touch AGENTS.md has no byte duty, so the expectation now
  requires AGENTS.md unchanged and no FAIL. A size note, if any, is an
  observation.
- **codex-bytes-push** (32,644-byte chain plus a dictated rule): runs
  disagreed. One put the rule at the top and pushed an old rule past the cap.
  Another shortened the user's wording to end 3 bytes under it. Neither was
  backed by the skill. Rule added (stage3-generator.md, update-mode.md
  dictated row, verifier check 3, agents-md-best-practices.md): text that
  would push the project chain past 32 KiB is not written as is. The run
  reports the bytes and proposes a shorter wording that keeps every fact, or a
  nested AGENTS.md, then waits for approval; headless runs leave the write
  pending. In round 2 all three runs left AGENTS.md unchanged and proposed
  the options. The answer regex was widened after the fact to accept "cut-down
  version"; that run's behavior matched the rule.

Round 3 behavior: selected-only edited only the nested file and proposed the
root fix and split; stop-preserved kept the "Think harder" line under the team
decision; rare-language ran `/init`, then wrote an AGENTS.md naming Gleam with
a link to its documentation and a CLAUDE.md of `@AGENTS.md`; colleague
rewrote the vague release line from the supplied facts.

Not run, because they need injected tool failures, fetch responses or
reviewer patches: cache-drift, tools, no-interview, evidence, review-states,
final-reference. Also not run: session-capture, broken-pointer and
summary-growth, whose decisions the Waza probes cover.

## Guidance freshness redesign

Rounds 1–3 showed that 18 of 87 skill runs had skipped Stage 0's "fetch the
best-practices page on every run" rule, mostly small updates, with no effect
on results. Fetching every run also made the bundled copy a fallback rather
than a cache, and it cost context tokens each time. The user chose to move the
freshness check into the skill-update notification:

- `upstream-check` (relayed by generate-skills Step 0 and skill-improver
  Phase 0) now also fetches each cached reference's upstream URLs and compares
  their sha256 with a `source_sha256` block in the reference's frontmatter. A
  changed page prints `source changed (...); run: /ujuc:generate-skills
  <skill> 업데이트`. `upstream-check hashes <file>` prints a fresh block. Ten
  source URLs fetched twice a second apart hashed identically. HTML pages can
  still change on a site deploy; that error only means one extra update run.
- Project runs of generate-agent-docs use the bundled rulebooks and state the
  cache date in one line. They fetch live only when the user asks.
- generate-skills fetches its frontmatter spec only when `upstream-check`
  reports it changed. Only an update run refreshes a cached reference, its
  hashes and `last_upstream_check`, after reviewing the content.
- `check_interval_days` was removed from the six references this covers.
  `guidance-testing.md` stays commit-pinned under `superpowers-upstream`.
- The redesign commit recorded no hashes. Recording one asserts that the cache
  matches today's page, and that needs a content review first.
- Baseline review on 2026-11-24, one fresh reviewer per reference, each
  checking every quote and sourced fact against the live pages it fetched:
  - claude-code-best-practices.md: one quote made verbatim, one source tag
    corrected to memory.md. memory.md's hash had changed since 2026-11-23.
  - agents-md-best-practices.md: omp discovery now notes the walk through
    enclosing workspace directories up to home.
  - tdd-agent-loop.md: two quotes made verbatim (capital "At",
    curly quotes).
  - frontmatter-spec.md: `paths` adds that the primary working directory
    holds after a `cd`, and one error message is joined onto a single line as
    upstream prints it.
  - context-engineering-claude5.md and model-prompting-guides.md: no drift.
    The secondary page lists 9 model guides, all already tracked.
  - No behavior-changing drift was found.
  - Each reviewer's reported sha256 matched `upstream-check hashes`.
  - `upstream-check` now prints `sources unchanged (cached 2026-11-24)` for
    all six references.
  - The agentskills.io HTML hash differed from a test fetch earlier the same
    day, so that HTML page may raise false `source changed` lines.

Verification: Waza baseline on the unchanged skills with the updated suites,
then after the change (3 trials each).

| Skill | Before | After |
| --- | --- | --- |
| generate-agent-docs (`cache-ownership` probe rewritten) | 21/22, `cache-ownership` failed 3/3 | 22/22 |
| generate-skills (new `spec-freshness` probe) | 5/6, `spec-freshness` failed 3/3 | 6/6 |
| skill-improver | 3/3 | 3/3 |

Round 4 above made no fetch in 9 of 9 runs. 8 of the 9 runs stated the
cache date. `upstream-check test` passes. A scratch reference with a real
block reported `sources unchanged`, and `source changed` after one hash was
altered.

## Independent review

skill-improver (run headless through `claude -p`) found no mechanical defects.
It left one manual item: `when_to_use` lacked AGENTS.md trigger phrases. Those
were added in `3cd1c96`.

Two independent reviewers, followed by a refutation pass, found these issues.
All were fixed in `e8d56ba`:

- The red flag against shared rules in CLAUDE.md contradicted the "Both, no
  import" and short routes. The verifier, the final check and the blind
  reviewer would fail a state the skill told them to leave.
- With AGENTS.md alone, a new CLAUDE.md came without `@AGENTS.md` and hid every
  AGENTS.md from Claude.
- The cached research wrongly counted Codex's global file against the 32 KiB
  budget (checked against the Codex source), and the verifier failed even
  excess that predated the run.
- A shared path rule could land in `.claude/rules/`, where other agents never
  see it. Personal rules pointed at `~/.claude/CLAUDE.md` only.
- Old "missing CLAUDE.md" trigger wording remained in SKILL.md and the
  best-practices cache, and the commit skill had no destination for shared
  rules in a CLAUDE.md-only repository.
- Eval gaps: `portability.yaml` was added. The `placement` and `pair-setup`
  graders let hedged or duplicated answers pass. Six behaviors are now recorded
  as artifact cases (nested sibling CLAUDE.md, AGENTS.md-only short route,
  shared path rule, Codex bytes, agent-specific rule, file restriction).

## Deviations and resolution

| Deviation | Resolution |
| --- | --- |
| Some files were written with shell heredoc or `sed` instead of the edit tool (eval tasks by the main agent; the four CLAUDE.md rewrites by a subagent) | The preservation check above confirmed the content. Later edits used edit/write |
| The global file was named `AGENTS.global.md` although `agents/claude/AGENTS.md` had been approved | User approved keeping it |
| The `install.sh` commit landed before the commit that created its link source | Commits were reordered with a rebase before the push; the final tree is unchanged |
| A subagent added the README section at the wrong heading level | Fixed before commit |

## Local, untracked change

`.claude/settings.local.json` (globally gitignored): `skillOverrides` entries
`autoresearch` and `prompting-assist` had no effect, because `skillOverrides`
does not apply to plugin skills and both are `ujuc` plugin skills. They became
`permissions.deny` rules `Skill(ujuc:autoresearch)` and
`Skill(ujuc:prompting-assist)`. A headless check of `ujuc:prompting-assist`
returned "Skill execution blocked by permission rules". Both descriptions still
appear in the skill listing.

## Open items

- No session evidence yet for the new ownership policy. The skill-improver
  digests predate `f02ae37`.
- Claims that these references source to pages outside their frontmatter
  (Codex and omp source code; code.claude.com model-config and hooks) were not
  re-checked in the baseline review.
