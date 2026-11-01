# Plan: skill audit follow-ups

Findings left open after the 2026-11-01 follow-up batch. Waza compares only against a
baseline carrying `suite_hash`, so each suite needs a new baseline on its next comparison;
`generate-skills` and `skill-improver` already have one.

## generate-skills

- No suite measures triggering. It needs a separate suite with `inject_skill_body: false`, a `skill_invocation` grader and the small-edit boundary, which lives only in `description`.
- The `description` now keeps full diets here, but `skill-diet`'s verbatim description still claims them, so a direct diet can skip Step 0 and Step 5.

## generate-agent-docs

- The baseline is 0.985. `authorization` missed a different regex in each of its three trials and `policy-preservation` failed two of three, so widening one regex would not fix either; read the answers before changing a grader.
- `generic-docs-clarify` once wrote a test command after an ambiguous request instead of asking (1 of 3 `after` runs). The row already forbids it, so edit only if it recurs.
