@~/.config/dotrc/agents/rules/AGENTS.md

## Amp

- Edit `~/.config/dotrc/agents/amp/`, not the `~/.config/amp` symlink targets.
- Keep stable, secret-free preferences in `settings.json`.
- Amp loads `~/.claude/skills/`; keep reusable skills there instead of duplicating them under `amp/`.
- Add Amp-only plugins, checks, or skills only when an Amp-native implementation is required.
- Keep each MCP configuration in the skill that uses it. Read credentials from environment variables; never commit tokens or machine-specific secrets.
