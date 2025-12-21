# CLAUDE.md

Guidance for Claude Code when working with this dotfiles repository.

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
| `guides/` | 16 detailed guide documents (~4,500 lines) |
| `scripts/` | Doc linting automation |
| `templates/` | Guide document template |
| `commands/` | CLI command definitions |

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

## Notes

- Use `(( $+commands[tool] ))` for command existence checks
- Work overrides: `~/.zshrc.work` (auto-sourced)
- Test config changes before committing
- Follow commit template in `gitmessage`
