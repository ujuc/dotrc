# Project Overview

Personal macOS development environment configuration. CLI tools, shell settings, editor configs, and AI agent setups managed via symlinks from `$XDG_CONFIG_HOME/dotrc`.

# Technical Stack

- Zsh (ZimFW, Starship prompt)
- Homebrew (package management)
- Symlink deployment model

# Development Commands

No build or test toolchain. This is a pure configuration repository.

Symlink deployment (manual, per README.md):

```bash
ln -sf ${DOTRCDIR}/zshrc ${HOME}/.zshrc
ln -sf ${DOTRCDIR}/starship.toml ${XDG_CONFIG_HOME}/starship.toml
ln -sf ${DOTRCDIR}/ghosttyrc ${XDG_CONFIG_HOME}/ghostty/config
ln -sf ${DOTRCDIR}/batrc ${XDG_CONFIG_HOME}/bat/config
ln -sf ${DOTRCDIR}/tigrc ${XDG_CONFIG_HOME}/tig/config
ln -sf ${DOTRCDIR}/zed/settings.json ${XDG_CONFIG_HOME}/zed/settings.json
```

Zsh startup benchmarks:

```bash
scripts/benchmark.sh          # Measure startup time
scripts/profile-startup.zsh   # Profile per-module timing
```

# Work Rules

- Commit directly to `main` (no branches/PRs)
- Korean Conventional Commits ending with `-하다`:
  ```
  <type>(<scope>): <Korean subject ending with -하다>
  ```
- **Types**: feat, fix, docs, style, refactor, test, chore
- **Scopes**: zshrc, agents, zed, scripts, or omit for root-level changes

# Behavioral Guidelines

- `agents/` is a git submodule (`ujuc/agent-stuff`) with its own CLAUDE.md — check submodule status separately when changes are detected
- Work-specific config goes in `~/.zshrc.work` (gitignored), never in tracked files
- When modifying `zshrc`, preserve the section structure: Environment → History → Plugins → Tools → Aliases → Local

# References

- **[AGENTS.md](./AGENTS.md)** — Full project structure, file inventory, and detailed guide
- **[agents/CLAUDE.md](./agents/CLAUDE.md)** — AI agent configuration (submodule)
