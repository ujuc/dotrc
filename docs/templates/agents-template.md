---
# AGENTS.md Template Metadata (YAML Frontmatter)
# Reference: https://agentskills.io/specification#frontmatter-required
name: "[project-name]-agents"
description: "[Describe the purpose of this AGENTS.md in one sentence]"
version: "1.0.0"

# Optional fields
tags: []
context: |
  [Describe the project context and why this AGENTS.md exists]
last_updated: "YYYY-MM-DD"

# AGENTS.md-specific fields
metadata:
  standard: "https://agents.md/"
  ai-compatibility: "Universal (Claude Code, GitHub Copilot, Cursor, Aider)"
---

<!-- ================================================================
  AGENTS.md Template
  ================================================================
  This template covers the 6 Core Areas identified from analysis of
  2,500+ repositories (GitHub blog, 2025):
    1. Commands       → Build & Test Commands
    2. Testing        → Testing Changes
    3. Project Struct → Project Overview + Repository Structure
    4. Code Style     → Code Style & Conventions
    5. Git Workflow   → Git Workflow
    6. Boundaries     → Boundaries (Always Do / Ask First / Never Do)

  Usage:
    1. Copy this template to your project root as AGENTS.md
    2. Remove this comment block and the YAML frontmatter above
    3. Fill in each section with project-specific information
    4. Delete sections that are not applicable (but keep 6 Core Areas)

  NOTE: The YAML frontmatter is for template management only.
        Remove it when creating the actual AGENTS.md file.
  ================================================================ -->

# [Project Name]

<!-- 프로젝트를 한 문장으로 소개합니다 -->
**Universal AI Agent Guide** for the `[project-name]` repository.

<!-- Claude Code 등 특정 에이전트용 별도 파일이 있다면 여기에 안내합니다 -->
<!-- > **For Claude Code users**: See [CLAUDE.md](./claude/CLAUDE.md) for Claude-specific guidelines. -->

## Project Overview

<!-- ★ CORE AREA: Project Structure (1/2)
     프로젝트의 핵심 정보를 빠르게 파악할 수 있도록 작성합니다.
     ANTI-PATTERN: "This is a web app" 같은 모호한 설명 대신
     구체적인 기술 스택과 목적을 명시하세요. -->

**Type**: [Application type - e.g., Web API, CLI tool, Library, Configuration]
**Primary Language**: [Main language(s)]
**Platform**: [Target platform(s)]
**Purpose**: [What this project does, in one sentence]

## Repository Structure

<!-- ★ CORE AREA: Project Structure (2/2)
     디렉토리 트리를 통해 코드베이스 탐색 시간을 줄입니다.
     ANTI-PATTERN: 모든 파일을 나열하지 마세요. 핵심 디렉토리와
     진입점 파일만 표시하고 나머지는 "..." 으로 줄입니다. -->

```
[project-name]/
├── README.md
├── AGENTS.md           # This file
├── src/                # Source code
│   ├── ...
│   └── ...
├── tests/              # Test files
├── docs/               # Documentation
└── ...
```

## Build & Test Commands

<!-- ★ CORE AREA: Commands
     에이전트가 직접 실행할 수 있는 구체적인 명령어를 제공합니다.
     ANTI-PATTERN: "Run the tests" 같은 설명 대신 복사-붙여넣기
     가능한 정확한 명령어를 작성하세요. -->

### Setup

```bash
# Initial setup (run once)
# [setup commands here]

# Install dependencies
# [install commands here]
```

### Build

```bash
# Build the project
# [build commands here]
```

### Test

```bash
# Run all tests
# [test commands here]

# Run specific test
# [specific test commands here]

# Run linter
# [lint commands here]
```

## Development Environment

### Required Tools

- **Language Runtime**: [e.g., Node.js 20+, Python 3.12+]
- **Package Manager**: [e.g., npm, pip, cargo]
- **Other**: [e.g., Docker, database]

### Installation

```bash
# [Installation commands for required tools]
```

## Code Style & Conventions

<!-- ★ CORE AREA: Code Style
     에이전트가 일관된 코드를 생성하도록 구체적인 규칙을 제공합니다.
     ANTI-PATTERN: "Follow best practices" 같은 모호한 지침 대신
     구체적인 패턴과 예시를 포함하세요. -->

### Formatting

- **Indentation**: [spaces/tabs, count]
- **Line length**: [max characters]
- **Quotes**: [single/double]
- **Semicolons**: [yes/no, if applicable]

### Naming Conventions

- **Files**: [e.g., kebab-case, PascalCase]
- **Variables**: [e.g., camelCase, snake_case]
- **Functions**: [e.g., camelCase, snake_case]
- **Classes**: [e.g., PascalCase]
- **Constants**: [e.g., UPPER_SNAKE_CASE]

### Code Patterns

```[language]
# Good example
# [Show preferred pattern]

# Bad example
# [Show pattern to avoid]
```

## Git Workflow

<!-- ★ CORE AREA: Git Workflow
     커밋 메시지 형식, 브랜치 전략 등을 명확히 정의합니다.
     ANTI-PATTERN: 형식만 나열하지 마세요. 올바른 예시와
     잘못된 예시를 함께 제공하세요. -->

### Commit Messages

**Format**:
```
<type>: <subject>

<body>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:
- [Good example 1]
- [Good example 2]

### Branch Strategy

- **Main branch**: `main`
- **Feature branches**: `feat/<description>`
- **Fix branches**: `fix/<description>`

## Testing Changes

<!-- ★ CORE AREA: Testing
     변경사항이 기존 기능을 깨뜨리지 않도록 검증 절차를 정의합니다.
     ANTI-PATTERN: "Write tests" 만 쓰지 마세요. 어떤 종류의
     테스트를 어떻게 실행하는지 구체적으로 안내하세요. -->

### Before Committing

1. **Run tests**: `[test command]`
2. **Run linter**: `[lint command]`
3. **Check types**: `[type-check command, if applicable]`
4. **Manual verification**: [What to check manually]

### Test Guidelines

- [Testing convention 1 - e.g., "Test files go in tests/ directory"]
- [Testing convention 2 - e.g., "Use describe/it pattern for test names"]
- [Testing convention 3 - e.g., "Mock external APIs, don't call them"]

## Common Tasks

<!-- 에이전트가 자주 수행하는 작업의 구체적인 절차를 안내합니다 -->

### [Task 1 Name]

1. [Step 1]
2. [Step 2]
3. [Step 3]

### [Task 2 Name]

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Boundaries

<!-- ★ CORE AREA: Boundaries
     에이전트가 해야 할 것, 물어봐야 할 것, 절대 하면 안 되는 것을
     명확히 구분합니다. 이 섹션은 안전한 자율 작업의 핵심입니다.
     ANTI-PATTERN: "Be careful" 같은 모호한 경고 대신
     구체적인 행동 목록을 작성하세요. -->

### Always Do

<!-- 에이전트가 확인 없이 자율적으로 수행해도 되는 작업 -->
- [e.g., Run tests before committing]
- [e.g., Follow existing code patterns]
- [e.g., Keep functions under 50 lines]

### Ask First

<!-- 에이전트가 사용자 확인을 받아야 하는 작업 -->
- [e.g., Adding new dependencies]
- [e.g., Changing public API signatures]
- [e.g., Modifying CI/CD configuration]

### Never Do

<!-- 에이전트가 절대 수행하면 안 되는 작업 -->
- [e.g., Commit secrets or API keys]
- [e.g., Delete database migration files]
- [e.g., Push directly to main branch]

## Security Considerations

- **Secrets**: [How to handle secrets in this project]
- **Dependencies**: [Security policy for dependencies]
- **Data**: [Sensitive data handling guidelines]

## Troubleshooting

### [Common Issue 1]

```bash
# Diagnostic command
# [command here]

# Fix
# [fix command here]
```

### [Common Issue 2]

```bash
# Diagnostic command
# [command here]

# Fix
# [fix command here]
```

## Related Resources

- [Project Documentation](./docs/)
- [External Reference 1](https://example.com)
- [External Reference 2](https://example.com)

---

**Maintainer**: [name]
**AI Agent Compatibility**: Universal (Claude Code, GitHub Copilot, Cursor, Aider)
**Last Updated**: YYYY-MM-DD

## See Also

- [**AGENTS.md Spec**](https://agents.md/) - Universal AI agent file standard
<!-- 아래는 예시입니다. 프로젝트에 맞게 수정하세요 -->
<!-- - [**CLAUDE.md**](./claude/CLAUDE.md) - Claude-specific guidelines -->
<!-- - [**README.md**](./README.md) - Project README -->
