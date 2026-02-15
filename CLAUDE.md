# CLAUDE.md — dotrc

Personal dotfiles repository for macOS. Manages Zsh, terminal, editor, and tool configurations via symlinks from `${DOTRCDIR}` (`~/.config/dotrc`).

## Key Commands

```bash
# Validate shell syntax
zsh -n zshrc

# Benchmark startup time (default 10 runs)
./scripts/benchmark.sh [runs]

# Profile startup with zprof
./scripts/profile-startup.zsh

# Compile configs to .zwc bytecode
./scripts/compile-zsh.sh
```

## Architecture

### Zsh Loading Chain

```
zshenv (DOTRCDIR, XDG, PATH)
  └─ zshrc (single file, sectioned)
       ├─ Environment    # fpath, PATH
       ├─ History        # setopt HIST_*
       ├─ Plugins        # Zimfw, completion
       ├─ Tools          # starship, fzf, zoxide, mise
       ├─ Aliases        # Functions, aliases
       └─ Local          # Work config, 1Password
```

### Auto-Compilation

`zshrc` automatically compiles itself to `.zwc` bytecode when the source is newer than the compiled version. No manual compilation needed during normal workflow.

### Tool Loading Patterns

**Eager** — fast tools needed immediately (starship, fzf):

```zsh
if (( $+commands[starship] )); then
    _evalcache starship init zsh
fi
```

**Lazy** — slow tools deferred until first use (zoxide, mise):

```zsh
function z() {
    unfunction z
    _evalcache zoxide init zsh
    z "$@"
}
```

### Symlink Deployment

Configs live in this repo and symlink to their expected locations:

- `agents/claude/` → `~/.claude` (submodule — Claude Code global config)
- `agents/pi/` → `~/.pi` (submodule — Pi agent config)
- `agents/gemini/` → `~/.gemini` (submodule — Gemini CLI config)
- `starship.toml` → `$XDG_CONFIG_HOME/starship.toml`
- `ghosttyrc` → `$XDG_CONFIG_HOME/ghostty/config`

Agent configs are managed as a git submodule (`agents/`) from [ujuc/agent-stuff](https://github.com/ujuc/agent-stuff).

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
