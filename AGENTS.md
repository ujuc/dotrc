---
name: "dotrc-agents"
description: "Universal AI agent guide for the dotrc dotfiles repository"
version: "3.1.0"
last_updated: "2026-02-10"
metadata:
  standard: "https://agents.md/"
  ai-compatibility: "Universal (Claude Code, GitHub Copilot, Cursor, Aider)"
---

# dotrc

**Universal AI Agent Guide** for the `dotrc` repository.

> **For Claude Code users**: See [CLAUDE.md](./claude/CLAUDE.md) for **Claude-specific** guidelines including:
> - Korean commit message format (Conventional Commits with `-하다` ending)
> - Code review process and quality standards
> - Auto-discovered skills (commit, review, troubleshoot, refactor, agents)
> - MCP server integrations and advanced features
>
> **Note**: CLAUDE.md contains comprehensive development standards optimized for Claude 4.5. Other AI agents should follow this AGENTS.md file.

## Project Overview

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
│   └── ai/             # AI work logs
├── zed/                # Zed editor settings
└── claude/             # Claude Code specific guidelines
    ├── CLAUDE.md       # Claude-specific entry point
    ├── guides/         # 16 detailed guideline documents
    ├── skills/         # Auto-discovered skills
    └── scripts/        # Automation scripts
```

### File Linking Strategy

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
```

**Important**: Always update files in `${DOTRCDIR}`, not the symlink targets.

## Build & Test Commands

**No build system** - This is a configuration repository.

### Setup

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

### Test

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

### Environment Variables

```bash
DOTRCDIR="${HOME}/.config/dotrc"          # This repository
XDG_CONFIG_HOME="${HOME}/.config"         # App configs
ZDOTDIR="${HOME}/.config/zsh"             # Zsh configs
```

#### Adding New Variables

1. Add to `zshenv` (sourced first, always)
2. Export with `export VAR="value"`
3. Use `${HOME}` not `~` for portability
4. Document in comments

## Code Style & Conventions

### Formatting

- **Indentation**: 2 spaces (YAML, TOML, JSON)
- **Line length**: No strict limit for config files
- **Quotes**: Always quote shell variables: `"${VAR}"`
- **Comments**: Explain non-obvious settings

### Naming Conventions

- **Files**: Flat structure, one tool per file (`starship.toml`, `batrc`)
- **Variables**: `${VAR}` for clarity, not `$VAR`
- **Functions**: Lowercase with underscores for complex logic
- **Exceptions**: Multi-file tools use directories (`claude/`, `zed/`)

### Code Patterns

```zsh
# Good - Eager loading (fast tools)
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# Good - Lazy loading (slow tools)
if (( $+commands[mise] )); then
  function mise() {
    unfunction mise
    eval "$(mise activate zsh)"
    mise "$@"
  }
fi

# Bad
if [ -x $(which starship) ]; then
  eval $(starship init zsh)
fi
```

### Shell Scripts (Zsh) Rules

- **Shebang**: `#!/usr/bin/env zsh` (not `/bin/zsh`)
- **Command checks**: Use `(( $+commands[tool] ))` instead of `which` or `command -v`
- **Conditionals**: Prefer `[[ ]]` over `[ ]`
- **Lazy loading**: Wrap expensive initializations in wrapper functions

### Aliases & Functions

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

## Git Workflow

### Commit Messages

**Format**: Korean commit messages using Conventional Commits with `-하다` verb ending.

```
<type>: <subject in Korean ending with -하다>

<body explaining WHY, not what>

<footer with issues/PRs>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:
- `feat: Starship 프롬프트 설정을 추가하다`
- `fix(zshrc): 중복된 PATH 항목을 제거하다`
- `docs: AGENTS.md 파일을 생성하다`

### Branch Strategy

- **Main branch**: `main`
- **Feature branches**: `feat/<description>`
- **Fix branches**: `fix/<description>`

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

> **Note**: This is Claude Code specific.

1. Edit files in `claude/guides/`
2. Run linter: `${DOTRCDIR}/claude/scripts/lint-docs.sh` (if exists)
3. Verify links work
4. Commit with `docs(claude): <description>`

### Managing Claude Skills

> **Note**: This is Claude Code specific. Other AI agents can skip this task.

1. Create skill directory: `claude/skills/<skill-name>/`
2. Write `SKILL.md` following existing patterns
3. Include: YAML frontmatter, metadata, context, instructions
4. Test with natural language: `"<skill-trigger>"`
5. Commit with `feat(claude): <skill-name> 스킬을 추가하다`

## Boundaries

### Always Do

- Run `zsh -n <file>` syntax check before committing shell scripts
- Follow existing code patterns and conventions in each file
- Quote all shell variables: `"${VAR}"`
- Use `(( $+commands[tool] ))` for command existence checks
- Test symlinks after creating or modifying them
- Include `-하다` verb ending in Korean commit messages
- Update files in `${DOTRCDIR}`, not symlink targets

### Ask First

- Adding new dependencies (Homebrew packages)
- Changing the zsh.d module loading order (XX- prefix numbers)
- Modifying `zshenv` (affects all Zsh sessions)
- Adding new symlinks to system directories
- Changing Claude Code guidelines in `claude/guides/`

### Never Do

- Commit secrets, API keys, or tokens
- Push directly to main without verification
- Delete or overwrite `~/.zshrc.work` (user's private work config)
- Modify files outside `${DOTRCDIR}` without explicit request
- Remove existing symlinks without confirming with user

## Security Considerations

- **Secrets**: Never commit secrets. Use `.env` files (gitignored)
- **Dependencies**: Use `~/.zshrc.work` for company-specific configs (gitignored)
- **Data**: Keep SSH keys in `~/.ssh/`, API tokens in keychain or environment-specific files

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

### Document Templates

Use templates in `docs/templates/` when creating new documents. See [docs/templates/AGENTS.md](./docs/templates/AGENTS.md) for details.

| Template | Purpose | Path |
|----------|---------|------|
| [guide-template.md](./docs/templates/guide-template.md) | Guide documents | `docs/templates/guide-template.md` |
| [work-template.md](./docs/templates/work-template.md) | Work logs | `docs/templates/work-template.md` |
| [agents-template.md](./docs/templates/agents-template.md) | AGENTS.md files | `docs/templates/agents-template.md` |
| [skill-template.md](./docs/templates/skill-template.md) | Claude skills | `docs/templates/skill-template.md` |

---

**Maintainer**: ujuc
**AI Agent Compatibility**: Universal (tested with Claude Code, GitHub Copilot, Cursor)
**Last Updated**: 2026-02-10

## See Also

- [**AGENTS.md Spec**](https://agents.md/) - Universal AI agent file standard
- [**CLAUDE.md**](./claude/CLAUDE.md) - Claude-specific guidelines
- [**docs/templates/AGENTS.md**](./docs/templates/AGENTS.md) - Document template directory guide

## Change Log

- **v3.1.0** (2026-02-10): Migrated from `<meta>` XML tag to YAML frontmatter
- **v3.0.0** (2026-02-10): Rewritten to follow agents-template.md structure
- **v2.1.0** (2026-02-10): Restructured to match agents-template format, added Boundaries section
- **v2.0.0** (2026-02-01): Separated Claude-specific content to claude/CLAUDE.md
- **v1.0.0** (2026-01-04): Initial version with universal and Claude-specific content merged
