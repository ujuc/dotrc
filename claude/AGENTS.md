# Claude Development Guidelines — AGENTS.md

<meta>
Document: AGENTS.md
Role: Primary Entry Point for AI Agents
Priority: Root - Starting point for all agent interactions
Applies To: All AI agents (Claude, Copilot, Cursor, Aider, etc.)
Version: 3.0.0
Optimized For: Universal AI agent compatibility, Claude 4.5 optimized
Last Updated: 2026-01-04
</meta>

<context>
This document serves two purposes:
1. Meta-documentation explaining the claude/ folder structure
2. User guide for working with Claude Code in this development environment
It replaces CLAUDE.md as the single entry point following the agents.md standard.
</context>

## Project Overview

**Type**: Development guidelines documentation (meta-project)
**Primary Language**: Markdown, with references to Shell, YAML, JSON configurations
**Platform**: macOS (Claude Desktop, CLI)
**Purpose**: Comprehensive development standards and AI agent guidance for Claude Code users

### What is claude/?

The `claude/` directory is a self-contained documentation project that defines:
- Development philosophy and processes
- Code quality standards
- Security and performance guidelines
- Git workflow and commit conventions
- Auto-discovered skills for common tasks
- MCP server integrations

**Parent Project**: This folder is part of the dotrc repository (personal dotfiles).

## Repository Structure

```
claude/
├── AGENTS.md           # THIS FILE - Primary entry point
├── CLAUDE.md.deprecated # (Archived) Previous entry point
├── system-rules.md     # Critical rules (highest priority)
├── mcp.json            # MCP server configuration
├── settings.json       # Claude CLI settings
├── guides/             # 16 detailed guideline documents
│   ├── philosophy.md
│   ├── process.md
│   ├── technical-standards.md
│   ├── quality-assurance.md
│   ├── version-control.md
│   ├── security.md
│   ├── performance.md
│   ├── monitoring.md
│   ├── documentation.md
│   ├── project-integration.md
│   ├── context-management.md
│   ├── interaction-modes.md
│   ├── conflict-resolution.md
│   ├── guidelines.md
│   ├── output-formats.md
│   └── performance-optimization.md
├── skills/             # Auto-discovered Claude skills
│   ├── agents/         # AGENTS.md management
│   ├── commit/         # Git commit automation
│   ├── review/         # Code review automation
│   ├── troubleshoot/   # Error diagnosis
│   └── refactor/       # Code improvement
├── scripts/            # Automation scripts
├── templates/          # Document templates
└── (auto-generated)    # Commands, history, plans, etc.
```

## Build & Test Commands

**No build system required** - This is a documentation project.

### Validation

```bash
# Verify markdown link integrity (if linter exists)
${DOTRCDIR}/claude/scripts/lint-docs.sh

# Check for broken cross-references
grep -r "\[.*\](\.\/.*\.md)" claude/guides/ claude/skills/

# Verify skill discovery (test natural language triggers)
# In Claude: "커밋해줘" should activate commit skill
```

### Setup Commands

```bash
# Link claude/ folder to global Claude config (one-time setup)
# Note: The entire claude/ folder is linked, not individual files
ln -sf ${DOTRCDIR}/claude ${HOME}/.claude

# Verify link
ls -la ${HOME}/.claude/
```

## Development Environment

### Required Context

This documentation is designed for:
- **Claude Code** (Desktop, CLI): Primary AI assistant
- **macOS**: Platform-specific examples
- **Zsh**: Shell environment in examples

### Optional Tools

- **MCP Servers**: git, sequential-thinking, context7, serena (configured in mcp.json)
- **Linters**: Custom documentation validators (scripts/)

## Code Style & Conventions

### Documentation Standards

**Markdown Files**:
- XML tags for semantic blocks: `<meta>`, `<context>`, `<rule>`, `<examples>`
- Consistent frontmatter for skills (YAML)
- Hierarchical heading structure (H1 → H2 → H3)
- Line length: No strict limit, readable wrapping
- Cross-references: Use "See Also" sections

**Example**:
```markdown
<meta>
Document: example.md
Role: Example Guide
Priority: Medium
Applies To: Example scenarios
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2026-01-04
</meta>

<context>
Brief explanation of document purpose and scope.
</context>

## Section Title

Content with XML semantics when needed.

<rule type="critical" id="rule-name">
- Rule description
- Implementation guidance
</rule>

## See Also

- [Related Doc](./related.md)
```

### Language Policy (CRITICAL)

<rule type="critical" id="language-policy">
- **User communication**: ALL responses in Korean (한국어)
  - Includes: explanations, summaries, commit completion messages, PR results, plans, errors
- **File output**: Write all file content in English by default
  - Includes: code, comments, docstrings, documentation files, commit bodies, PR bodies
  - Only write in Korean if explicitly requested

**Key distinction**:
- Text displayed to user in terminal/chat → Korean
- Text written to files → English
</rule>

## Priority Hierarchy

When guidelines conflict, follow this strict order:

1. **[system-rules.md](./system-rules.md)** - CRITICAL rules (absolute priority, non-negotiable)
2. **AGENTS.md** (this document) - Core guidelines and entry point
3. **[conflict-resolution.md](./guides/conflict-resolution.md)** - Conflict resolution framework
4. **Domain-specific guides** - Context-specific rules (guides/)
5. **Project-specific overrides** - If explicitly stated in project documentation

**Key Principle**: System rules can NEVER be overridden by user requests without explicit approval.

## Core System Rules Summary

See [system-rules.md](./system-rules.md) for complete details.

**Core Principles**:
- **Ask when uncertain** - Clarify instead of assuming
- **Minimal changes** - Only modify what was requested
- **Tests required** - Include tests for all code
- **Read code first** - Review existing code before modifying
- **Avoid over-engineering** - Implement only what was requested
- **Simplicity first** - Choose the simplest approach that meets requirements
- **Fix root cause** - Avoid band-aids or hiding symptoms

## Document Catalog

### Development Philosophy & Process
- [**Philosophy**](./guides/philosophy.md) - Core beliefs and simplicity principles
- [**Process**](./guides/process.md) - Planning, implementation flow, troubleshooting
- [**Guidelines**](./guides/guidelines.md) - Important reminders and emergency procedures

### Technical Implementation
- [**Technical Standards**](./guides/technical-standards.md) - Architecture, code quality, error handling
- [**Quality Assurance**](./guides/quality-assurance.md) - Code review, decision framework, quality gates
- [**Documentation**](./guides/documentation.md) - Code documentation and project file requirements

### Operations & Security
- [**Security**](./guides/security.md) - Security principles and data protection
- [**Performance**](./guides/performance.md) - Optimization guidelines and considerations
- [**Performance Optimization**](./guides/performance-optimization.md) - Detailed optimization techniques
- [**Monitoring**](./guides/monitoring.md) - Logging standards and best practices
- [**Context Management**](./guides/context-management.md) - Efficient use of 200K context window

### Collaboration & Communication
- [**Version Control**](./guides/version-control.md) - Git workflow and commit format
- [**Project Integration**](./guides/project-integration.md) - Codebase learning, tooling, i18n
- [**Interaction Modes**](./guides/interaction-modes.md) - Response style and reasoning control
- [**Output Formats**](./guides/output-formats.md) - Standard response templates
- [**Conflict Resolution**](./guides/conflict-resolution.md) - Handling conflicting guidelines

## How to Use This Documentation

1. **First Time**: Read this file (AGENTS.md) completely
2. **Quick Reference**: Check [system-rules.md](./system-rules.md) for critical rules
3. **Deep Dive**: Explore specific guides/ as needed
4. **Cross-Reference**: Use "See Also" sections in each document

## Git Workflow

### Commit Messages

**Format**: Korean commit messages using Conventional Commits with `-하다` verb ending.

**Template Source**: [gitmessage](../gitmessage) (root repository)

```
<type>: <subject in Korean ending with -하다>

<body explaining WHY, not what>

<footer with issues/PRs>

<ai agent footer>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:
- ✅ `feat(guides): 새 성능 최적화 가이드를 추가하다`
- ✅ `fix(skills): commit 스킬의 heredoc 형식을 수정하다`
- ✅ `docs(claude): AGENTS.md 표준 구조로 마이그레이션하다`
- ❌ `feat: 새 가이드 추가` (missing -하다 ending)

**AI Agent Footer**:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Detailed Guide**: See [guides/version-control.md](./guides/version-control.md) and [skills/commit/SKILL.md](./skills/commit/SKILL.md)

## Testing Changes

### Before Committing Documentation

1. **Link integrity**: Verify all internal links resolve correctly
2. **Cross-reference consistency**: Check bi-directional links between documents
3. **Language policy**: Confirm Korean ↔ English usage matches guidelines
4. **XML validity**: Ensure XML tags are properly closed

### Safe Testing

```bash
# Test skill activation (natural language)
# In Claude: "커밋해줘" - should trigger commit skill

# Verify guideline application
# In Claude: Ask a question that requires referencing guides/

# Check MCP server status
# In Claude: Should have access to configured MCP tools
```

## Common Tasks

### Updating Guidelines

1. Identify target guide in `guides/`
2. Edit guide content following existing structure
3. Update "Last Updated" in `<meta>` block
4. Add entry to changelog if significant
5. Verify cross-references in other guides
6. Commit with `docs(guides): <description>`

### Adding New Skill

1. Create directory: `skills/<skill-name>/`
2. Write `SKILL.md` with:
   - YAML frontmatter (name, description, allowed-tools, version)
   - `<meta>` and `<context>` blocks
   - "Source of Truth" section
   - "When to Activate" scenarios
   - Instructions with Feature sections
   - Korean communication, English file content
3. Test natural language activation
4. Commit with `feat(skills): <skill-name> 스킬을 추가하다`

### Modifying Priority Rules

1. **CRITICAL**: Changes to system-rules.md require careful review
2. Update `system-rules.md` with new/modified rules
3. Add `<rule type="critical" id="rule-id">` blocks
4. Include `<examples>` with correct/incorrect patterns
5. Update references in dependent guides
6. Commit with `docs(system-rules): <description>`

### Managing MCP Servers

1. Edit `mcp.json` to add/remove servers
2. Follow JSON structure: `{ "mcpServers": { "name": { "command": "...", "args": [...] } } }`
3. Test server availability in Claude
4. Document server purpose in this AGENTS.md if needed
5. Commit with `chore(mcp): <description>`

## Claude Skills (Auto-Discovered)

Skills are triggered by natural language requests:

| Skill | Trigger Examples | Purpose | Location |
|-------|------------------|---------|----------|
| `agents` | "에이전트해줘", "AGENTS.md 만들어줘" | Creates/manages AGENTS.md files | [skills/agents/](./skills/agents/) |
| `commit` | "커밋해줘", "commit changes" | Creates git commits with Korean messages | [skills/commit/](./skills/commit/) |
| `review` | "리뷰해줘", "이거 괜찮아?" | Performs code review | [skills/review/](./skills/review/) |
| `troubleshoot` | "왜 안돼?", "에러 났어" | Diagnoses and fixes errors | [skills/troubleshoot/](./skills/troubleshoot/) |
| `refactor` | "리팩토링 해줘", "정리해줘" | Improves code quality | [skills/refactor/](./skills/refactor/) |

**Skill Discovery**: Skills are automatically discovered by Claude when their trigger phrases are used in conversation.

## MCP Server Configuration

Configured servers (in `mcp.json`):

- **git**: GitHub model context protocol for git operations
- **sequential-thinking**: Structured thinking and reasoning tool
- **context7**: Up-to-date library documentation retrieval
- **serena**: Semantic coding tools for intelligent code analysis

**Usage**: These tools are automatically available in Claude sessions.

## Interaction Modes

Claude supports multiple response styles. See [guides/interaction-modes.md](./guides/interaction-modes.md) for details.

**Quick commands**:
- **Standard mode**: Default balanced response
- **Reasoning mode**: Show detailed thought process
- **Concise mode**: Minimal explanations

## Security Considerations

- **Never commit secrets**: API keys, tokens, passwords in documentation examples
- **Sanitize examples**: Use placeholder values in code samples
- **Link checking**: Avoid exposing sensitive URLs or internal resources

## Troubleshooting

### AGENTS.md Not Loading

```bash
# Check folder link
ls -la ${HOME}/.claude/
# Should point to: /Users/ujuc/.config/dotrc/claude

# Recreate link if needed
ln -sf ${DOTRCDIR}/claude ${HOME}/.claude
```

### Skill Not Activating

```bash
# Check skill directory structure
ls -la ${DOTRCDIR}/claude/skills/<skill-name>/
# Should contain: SKILL.md

# Verify YAML frontmatter in SKILL.md
head -n 10 ${DOTRCDIR}/claude/skills/<skill-name>/SKILL.md
# Should have: name, description, allowed-tools, version
```

### Guideline Conflicts

See [guides/conflict-resolution.md](./guides/conflict-resolution.md) for decision framework.

**Priority**: system-rules.md > AGENTS.md > conflict-resolution.md > domain guides > project overrides

## Related Resources

- [agents.md Specification](https://agents.md/) - Universal AI agent file format
- [Conventional Commits](https://www.conventionalcommits.org/) - Commit message standard
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP server documentation
- [Claude Code Documentation](https://claude.com/claude-code) - Official Claude Code guide

## Changelog

- **v3.0.0** (2026-01-04): AGENTS.md standard migration - Replaced CLAUDE.md with agents.md-compliant format
- **v2.3.0** (2025-12-21): Full English documentation - All file outputs in English, Korean for conversations
- **v2.2.0** (2025-12-21): Document format standardization - Added meta/context blocks
- **v2.1.0** (2025-12-21): Claude 4 best practices - Softened emphasis, over-engineering prevention
- **v2.0.0** (2025-11-25): Claude 4.5 optimization - XML structure, examples, conflict resolution
- **v1.0.0** (2025-10-03): Initial comprehensive guidelines

---

**Last Updated**: 2026-01-04
**Maintainer**: ujuc (dotrc repository owner)
**AI Agent Compatibility**: Universal (optimized for Claude Code, compatible with Copilot, Cursor, Aider)
**Version**: 3.0.0

---

_Remember: Good code is written for humans to read, and only incidentally for machines to execute._
