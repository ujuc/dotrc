# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

> **For Claude Code users**: See [AGENTS.md](./claude/AGENTS.md) for detailed Claude-specific guidelines including Korean commit message format, code review process, and refactoring standards.

## Project Overview

Personal dotfiles repository (`dotrc`) for macOS. Manages shell configurations, application settings, and development environment setup.

**Type**: Configuration repository (dotfiles)
**Primary Language**: Shell (Zsh), Configuration files (YAML, TOML, JSON)
**Platform**: macOS
**Purpose**: Centralized management of development environment and tool configurations

## Repository Structure

```
dotrc/
├── zshrc               # Zsh main config (sourced by zshenv)
├── zshenv              # Zsh environment setup (entry point)
├── zimrc               # Zim framework modules
├── starship.toml       # Starship prompt config
├── ghosttyrc          # Ghostty terminal config
├── batrc              # bat (cat alternative) config
├── tigrc              # tig (git UI) config
├── gitmessage         # Git commit template
├── zed/               # Zed editor settings
├── claude/            # Claude Code guidelines
│   ├── AGENTS.md      # Main guidelines document
│   ├── system-rules.md # Critical rules
│   ├── mcp.json       # MCP server configuration
│   ├── guides/        # 16 detailed guide documents
│   ├── skills/        # Auto-discovered skills (commit, review, troubleshoot, refactor, agents)
│   ├── scripts/       # Automation scripts
│   └── templates/     # Document templates
└── AGENTS.md          # This file
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
ls -la ${HOME}/.claude/AGENTS.md
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

**Example**:
```zsh
# Good ✅
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
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

**For Claude Code users**: See [AGENTS.md](./claude/AGENTS.md) and [gitmessage](./gitmessage) for full commit guidelines.

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

1. Edit `zshrc` or `zshenv` in `${DOTRCDIR}`
2. Syntax check: `zsh -n ~/.config/dotrc/zshrc`
3. Test in new shell: `zsh -c 'source ~/.config/dotrc/zshrc'`
4. Reload current shell: `source ~/.config/dotrc/zshrc`
5. Commit with appropriate type (`refactor`, `feat`, `fix`)

### Updating Claude Guidelines

1. Edit files in `claude/guides/`
2. Run linter: `${DOTRCDIR}/claude/scripts/lint-docs.sh` (if exists)
3. Verify links work
4. Commit with `docs(claude): <description>`

### Managing Skills

1. Create skill directory: `claude/skills/<skill-name>/`
2. Write `SKILL.md` following existing patterns
3. Include: YAML frontmatter, metadata, context, instructions
4. Test with natural language: "<skill-trigger>"
5. Commit with `feat(claude): <skill-name> 스킬을 추가하다`

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

## Claude Skills (Auto-Discovered)

Skills are triggered by natural language requests:

| Skill | Trigger Examples | Purpose |
|-------|------------------|---------|
| `commit` | "커밋해줘", "commit changes" | Creates git commits with Korean messages |
| `review` | "리뷰해줘", "이거 괜찮아?" | Performs code review |
| `troubleshoot` | "왜 안돼?", "에러 났어" | Diagnoses and fixes errors |
| `refactor` | "리팩토링 해줘", "정리해줘" | Improves code quality |
| `agents` | "에이전트해줘", "AGENTS.md 만들어줘" | Manages AGENTS.md file |

## Related Resources

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [ZimFW Modules](https://zimfw.sh/docs/modules/)
- [Starship Config](https://starship.rs/config/)
- [mise Documentation](https://mise.jdx.dev/)
- [AGENTS.md Spec](https://agents.md/)

---

**Last Updated**: 2026-01-04
**Maintainer**: ujuc
**AI Agent Compatibility**: Universal (tested with Claude Code, GitHub Copilot, Cursor)
