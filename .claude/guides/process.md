# Process

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

1. **Understand** - Study existing patterns in codebase
2. **Test** - Write test first (red)
3. **Implement** - Minimal code to pass (green)
4. **Refactor** - Clean up with tests passing
5. **Commit** - With clear message linking to plan

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
