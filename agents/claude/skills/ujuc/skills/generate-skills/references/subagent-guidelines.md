# Subagents in skill generation

Spawn one only when at least two hold: doing it inline would pull 500+ tokens of
raw data into the main context, it can run while the user answers or you draft,
and its result fits in a summary. Use `Explore` for read-only work and
`general-purpose` only when the worker must edit or run validation, picking
`model`/`effort` per call from [dispatch routing](model-selection.md#dispatch-routing).
Never pass a tier label as a model ID.

## Explore-1: Existing skill survey

Step 1, in the background while the user answers; read the summary before Step 2.
Skip it when the request already gives the name, purpose and pattern.
Lightweight; Standard when similarities need interpretation across workflows.

Dispatch: "Read `<abs>/references/roles/skill-survey.md` first and follow it." plus the proposed topic and the absolute user and project skills directories.

## Explore-2: Reference skill analysis

Step 4, in the foreground while drafting, when Step 1 found a similar skill
worth studying. Standard; Advanced for conflicting role ownership or policy
dependencies.

Dispatch: "Read `<abs>/references/roles/reference-analysis.md` first and follow it." plus the skill path.

## Reviewer

Step 5, foreground, `Explore`, before the final report; the main agent
fixes what it finds. Standard for routine structure, Advanced for evidence
quality or workflow contracts, Frontier for unresolved broad tradeoffs.
Independence comes from a separate context with the evidence and without the
author's self-assessment, not from a different model.

Dispatch: "Read `<abs>/references/roles/reviewer.md` first and follow it." plus the skill path, the original or diff (empty for a new skill), scope, facts, user decisions and the repository rules that bind the target.
