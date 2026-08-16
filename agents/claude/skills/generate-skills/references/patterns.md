# Skill structural patterns

> Five structural patterns for skills, plus selection guidance.

---

## Pattern selector

| Pattern | Best fit | User interaction | Freedom |
|---------|----------|------------------|---------|
| Linear workflow | Tasks executed in a fixed order | Low | Low–medium |
| Interview-based | Requirements vary; needs user context | High | High |
| Tool orchestration | Combines several tools / APIs | Medium | Medium |
| Template fill | Produces a fixed-shape artifact | Low | Low |
| Validation / review | Quality-checks an existing artifact | Medium | Medium |

---

## 1. Linear workflow

Run a fixed sequence of steps in order.

### When to use

- Execution order is clear and there are few branches.
- Each step's input/output flows into the next (pipeline).
- Examples: build → test → deploy; create file → validate → commit.

### Skeleton

```markdown
## Step 1: Environment check
(check dependencies, prerequisites)

## Step 2: Generate code
(perform the core work)

## Step 3: Validate
(check results, run tests)

## Step 4: Wrap up
(commit, report)
```

### Trade-offs

- Pros: predictable, easy to debug, reproducible.
- Cons: not flexible, branching is awkward.

---

## 2. Interview-based

Talk to the user to gather requirements, then act.

### When to use

- The user's context / preference materially shapes the result.
- Requirements are ambiguous or have multiple valid choices.
- Examples: project setup, doc generation, design decisions.

### Skeleton

```markdown
## Step 1: Detect
(collect what can be inferred automatically)

## Step 2: Interview
(use AskUserQuestion to gather what's missing)
- Question 1: ...
- Question 2: ...

## Step 3: Generate
(act based on collected info)

## Step 4: Validate
(check results, get user approval)
```

### Trade-offs

- Pros: tailored output, higher user satisfaction.
- Cons: longer runtime; too many questions cause fatigue.

---

## 3. Tool orchestration

Combine several tools (built-ins, MCP servers, external CLIs) into a compound task.

### When to use

- A single tool cannot solve the task.
- Data flows between several systems.
- Examples: API call → transform → write file; Git + issue tracker integration.

### Skeleton

```markdown
## Prerequisites
(verify required tools / servers, check connectivity)

## Workflow
1. Query data from [tool A]
2. Transform
3. Push result to [tool B]
4. Verify

## Error handling
| Error | Cause | Resolution |
|-------|-------|------------|
| Connection refused | Server not running | ... |
```

### Trade-offs

- Pros: powerful automation, handles compound work.
- Cons: many dependencies, complex error handling, hard to debug.

---

## 4. Template fill

Produce an artifact by substituting variables into a fixed template.

### When to use

- Output shape is consistent and repetitive.
- Boilerplate generation.
- Examples: PR template, config files, doc skeletons.

### Skeleton

```markdown
## Input variables
- `$PROJECT_NAME`: project name
- `$AUTHOR`: author
- `$TECH_STACK`: tech stack

## Template

\```
# $PROJECT_NAME

Author: $AUTHOR
Stack: $TECH_STACK
\```

## Generation rules
(substitution rules, conditional inclusion criteria)
```

### Trade-offs

- Pros: consistent output, fast, easy to maintain.
- Cons: limited flexibility, hard to express complex logic.

---

## 5. Validation / review

Check an existing artifact against criteria and surface improvements.

### When to use

- Acts as a quality gate.
- Checklist-driven review.
- Examples: code review, doc validation, config audit.

### Skeleton

```markdown
## Subject
(identify target file/directory)

## Criteria
### Criterion 1: structure
- [ ] Item A
- [ ] Item B

### Criterion 2: content
- [ ] Item C

## Report
(pass/fail summary, suggested fixes)

## Re-validation
(after fixing failed items, re-run only those criteria)
```

### Trade-offs

- Pros: enforces quality, reproducible, easy to automate.
- Cons: criteria take time to write; over-validation hurts productivity.

---

## 6. Workflow composition patterns

Two ways to design step-to-step flow inside a complex skill.

### Sequential workflow

Use when execution order is clear and each step depends on the previous step's output.

**Principles:**
- Provide an overview before detailed steps.
- Define each step's input / output explicitly.
- State dependencies ("only after Step 2 completes").

```markdown
## Step 1: Environment check
(prerequisites)

## Step 2: Generate
(core work — requires Step 1 success)

## Step 3: Validate
(needs Step 2 output)
```

### Conditional workflow

Use when the path depends on user input or environment state.

**Principles:**
- Make branching logic explicit.
- Keep if/else branches to 2–3 max.
- Make all branches converge on the same goal.

```markdown
## Detect environment

- Config file exists → "update mode"
- Config file missing → "fresh-create mode"

### Update mode
(keep existing config, apply changes only)

### Fresh-create mode
(create everything with defaults)
```

---

## Combining patterns

Complex skills often combine patterns:

- **Interview + linear**: collect requirements, then run a fixed sequence (e.g., `generate-agent-docs`).
- **Linear + validation**: generate, then quality-check (e.g., `generate-skills`).
- **Tool orchestration + validation**: run automation, then verify the result.
- **Sequential + conditional**: a fixed flow that branches based on situation (e.g., update if config exists, create otherwise).

When combining, separate each pattern boundary with explicit step headings.
