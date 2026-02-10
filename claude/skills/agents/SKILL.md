---
name: agents
description: Creates and manages AGENTS.md files for AI agent integration. Use when the user asks to "에이전트해줘", "create agents", "AGENTS.md 만들어줘", "agents.md 업데이트", "agents 파일 검증", or needs to set up project guidance for AI agents.
allowed-tools: Read, Write, Edit, Bash(git status:*), Bash(git diff:*), Bash(test:*)
model: haiku
version: 2.1.0
metadata:
  role: "AGENTS.md Manager"
  priority: "Medium - Project setup automation"
  applies-to: "AGENTS.md creation and maintenance in any project"
  optimized-for: "Claude 4.5 (Sonnet/Opus)"
  last-updated: "2026-02-10"
  context: |
    This skill is auto-discovered by Claude when users request AGENTS.md-related tasks.
    AGENTS.md is a project-specific guide for AI agents (Copilot, Cursor, Aider, etc.),
    complementing CLAUDE.md which contains Claude-specific global standards.
---

# AGENTS.md Management Skill

This skill creates and manages AGENTS.md files for universal AI agent integration.

## Source of Truth

- **AGENTS.md Spec**: [agents.md](https://agents.md/)
- **Template**: [`agents-template.md`](./agents-template.md) - Base template for new AGENTS.md files

## When to Activate

This skill activates in these scenarios:

1. **Create request**: "에이전트해줘", "create agents", "AGENTS.md 만들어줘"
2. **Update request**: "agents.md 업데이트", "Build Commands 섹션 수정"
3. **Regenerate request**: "AGENTS.md 다시 만들어줘", "reset agents.md"
4. **Validate request**: "AGENTS.md 검증", "agents 파일 확인"
5. **Context-based**: User asks about agent configuration for the project

## AGENTS.md Principles

- **Universal format**: Works for all AI agents (Copilot, Cursor, Aider, Claude, etc.)
- **Project-specific**: Contains project context, not generic standards
- **Flexible structure**: No required fields, adapt to project needs
- **Hierarchical support**: Root file + subdirectory overrides (monorepo)
- **Complementary to CLAUDE.md**: Reference Claude-specific standards via link
- **Template as starting point**: Use `agents-template.md` as base, then customize per project

## Instructions

### Feature 1: Create New AGENTS.md

**When**: User requests new AGENTS.md file and none exists

**Steps**:

1. **Check for existing file**:
   - Use `test -f <project_root>/AGENTS.md` to check existence
   - If exists: Ask user to choose update (Feature 2) or regenerate (Feature 3)

2. **Detect project characteristics**:
   - Read project files (README.md, package.json, setup.py, Cargo.toml, go.mod, etc.) to identify project type, primary language(s), and build system
   - Check directory structure and key entry points
   - Check if CLAUDE.md exists to determine if Claude-specific callout should be included

3. **Load and adapt template**:
   - Read `agents-template.md` from the skill directory
   - Remove YAML frontmatter and comment blocks (template management only)
   - Customize each section based on project analysis from Step 2:
     - Replace placeholders (`[Project Name]`, `[language]`, etc.) with actual values
     - Fill 6 Core Areas with project-specific content (see Template Sections Reference)
     - Remove sections that don't apply (but keep all 6 Core Areas)
     - Add project-specific sections as needed based on project type
   - If CLAUDE.md exists in the project: Add Claude Code callout:
     ```markdown
     > **For Claude Code users**: See [CLAUDE.md](./CLAUDE.md) for Claude-specific guidelines.
     ```
   - Include footer: Last Updated, Maintainer, AI Agent Compatibility

4. **Create file**:
   - Write to `<project_root>/AGENTS.md` using Write tool
   - Confirm completion with file path and section summary

**Output Format** (Korean):

```markdown
## AGENTS.md 생성 완료 ✅

**위치**: `<absolute-path>/AGENTS.md`

**포함된 섹션** (<N>개):

- Project Overview
- Repository Structure
- Build & Test Commands
- ...

**다음 단계**:

- 파일을 검토하고 프로젝트에 맞게 조정
- 커밋: "커밋해줘"
```

---

### Feature 2: Update Specific Section

**When**: User requests update to a specific section in existing AGENTS.md

**Steps**:

1. **Read existing file**:
   - Use Read tool to load `<project_root>/AGENTS.md`
   - If file doesn't exist: Suggest Feature 1 (Create)

2. **Identify target section**:
   - Parse user request for section name (e.g., "Build Commands", "Code Style")
   - Find section using markdown heading pattern: `## {section_name}`
   - If section not found: Ask user if they want to add new section

3. **Update section content**:
   - Extract section boundaries (from `## Section` to next `##` or EOF)
   - Preserve all other sections unchanged
   - Use Edit tool with precise string matching for the target section

4. **Validate against template principles** (guardrail):
   - Verify all 6 Core Areas are still covered after the update
   - If a Core Area section was removed or emptied: Warn user before proceeding
   - Check Boundaries section structure (Always Do / Ask First / Never Do) is maintained
   - Ensure updated content is project-specific, not generic placeholder text

5. **Verify changes**:
   - Show before/after preview
   - Suggest running `git diff AGENTS.md` for full review

**Output Format** (Korean):

````markdown
## 섹션 업데이트 완료 ✅

**수정된 섹션**: <Section Name>

**전체 diff 확인**:
\```bash
git diff AGENTS.md
\```
````

---

### Feature 3: Full Regenerate with Backup

**When**: User requests complete regeneration of AGENTS.md

**Steps**:

1. **Create backup**:
   - Generate timestamp: `$(date +%Y%m%d-%H%M%S)`
   - Create backup: `cp AGENTS.md AGENTS.md.backup.<timestamp>`
   - If file doesn't exist: Forward to Feature 1 (Create)

2. **Generate new template**:
   - Follow Feature 1 steps (detect project, create content)
   - Optionally preserve user-added custom sections

3. **Confirm before replacing**:
   - Show backup location
   - Ask user: "기존 파일을 백업했습니다. 새 템플릿으로 교체하시겠습니까?"

4. **Replace file**:
   - Write new content using Write tool
   - Confirm completion with backup path

**Output Format** (Korean):

````markdown
## AGENTS.md 재생성 완료 ✅

**백업 위치**: `<path>/AGENTS.md.backup.<timestamp>`

**새 파일 생성**: `<path>/AGENTS.md`

**변경사항**:

- ✅ 최신 템플릿 구조 적용
- ✅ 프로젝트 특성 재분석
- ⚠️ 이전 커스텀 내용은 백업 파일에서 확인 가능

**백업과 비교**:
\```bash
diff <backup-file> AGENTS.md
\```
````

---

### Feature 4: Validate AGENTS.md

**When**: User requests validation of existing AGENTS.md

**Steps**:

1. **Check file existence**:
   - Use `test -f <project_root>/AGENTS.md`
   - If not found: Suggest Feature 1 (Create)

2. **Read and analyze**:
   - Parse markdown structure (count headings, check hierarchy)
   - Identify all sections (scan for `## ` patterns)
   - Verify AGENTS.md link if present (check file exists at path)

3. **Quality checks**:
   - **Structure**: Valid markdown, proper H1 → H2 → H3 hierarchy
   - **Completeness**: Has essential sections for project type (Overview, Build Commands, etc.)
   - **Clarity**: Sections have meaningful content (not just placeholders or "TODO")
   - **Specificity**: Contains project-specific information (not generic template text)

4. **Core Area coverage check**:
   - Verify each of the 6 Core Areas exists and has meaningful content:
     1. Commands (Build & Test Commands) → ✅/⚠️/❌
     2. Testing (Testing Changes) → ✅/⚠️/❌
     3. Project Structure (Project Overview + Repository Structure) → ✅/⚠️/❌
     4. Code Style (Code Style & Conventions) → ✅/⚠️/❌
     5. Git Workflow (Git Workflow) → ✅/⚠️/❌
     6. Boundaries (Boundaries: Always Do / Ask First / Never Do) → ✅/⚠️/❌

5. **Anti-pattern detection**:
   - **Vague descriptions**: Sections with only generic text like "Follow best practices"
   - **Missing code samples**: Commands/Testing sections without executable examples
   - **Undefined boundaries**: No Boundaries section or missing subsections
   - **Placeholder content**: Unreplaced `[brackets]`, `TODO`, `TBD` markers
   - **Stale information**: Last Updated date older than 6 months

6. **Generate report**:
   - List found sections with status (✅ complete, ⚠️ needs improvement, ❌ missing)
   - Show 6 Core Areas coverage summary
   - List detected anti-patterns (if any)
   - Suggest improvements
   - Assign quality score: 10/10 (Excellent), 7-9/10 (Good), 4-6/10 (Needs work), 1-3/10 (Incomplete)

**Output Format** (Korean):

```markdown
## AGENTS.md 검증 결과

**품질 점수**: <X>/10 (<Rating>)

### ✅ 구조

- 유효한 Markdown 형식
- 적절한 헤딩 계층 구조
- <N>개 섹션 발견

### 📋 6 Core Areas 커버리지

- ✅ Commands (Build & Test Commands)
- ✅ Testing (Testing Changes)
- ✅ Project Structure (Project Overview + Repository Structure)
- ⚠️ Code Style (Code Style & Conventions) - 예시 부족
- ✅ Git Workflow
- ❌ Boundaries - 섹션 누락

### 📋 기타 섹션

- ✅ Development Environment
- ⚠️ Security Considerations (내용 부족)
- ...

### ⚠️ 탐지된 Anti-patterns

- [해당 사항이 있으면 나열]

### 💡 개선 제안

<Specific recommendations>

**다음 단계**: 특정 섹션 업데이트는 "Security 섹션 업데이트" 요청
```

---

## Template Sections Reference

Full template: [`agents-template.md`](./agents-template.md)

### 6 Core Areas (Required)

These 6 areas must be present in every AGENTS.md (based on analysis of 2,500+ repositories):

| Core Area         | AGENTS.md Section                       | What It Covers                                         |
| ----------------- | --------------------------------------- | ------------------------------------------------------ |
| Commands          | Build & Test Commands                   | Setup, build, test, lint commands (copy-pasteable)     |
| Testing           | Testing Changes                         | Pre-commit checks, test guidelines, verification steps |
| Project Structure | Project Overview + Repository Structure | Type, languages, directory tree, key files             |
| Code Style        | Code Style & Conventions                | Formatting, naming, patterns with good/bad examples    |
| Git Workflow      | Git Workflow                            | Commit format, branch strategy, examples               |
| Boundaries        | Boundaries                              | Always Do / Ask First / Never Do action lists          |

### Additional Recommended Sections

- **Development Environment**: Required/optional tools, installation
- **Common Tasks**: Frequent operations with step-by-step examples
- **Security Considerations**: Secrets handling, sensitive file locations
- **Troubleshooting**: Common issues, diagnostic commands
- **Related Resources**: External documentation links

### Anti-Patterns to Avoid

- **Vague instructions**: "Follow best practices" instead of specific rules with examples
- **Missing code samples**: Commands section without executable `bash` blocks
- **No boundaries defined**: Missing Boundaries section or incomplete subsections
- **Generic content**: Unreplaced template placeholders (`[brackets]`, `TODO`, `TBD`)
- **Stale documentation**: Last Updated date more than 6 months old
- **Over-documentation**: Documenting every file instead of key directories and entry points

## Response Language

- **File content (AGENTS.md)**: English by default (for universal AI agent compatibility)
- **Section headers in AGENTS.md**: English
- **Code examples**: English (comments, variable names)
- **User communication**: Follow the project's or user's language preference

## See Also

- [agents-template.md](./agents-template.md) - AGENTS.md base template (6 Core Areas)
- [AGENTS.md Spec](https://agents.md/) - Universal AI agent file standard
