---
name: [skill-name]
description:
  [
    What this skill does and when to use it. Include trigger phrases in both English and Korean. Write in third person.,
  ]
allowed-tools: [Space-delimited list of pre-approved tools]
version: 1.0.0
metadata:
  role: [Role description, e.g., "Git Commit Generator"]
  priority: [High/Medium/Low]
  applies-to: [Scope of applicability]
  optimized-for: [Claude 4.5 (Sonnet/Opus)]
  last-updated: [YYYY-MM-DD]
  context: |
    [Brief explanation of what this skill does and why it exists.]
    [Include how it fits into the broader workflow.]
---

# [Skill Display Name]

[One-sentence summary of what this skill does.]

## Source of Truth

- **[Reference Name]**: [`filename`](relative/path/to/file)
- **[Guidelines]**: [`guide-name.md`](../guides/guide-name.md)

## When to Activate

This skill activates in these scenarios:

1. **[Scenario name]**: "[trigger phrase]", "[한국어 트리거]"
2. **[Scenario name]**: "[trigger phrase]", "[한국어 트리거]"
3. **[Context-based]**: [Description of contextual activation]

## Instructions

### Feature 1: [Feature Name]

**When**: [Condition that triggers this feature]

**Steps**:

1. **[Step name]**:
   - [Detailed instruction]
   - [Additional detail if needed]

2. **[Step name]**:
   - [Detailed instruction]

**Example**:

```
Input: [example input]
Output: [expected output]
```

---

### Feature 2: [Feature Name]

**When**: [Condition that triggers this feature]

**Steps**:

1. **[Step name]**:
   - [Detailed instruction]

2. **[Step name]**:
   - [Detailed instruction]

---

## [Domain-Specific Section]

<!-- Add sections specific to your skill's domain. Move detailed references to separate files. -->

[Domain-specific content here]

## Response Language

- **User communication**: Korean (한국어)
- **File content**: English (default)

## See Also

- [Related document](relative/path) - Brief description
- [Another reference](relative/path) - Brief description
