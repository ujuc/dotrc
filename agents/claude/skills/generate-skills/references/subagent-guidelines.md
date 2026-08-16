# Subagent Guidelines for Skill Generation

> When and how to use subagents during skill generation. Tier 3 reference — load only when needed.

---

## Decision Criteria

Ask these 3 questions before spawning a subagent:

| # | Question | If Yes |
|---|----------|--------|
| 1 | Will the main agent accumulate 500+ tokens of raw data by doing this directly? | Subagent candidate |
| 2 | Can this run in parallel with user wait time or another task? | Subagent candidate |
| 3 | Can the result be delivered as a summary? | Subagent suitable |

**Rule**: 2+ Yes → use a subagent. All No → do it directly.

---

## Available Subagent Types

| Type | Strengths | Limitations |
|------|-----------|-------------|
| Explore | Fast codebase search, file pattern matching, keyword search | Cannot edit files or run arbitrary commands |
| general-purpose | Full tool access, autonomous multi-step tasks | Slower startup, heavier context |

**Default**: Prefer Explore for read-only investigation. Use general-purpose only when the task requires edits, validation scripts, or multi-tool orchestration.

---

## Workflow Integration

### Explore-1: Existing Skill Survey (Step 1)

**Trigger**: AskUserQuestion sent to user AND $ARGUMENTS lacks sufficient context.

**When to skip**: $ARGUMENTS already provides skill name, purpose, and pattern.

**Prompt template**:

```
Explore the skills directory to find:
1. All existing skill names (list folder names under skills/)
2. Any skills with similar purpose or naming to: {proposed_skill_topic}
3. Common patterns used (check SKILL.md frontmatter for model, disable-model-invocation)
4. Potential naming conflicts

Report as a brief summary: skill count, similar skills (name + one-line purpose), dominant patterns.
```

**Agent parameters**:
- `subagent_type`: `Explore`
- `description`: "Survey existing skills"
- `run_in_background`: `true` — the subagent runs independently; consume its summary only *after* AskUserQuestion returns and before starting Step 2.

---

### Explore-2: Reference Skill Analysis (Step 4)

**Trigger**: Step 1 identified a similar-pattern skill worth studying.

**When to skip**: No similar skills found, or the pattern is straightforward enough.

**Prompt template**:

```
Analyze the skill at {similar_skill_path}:
1. SKILL.md structure: heading hierarchy, section count, use of references/
2. Frontmatter fields used
3. How instructions are organized (linear steps, conditionals, tables)
4. Any scripts/ or assets/ usage

Return a structural summary (not full content) that can inform SKILL.md drafting.
```

**Agent parameters**:
- `subagent_type`: `Explore`
- `description`: "Analyze reference skill"
- `run_in_background`: `false` (result needed before finalizing draft)

---

### Reviewer: Independent Validation (Step 5)

**Trigger**: Generated skill includes `references/` or `scripts/` directories.

**When to skip**:
- Skill is minimal (SKILL.md only, no bundled resources)
- User explicitly requested fast generation

**Prompt template**:

```
You are reviewing a newly generated skill at {skill_path}.
You did NOT write this skill. Review it independently using these criteria:

1. Structure: Does the folder follow kebab-case? Is SKILL.md present? No README.md?
2. Frontmatter: Valid YAML? name matches folder? description has WHAT + WHEN?
3. References: Do all paths in SKILL.md point to existing files?
4. Instructions: Are they specific and actionable? Error handling included?
5. Size: SKILL.md under 500 lines / 5000 words?

For any criterion where your PASS/FAIL call is low-confidence, call advisor() for an independent opus second opinion before finalizing.

Report: PASS/FAIL per criterion, with specific issues for any FAIL.
Do NOT fix issues — only report them.
```

**Agent parameters**:
- `subagent_type`: `general-purpose`
- `model`: `sonnet`
- advisor: the reviewer calls `advisor()` (opus per settings `advisorModel`) for uncertain findings — a cross-model second opinion. advisor forwards only the reviewer's transcript, so the review stays blind.
- `description`: "Blind review generated skill"
- `run_in_background`: `false` (must receive results before reporting to user)

---

## Parallelism Rules

### Safe to parallelize

- Explore-1 + AskUserQuestion wait (independent)
- Explore-2 + SKILL.md draft writing (draft can incorporate results later)

### Must NOT parallelize

- Reviewer + final user report (reviewer results must be incorporated first)
- Multiple Explore agents querying overlapping file sets (redundant work)

### Execution timeline

```
Step 1: [Main]      AskUserQuestion ─── wait ──── response received
        [Explore-1] Survey skills ───── done ──┘

Steps 2-3: [Main only]

Step 4: [Explore-2] Analyze ref skill ── done ─┐
        [Main]      Draft SKILL.md ──────────── incorporate results

Step 5: [Main]      Run validate-skill
        [Reviewer]  Independent review ── results ── fix issues
```

---

## Anti-patterns

| Anti-pattern | Why it's wrong | Do instead |
|--------------|----------------|------------|
| Spawning a subagent for a single file read | Overhead exceeds benefit | Use Read tool directly |
| Running Explore when $ARGUMENTS has all info | Wastes tokens on known data | Skip Explore-1 |
| Letting Reviewer fix issues it finds | Breaks blind review independence | Main agent fixes based on report |
| Parallelizing dependent steps | Results arrive too late to use | Run sequentially |
| Spawning general-purpose for read-only tasks | Unnecessary tool access, slower | Use Explore instead |
