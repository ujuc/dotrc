# Plan: skill audit follow-ups

Findings from the targeted `skill-improver` run on 2026-11-01 that were left open.
Each predates that day's edits, or needs a decision. Work them per skill, with a
Waza run against the current baseline; a suite edit needs a new baseline.

## Needs a decision

| Item | Options |
| --- | --- |
| Humanizer role files are in Korean while the SKILL.md body is English | Treat them as linguistic rulebooks, or translate them |
| Humanizer `강도: 보수\|기본\|적극` has no consumer | Remove it, or define what each value does |

## Borrowing from `writing-skills`: awaiting approval

Both plans below are unapplied. `superpowers-upstream check` reports later upstream changes.

### Force without emphasis

The persuasion reference cites a study of compliance with objectionable requests, so its
33% to 72% figure says nothing about adherence to a skill. `generate-agent-docs`
already fails IMPORTANT, ALL CAPS and MUST in project docs. Use the first level that holds:

1. **Enforce it**: a hook, deny rule, validator or test, for a rule with no exceptions.
2. **Force it in plain words**, only when a baseline shows the agent knows the rule and
   skips it: an observable trigger with its action ("after X, before Y, run Z"), a required
   choice or status line, a rationalization table of verbatim excuses, and "no exceptions"
   only for a rule that has none.
3. **Emphasis**: capitals or MUST ship only when a micro-test beats the plain wording.

Never use false urgency, guilt, or a claim such as "every time" that nobody measured.
Apply per skill type: discipline gets levels 1 to 3, technique and pattern get plain
imperatives, and reference gets none.

Changes: a short section in `guidance-testing.md`; replace "ALWAYS use this exact format" in
`design-principles.md`; one micro-test of a real rule, plain against emphasized, 5+ reps
against a control.

Decide: whether level 3 is allowed or emphasis is banned; whether the micro-test runs now.

### Checklists and flowcharts

Upstream has no schedule table. It has a creation checklist and flowchart guidance with a
renderer. No local skill uses a flowchart, and `dot` and `mmdc` are not installed.

- **Checklist**: keep Step 5 and `Eval Criteria` as the only list. Create one todo per Step 5
  gate, only if a session shows a skipped gate; the behavior baseline is the first candidate.
- **Flowchart**: allow one only for a non-obvious decision or a loop that stops early,
  written inline as Mermaid so it needs no install and renders on GitHub.
- **Human view**: use `artifact-diagramming` rather than porting `render-graphs.js`.

Decide: Mermaid or Graphviz; whether to add the todo rule before session evidence exists.

## generate-skills

- Update and Create routes never name the Behavior baseline section; `create-mode.md:3` places it differently.
- `subagent-guidelines.md`: the Reviewer prompt assumes a new skill and takes no originals or diff. It dispatches as `general-purpose` though it only reads. Prompts sit inline rather than under `references/roles/`.
- `evals/generate-skills/behavior-cases.md:10` describes a U3 confirmation that no longer exists.
- `skill-diet-upstream` can print release notes where the skill says one line.
- `create-mode.md:34` overstates the placeholders, and `:42` lists a rule the validator does enforce.
- `init-skill` usage omits `--group`, and its next steps print CWD-relative commands.

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

## generate-agent-docs

- `authorization` passed 0/3 to 1/3 in recent runs; its required limit wording is the narrowest grader left.
- `generic-docs-clarify` once wrote a test command after an ambiguous request instead of asking.
- Cached quotes in `claude-code-best-practices.md` were checked against the earlier copy; about six did not match upstream by plain string.
