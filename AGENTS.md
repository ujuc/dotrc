# AGENTS.md

<meta>
Version: 2.0.0
Last Updated: 2026-02-01
Standard: https://agents.md/
AI Compatibility: Universal (Claude Code, GitHub Copilot, Cursor, Aider)
</meta>

**Universal AI Agent Guide** for the `dotrc` repository.

This file provides **platform-agnostic guidance** for all AI coding assistants (GitHub Copilot, Cursor, Aider, etc.) working with this dotfiles repository.

> **For Claude Code users**: See [CLAUDE.md](./claude/CLAUDE.md) for **Claude-specific** guidelines including:
> - Korean commit message format (Conventional Commits with `-하다` ending)
> - Code review process and quality standards
> - Auto-discovered skills (commit, review, troubleshoot, refactor, agents)
> - MCP server integrations and advanced features
>
> **Note**: CLAUDE.md contains comprehensive development standards optimized for Claude 4.5. Other AI agents should follow this AGENTS.md file.

## Project Overview

Personal dotfiles repository (`dotrc`) for macOS. Manages shell configurations, application settings, and development environment setup.

**Type**: Configuration repository (dotfiles)
**Primary Language**: Shell (Zsh), Configuration files (YAML, TOML, JSON)
**Platform**: macOS
**Purpose**: Centralized management of development environment and tool configurations

### AI Agent Usage

- **Claude Code**: Use [CLAUDE.md](./claude/CLAUDE.md) for comprehensive guidelines
- **GitHub Copilot**: Follow this AGENTS.md + code style conventions
- **Cursor**: Follow this AGENTS.md + git workflow guidelines
- **Aider**: Follow this AGENTS.md + commit message format
- **Other AI tools**: This AGENTS.md provides all essential guidance

## Repository Structure

```
dotrc/
├── AGENTS.md           # This file - Universal AI agent guide
├── zshrc               # Zsh main config (module loader)
├── zsh.d/              # Modular Zsh configurations (optimized)
│   ├── 00-env.zsh      # Environment variables, PATH
│   ├── 10-history.zsh  # History settings
│   ├── 20-plugins.zsh  # Zimfw and plugins (incl. completion)
│   ├── 30-tools.zsh    # External tools (lazy loading)
│   ├── 40-aliases.zsh  # Aliases, functions, benchmarks
│   ├── 99-local.zsh    # Local/work overrides
│   └── README.md       # Module documentation
├── scripts/            # Automation and optimization scripts
│   ├── compile-zsh.sh  # Compile configs to bytecode
│   ├── benchmark.sh    # Measure startup time
│   └── profile-startup.zsh # Profile module loading
├── zshenv              # Zsh environment setup (entry point)
├── zimrc               # Zim framework modules
├── starship.toml       # Starship prompt config
├── ghosttyrc           # Ghostty terminal config
├── batrc               # bat (cat alternative) config
├── tigrc               # tig (git UI) config
├── gitmessage          # Git commit template
├── docs/               # Project documentation
│   ├── templates/      # Document templates (shared)
│   │   ├── AGENTS.md          # Template directory guide
│   │   ├── guide-template.md  # Guide document template
│   │   ├── work-template.md   # Work document template
│   │   ├── agents-template.md # AGENTS.md template
│   │   └── skill-template.md  # Claude skill template
│   └── ai/             # AI work logs
├── zed/                # Zed editor settings
└── claude/             # Claude Code specific guidelines
    ├── CLAUDE.md       # Claude-specific entry point
    ├── system-rules.md # Critical rules (highest priority)
    ├── mcp.json        # MCP server configuration
    ├── settings.json   # Claude CLI settings
    ├── guides/         # 16 detailed guideline documents
    │   ├── philosophy.md
    │   ├── process.md
    │   ├── technical-standards.md
    │   ├── quality-assurance.md
    │   └── ... (12 more)
    ├── skills/         # Auto-discovered skills
    │   ├── commit/     # Korean commit message automation
    │   ├── review/     # Code review automation
    │   ├── troubleshoot/ # Error diagnosis
    │   ├── refactor/   # Code improvement
    │   └── agents/     # AGENTS.md management
    ├── scripts/        # Automation scripts
    └── (runtime)       # Auto-generated: commands/, history.jsonl, plans/, etc.
```

## File Linking Strategy

This repository uses symbolic links to place configs in their expected locations:

```bash
# Core environment
export DOTRCDIR="${HOME}/.config/dotrc"
export XDG_CONFIG_HOME="${HOME}/.config"
export ZDOTDIR="${HOME}/.config/zsh"

# Example links (from zshrc)
ln -sf ${DOTRCDIR}/starship.toml ${XDG_CONFIG_HOME}/starship.toml
ln -sf ${DOTRCDIR}/zed/settings.json ${XDG_CONFIG_HOME}/zed/settings.json
ln -sf ${DOTRCDIR}/ghosttyrc ${XDG_CONFIG_HOME}/ghostty/config

# Claude global config (folder link)
ln -sf ${DOTRCDIR}/claude ${HOME}/.claude

# Pre-commit hook (optional)
ln -sf ${DOTRCDIR}/claude/scripts/pre-commit-lint ${DOTRCDIR}/.git/hooks/pre-commit
```

**Important**: Always update files in `${DOTRCDIR}`, not the symlink targets.

## Build & Test Commands

**No build system** - This is a configuration repository.

### Setup Commands

```bash
# Initial setup (run once)
git clone <repo-url> ~/.config/dotrc
source ~/.config/dotrc/zshenv

# Update dotfiles
cd ${DOTRCDIR}
git pull

# Update all tools
update  # Alias: brew update + zimfw update + cleanup
```

### Validation

```bash
# Check Zsh config syntax
zsh -n ~/.config/dotrc/zshrc

# Test Zsh startup
zsh -c 'echo "Zsh loaded successfully"'

# Verify symlinks
ls -la ${XDG_CONFIG_HOME}/starship.toml

# Verify Claude config (if using Claude Code)
ls -la ${HOME}/.claude/CLAUDE.md
test -L ${HOME}/.claude && echo "Claude config symlink OK" || echo "Claude config not linked"
```

## Development Environment

### Required Tools

- **Shell**: Zsh 5.8+
- **Framework**: Zim (ZimFW)
- **Prompt**: Starship
- **Version Manager**: mise (asdf alternative)
- **Navigation**: zoxide (autojump replacement)
- **Fuzzy Finder**: fzf
- **Terminal**: Ghostty (recommended)
- **Editor**: Zed (recommended)

### Optional Tools

- **File Viewer**: bat (cat with syntax highlighting)
- **Directory Listing**: eza (ls replacement)
- **Git UI**: tig
- **Git Diff**: git-delta
- **AI**: ollama (local LLM)

### Installation

```bash
# macOS (Homebrew)
brew install zsh starship mise zoxide fzf bat eza tig git-delta

# Zim framework (follow official instructions)
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
```

## Code Style & Conventions

### Shell Scripts (Zsh)

- **Shebang**: `#!/usr/bin/env zsh` (not `/bin/zsh`)
- **Command checks**: Use `(( $+commands[tool] ))` instead of `which` or `command -v`
- **Variables**: Use `${VAR}` for clarity, not `$VAR`
- **Quoting**: Always quote variables: `"${VAR}"`
- **Conditionals**: Prefer `[[ ]]` over `[ ]`
- **Lazy loading**: Wrap expensive initializations in wrapper functions

**Example**:
```zsh
# Good ✅ - Eager loading (fast tools)
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# Good ✅ - Lazy loading (slow tools)
if (( $+commands[mise] )); then
  function mise() {
    unfunction mise
    eval "$(mise activate zsh)"
    mise "$@"
  }
fi

# Bad ❌
if [ -x $(which starship) ]; then
  eval $(starship init zsh)
fi
```

### Configuration Files

- **YAML/TOML**: 2-space indentation
- **JSON**: 2-space indentation (per Zed settings)
- **Line length**: No strict limit for config files
- **Comments**: Explain non-obvious settings

### File Organization

- **Keep flat**: Avoid deep nesting unless necessary (apps like Zed)
- **One tool per file**: `starship.toml`, `batrc`, not `config/starship.toml`
- **Exceptions**: Multi-file tools like `claude/`, `zed/`

## Aliases & Functions

### Standard Aliases (from zshrc)

```bash
ls='eza --icons=auto --group-directories-first --git'
ll='eza -l --git --icons=auto'
cat='bat'
update='brew update && brew upgrade && zimfw update && brew cleanup'
```

When modifying aliases:
- Keep them intuitive (common command names)
- Test for conflicts with system commands
- Document non-obvious behavior
- Use functions for complex logic (not aliases)

## Environment Variables

### Core Variables

```bash
DOTRCDIR="${HOME}/.config/dotrc"          # This repository
XDG_CONFIG_HOME="${HOME}/.config"         # App configs
ZDOTDIR="${HOME}/.config/zsh"             # Zsh configs
```

### Adding New Variables

1. Add to `zshenv` (sourced first, always)
2. Export with `export VAR="value"`
3. Use `${HOME}` not `~` for portability
4. Document in comments

## Git Workflow

### Commit Messages

**Format**: Korean commit messages using Conventional Commits with `-하다` verb ending.

**Template** (from `gitmessage`):
```
<type>: <subject in Korean ending with -하다>

<body explaining WHY, not what>

<footer with issues/PRs>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:
- ✅ `feat: Starship 프롬프트 설정을 추가하다`
- ✅ `fix(zshrc): 중복된 PATH 항목을 제거하다`
- ✅ `docs: AGENTS.md 파일을 생성하다`
- ❌ `feat: Starship 프롬프트 추가` (missing -하다)

**For Claude Code users**: See [CLAUDE.md](./claude/CLAUDE.md) and [gitmessage](./gitmessage) for full commit guidelines.

## Testing Changes

### Before Committing

1. **Syntax check**: `zsh -n <file>` for shell scripts
2. **Reload test**: Source the file or restart shell
3. **Symlink check**: Verify links point to correct locations
4. **Tool function**: Test affected aliases/functions

### Safe Testing

```bash
# Test in new shell (won't affect current session)
zsh -c 'source ~/.config/dotrc/zshrc; ls'

# Test specific config
zsh -c 'source ~/.config/dotrc/zshenv; echo ${DOTRCDIR}'
```

## Common Tasks

### Adding New Tool Config

1. Add config file to `${DOTRCDIR}/` (e.g., `newtool.toml`)
2. Create symlink in `zshrc` or tool-specific setup
3. Test symlink: `ls -la ${XDG_CONFIG_HOME}/newtool.toml`
4. Commit with `feat: <tool> 설정을 추가하다`

### Modifying Zsh Config

**Modular structure**: Configurations are split into `zsh.d/*.zsh` files, loaded by `zshrc`.

1. **Edit appropriate module**:
   - Environment/PATH → `zsh.d/00-env.zsh`
   - History → `zsh.d/10-history.zsh`
   - Plugins/Completion → `zsh.d/20-plugins.zsh`
   - Tools (starship, fzf, etc.) → `zsh.d/30-tools.zsh`
   - Aliases/functions → `zsh.d/40-aliases.zsh`
   - Local settings → `zsh.d/99-local.zsh`

2. **Syntax check**: `zsh -n zsh.d/XX-name.zsh`
3. **Auto-compile**: Modified files auto-compile to `.zwc` on next load
4. **Test in new shell**: `zsh -c 'source ~/.config/dotrc/zshrc'`
5. **Reload current shell**: `source ~/.config/dotrc/zshrc`
6. **Commit** with appropriate type (`refactor`, `feat`, `fix`)

**Adding new module**: Create `zsh.d/XX-name.zsh` (XX = load order 00-99). Auto-loaded and auto-compiled by `zshrc`.

**Performance tools**: Use `zbench`, `zprofile`, `zcompile` to measure and optimize.

### Updating Claude Guidelines

**Note**: This is Claude Code specific.

1. Edit files in `claude/guides/`
2. Run linter: `${DOTRCDIR}/claude/scripts/lint-docs.sh` (if exists)
3. Verify links work
4. Commit with `docs(claude): <description>`

For details, see [CLAUDE.md](./claude/CLAUDE.md).

### Managing Claude Skills

**Note**: This is Claude Code specific. Other AI agents can skip this section.

1. Create skill directory: `claude/skills/<skill-name>/`
2. Write `SKILL.md` following existing patterns
3. Include: YAML frontmatter, metadata, context, instructions
4. Test with natural language: "<skill-trigger>"
5. Commit with `feat(claude): <skill-name> 스킬을 추가하다`

For details, see [CLAUDE.md](./claude/CLAUDE.md).

## Security Considerations

- **Never commit secrets**: Use `.env` files (gitignored)
- **Work overrides**: Use `~/.zshrc.work` for company-specific configs (gitignored)
- **SSH keys**: Keep in `~/.ssh/`, not in dotrc
- **API tokens**: Use keychain or environment-specific files

## Troubleshooting

### Zsh Not Loading Configs

```bash
# Check ZDOTDIR
echo ${ZDOTDIR}  # Should be ~/.config/zsh

# Check if zshenv is sourced
echo ${DOTRCDIR}  # Should be ~/.config/dotrc

# Verify symlinks
ls -la ~/.zshenv  # Should point to ${DOTRCDIR}/zshenv
```

### Tool Command Not Found

```bash
# Check if installed
(( $+commands[tool] )) && echo "installed" || echo "missing"

# Check Homebrew
brew list | grep tool

# Check mise (for language runtimes)
mise list
```

### Symlink Broken

```bash
# Check symlink target
ls -la ${XDG_CONFIG_HOME}/tool.toml

# Recreate link
ln -sf ${DOTRCDIR}/tool.toml ${XDG_CONFIG_HOME}/tool.toml
```

## Claude Code Features

**Note**: The following features are specific to Claude Code. Other AI agents can ignore this section.

### Auto-Discovered Skills

Claude Code automatically discovers and activates skills based on natural language triggers:

| Skill | Trigger Examples | Purpose |
|-------|------------------|---------|
| `commit` | "커밋해줘", "commit changes" | Creates git commits with Korean messages |
| `review` | "리뷰해줘", "이거 괜찮아?" | Performs code review |
| `troubleshoot` | "왜 안돼?", "에러 났어" | Diagnoses and fixes errors |
| `refactor` | "리팩토링 해줘", "정리해줘" | Improves code quality |
| `agents` | "에이전트해줘", "AGENTS.md 만들어줘" | Manages AGENTS.md file |

For complete documentation, see [CLAUDE.md](./claude/CLAUDE.md) and [claude/skills/](./claude/skills/).

## Document Templates

문서 작성 시 `docs/templates/` 의 템플릿을 참고하세요.

| 템플릿 | 용도 | 경로 |
|--------|------|------|
| [guide-template.md](./docs/templates/guide-template.md) | 가이드 문서 작성 (역할, 지침, 참고문서 구조) | `docs/templates/guide-template.md` |
| [work-template.md](./docs/templates/work-template.md) | 작업 문서 작성 (분석, 계획, 구현, 테스트, 회고) | `docs/templates/work-template.md` |
| [agents-template.md](./docs/templates/agents-template.md) | AGENTS.md 작성 (AI 에이전트 가이드, 프로젝트 구조, 명령어, 경계) | `docs/templates/agents-template.md` |
| [skill-template.md](./docs/templates/skill-template.md) | Claude 스킬 작성 (SKILL.md, 트리거, 명령어) | `docs/templates/skill-template.md` |

**공통 규칙**:
- 메타데이터는 YAML frontmatter(`---`) 형식으로 작성
- `name`, `description`, `version` 은 필수 필드
- 템플릿 고유 필드는 `metadata:` 블록 하위에 배치
- 상세 가이드: [docs/templates/AGENTS.md](./docs/templates/AGENTS.md)
- 참고: [agentskills.io frontmatter spec](https://agentskills.io/specification#frontmatter-required)

## Related Resources

### Documentation
- [CLAUDE.md](./claude/CLAUDE.md) - Claude Code specific guidelines
- [AGENTS.md Spec](https://agents.md/) - Universal AI agent guide standard

### Tool Documentation
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [ZimFW Modules](https://zimfw.sh/docs/modules/)
- [Starship Config](https://starship.rs/config/)
- [mise Documentation](https://mise.jdx.dev/)
- [Ghostty](https://ghostty.org/)
- [Zed Editor](https://zed.dev/)

---

## Document Organization

- **AGENTS.md** (this file): Universal guide for all AI agents
- **claude/CLAUDE.md**: Claude Code specific standards and advanced features
- **Relationship**: AGENTS.md provides the foundation; CLAUDE.md extends it for Claude users

## Change Log

- **v2.0.0** (2026-02-01): Separated Claude-specific content to claude/CLAUDE.md
- **v1.0.0** (2026-01-04): Initial version with universal and Claude-specific content merged

---

**Maintainer**: ujuc  
**AI Agent Compatibility**: Universal (tested with Claude Code, GitHub Copilot, Cursor)  
**Last Updated**: 2026-02-01
