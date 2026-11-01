# Plan: skill audit follow-ups

Findings left open after the 2026-11-01 follow-up batch. Waza compares only against a
baseline carrying `suite_hash`. `generate-skills`, `generate-skills-trigger`,
`skill-improver` and `generate-agent-docs` have one; the other suites need one on their
next comparison.

## generate-agent-docs

- Regex graders keep rejecting correct paraphrases. Widening them moved the score from 0.985 to 0.991, but each run still fails a different trial, with no wrong answer seen so far. The regression threshold absorbs this; if a task-level signal is needed, use a `prompt` grader with a separate judge model instead of more regexes.
- `generic-docs-clarify` once wrote a test command after an ambiguous request instead of asking (1 of 3 `after` runs). The row already forbids it, so edit only if it recurs.
