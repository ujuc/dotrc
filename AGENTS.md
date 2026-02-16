---
name: dotrc
description: Personal macOS development environment configuration
version: "1.0"
standard: agents.md/v1
---

## Project Overview

Personal macOS development environment configuration repository. Manages Zsh shell settings, CLI tool configs, editor settings, and AI agent setups. Deployed via symlinks from `$XDG_CONFIG_HOME/dotrc` to each tool's expected location.

### Technical Stack

- **Shell**: Zsh + ZimFW + Starship prompt
- **Package manager**: Homebrew
- **Deployment**: Symlinks to `$HOME` and `$XDG_CONFIG_HOME`
- **CI/CD**: None

## Repository Structure

```
dotrc/
├── CLAUDE.md              # Claude Code project instructions
├── AGENTS.md              # This file — project guide for AI agents
├── README.md              # Installation guide (Homebrew-first setup)
├── LICENSE                # MIT License
├── .gitmodules            # Submodule declaration (agents/)
├── zshrc                  # Zsh config (→ ~/.zshrc)
├── zimrc                  # ZimFW plugin list
├── starship.toml          # Starship prompt config (→ $XDG_CONFIG_HOME/starship.toml)
├── ghosttyrc              # Ghostty terminal config (→ $XDG_CONFIG_HOME/ghostty/config)
├── batrc                  # bat theme config (→ $XDG_CONFIG_HOME/bat/config)
├── tigrc                  # Tig vim keybindings (→ $XDG_CONFIG_HOME/tig/config)
├── gitmessage             # Git commit message template
├── scripts/
│   ├── benchmark.sh       # Zsh startup time benchmark
│   └── profile-startup.zsh  # Per-module startup profiling
├── zed/
│   └── settings.json      # Zed editor config (→ $XDG_CONFIG_HOME/zed/settings.json)
└── agents/                # Git submodule (ujuc/agent-stuff)
    ├── CLAUDE.md          # Submodule-level instructions
    ├── AGENTS.md          # Submodule-level agent guide
    ├── claude/            # Claude Code global config (→ ~/.claude)
    ├── gemini/            # Gemini CLI config (→ ~/.gemini) — placeholder
    └── pi/                # Pi agent config (→ ~/.pi) — placeholder
```

### Key Files

| File | Purpose |
| ---- | ------- |
| `zshrc` | Single-file Zsh configuration: environment, plugins, tools, aliases |
| `zimrc` | ZimFW module list (completions, syntax highlighting, autosuggestions) |
| `gitmessage` | Commit template enforcing Korean Conventional Commits format |
| `agents/` | AI agent configs — independent git submodule with own docs |

## Build & Test

No build or test toolchain. This is a pure configuration repository.

### Validation

```bash
scripts/benchmark.sh          # Measure Zsh startup time
scripts/profile-startup.zsh   # Profile per-module startup timing
```

## Code Style

Conventions not enforceable by linters:

- `zshrc` uses section separators: `# ── Section ──────────────────────────`
- Lazy loading pattern for heavy tools: create wrapper function that unloads itself on first call
- Conditional tool setup: `if (( $+commands[tool] ))` guard before tool initialization

## Git Workflow

- **Branch strategy**: Direct commit to `main`
- **Commit format**: Korean Conventional Commits ending with `-하다`

```
<type>(<scope>): <Korean subject ending with -하다>
```

### Types

feat, fix, docs, style, refactor, test, chore

### Scopes

| Scope | When to use |
| -------- | -------------------------------- |
| `zshrc` | Changes to zshrc or zimrc |
| `agents` | Submodule pointer updates |
| `zed` | Changes to zed/ directory |
| `scripts` | Changes to scripts/ directory |
| _(omit)_ | Root-level or multi-file changes |

### Examples

- `refactor(zshrc): zsh.d 모듈들을 단일 zshrc 파일로 통합하다`
- `chore(agents): 서브모듈을 업데이트하다`
- `docs: 설치 가이드를 Homebrew 관리 방식에 맞게 재구성하다`

## Boundaries

### Always Do

- Use symlinks for deployment, never copy files
- Preserve `zshrc` section structure when editing
- Check submodule status separately: `git -C agents status`
- Keep work-specific config in `~/.zshrc.work` (gitignored)

### Ask First

- Adding new dotfiles (needs symlink setup documentation in README.md)
- Modifying `gitmessage` template (affects all git commits globally)
- Changes to `agents/` submodule content (has its own repository and workflow)

### Never Do

- Track secrets, tokens, or work-specific paths in this repository
- Modify files in `agents/` without committing in the submodule first
- Use `cd` in Bash tool — always use absolute paths or `git -C <path>`
