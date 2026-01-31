# Process

<meta>
Document: process.md
Role: Process Guide
Priority: High
Applies To: All development workflows and problem-solving tasks
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document defines the development process from planning to implementation to problem solving.
Following this structured approach ensures consistent, high-quality code delivery.
</context>

<your_responsibility>
As Process Guide, you must:
- **Plan before coding**: Break down complex tasks into steps
- **Verify each step**: Confirm each step is complete before proceeding
- **Document progress**: Clearly record progress
- **Handle failures gracefully**: Debug systematically when issues occur
</your_responsibility>

## Parallel Operations Guide

<parallel_operations>
Claude 4.x excels at parallel tool execution. Use it for efficiency:

**Run in parallel:**
- Read multiple files simultaneously
- Run independent searches concurrently
- Execute commands without dependencies simultaneously

**Run sequentially:**
- Tasks that depend on previous results
- When one task's output is the next task's input

Example:
```
# Parallel: Read 3 files simultaneously
Read(file1.ts) + Read(file2.ts) + Read(file3.ts)

# Sequential: Create directory then create file
mkdir project && touch project/index.ts
```
</parallel_operations>

## 1. Planning and Step Organization

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

If unresolved after 3 attempts, stop and consider different approaches.
Repeating the same method is inefficient.

1. **Document what failed**:
   - What was attempted
   - Specific error messages
   - Estimated cause of failure

2. **Research alternatives**:
   - Find 2-3 similar implementations
   - Document alternative approaches

3. **Check fundamentals**:
   - Is this the right abstraction level?
   - Can the problem be split into smaller parts?
   - Is there a completely different, simpler approach?

4. **Try different angle**:
   - Different library/framework features?
   - Different architectural pattern?
   - Remove abstraction instead of adding?

## Problem Solving Principles

- **Fix root cause**
  Avoid band-aids that only hide symptoms.
  Fixing the root cause prevents the problem from recurring.

- **Improve, not band-aid**
  Don't solve problems by increasing memory, retry counts, or suppressing warnings.
  This only postpones the problem.

- **Sustainable solutions**
  Choose solutions that improve performance, stability, and maintainability.

## Troubleshooting Decision Tree

<decision_tree>
Use this systematic approach when debugging issues or making technical decisions.

### Level 1: Initial Assessment

<node id="start">
<question>What type of issue are you facing?</question>
<options>
- **Compilation/Build Error** → Go to [Compilation Issues](#node-compilation)
- **Runtime Error** → Go to [Runtime Issues](#node-runtime)
- **Logic Bug** → Go to [Logic Issues](#node-logic)
- **Performance Issue** → Go to [Performance Issues](#node-performance)
- **Test Failure** → Go to [Test Issues](#node-test)
- **Unclear Requirements** → Go to [Clarification Needed](#node-clarify)
</options>
</node>

### Level 2: Specific Issue Trees

<node id="node-compilation">
<category>Compilation/Build Errors</category>

**Step 1: Read the error message**
<decision>
Does the error message clearly indicate the problem?
- ✅ Yes → Fix the specific issue (syntax, import, type error)
- ❌ No → Continue to Step 2
</decision>

**Step 2: Check recent changes**
<decision>
Did this work before your changes?
- ✅ Yes → Review your recent changes, likely introduced bug
- ❌ No → Check dependencies and environment
</decision>

**Step 3: Verify environment**
<checklist>
- [ ] Dependencies installed correctly? (`npm install`, `pip install`)
- [ ] Correct language/framework version?
- [ ] Environment variables set?
- [ ] Build cache corrupted? (try clean build)
</checklist>

**If still stuck after 3 attempts** → Ask for help with:
- Full error message
- Build command used
- Environment details (OS, versions)
- Recent changes made
</node>

<node id="node-runtime">
<category>Runtime Errors</category>

**Step 1: Locate the error**
<decision>
Do you have a stack trace?
- ✅ Yes → Identify the exact line causing the error
- ❌ No → Add logging/debugging to find error location
</decision>

**Step 2: Understand the error**
<questions>
- What is the exact error type? (NullPointerException, TypeError, etc.)
- What operation was being performed?
- What were the input values?
- What was expected vs what happened?
</questions>

**Step 3: Reproduce consistently**
<decision>
Can you reproduce the error reliably?
- ✅ Yes → Write a test that reproduces it, then fix
- ❌ No → Add more logging, try edge cases
</decision>

**Step 4: Fix systematically**
<approach>
1. Write a failing test that catches the error
2. Implement minimal fix
3. Verify test passes
4. Check for similar bugs in codebase
</approach>

**If still stuck after 3 attempts** → Ask for help with:
- Full stack trace
- Steps to reproduce
- Input data that triggers error
- Expected vs actual behavior
</node>

<node id="node-logic">
<category>Logic Bugs (Wrong Behavior)</category>

**Step 1: Define expected behavior**
<questions>
- What should happen?
- What is actually happening?
- How do you know it's wrong? (test? user report?)
</questions>

**Step 2: Isolate the issue**
<process>
1. Add logging at key points
2. Trace data flow through the system
3. Identify where behavior diverges from expected
4. Narrow down to specific function/line
</process>

**Step 3: Understand why**
<decision>
Is this a:
- **Logic error** → Review algorithm, check conditions
- **Data error** → Check input validation, data transformation
- **State error** → Review state management, check for race conditions
- **Integration error** → Check external dependencies, APIs
</decision>

**Step 4: Fix and verify**
<checklist>
- [ ] Write test that catches the bug
- [ ] Implement fix
- [ ] Verify all tests pass
- [ ] Check for similar issues
- [ ] Document root cause in commit
</checklist>

**If still stuck after 3 attempts** → Ask for help with:
- Expected vs actual behavior (with examples)
- Relevant code section
- Data flow diagram
- Test cases that fail
</node>

<node id="node-performance">
<category>Performance Issues</category>

**Step 1: Measure first**
<decision>
Do you have concrete metrics?
- ✅ Yes → Proceed to Step 2
- ❌ No → Add instrumentation, measure baseline
</decision>

**Step 2: Identify bottleneck**
<tools>
- Profiling (CPU, memory, I/O)
- Database query analysis
- Network request timing
- Log analysis
</tools>

**Step 3: Categorize the bottleneck**
<decision>
What's the primary cause?
- **Database** → Check queries (N+1, missing indexes, complex joins)
- **Computation** → Check algorithms (O(n²) → O(n log n), caching)
- **I/O** → Check file/network operations (batching, async, compression)
- **Memory** → Check for leaks, large objects, unnecessary copies
</decision>

**Step 4: Optimize systematically**
<approach>
1. Document current performance (metrics)
2. Make one change at a time
3. Measure after each change
4. Keep changes that improve, revert ones that don't
5. Document final improvement
</approach>

**Performance Optimization Checklist**:
<checklist>
- [ ] Measured before/after metrics
- [ ] Achieved ≥20% improvement
- [ ] All tests still pass
- [ ] No new bottlenecks introduced
- [ ] Resource usage acceptable
</checklist>

**If still stuck after 3 attempts** → Ask for help with:
- Profiling results
- Current metrics
- Target metrics
- What's been tried so far
</node>

<node id="node-test">
<category>Test Failures</category>

**Step 1: Understand the failure**
<decision>
Is the test failure:
- **Expected** (new code breaks old behavior) → Update code or test
- **Unexpected** (existing code now failing) → Investigation needed
</decision>

**Step 2: Categorize the issue**
<types>
- **Flaky test** → Test has random failures (timing, external dependency)
- **Wrong assumption** → Test expects incorrect behavior
- **Actual bug** → Code has real issue
- **Environment issue** → Test env different from dev env
</types>

**Step 3: Fix appropriately**
<decision>
For each type:
- **Flaky test** → Fix test (proper mocking, retry logic, longer timeouts)
- **Wrong assumption** → Update test to reflect correct behavior
- **Actual bug** → Fix the code
- **Environment issue** → Fix environment configuration
</decision>

**NEVER:**
- ❌ Delete failing tests
- ❌ Comment out assertions
- ❌ Add `try-catch` to hide errors
- ❌ Skip tests without investigation

**If still stuck after 3 attempts** → Ask for help with:
- Test failure output
- What the test is checking
- Recent changes that might affect test
- Test environment details
</node>

<node id="node-clarify">
<category>Unclear Requirements</category>

**Step 1: Identify what's unclear**
<questions>
- Is the goal unclear?
- Are there multiple valid approaches?
- Are there conflicting requirements?
- Is the scope ambiguous?
- Are there missing details?
</questions>

**Step 2: Gather context**
<research>
- Check existing similar features
- Review related documentation
- Look for past discussions/decisions
- Identify stakeholders
</research>

**Step 3: Ask specific questions**
<template>
Structure questions clearly:
1. **Context**: What you're trying to do
2. **Unclear point**: What specifically is ambiguous
3. **Options**: Possible interpretations or approaches
4. **Impact**: How the choice affects implementation
5. **Recommendation**: Your suggested approach with reasoning
</template>

**Example:**
```markdown
I'm implementing the user profile caching feature.

**Unclear**: Cache expiration strategy

**Options**:
1. Time-based (TTL): Cache for X minutes
2. Event-based: Invalidate on user updates
3. Hybrid: TTL with manual invalidation

**Impact**:
- Option 1: Simple, but may serve stale data
- Option 2: Complex, requires event system
- Option 3: Balanced, moderate complexity

**Recommendation**: Option 3 (hybrid approach)
- Use 5-minute TTL for automatic cleanup
- Invalidate immediately on user updates
- Balances freshness and performance

Does this sound right, or should I take a different approach?
```

**Never:**
- ❌ Assume without asking
- ❌ Implement all possibilities
- ❌ Ignore ambiguity and hope for the best
</node>
</decision_tree>

## Decision Framework for Technical Choices

<technical_decisions>
When choosing between multiple valid technical approaches, use this framework:

### 1. Define Evaluation Criteria
<criteria_template>
Rate each option (1-5) on:
- **Simplicity**: How easy to understand and maintain?
- **Performance**: Meets speed/resource requirements?
- **Flexibility**: Easy to change later if needed?
- **Reliability**: Proven, stable, well-tested?
- **Compatibility**: Works with existing system?
- **Development time**: How long to implement?
- **Team familiarity**: Do we know this tech?
</criteria_template>

### 2. Compare Options
<comparison_example>
**Example: Choosing State Management**

| Criteria | Redux | Zustand | Context API | Weight |
|----------|-------|---------|-------------|--------|
| Simplicity | 2 | 5 | 4 | 3x |
| Performance | 5 | 5 | 3 | 2x |
| Flexibility | 5 | 4 | 3 | 2x |
| Team Familiarity | 5 | 2 | 5 | 2x |
| **Weighted Score** | **41** | **38** | **35** | |

**Decision**: Redux (highest score)
**Reasoning**: Despite being more complex, Redux's flexibility, performance, and team familiarity outweigh simplicity concerns.
</comparison_example>

### 3. Document Decision
<documentation_template>
```markdown
## Decision: [Technology/Approach Choice]

**Date**: 2025-11-25
**Status**: Accepted
**Context**: [Why this decision was needed]

**Options Considered**:
1. Option A - [brief description]
2. Option B - [brief description]
3. Option C - [brief description]

**Decision**: Option [X]

**Rationale**:
- [Key reason 1]
- [Key reason 2]
- [Key reason 3]

**Consequences**:
- Positive: [benefits]
- Negative: [trade-offs]
- Risks: [potential issues]

**Validation**: [How we'll verify this was the right choice]
```
</documentation_template>
</technical_decisions>

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Philosophy](../philosophy.md) - Development philosophy and principles
- [Quality Assurance](../quality-assurance.md) - Testing and quality gates
- [Guidelines](../guidelines.md) - Emergency procedures and getting help
