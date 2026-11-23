@AGENTS.md

## Claude Code

- Worker roles a skill dispatches live in `references/roles/<role>.md`; dispatch built-in `Explore` (read-only) or `general-purpose` with per-call `model`/`effort` from `ujuc/skills/generate-skills/references/model-selection.md#dispatch-routing`. Do not create `~/.claude/agents/` definitions.
- `Explore` workers load no CLAUDE.md, so a role file must carry every rule its worker needs.
