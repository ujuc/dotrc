# Context Management

<meta>
Document: context-management.md
Role: Context Optimizer
Priority: Medium
Applies To: All interactions with large codebases or lengthy conversations
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document provides strategies for efficiently managing Claude's 200K token context window. Effective context management ensures that the most relevant information is available for decision-making while avoiding unnecessary token consumption.
</context>

<your_responsibility>
As Context Optimizer, you must:
- **Prioritize information**: Focus on what's most relevant to the current task
- **Summarize wisely**: Know when to summarize vs provide full detail
- **Use references**: Link to files rather than duplicating content
- **Track context usage**: Be aware of approximate token consumption
- **Request strategically**: Ask for additional context only when needed
</your_responsibility>

## Context Window Overview

<window_specs>
**Claude 4.5 Context Window:**
- **Total capacity**: 200,000 tokens (~600-700 pages of text)
- **Recommended usage**: Keep under 150K for optimal performance
- **Input vs Output**: Context includes both user messages and assistant responses
- **Persistence**: Context is maintained throughout a conversation

**Token Approximations:**
- 1 token ≈ 4 characters (English)
- 1 token ≈ 1-2 characters (Korean with mix of English)
- Average function: ~100-200 tokens
- Average class: ~300-800 tokens
- Average file: ~500-2000 tokens
</window_specs>

## Hybrid Language Strategy

A language usage strategy to achieve both context efficiency and readability.

### Language by Element

| Element | Language | Reason |
|---------|----------|--------|
| Headings/Headers | English | Token efficiency, easy to search |
| XML tags | English | Structural consistency |
| Rule keywords | English | Concise, easy to scan |
| Explanations | English | Clear understanding (default) |
| Code/docstring | English | International compatibility |

### Pattern Example

<pattern_example>
**Before** (inefficient):
```markdown
- **Ask when uncertain** - If requirements are unclear...
```

**After** (optimized):
```markdown
- **Ask when uncertain**
  If requirements are unclear, ask questions instead of assuming.
```
</pattern_example>

### Token Efficiency
- English: ~4 chars/token
- Korean: ~1-2 chars/token
- Hybrid approach saves ~15% tokens

## Information Priority Hierarchy

<priority_levels>
### Level 1: Critical (Always Include)
- **System rules** and guidelines from CLAUDE.md, system-rules.md
- **Current task** description and requirements
- **Direct dependencies**: Code directly referenced or modified
- **Error messages**: Full, exact error text when debugging
- **User's explicit requests**: What was specifically asked for

### Level 2: Important (Include When Relevant)
- **Related implementations**: Similar features in the codebase
- **Test cases**: For the code being worked on
- **Architecture context**: How the component fits in the system
- **Recent changes**: Git history for the files being modified
- **Documentation**: README, API docs for libraries being used

### Level 3: Supporting (Include If Space Permits)
- **Broader codebase structure**: Overall project organization
- **Tangential code**: Related but not directly used
- **Historical context**: Why previous decisions were made
- **Alternative approaches**: Other ways to solve the problem
- **Edge cases**: Less common scenarios

### Level 4: Reference (Link, Don't Duplicate)
- **Standard library documentation**: Link to official docs
- **Common patterns**: Reference well-known design patterns
- **Boilerplate code**: Standard setup/configuration
- **Generated files**: Build artifacts, compiled code
- **Large data files**: Sample data, test fixtures
</priority_levels>

## Strategies for Efficient Context Usage

### 1. Progressive Disclosure

<strategy name="progressive_disclosure">
**Principle**: Start with minimal context, add more only when needed.

**Process**:
```
1. Start with summary/overview
2. If insufficient, request specific details
3. Add targeted information incrementally
4. Stop when you have enough to proceed
```

**Example**:
```markdown
**Initial**: "I need to fix the login bug"
→ Read: test file (to understand expected behavior)
→ Read: login function (to see implementation)
→ IF unclear: Read related authentication helpers
→ IF still unclear: Read authentication configuration

Don't read: entire auth module, all tests, full user model
```

**Benefits**:
- Reduces unnecessary token consumption
- Focuses attention on relevant code
- Allows for faster iteration
</strategy>

### 2. Strategic Summarization

<strategy name="strategic_summarization">
**When to Summarize**:
- ✅ Long discussions or exploration phases
- ✅ Code review of multiple files
- ✅ Documentation or specification reviews
- ✅ Historical context or decision rationale

**When to Keep Full Detail**:
- ❌ Error messages and stack traces
- ❌ Code being directly modified
- ❌ Test cases for current feature
- ❌ Critical system rules or requirements

**Summarization Techniques**:

**High-Level Summary** (for context):
```markdown
## Authentication System Overview
- JWT-based auth with refresh tokens
- OAuth2 integration (Google, GitHub)
- Role-based access control (RBAC)
- Session management in Redis
- Key files: auth.service.ts, jwt.strategy.ts, auth.guard.ts
```

**Key Points Summary** (for decisions):
```markdown
## Code Review Findings
**Critical Issues** (3):
- SQL injection in search.ts:45
- Missing auth check in /admin routes
- Password stored in plain text

**Improvements** (5):
- [Brief list of non-critical suggestions]

Full details in [code-review-notes.md]
```

**Decision Summary** (for history):
```markdown
## Why We Chose PostgreSQL Over MongoDB
- **Primary reason**: Complex relational queries needed
- **Trade-offs**: More rigid schema vs flexibility
- **Context**: E-commerce app with inventory management
- Full discussion: [architecture-decisions.md#database-2024-03]
```
</strategy>

### 3. Reference-First Approach

<strategy name="reference_first">
**Principle**: Link to information rather than duplicating it.

**Use References For**:
- Standard library documentation
- Well-known design patterns
- Project README and setup guides
- Common utilities and helpers
- Build and deployment procedures

**Inline vs Reference Decision Tree**:
```
Is the information:
├─ Specific to current task? → INLINE
├─ Frequently referenced? → INLINE (once, then reference)
├─ Standard/well-known? → REFERENCE only
├─ Generated/boilerplate? → REFERENCE only
└─ Large dataset/config? → REFERENCE only
```

**Good Reference Examples**:
```markdown
✅ "Following the Observer pattern (see: Design Patterns book)"
✅ "Using standard Express middleware (docs: expressjs.com/guide/using-middleware)"
✅ "Build process defined in [BUILD.md](./docs/BUILD.md)"
✅ "Test data in [fixtures/users.json](./tests/fixtures/users.json)"
```

**Bad Reference Examples** (should inline):
```markdown
❌ "Fix the bug in [src/auth.ts]" (should show the buggy code)
❌ "Following team conventions" (should state what conventions)
❌ "As discussed before" (should re-state the decision briefly)
```
</strategy>

### 4. Symbolic vs Full Code Reading

<strategy name="symbolic_reading">
**Principle**: Use symbolic tools to understand structure before reading full code.

**Workflow**:
```
1. Get overview (file structure, module organization)
2. Identify relevant symbols (classes, functions)
3. Read signatures/interfaces (understand contracts)
4. Read implementations (only for code being modified)
5. Read tests (to understand expected behavior)
```

**Tools to Use** (via Serena MCP):
- `get_symbols_overview`: See file structure without reading code
- `find_symbol`: Get specific function/class without full file
- `find_referencing_symbols`: Understand usage without reading all callers
- `search_for_pattern`: Find specific patterns without broad search

**Example**:
```markdown
Task: "Add caching to getUserProfile"

❌ Bad approach (wastes tokens):
→ Read entire user.service.ts (500 lines)
→ Read entire cache.service.ts (300 lines)
→ Read entire user.controller.ts (400 lines)
Total: ~1200 lines, ~6000 tokens

✅ Good approach (efficient):
→ find_symbol "getUserProfile" (read just this function: ~20 lines)
→ find_symbol "cacheService" (read interface: ~10 lines)
→ search_for_pattern "cache.*get.*User" (find similar usage: ~5 examples)
Total: ~40 lines, ~200 tokens (30x more efficient!)
```
</strategy>

### 5. Conversation Checkpointing

<strategy name="checkpointing">
**Purpose**: Maintain long conversations without context overflow.

**When to Checkpoint**:
- Every 10-15 exchanges in complex discussions
- After completing a major subtask
- Before switching to a different topic/file
- When approaching 150K token usage

**Checkpoint Format**:
```markdown
## Checkpoint: [Task Name] - [Timestamp]

### Completed
- ✅ [What was accomplished]
- ✅ [Key decisions made]
- ✅ [Files modified: list with line numbers]

### Current State
- 📍 Working on: [Current subtask]
- 📂 Key files: [Most relevant files]
- ⚠️ Open issues: [Known problems]

### Next Steps
1. [Next immediate action]
2. [Following action]
3. [Final goal]

### Important Context
- [Critical information to remember]
- [Constraints or requirements]
- [User preferences stated]

---
*Checkpoint allows starting fresh conversation if needed*
```

**Using Checkpoints**:
```markdown
User: "Let's checkpoint and continue"
Assistant: [Creates checkpoint as above]

[New conversation]
User: "Continue from checkpoint: [paste checkpoint]"
Assistant: [Resumes with fresh context window]
```
</strategy>

### 6. Claude 4.5 State Management

<strategy name="state_management_claude4">
**Principle**: Use Claude 4.5's context awareness feature to efficiently track state.

**Structured State Tracking (JSON)**:
Suitable for structured data like test results, task status:
```json
{
  "tasks": [
    {"id": 1, "name": "Auth flow", "status": "passing"},
    {"id": 2, "name": "User management", "status": "failing", "reason": "DB connection error"}
  ],
  "progress": "2/5 complete",
  "next_action": "Debug user management tests"
}
```

**Progress Notes (Free-form)**:
Suitable for exploration process or decision records:
```markdown
## Session 3 Progress:
- Completed auth token validation logic fix
- Discovered DB connection timeout issue
- Next: Need to check connection pool settings
```

**Git Usage**:
- Use as checkpoints for work restoration between sessions
- Save work state with WIP commits
- Isolate experimental changes with branches

**Multi-Context Workflow**:
Complex tasks are divided into multiple contexts:
```
Context 1: Framework setup
- Configure test environment
- Write setup scripts
- Establish initial structure

Context 2+: Iterative implementation
- Proceed with todo-list based work
- Save state when approaching context limit
- Restore state and continue in next context
```

**When to Save State**:
- When major milestones are completed
- When approaching 150K context window
- During complex debugging sessions
- At natural break points in long tasks
</strategy>

## Context Budget Guidelines

<budgeting>
### Task-Based Budgets

**Small Bug Fix** (< 20K tokens):
- Error message + stack trace: ~2K
- Relevant function/class: ~2-5K
- Related tests: ~2K
- Context/architecture: ~1-2K
- Discussion/reasoning: ~5-10K
- Buffer: ~5K

**New Feature** (< 50K tokens):
- Requirements + specs: ~5K
- Existing similar features: ~10K
- Architecture context: ~5K
- Implementation: ~10-15K
- Tests: ~5-10K
- Discussion/planning: ~10K

**Large Refactoring** (< 100K tokens):
- Current codebase analysis: ~20-30K
- Architecture documentation: ~10K
- Migration plan: ~10K
- Implementation: ~20-30K
- Testing strategy: ~10K
- Discussion/review: ~20K

**System Design** (< 150K tokens):
- Requirements gathering: ~20K
- Alternative analysis: ~30K
- Detailed design: ~40K
- Implementation plan: ~30K
- Risk analysis: ~15K
- Documentation: ~15K

### Budget Monitoring

**Signs You're Approaching Limits**:
- Response latency increasing
- Reduced response quality
- Claude "forgetting" earlier context
- Responses missing key details

**Actions When Near Limit**:
1. **Summarize**: Condense earlier discussion
2. **Checkpoint**: Save state and start fresh
3. **Focus**: Remove tangential context
4. **Reference**: Replace duplicated content with links
</budgeting>

## Anti-Patterns (What NOT to Do)

<anti_patterns>
### ❌ The "Include Everything" Anti-Pattern
```markdown
Bad: Reading entire codebase "just in case"
- Reads 50 files
- 100K tokens consumed
- Most information unused
- Slow, unfocused responses

Good: Targeted reading based on task
- Reads 3-5 relevant files
- 5-10K tokens consumed
- All information used
- Fast, focused responses
```

### ❌ The "Repeat Full Context" Anti-Pattern
```markdown
Bad: Every response includes full context
User: "What about error handling?"
Assistant: [Re-explains entire system architecture,
           then answers error handling question]

Good: Build on existing context
User: "What about error handling?"
Assistant: "In the authentication flow we discussed,
           error handling should..."
```

### ❌ The "No Summarization" Anti-Pattern
```markdown
Bad: Keeping every detail forever
- Hour 1: Read files A, B, C (10K tokens)
- Hour 2: Read files D, E, F (10K tokens)
- Hour 3: Still keeping all previous content
- Hour 4: Context overflow, information lost

Good: Progressive summarization
- Hour 1: Read files A, B, C (10K tokens)
- Hour 2: Summarize A, B, C (2K), Read D, E, F (10K)
- Hour 3: Summarize A-F (3K), New content (10K)
- Hour 4: Working context: 13K tokens
```

### ❌ The "Duplicate Documentation" Anti-Pattern
```markdown
Bad: Copying official documentation
"Here's how Express.js middleware works: [3000 words]"
"Here's how JWT works: [2000 words]"
"Here's how PostgreSQL transactions work: [2000 words]"

Good: Reference with key points
"Using Express.js middleware (docs: expressjs.com/guide/using-middleware)
 Key for our use: Order matters, next() is required"
"JWT authentication (jwt.io) - We use HS256 with 1hr expiry"
```

### ❌ The "Premature Detail" Anti-Pattern
```markdown
Bad: Loading all details before understanding need
Task: "Add a new API endpoint"
→ Reads entire API documentation (20K tokens)
→ Reads all existing endpoints (30K tokens)
→ Reads authentication system (15K tokens)
→ Finally starts actual work

Good: Progressive detail loading
Task: "Add a new API endpoint"
→ Finds similar endpoint (1K tokens)
→ Reads authentication middleware (2K tokens)
→ Implements new endpoint
→ Reads additional details only if needed
```
</anti_patterns>

## Context-Aware Tool Usage

<tool_usage>
### Prefer These Patterns

**For Exploration**:
```markdown
✅ Use: glob "**/*.service.ts" (get file list)
✅ Use: grep "class.*Service" (find relevant classes)
✅ Use: get_symbols_overview (see structure)

❌ Avoid: Reading every file to "understand the system"
```

**For Understanding Dependencies**:
```markdown
✅ Use: find_referencing_symbols (who calls this?)
✅ Use: grep "import.*MyClass" (where is this used?)

❌ Avoid: Reading every file that might import it
```

**For Implementing Features**:
```markdown
✅ Use: find_symbol with include_body=True (targeted reading)
✅ Use: search_for_pattern "similar.*pattern" (find examples)

❌ Avoid: Read entire files when you need one function
```

**For Debugging**:
```markdown
✅ Read: Exact error location + stack trace
✅ Read: Function where error occurs
✅ Read: Relevant test cases

❌ Avoid: Reading entire modules "to understand context"
```
</tool_usage>

## Best Practices Summary

<best_practices>
1. **Start Narrow, Expand If Needed**
   - Begin with minimal context
   - Add incrementally based on actual need
   - Stop when sufficient

2. **Use the Right Tool for Reading**
   - Symbolic tools for structure
   - Targeted reads for implementation
   - Search for patterns and examples

3. **Summarize Progressively**
   - Condense completed work
   - Keep only active context detailed
   - Reference historical decisions

4. **Think in Priorities**
   - Critical info always included
   - Supporting info conditionally
   - Reference info linked only

5. **Monitor Your Budget**
   - Be aware of conversation length
   - Checkpoint when getting long
   - Trim unnecessary context

6. **Reference Over Duplication**
   - Link to standard docs
   - Point to previous discussions
   - Avoid copying boilerplate

7. **Quality Over Quantity**
   - Focused context produces better responses
   - Too much context causes confusion
   - Relevant context enables precision
</best_practices>

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [Process](./process.md) - Implementation workflow (uses context efficiently)
- [Conflict Resolution](./conflict-resolution.md) - Managing complex decisions
- [Output Formats](./output-formats.md) - Structured responses save tokens
- [Technical Standards](./technical-standards.md) - Code reading best practices
