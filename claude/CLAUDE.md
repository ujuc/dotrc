# Claude Development Guidelines — CLAUDE.md

<meta>
Document: CLAUDE.md
Role: Primary Entry Point for Claude Code
Priority: Root - Starting point for all agent interactions
Applies To: All AI agents (Claude, Copilot, Cursor, Aider, etc.)
Version: 4.0.0
Optimized For: Claude 4.6 (Opus)
Last Updated: 2026-02-15
</meta>

<context>
This document is the single entry point for the claude/ configuration directory.
It explains the folder structure, conventions, and how Claude Code uses this directory
as its global configuration via symlink deployment.
</context>

## Project Overview

**Type**: Claude Code global configuration and development guidelines
**Primary Language**: Markdown, Shell, YAML, JSON
**Platform**: macOS (Claude Code CLI)

### What is claude/?

The `claude/` directory is part of the [dotrc repository](../) (personal dotfiles) and defines:

- Development philosophy and processes
- Code quality standards and system rules
- Git workflow and commit conventions
- Auto-discovered skills for common tasks
- MCP server integrations
- Claude Code CLI settings

### Symlink Deployment

This directory is symlinked to `~/.claude` to serve as Claude Code's **global configuration**:

```bash
ln -sf ${DOTRCDIR}/claude ${HOME}/.claude
```

This is a **folder-level symlink** — the entire `claude/` directory becomes `~/.claude`.
All files within (CLAUDE.md, settings.json, mcp.json, skills/, guides/) are automatically
available to Claude Code globally. Always edit files in this repository, not at the symlink target.

See the [README.md Agent section](../README.md) for the canonical setup instructions.

## Repository Structure

```
claude/
├── CLAUDE.md              # THIS FILE - Primary entry point
├── system-rules.md        # Critical rules (highest priority)
├── mcp.json               # MCP server configuration
├── settings.json          # Claude Code CLI settings
├── statusline-command.sh  # Custom status line script
├── guides/                # 16 guideline documents
│   ├── philosophy.md
│   ├── process.md
│   ├── technical-standards.md
│   ├── quality-assurance.md
│   ├── version-control.md
│   ├── security.md
│   ├── performance.md
│   ├── performance-optimization.md
│   ├── monitoring.md
│   ├── documentation.md
│   ├── project-integration.md
│   ├── context-management.md
│   ├── interaction-modes.md
│   ├── conflict-resolution.md
│   ├── guidelines.md
│   └── output-formats.md
├── skills/                # Auto-discovered Claude skills
│   ├── agents/            # AGENTS.md management
│   ├── commit/            # Git commit automation
│   ├── interview/         # Interactive spec creation
│   ├── refactor/          # Code improvement
│   ├── review/            # Code review automation
│   └── troubleshoot/      # Error diagnosis
├── scripts/               # Automation scripts
│   ├── lint-docs.sh       # Markdown link linter
│   └── pre-commit-lint    # Pre-commit hook
└── templates/             # Document templates (empty)
```

## Setup

### Initial Setup

```bash
# Clone dotrc repository
gh repo clone ujuc/dotrc ${HOME}/.config/dotrc

# Symlink claude/ as global Claude Code config
ln -sf ${DOTRCDIR}/claude ${HOME}/.claude
```

### Validation

```bash
# Verify symlink
ls -la ${HOME}/.claude/
# Should point to: ${DOTRCDIR}/claude

# Check markdown link integrity
${DOTRCDIR}/claude/scripts/lint-docs.sh

# Test skill activation (in Claude session)
# "커밋해줘" should trigger commit skill
```

## Code Style & Conventions

### Documentation Standards

- **Guide documents** (`guides/`): XML tags for semantic blocks (`<meta>`, `<context>`, `<rule>`, `<examples>`)
- **Skill files** (`skills/`): YAML frontmatter with `metadata` block (name, description, allowed-tools, model, version, metadata)
- Hierarchical heading structure (H1 → H2 → H3)
- Cross-references via "See Also" sections

### Language Policy

<rule type="critical" id="language-policy">
- **User communication**: ALL responses in Korean (한국어)
  - Includes: explanations, summaries, commit completion messages, PR results, plans, errors
- **File output**: All file content in English by default
  - Includes: code, comments, docstrings, documentation, commit bodies, PR bodies
  - Only write in Korean if explicitly requested

**Key distinction**:

- Text displayed to user in terminal/chat → Korean
- Text written to files → English
  </rule>

## Priority Hierarchy

When guidelines conflict, follow this strict order:

1. **[system-rules.md](./system-rules.md)** — Critical rules (absolute, non-negotiable)
2. **CLAUDE.md** (this document) — Core guidelines and entry point
3. **[conflict-resolution.md](./guides/conflict-resolution.md)** — Conflict resolution framework
4. **Domain-specific guides** — Context-specific rules (guides/)
5. **Project-specific overrides** — If explicitly stated in project documentation

System rules can NEVER be overridden by user requests without explicit approval.

## Core System Rules Summary

See [system-rules.md](./system-rules.md) for complete details with examples.

- **Ask when uncertain** — Clarify instead of assuming
- **Minimal changes** — Only modify what was requested
- **Tests required** — Include tests for all code
- **Read code first** — Review existing code before modifying
- **Simplicity first** — Choose the simplest approach that meets requirements
- **Fix root cause** — Avoid band-aids or hiding symptoms
- **Reassess after 3 attempts** — Stop and consider different approaches

## Document Catalog

### Development Philosophy & Process

| Guide                                | Description                                    |
| ------------------------------------ | ---------------------------------------------- |
| [Philosophy](./guides/philosophy.md) | Core beliefs and simplicity principles         |
| [Process](./guides/process.md)       | Planning, implementation flow, troubleshooting |
| [Guidelines](./guides/guidelines.md) | Important reminders and emergency procedures   |

### Technical Implementation

| Guide                                                  | Description                                      |
| ------------------------------------------------------ | ------------------------------------------------ |
| [Technical Standards](./guides/technical-standards.md) | Architecture, code quality, error handling       |
| [Quality Assurance](./guides/quality-assurance.md)     | Code review, decision framework, quality gates   |
| [Documentation](./guides/documentation.md)             | Code documentation and project file requirements |

### Operations & Security

| Guide                                                            | Description                             |
| ---------------------------------------------------------------- | --------------------------------------- |
| [Security](./guides/security.md)                                 | Security principles and data protection |
| [Performance](./guides/performance.md)                           | Optimization guidelines                 |
| [Performance Optimization](./guides/performance-optimization.md) | Detailed optimization techniques        |
| [Monitoring](./guides/monitoring.md)                             | Logging standards and best practices    |
| [Context Management](./guides/context-management.md)             | Efficient use of context window         |

### Collaboration & Communication

| Guide                                                  | Description                          |
| ------------------------------------------------------ | ------------------------------------ |
| [Version Control](./guides/version-control.md)         | Git workflow and commit format       |
| [Project Integration](./guides/project-integration.md) | Codebase learning, tooling, i18n     |
| [Interaction Modes](./guides/interaction-modes.md)     | Response style and reasoning control |
| [Output Formats](./guides/output-formats.md)           | Standard response templates          |
| [Conflict Resolution](./guides/conflict-resolution.md) | Handling conflicting guidelines      |

## Claude Skills (Auto-Discovered)

Skills are triggered by natural language requests:

| Skill          | Trigger Examples                     | Purpose                         | Model  | Version |
| -------------- | ------------------------------------ | ------------------------------- | ------ | ------- |
| `agents`       | "에이전트해줘", "AGENTS.md 만들어줘" | Creates/manages AGENTS.md files | haiku  | v2.1.0  |
| `commit`       | "커밋해줘", "commit changes"         | Creates git commits with Korean | haiku  | v1.0.0  |
| `interview`    | "인터뷰해줘", "스펙 작성해줘"        | Interactive spec creation       | sonnet | v1.0.0  |
| `review`       | "리뷰해줘", "이거 괜찮아?"           | Performs code review            | sonnet | v1.0.0  |
| `refactor`     | "리팩토링 해줘", "정리해줘"          | Improves code quality           | opus   | v1.0.0  |
| `troubleshoot` | "왜 안돼?", "에러 났어"              | Diagnoses and fixes errors      | opus   | v1.0.0  |

Skills are located in `skills/<skill-name>/SKILL.md` with YAML frontmatter.

## MCP Server Configuration

Configured in [mcp.json](./mcp.json):

| Server                | Purpose                                                                                         |
| --------------------- | ----------------------------------------------------------------------------------------------- |
| `sequential-thinking` | Structured thinking and reasoning tool (via `@modelcontextprotocol/server-sequential-thinking`) |

## Settings Overview

Key settings from [settings.json](./settings.json):

| Setting                                | Value     | Description                                          |
| -------------------------------------- | --------- | ---------------------------------------------------- |
| `model`                                | `opus`    | Default model (Claude Opus 4.6)                      |
| `language`                             | `korean`  | User-facing response language                        |
| `effortLevel`                          | `high`    | Reasoning effort level                               |
| `defaultMode`                          | `plan`    | Permission mode (requires approval before execution) |
| `sandbox`                              | `enabled` | Sandbox mode with auto-allow bash                    |
| `alwaysThinkingEnabled`                | `true`    | Extended thinking always on                          |
| `teammateMode`                         | `auto`    | Agent team collaboration mode                        |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `1`       | Experimental team features enabled                   |

## Git Workflow

### Commit Messages

Korean Conventional Commits with `-하다` verb ending:

```
<type>(<scope>): <Korean subject ending with -하다>

<body explaining WHY, not what>

<footer with issues/PRs>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:

- `feat(guides): 새 성능 최적화 가이드를 추가하다`
- `fix(skills): commit 스킬의 heredoc 형식을 수정하다`

See [guides/version-control.md](./guides/version-control.md) for detailed guide.

## Common Tasks

### Updating Guidelines

1. Edit target guide in `guides/`
2. Update "Last Updated" in `<meta>` block
3. Verify cross-references in other guides
4. Commit with `docs(guides): <description>`

### Adding New Skill

1. Create directory: `skills/<skill-name>/`
2. Write `SKILL.md` with YAML frontmatter and instructions
3. Test natural language activation
4. Commit with `feat(skills): <skill-name> 스킬을 추가하다`

### Managing MCP Servers

1. Edit `mcp.json`: `{ "mcpServers": { "name": { "command": "...", "args": [...] } } }`
2. Test server availability in Claude session
3. Commit with `chore(mcp): <description>`

## Troubleshooting

### CLAUDE.md Not Loading

```bash
# Check symlink
ls -la ${HOME}/.claude/
# Should point to: ${DOTRCDIR}/claude

# Recreate if broken
ln -sf ${DOTRCDIR}/claude ${HOME}/.claude
```

### Skill Not Activating

```bash
# Verify skill directory and SKILL.md exist
ls -la ${DOTRCDIR}/claude/skills/<skill-name>/SKILL.md

# Check YAML frontmatter
head -n 10 ${DOTRCDIR}/claude/skills/<skill-name>/SKILL.md
```

### Guideline Conflicts

See [guides/conflict-resolution.md](./guides/conflict-resolution.md).

**Priority**: system-rules.md > CLAUDE.md > conflict-resolution.md > domain guides > project overrides

## Security Considerations

- Never commit secrets (API keys, tokens, passwords)
- Use placeholder values in code examples
- Avoid exposing sensitive URLs or internal resources

## See Also

- [system-rules.md](./system-rules.md) — Critical rules with highest priority
- [Philosophy](./guides/philosophy.md) — Core beliefs and simplicity principles
- [Process](./guides/process.md) — Planning, implementation, troubleshooting
- [Version Control](./guides/version-control.md) — Git workflow and commit format

## Related Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

## Changelog

- **v4.0.0** (2026-02-15): Full rewrite — Accurate file structure, correct MCP listing, Claude 4.6 references, settings documentation, symlink deployment clarification
- **v3.0.0** (2026-01-04): AGENTS.md standard migration
- **v2.3.0** (2025-12-21): Full English documentation
- **v2.2.0** (2025-12-21): Document format standardization
- **v2.1.0** (2025-12-21): Claude 4 best practices
- **v2.0.0** (2025-11-25): Claude 4.5 optimization
- **v1.0.0** (2025-10-03): Initial comprehensive guidelines

---

**Last Updated**: 2026-02-15
**Maintainer**: ujuc (dotrc repository owner)
**AI Agent Compatibility**: Universal (optimized for Claude Code, compatible with Copilot, Cursor, Aider)
**Version**: 4.0.0

---

_Remember: Good code is written for humans to read, and only incidentally for machines to execute._
