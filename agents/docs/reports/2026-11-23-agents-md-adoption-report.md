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
| [omp context files](https://github.com/can1357/oh-my-pi/blob/main/docs/context-files.md) | User-global `~/.omp/agent/AGENTS.md`. Task subagents drop files named AGENTS.md but keep AGENTS.md text imported through CLAUDE.md |
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
| Live loading of `AGENTS.global.md` | Claude Code, Codex and omp each reported the "Global Agent Guidance" heading. Codex inside dotrc listed `~/.codex/AGENTS.md` and the root `AGENTS.md`. pi was not run |
| `install.sh` preflight | Passes for the three existing links; stops on a regular file at the destination |
| Split preservation | Every line of the four original CLAUDE.md files is in the new pair, except 8 lines deliberately reworded for the new layout; no line appears in both files of a pair |

The Waza suite contains decision probes only (the eval model answers about the
SKILL.md body; no files are written). The artifact cases in `behavior-cases.md`
were not run.

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
- Artifact cases in `behavior-cases.md` have not been executed.
- When AGENTS.md and CLAUDE.md sit in the same directory, which file omp loads
  is undocumented (both have priority 10). Either outcome delivers the content,
  but omp task subagents keep it only if CLAUDE.md wins.
- pi loading of `~/.pi/agent/AGENTS.md` is unverified.
