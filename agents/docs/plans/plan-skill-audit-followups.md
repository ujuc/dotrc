# Plan: skill audit follow-ups

Findings from the targeted `skill-improver` run on 2026-11-01 that were left open.
Each predates that day's edits, or needs a decision. Work them per skill, with a
Waza run against the current baseline; a suite edit needs a new baseline.

## Needs a decision

| Item | Options |
| --- | --- |
| Humanizer role files are in Korean while the SKILL.md body is English | Treat them as linguistic rulebooks, or translate them |
| Humanizer `강도: 보수\|기본\|적극` has no consumer | Remove it, or define what each value does |

## generate-skills

- Update and Create routes never name the Behavior baseline section; `create-mode.md:3` places it differently.
- `subagent-guidelines.md`: the Reviewer prompt assumes a new skill and takes no originals or diff. It dispatches as `general-purpose` though it only reads. Prompts sit inline rather than under `references/roles/`.
- `evals/generate-skills/behavior-cases.md:10` describes a U3 confirmation that no longer exists.
- `skill-diet-upstream` can print release notes where the skill says one line.
- `create-mode.md:34` overstates the placeholders, and `:42` lists a rule the validator does enforce.
- `init-skill` usage omits `--group`, and its next steps print CWD-relative commands.
- `SKILL.md` U2 step 8 lets a drift report select cache maintenance, which contradicts the Authority section and Step 0; `guidance-testing.md` updates its date with no scope condition.
- Eval Criteria 4 turns the 500-line recommendation into a hard limit, while Step 5 calls the warning a backstop.
- Step 0 "go to the mode's first step" skips the upstream relay inside the check interval.
- `create-mode.md` Step 3 "ask only if placement remains unclear" conflicts with the rule that `group` is never guessed.
- `design-principles.md` applies a model-specific finding as a global default, and its "recipe hinders" line needs reconciling with the recipe form in `guidance-testing.md`.
- Both `quality-evidence` tasks echo `UNVERIFIED` from the prompt into the grader, and no grader measures triggering. Natural-language create, update, diet and small-edit routes are not in the suite.
- A full diet request can reach `skill-diet` directly and skip Step 0 and Step 5. `skill-diet/` is a verbatim subtree, so the boundary must live here or be accepted.

## waza

- The launcher cannot detect a changed task or grader under the same `test_id`; a suite content hash would close that.

## humanizer

- `기술 문서` is the proactive default but is not a `genre_hint` value for the monolith.
- `patterns-ko.md`: K3 allows asserting facts against the no-strengthening rule, and its examples add or drop content. Its header still calls it the Korean fast catalog.
- `patterns-common.md:3` claims the Korean fast track uses it.
- Genre estimation has three disagreeing rules (`SKILL.md:55`, `:149`, `playbook-ko.md:156`).
- `quick-rules.md:7` claims 1:1 taxonomy IDs, but five rows differ.
- `strict.md`: no step produces N/6, and two grade definitions exist.
- `over_polish_aborted` exists only in the monolith; the rewriter has no such flag.
- Redo rows have no English severity mapping, and redo names a `03_rewrite_v2.md` a fast run lacks.
- `playbook-ko.md:32` removes a possibility modal against A-10.
- `taxonomy-ko.md` and `playbook-ko.md` keep pre-merge role names.

## skill-improver

- `SKILL.md:19` names review triggers in Phases 2, 4 and 5 that the diet removed.
- `evals.md:12` requires a rubric label that no step asks for.
- The `group-stays-manual` grader only checks the word "seven", and the suite calls itself trigger probes without measuring triggers.
- `.claude/skills/` resolves under `agents/`, not the repository root, and differs from `skill-engineer.md:13`.
- `allowed-tools` does not cover the direct `./script --help` runs.
- B.7 flags `skill-diet`'s English description, which must stay verbatim.
- `SKILL.md:65` and `eval-guide.md` disagree on whether `regex_match` graders count as low signal.
- Phase 5 step 4 applies UNVERIFIED to optional evidence, though the term means required evidence is missing.
- "Review, don't run" and "the only measurement" conflict with Dimension C running each script.
- The Explore dispatch has no fallback for a host without `Agent`.

## generate-agent-docs

- `authorization` passed 0/3 to 1/3 in recent runs; its required limit wording is the narrowest grader left.
- `generic-docs-clarify` once wrote a test command after an ambiguous request instead of asking.
- Cached quotes in `claude-code-best-practices.md` were checked against the earlier copy; about six did not match upstream by plain string.
