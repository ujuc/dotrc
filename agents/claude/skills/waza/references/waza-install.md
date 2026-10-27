# waza Installation Guide

When waza is missing, only the evaluation is skipped; the caller's work continues.

## Install or update

`scripts/install.sh --agents` runs this when `waza` is not on PATH:

```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/waza/main/install.sh | bash
```

It installs to `/usr/local/bin` when writable, otherwise `$HOME/bin`; both are
on the dotrc `zshrc` path. Use 0.38.6 or later (`waza --version`); the local
Ollama BYOK path needs at least 0.35.

With no release binary for the platform: `git clone https://github.com/microsoft/waza.git`,
then `make install` in it (Go 1.21+, npm), and put `$(go env GOPATH)/bin` on PATH.

## Launcher prerequisites

Installing the binary does not create `~/.claude/data/waza-workspace/`.
`waza-run.sh` evaluates only when its `.waza.yaml` has relative `skills/` and
`evals/` paths with matching symlinks; otherwise it exits without a score.
Create it from the schema in the current
[upstream README](https://github.com/microsoft/waza/blob/main/README.md). The
format changes quickly, so dotrc does not generate it.

## Troubleshooting

**`waza: command not found` only inside an agent's Bash tool**: non-interactive
shells skip `~/.zshrc`. Put `export PATH="$HOME/bin:$PATH"` in `~/.zshenv`
(bash: `~/.bashrc`). The launcher also searches `$HOME/bin`, `/usr/local/bin`,
`/opt/homebrew/bin`, and GOPATH/bin.

## Uninstall

```bash
rm -f "$(command -v waza)"
rm -rf "$HOME/.claude/data/waza-workspace" "$HOME/.claude/data/waza"
```

Both directories live under `~/.claude/data/`, outside git tracking, so removing them is safe.
