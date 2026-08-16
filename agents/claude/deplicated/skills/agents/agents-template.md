---
name: "[project-name]-agents"
description: "[Describe the purpose of this AGENTS.md in one sentence]"
version: "1.0.0"
tags: []
context: |
  [Describe the project context and why this AGENTS.md exists]
last_updated: "YYYY-MM-DD"
metadata:
  standard: "https://agents.md/"
  ai-compatibility: "Universal (Claude Code, GitHub Copilot, Cursor, Aider)"
---

# [Project Name]

**Universal AI Agent Guide** for the `[project-name]` repository.

## Project Overview

**Type**: [Application type - e.g., Web API, CLI tool, Library, Configuration]
**Primary Language**: [Main language(s)]
**Platform**: [Target platform(s)]
**Purpose**: [What this project does, in one sentence]

## Repository Structure

<!-- Show only key directories and entry points -->

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

<!-- Provide exact, copy-pasteable commands -->

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

<!-- Include concrete patterns and examples -->

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

<!-- Provide both good and bad examples -->

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

<!-- Describe which tests to run and how -->

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

### [Task 1 Name]

1. [Step 1]
2. [Step 2]
3. [Step 3]

### [Task 2 Name]

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Boundaries

<!-- Separate what to always do, ask first, and never do -->

### Always Do

- [e.g., Run tests before committing]
- [e.g., Follow existing code patterns]
- [e.g., Keep functions under 50 lines]

### Ask First

- [e.g., Adding new dependencies]
- [e.g., Changing public API signatures]
- [e.g., Modifying CI/CD configuration]

### Never Do

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
- [**Claude Code Skills**](https://code.claude.com/docs/en/skills) - Claude Code skills documentation
