---
name: ship
description: End-to-end development workflow from planning through review to commit/PR. Use when the user asks to "배포해줘", "ship it", "완성해줘", "개발해줘", "처음부터 끝까지", or wants a full plan-build-review-ship cycle.
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git show:*), Bash(git add:*), Bash(git commit:*), Bash(gh pr:*), Bash(gdate:*), AskUserQuestion
model: opus
version: 1.0.0
metadata:
  role: "Full-Cycle Development Orchestrator"
  priority: "High"
  applies-to: "End-to-end development workflow in any project"
  optimized-for: "Claude Opus 4.6"
  last-updated: "2026-02-16"
  context: |
    This skill orchestrates a complete development cycle: plan, build, review, and ship.
    It consolidates 18 granular steps into 4 phases / 7 steps while preserving all
    quality checks. The 12 review steps are merged into 4 perspective-based passes:
    correctness, architecture, impact, and readiness. Self-contained — does not
    delegate to other skills to avoid model-switching context loss.
---

# Ship Skill

Orchestrates a complete development cycle — plan, build, review, and ship — in a single self-contained workflow.

## Source of Truth

- **Quality Standards**: [`quality-assurance.md`](../guides/quality-assurance.md)
- **Security Guidelines**: [`security.md`](../guides/security.md)
- **Version Control**: [`version-control.md`](../guides/version-control.md)
- **Output Format**: [`output-formats.md`](../guides/output-formats.md)

## When to Activate

This skill activates in these scenarios:

1. **Full workflow request**: "배포해줘", "ship it", "완성해줘"
2. **End-to-end development**: "개발해줘", "처음부터 끝까지"
3. **Plan-to-ship cycle**: When user wants planning, implementation, review, and commit in one flow

## Design Principles

- **Self-contained**: Does not invoke other skills; avoids model-switching context loss
- **User checkpoints**: 3 explicit approval gates to balance autonomy and control
- **4-pass review**: Correctness, Architecture, Impact, Readiness — thorough yet non-redundant
- **Over-engineering guard**: Every step checks for unnecessary complexity

## Instructions

### Overview

| Phase     | Step                    | Original Steps | Focus                              |
| --------- | ----------------------- | -------------- | ---------------------------------- |
| 1: Plan   | Step 1: Plan & Validate | 1-4            | Scope, design, over-engineering check |
| 2: Build  | Step 2: Implement       | 5              | TDD-based implementation           |
| 3: Review | Step 3: Correctness     | 6-8            | Purpose alignment, bugs, security  |
| 3: Review | Step 4: Architecture    | 9-10           | Code splitting, reuse, integration |
| 3: Review | Step 5: Impact          | 11-13          | Side effects, full diff, dead code |
| 3: Review | Step 6: Readiness       | 14-17          | Quality, UX flow, recursive review, deploy readiness |
| 4: Ship   | Step 7: Commit & PR     | 18             | Commit message + PR creation       |

**User Checkpoints**: after Step 1 (plan approval), after Step 6 (review results), Step 7 (commit confirmation)

---

### Phase 1: Plan

#### Step 1: Plan & Validate

**Goal**: Establish a clear, minimal plan and get user approval before writing code.

**Steps**:

1. **Understand the request**:
   - Read relevant code and documentation
   - Identify affected files, modules, and boundaries
   - Clarify ambiguities with the user if needed

2. **Draft a plan**:
   - List the changes needed (files, functions, tests)
   - Choose the simplest approach that satisfies the requirement
   - Identify risks and edge cases

3. **Over-engineering check**:
   - Is every planned change directly required?
   - Are there unnecessary abstractions, premature generalizations, or speculative features?
   - Could the same goal be achieved with fewer changes?

4. **Present the plan to the user**:

```markdown
## 구현 계획

### 변경 범위
- [File/module list with brief description of each change]

### 접근 방식
- [Chosen approach and rationale]

### 위험 요소
- [Identified risks and mitigations]

### 테스트 전략
- [What tests will be added/modified]
```

5. **🔴 CHECKPOINT — User approval required**: Wait for user to approve, modify, or reject the plan before proceeding.

---

### Phase 2: Build

#### Step 2: Implement

**Goal**: Write code following the approved plan, test-first when possible.

**Steps**:

1. **Write tests first** (when applicable):
   - Add tests that describe the expected behavior
   - Verify tests fail before implementation (red phase)

2. **Implement the changes**:
   - Follow the approved plan exactly — do not scope-creep
   - Write minimal code to make tests pass (green phase)
   - Keep changes focused and incremental

3. **Verify implementation**:
   - Run tests if available
   - Confirm all planned changes are complete
   - Check for accidental regressions

---

### Phase 3: Review

Perform 4 review passes. Each pass focuses on a distinct perspective to ensure thorough coverage without redundancy.

#### Step 3: Correctness Pass

**Goal**: Verify the code does what it should, safely.

**Checklist**:

- [ ] **Purpose alignment**: Do the changes match the original request exactly?
- [ ] **Functional correctness**: Are there logic errors, off-by-ones, null/undefined risks?
- [ ] **Edge cases**: Are boundary conditions handled?
- [ ] **Security**: No injection vulnerabilities, no secrets in code, no unsafe operations?
- [ ] **Error handling**: Are errors caught and reported meaningfully?
- [ ] **Test coverage**: Do tests cover the main path and key edge cases?

#### Step 4: Architecture Pass

**Goal**: Ensure the code is well-structured and maintainable.

**Checklist**:

- [ ] **Responsibility separation**: Is each function/module doing one thing?
- [ ] **Naming clarity**: Are names self-documenting?
- [ ] **Code splitting**: Are files and functions appropriately sized?
- [ ] **Reuse and integration**: Does the code leverage existing utilities instead of duplicating?
- [ ] **Consistency**: Does the code follow existing patterns in the codebase?

#### Step 5: Impact Pass

**Goal**: Assess the blast radius and unintended consequences.

**Checklist**:

- [ ] **Side effects**: Could these changes break other parts of the system?
- [ ] **Full diff review**: Review every line of the diff — no changes should be accidental
- [ ] **Dead code**: Are there unused imports, variables, or functions introduced?
- [ ] **Performance**: Are there obvious performance regressions (N+1, unnecessary loops)?
- [ ] **Dependencies**: Are new dependencies justified and minimal?

#### Step 6: Readiness Pass

**Goal**: Confirm the code is ready to ship.

**Checklist**:

- [ ] **Quality bar**: Would you be confident merging this without further review?
- [ ] **UX flow**: If user-facing, does the experience make sense end-to-end?
- [ ] **Recursive self-review**: Re-read the full diff one final time — anything missed?
- [ ] **Documentation**: Are non-obvious decisions explained in code comments?
- [ ] **Deploy safety**: No debug code, no hardcoded values, no TODO hacks left behind?

**Present review results**:

```markdown
## 리뷰 결과

### 📊 전체 평가
- **품질**: [상/중/하]
- **발견 이슈**: [N개]

### ✅ 통과 항목
- [Passed checks]

### ⚠️ 발견된 이슈
1. **[Issue]** (`file:line`) — [Description and fix]

### 수정 사항
- [Changes made to address issues, if any]
```

6. **🔴 CHECKPOINT — Review results presented**: Show the review summary to the user. If issues were found and fixed, explain what was changed. Wait for user acknowledgment before proceeding to commit.

---

### Phase 4: Ship

#### Step 7: Commit & PR

**Goal**: Create a well-formed commit and optionally a pull request.

**Steps**:

1. **Stage changes**:
   - Run `git status` to confirm the changeset
   - Stage specific files (avoid `git add -A`)
   - Exclude files that should not be committed (secrets, build artifacts)

2. **Compose commit message**:
   - Follow Korean Conventional Commits with `-하다` ending
   - Format: `<type>(<scope>): <Korean subject ending with -하다>`
   - Body: Explain WHY the change was made (Korean)
   - Include AI agent footer

3. **🔴 CHECKPOINT — Commit confirmation**: Show the proposed commit message and staged files to the user. Wait for approval before committing.

4. **Create commit**:

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <Korean subject ending with -하다>

<Korean body — WHY the change was made>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

5. **Create PR** (if requested):
   - Push branch with `-u` flag
   - Create PR with `gh pr create`
   - Title: Short Korean summary (under 70 characters)
   - Body: Summary, test plan, and generated-with footer

## Abort and Recovery

At any checkpoint, the user may:

- **Modify**: Request changes to the plan, implementation, or commit message
- **Abort**: Stop the workflow entirely — no partial commits are left behind
- **Skip**: Skip remaining review steps if confident (e.g., trivial change)

If an issue is found during review that requires significant rework, return to Step 2 and re-implement.

## Response Language

- **User communication**: Korean (한국어)
- **Code and file content**: English
- **Commit messages**: Korean subject and body (per version-control.md)
- **Technical terms**: Keep in English (e.g., TDD, PR, refactoring)

## See Also

- [quality-assurance.md](../guides/quality-assurance.md) — Quality standards and checklists
- [security.md](../guides/security.md) — Security guidelines
- [version-control.md](../guides/version-control.md) — Git workflow and commit conventions
- [output-formats.md](../guides/output-formats.md) — Output format templates
