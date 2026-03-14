# Project Overview

Personal macOS development environment configuration. CLI tools, shell settings, editor configs, and AI agent setups managed via symlinks from `$XDG_CONFIG_HOME/dotrc`.

# Technical Stack

- Zsh (ZimFW, Starship prompt)
- Homebrew (package management)
- Symlink deployment model

# Development Commands

No build or test toolchain. This is a pure configuration repository.

# Work Rules

- Commit directly to `main` (no branches/PRs)
- Korean Conventional Commits ending with `-하다`:
  ```
  <type>(<scope>): <Korean subject ending with -하다>
  ```
- **Types**: feat, fix, docs, style, refactor, test, chore
- **Scopes**: zshrc, agents, zed, scripts, docs, or omit for root-level changes

# Behavioral Guidelines

- `agents/` is a git submodule (`ujuc/agent-stuff`) with its own CLAUDE.md — check submodule status separately when changes are detected
- Work-specific config goes in `~/.zshrc.work` (gitignored), never in tracked files
- When modifying `zshrc`, preserve the section structure: Environment → History → Plugins → Tools → Aliases → Local

# References

- **[AGENTS.md](./AGENTS.md)** — Full project structure, file inventory, and detailed guide
- **[agents/CLAUDE.md](./agents/CLAUDE.md)** — AI agent configuration (submodule)
