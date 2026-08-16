# Annotation Guide

How to annotate plans during the annotation cycle.

## Annotation Methods

Add your notes directly in the plan file using any of these formats:

### Blockquote
```markdown
> I think we should use Redis instead of in-memory cache here
```

### Inline NOTE/TODO/FIXME
```markdown
NOTE: this function already exists in utils/helpers.ts
TODO: check if this breaks the existing API
FIXME: wrong assumption — we use PostgreSQL, not MySQL
```

### HTML Comment
```markdown
<!-- this approach won't work because of X constraint -->
```

### Direct Edit
Simply modify, delete, or rewrite any section of the plan.

## Feedback Types

### Domain Knowledge Correction
Correct wrong assumptions about the codebase or domain.
- "this should use X not Y"
- "we migrated away from this pattern in Q3"

### Assumption Rejection
Reject implicit assumptions in the plan.
- "we can't assume the user is authenticated here"
- "this endpoint is public, not internal"

### Constraint Addition
Add requirements the plan missed. When an active sprint contract exists, scope, exclusion, or acceptance changes require a new archived contract workspace before the plan changes.
- "must support offline mode"
- "needs backwards compatibility with v2 API"

### Approach Change
Redirect the implementation strategy.
- "use the pattern from X instead"
- "this should be a background job, not synchronous"

### Reference-Based Instruction
Point to existing implementations as the source of truth.
- "this table should look exactly like the users table"
- "follow the same pattern as src/auth/middleware.ts"
- "copy the validation approach from the orders module"

### Short Correction
Minimal, precise feedback during later cycles.
- "wider"
- "2px gap"
- "missing the deduplicateByTitle function"
- "wrong file path"

## Tips
- Be as specific as possible — cite file paths and line numbers
- Short notes are better than long explanations
- If the plan is fundamentally wrong, say so directly rather than patching details
- Reference existing code ("do it like X") rather than describing from scratch
