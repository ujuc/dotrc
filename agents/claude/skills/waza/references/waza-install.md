# waza Installation Guide

`waza` is Microsoft's CLI for evaluating AI agent skills. In dotrc the `waza`
skill launcher (`scripts/waza-run.sh`) is the only call site; `generate-skills`,
`skill-improver`, and explicit evaluation requests all go through it. When waza
is not installed, only the evaluation is skipped.

## Quick install (macOS / Linux)

`scripts/install.sh --agents` runs the upstream installer below whenever `waza`
is missing from PATH. Use the same command to install or update manually.

```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/waza/main/install.sh | bash
```

Install location: `/usr/local/bin` when writable, otherwise `$HOME/bin`. Both
are already on the `path` array in the dotrc `zshrc`. For shells that do not
load the dotrc `zshrc`, add to `~/.zshenv` (zsh) or `~/.bashrc` (bash):

```sh
export PATH="$HOME/bin:$PATH"
```

> Prefer `~/.zshenv` in a dotrc environment. It applies to interactive and
> non-interactive shells alike, so the Bash tools inside Claude Code, Amp, and
> Codex also see `waza`.

## Verify

```bash
waza --version          # waza version 0.38.6 (or higher)
waza --help             # list available subcommands
which waza              # confirm the install path
```

## Build from source (Go 1.21+)

When no release binary exists for your platform, or you want the latest `main`:

```bash
git clone https://github.com/microsoft/waza.git
cd waza
make install            # installs to GOPATH/bin (needs Go 1.21+ and npm for the web dashboard)
```

Or, if the repository is already cloned locally:

```bash
cd ~/repos/waza
make install
```

After `make install`, confirm `$(go env GOPATH)/bin` is on PATH.

## Launcher prerequisites

Installing the binary does not create `~/.claude/data/waza-workspace/`.
`waza-run.sh` runs an evaluation only when a valid `.waza.yaml` exists with
relative `skills/` and `evals/` paths and the matching symlinks. Otherwise it
exits safely without a score.

To create the workspace, follow the initialization steps and schema in the
current [upstream README](https://github.com/microsoft/waza/blob/main/README.md).
The `.waza.yaml` format changes quickly, so this repository does not generate it.

## Local Ollama model

`waza-run.sh` uses the local Ollama model `gemma4:26b-mlx` as the default
evaluation target through waza's Copilot SDK BYOK path. The defaults are:

```sh
COPILOT_PROVIDER_BASE_URL=http://localhost:11434/v1
COPILOT_PROVIDER_TYPE=openai
COPILOT_MODEL=gemma4:26b-mlx
COPILOT_OFFLINE=true
```

Existing environment values override the launcher defaults. The Ollama server
and model must be ready before a real (non-mock) evaluation.

## Troubleshooting

**`waza: command not found` (visible in your shell, missing inside an agent's Bash tool)**
- A non-interactive shell does not source `~/.zshrc`. Fix: move the PATH line to `~/.zshenv` so every shell picks it up.
- Workaround: `waza-run.sh` searches `$HOME/bin`, `/usr/local/bin`, `/opt/homebrew/bin`, and GOPATH/bin as fallbacks, so it usually works anyway.

**`Permission denied`**
- `chmod +x /usr/local/bin/waza`, or grant execute permission to the binary wherever it was installed.

**Version too old (0.38.5 or lower)**
- The local Ollama BYOK setup needs 0.35+ for the provider-only model ID fix; the current configuration recommends 0.38.6 or higher.

## Uninstall

```bash
rm -f "$(command -v waza)"
rm -rf "$HOME/.claude/data/waza-workspace" "$HOME/.claude/data/waza"
```

The workspace and results directories live outside the dotrc repository under
`~/.claude/data/` and are not tracked by git, so removing them is safe.

## Related locations

- Workspace config: `~/.claude/data/waza-workspace/.waza.yaml`
- Result JSON: `~/.claude/data/waza/results/`
- Skill launcher: `~/.claude/skills/waza/scripts/waza-run.sh`
- `waza-runner` agent (Claude Code isolated-context wrapper): `~/.claude/agents/waza-runner.md`
- Eval suites: `~/.claude/evals/<skill>/eval.yaml` (for example `~/.claude/evals/commit/eval.yaml`)
