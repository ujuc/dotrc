# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository (`dotrc`) for macOS. Manages shell configs, application settings, and development environment.

## Structure

| Component | Files | Purpose |
|-----------|-------|---------|
| Shell | `zshrc`, `zshenv`, `zimrc` | Zsh + ZimFW setup |
| Apps | `zed/`, `starship.toml`, `batrc`, `tigrc`, `ghosttyrc` | Tool configs |
| Git | `gitmessage` | Commit template |
| Claude | `claude/` | AI development guidelines |

### Claude Directory (`claude/`)

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Main entry point (→ `~/.claude/CLAUDE.md`) |
| `system-rules.md` | Critical rules (highest priority) |
| `mcp.json` | MCP server configuration |
| `guides/` | 16 detailed guide documents |
| `skills/` | Auto-discovered skills (commit, review, troubleshoot, refactor) |
| `scripts/` | Doc linting automation |
| `templates/` | Guide document template |

## File Linking

```bash
# App configs
ln -sf ${DOTRCDIR}/starship.toml ${XDG_CONFIG_HOME}/starship.toml
ln -sf ${DOTRCDIR}/zed/settings.json ${XDG_CONFIG_HOME}/zed/settings.json
ln -sf ${DOTRCDIR}/ghosttyrc ${XDG_CONFIG_HOME}/ghostty/config

# Claude global config
ln -sf ${DOTRCDIR}/claude/CLAUDE.md ${HOME}/.claude/CLAUDE.md

# Pre-commit hook (optional)
ln -sf ${DOTRCDIR}/claude/scripts/pre-commit-lint ${DOTRCDIR}/.git/hooks/pre-commit
```

## Key Tools

- **Shell**: Zsh + ZimFW + Starship + mise + zoxide + fzf
- **Editor**: Zed (Catppuccin theme, VSCode keybindings)
- **Terminal**: Ghostty (Nord Wave theme, Cascadia Code font)
- **CLI**: bat, eza, tig, git-delta, ollama

## Key Aliases (zshrc)

```bash
ls → eza --icons=auto --group-directories-first --git
ll → eza -l --git --icons=auto
cat → bat
update → brew update/upgrade + zimfw update + cleanup
```

## Env Variables

- `DOTRCDIR`: Repository location
- `XDG_CONFIG_HOME`: App configs
- `ZDOTDIR`: Zsh config directory

## Skills (Auto-Discovered)

Skills are triggered by natural language requests:

| Skill | Trigger Examples | Purpose |
|-------|------------------|---------|
| `commit` | "커밋해줘", "commit changes" | Creates git commits with Korean messages |
| `review` | "리뷰해줘", "이거 괜찮아?" | Performs code review |
| `troubleshoot` | "왜 안돼?", "에러 났어" | Diagnoses and fixes errors |
| `refactor` | "리팩토링 해줘", "정리해줘" | Improves code quality |

## Notes

- Use `(( $+commands[tool] ))` for command existence checks
- Work overrides: `~/.zshrc.work` (auto-sourced)
- Test config changes before committing
- Korean commit messages use "-하다" verb ending (e.g., `feat: 기능을 추가하다`)
