# CLAUDE.md — dotrc

Personal dotfiles repository for macOS. Manages Zsh, terminal, editor, and tool configurations via symlinks from `${DOTRCDIR}` (`~/.config/dotrc`).

## Key Commands

```bash
zsh -n zshrc                     # Validate shell syntax
./scripts/benchmark.sh [runs]    # Benchmark startup time
./scripts/profile-startup.zsh    # Profile startup with zprof
```

## Architecture

### Zsh Loading Chain

```
~/.zshrc → ${DOTRCDIR}/zshrc (single file, sectioned)
  ├─ Environment    # XDG, DOTRCDIR, PATH
  ├─ History        # setopt HIST_*
  ├─ Plugins        # Zimfw, completion
  ├─ Tools          # starship, fzf, zoxide, mise
  ├─ Aliases        # Functions, aliases
  └─ Local          # Work config, 1Password
```

### Key Patterns

- **Eager loading**: Fast tools initialized immediately — starship, fzf (zshrc:77-90)
- **Lazy loading**: Slow tools deferred via wrapper functions — zoxide, mise (zshrc:92-122)

### Symlink Deployment

Configs symlink to expected locations. Agent configs managed as git submodule (`agents/`) from ujuc/agent-stuff.

- `agents/claude/` → `~/.claude`, `agents/pi/` → `~/.pi`, `agents/gemini/` → `~/.gemini`
- `starship.toml` → `$XDG_CONFIG_HOME/starship.toml`
- `ghosttyrc` → `$XDG_CONFIG_HOME/ghostty/config`

Always edit files in this repo, not at symlink targets.

## Conventions

### Language Policy

- **User-facing output** (terminal responses, commit subjects): Korean
- **File content** (code, comments, docs, commit body): English

### Commit Messages

Korean Conventional Commits ending with `-하다`:

```
<type>(<scope>): <Korean subject ending with -하다>
```

Examples: `feat: Starship 프롬프트 설정을 추가하다`, `fix(zshrc): 중복된 PATH 항목을 제거하다`

### Shell Coding

- Quote variables: `"${VAR}"` not `$VAR`
- Command checks: `(( $+commands[tool] ))` not `which` or `command -v`
- Conditionals: `[[ ]]` not `[ ]`
- Shebang: `#!/usr/bin/env zsh`

## Cross-References

- **[AGENTS.md](./AGENTS.md)** — Full repo structure, all tool configs, troubleshooting, boundaries
- **[agents/claude/CLAUDE.md](./agents/claude/CLAUDE.md)** — Claude-specific skills, MCP servers, priority hierarchy, guides
