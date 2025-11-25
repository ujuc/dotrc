# Process

<meta>
Document: process.md
Role: Process Guide
Priority: High
Applies To: All development workflows and problem-solving tasks
</meta>

<context>
This document defines the development process, from planning through implementation to troubleshooting. Following this structured approach ensures consistent, high-quality code delivery.
</context>

## 1. Planning & Staging

Break complex work into 3-5 stages. Document in `IMPLEMENTATION_PLAN.md`:

```markdown
## Stage N: [Name]

**Goal**: [Specific deliverable]
**Success Criteria**: [Testable outcomes]
**Tests**: [Specific test cases]
**Status**: [Not Started|In Progress|Complete]
```

- Update status as you progress
- Remove file when all stages are done

## 2. Implementation Flow

<thinking_process>
Before implementing any change, explicitly work through these steps and show your reasoning:

### Step 1: Understand
**Study existing patterns in codebase**

<think>
Before writing any code, ask yourself:
- What similar features or functions already exist in this codebase?
- What patterns, libraries, and conventions do they use?
- What architectural decisions have been made?
- Are there any related tests I can learn from?

**Action**: Search for similar implementations, read relevant code, document findings
**Output**: "I found X similar implementations that use pattern Y"
</think>

### Step 2: Test
**Write test first (red)**

<think>
Before implementing the feature:
- What behavior needs to be tested?
- What are the edge cases? (null values, empty inputs, boundary conditions)
- What should happen in error scenarios?
- How will I verify correctness?

**Action**: Write failing tests that describe the desired behavior
**Output**: "Test written, currently failing as expected"
</think>

### Step 3: Implement
**Minimal code to pass (green)**

<think>
When writing the implementation:
- What is the simplest code that will make the tests pass?
- Am I following the patterns found in Step 1?
- Am I only changing what was explicitly requested?
- Does this introduce any breaking changes?

**Action**: Write minimal implementation to pass tests
**Output**: "Implementation complete, all tests passing"
</think>

### Step 4: Refactor
**Clean up with tests passing**

<think>
After tests are green:
- Can this code be simpler or more readable?
- Are variable and function names clear and descriptive?
- Does it follow the project's coding conventions?
- Are there any code smells or duplication?

**Action**: Improve code quality while keeping tests green
**Output**: "Refactored for clarity, tests still passing"
</think>

### Step 5: Commit
**With clear message linking to plan**

<think>
Before committing:
- What changed and why did it change?
- Does the commit message explain the motivation?
- Are all tests still passing?
- Should this be split into smaller commits?

**Action**: Create commit with proper format (see version-control.md)
**Output**: "Committed with message: [type]: [description]"
</think>
</thinking_process>

<instruction>
When implementing changes, explicitly state which step you're on and show your thinking process. This helps catch issues early and ensures nothing is missed.

Example:
"**Step 1: Understanding** - I'm searching for existing authentication implementations..."
"**Step 2: Testing** - Writing test for invalid password scenario..."
</instruction>

## 3. When Stuck (After 3 Attempts)

**CRITICAL**: Maximum 3 attempts per issue, then STOP.

1. **Document what failed**:

- What you tried
- Specific error messages
- Why you think it failed

2. **Research alternatives**:

- Find 2-3 similar implementations
- Note different approaches used

3. **Question fundamentals**:

- Is this the right abstraction level?
- Can this be split into smaller problems?
- Is there a simpler approach entirely?

4. **Try different angle**:

- Different library/framework feature?
- Different architectural pattern?
- Remove abstraction instead of adding?

## Problem Solving Rules (CRITICAL)

- **Fix root causes** - Do not rely on quick fixes that only mask symptoms
- **Improve, don't band-aid** - Do not solve issues by just increasing memory, retries, or suppressing warnings
- **Sustainable solutions** - Choose solutions that improve performance, stability, and maintainability

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Philosophy](../philosophy.md) - Development philosophy and principles
- [Quality Assurance](../quality-assurance.md) - Testing and quality gates
- [Guidelines](../guidelines.md) - Emergency procedures and getting help
