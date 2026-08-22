# Pi Extension Configuration

- Keep `extensions/workflow-hooks.ts` limited to Pi event translation; shared behavior belongs in `../hooks/workflow-hooks.sh`.
- Load portable skills from `~/.claude/skills/` through `resources_discover`; do not duplicate skill files under `pi/`.
- Preserve built-in tool result content when appending hook feedback.
- Deploy the extension as `~/.pi/agent/extensions/workflow-hooks.ts`; edit this repository source, never the symlink target.
- Keep credentials and Pi runtime state outside tracked files.
