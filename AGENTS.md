---
name: dotrc
description: Personal macOS development environment configuration
standard: agents.md/v1
---

## Project Overview

Personal macOS development environment configuration repository. Deployed via symlinks from `$XDG_CONFIG_HOME/dotrc` to each tool's expected location.

## Operational Gotchas

- `agents/` is an independent git submodule (`ujuc/agent-stuff`) — always commit and push inside `agents/` first, then update the parent pointer
- Each dotfile symlinks to a specific target path (e.g., `zshrc` → `~/.zshrc`, `starship.toml` → `$XDG_CONFIG_HOME/starship.toml`) — adding new files requires documenting the symlink target in README.md
- `~/.zshrc.work` is gitignored and loaded at the end of `zshrc` — work-specific config goes here, never in tracked files

## Non-Obvious Conventions

- `zshrc` has a strict section order: Environment → History → Plugins → Tools → Aliases → Local — preserve this when editing
- Commit scope maps to directories:

| Scope | When to use |
| -------- | --------------------------------------------------- |
| `zshrc` | Changes to zshrc or zimrc |
| `agents` | Submodule pointer updates |
| `zed` | Changes to zed/ directory |
| `scripts` | Changes to scripts/ directory |
| `docs` | Documentation files (CLAUDE.md, AGENTS.md, README.md) |
| _(omit)_ | Root-level dotfiles or multi-file changes |

## Boundaries

### Always Do

- Use symlinks for deployment, never copy files
- Check submodule status separately: `git -C agents status`

### Ask First

- Adding new dotfiles (needs symlink setup documentation in README.md)
- Modifying `gitmessage` template (affects all git commits globally)
- Changes to `agents/` submodule content (has its own repository and workflow)

### Never Do

- Track secrets, tokens, or work-specific paths in this repository
- Modify files in `agents/` without committing in the submodule first
