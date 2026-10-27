# Subagents in skill generation

Spawn one only when at least two hold: doing it inline would pull 500+ tokens of
raw data into the main context, it can run while the user answers or you draft,
and its result fits in a summary. Use `Explore` for read-only work and
`general-purpose` only when the worker must edit or run validation, picking
`model`/`effort` per call from [dispatch routing](model-selection.md#dispatch-routing).
Never pass a tier label as a model ID.

## Explore-1: Existing skill survey

Step 1, in the background while the user answers; read the summary before Step 2.
Skip it when `$ARGUMENTS` already gives the name, purpose and pattern.
Lightweight; Standard when similarities need interpretation across workflows.

```
Explore the skills directory to find:
1. All existing skill names (list folder names under skills/)
2. Any skills with similar purpose or naming to: {proposed_skill_topic}
3. Common patterns used (check SKILL.md frontmatter for model, disable-model-invocation)
4. Potential naming conflicts

Report as a brief summary: skill count, similar skills (name + one-line purpose), dominant patterns.
```

## Explore-2: Reference skill analysis

Step 4, in the foreground while drafting, when Step 1 found a similar skill
worth studying. Standard; Advanced for conflicting role ownership or policy
dependencies.

```
Analyze the skill at {similar_skill_path}:
1. SKILL.md structure: heading hierarchy, section count, use of references/
2. Frontmatter fields used
3. How instructions are organized (linear steps, conditionals, tables)
4. Any scripts/ or assets/ usage

Return a structural summary (not full content) that can inform SKILL.md drafting.
```

## Reviewer

Step 5, foreground, `general-purpose`, before the final report; the main agent
fixes what it finds. Standard for routine structure, Advanced for evidence
quality or workflow contracts, Frontier for unresolved broad tradeoffs.
Independence comes from a separate context with the evidence and without the
author's self-assessment, not from a different model.

```
You are reviewing a newly generated skill at {skill_path}.
You did NOT write this skill. Review it independently using these criteria:

1. Structure: Does the folder follow kebab-case? Is SKILL.md present? No README.md?
2. Frontmatter: Valid YAML? name matches folder? description has WHAT + WHEN?
3. References: Do all paths in SKILL.md point to existing files?
4. Instructions: Are they specific and actionable? Error handling included?

For any criterion where your PASS/FAIL call is low-confidence, seek a second
independent opinion through an available advisor or fresh-context reviewer.
Give that reviewer the relevant source evidence and the uncertain finding.
If unavailable, report the uncertainty instead of inventing an independent pass.

Report: PASS/FAIL per criterion, with specific issues for any FAIL.
Do NOT fix issues — only report them.
```
