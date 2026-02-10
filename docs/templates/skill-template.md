---
# =============================================================================
# SKILL.md Template
#
# Based on: agentskills.io/specification
# Best practices: platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
#
# Usage:
#   1. Copy this template to skills/<skill-name>/SKILL.md
#   2. Replace all [PLACEHOLDERS] with actual values
#   3. Remove all <!-- comment --> blocks before finalizing
#   4. Keep SKILL.md body under 500 lines (move details to reference files)
#   5. Validate: the `name` field must match the parent directory name
# =============================================================================

# --- Required Fields ---
name: [skill-name]
# Constraints:
#   - Max 64 characters
#   - Lowercase letters, numbers, and hyphens only (a-z, 0-9, -)
#   - Must not start or end with hyphen
#   - Must not contain consecutive hyphens (--)
#   - Must match parent directory name
# Naming conventions (pick one style and be consistent):
#   - Gerund form (recommended): processing-pdfs, analyzing-data, writing-docs
#   - Noun phrase: pdf-processing, data-analysis
#   - Action-oriented: process-pdfs, analyze-data

description: [What this skill does and when to use it. Include trigger phrases in both English and Korean. Write in third person.]
# Constraints:
#   - Max 1024 characters, non-empty
#   - Must describe WHAT the skill does AND WHEN to use it
#   - Include specific keywords for agent discovery
#   - Write in third person (not "I can help" or "You can use")
# Example:
#   description: Creates and manages AGENTS.md files for AI agent integration.
#     Use when the user asks to "create agents", "AGENTS.md 만들어줘", or needs
#     to set up project guidance for AI agents.

# --- Optional Fields ---
allowed-tools: [Space-delimited list of pre-approved tools]
# Examples:
#   allowed-tools: Bash(git:*) Read Write Edit
#   allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
#   allowed-tools: AskUserQuestion, Write

# argument-hint: [hint for optional arguments]
# Shows users what arguments the skill accepts
# Example: argument-hint: [file-path or instructions]

version: 1.0.0

# license: [License name or reference]
# Example: license: Apache-2.0

# compatibility: [Environment requirements, max 500 chars]
# Only include if skill has specific requirements
# Example: compatibility: Requires git and docker

metadata:
  # --- Document Meta (optional, from <meta> block pattern) ---
  role: [Role description, e.g., "Git Commit Generator"]
  priority: [High/Medium/Low]
  applies-to: [Scope of applicability]
  optimized-for: Claude 4.5 (Sonnet/Opus)
  last-updated: [YYYY-MM-DD]
  # --- Context (optional, from <context> block pattern) ---
  context: |
    [Brief explanation of what this skill does and why it exists.]
    [Include how it fits into the broader workflow.]
  # --- Additional (optional) ---
  # author: [organization or username]
---

<!-- =========================================================================
  AUTHORING GUIDELINES (remove this block before finalizing)

  Progressive Disclosure Strategy:
    1. Metadata (~100 tokens): name + description loaded at startup for ALL skills
    2. Instructions (< 5000 tokens recommended): Full SKILL.md loaded on activation
    3. Resources (as needed): Reference files loaded only when required

  Key Principles:
    - Claude is already smart. Only add context it doesn't already have.
    - Challenge each piece: "Does Claude really need this explanation?"
    - Keep file references ONE level deep from SKILL.md
    - Use forward slashes for all file paths (not backslashes)
    - Test with Haiku, Sonnet, and Opus models

  Degrees of Freedom:
    - High freedom (text instructions): Multiple valid approaches, context-dependent
    - Medium freedom (pseudocode/parameters): Preferred pattern with some variation
    - Low freedom (specific scripts): Fragile operations, consistency critical
========================================================================= -->

# [Skill Display Name]

[One-sentence summary of what this skill does.]

<!-- Optional: Include if there are authoritative references -->
## Source of Truth

- **[Reference Name]**: [`filename`](relative/path/to/file)
- **[Guidelines]**: [`guide-name.md`](../guides/guide-name.md)

## When to Activate

<!-- List specific scenarios that trigger this skill.
     Include both English and Korean trigger phrases. -->

This skill activates in these scenarios:

1. **[Scenario name]**: "[trigger phrase]", "[한국어 트리거]"
2. **[Scenario name]**: "[trigger phrase]", "[한국어 트리거]"
3. **[Context-based]**: [Description of contextual activation]

## Instructions

<!-- Structure instructions as Features for distinct operations,
     or as Steps for a single workflow.
     Choose the pattern that fits your skill best. -->

### Feature 1: [Feature Name]

**When**: [Condition that triggers this feature]

**Steps**:

1. **[Step name]**:
   - [Detailed instruction]
   - [Additional detail if needed]

2. **[Step name]**:
   - [Detailed instruction]

<!-- Include concrete examples where output quality depends on them -->

**Example**:

<!-- Use input/output pairs for clarity -->

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

<!-- For complex workflows, include a progress checklist:

Copy this checklist and track your progress:

```
Task Progress:
- [ ] Step 1: [description]
- [ ] Step 2: [description]
- [ ] Step 3: [description]
```
-->

---

<!-- Optional: Add validation/feedback loop for quality-critical tasks

### Validation

1. [Run validation step]
2. If validation fails:
   - [Fix instructions]
   - [Re-run validation]
3. Only proceed when validation passes
-->

## [Domain-Specific Section]

<!-- Add sections specific to your skill's domain.
     Examples:
     - "Korean Commit Message Rules" for commit skill
     - "Review Checklist" for review skill
     - "Error Categories" for troubleshoot skill

     Keep domain sections focused and concise.
     Move detailed reference material to separate files:
     - See [reference-name.md](references/reference-name.md) for details
-->

[Domain-specific content here]

## Response Language

<!-- Adjust based on skill requirements -->

- **User communication**: Korean (한국어)
- **File content**: English (default)

## See Also

- [Related document](relative/path) - Brief description
- [Another reference](relative/path) - Brief description
