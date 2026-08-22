# Codex Hook Configuration

- Keep `hooks.json` limited to Codex event wiring; shared behavior belongs in `../hooks/workflow-hooks.sh`.
- Keep `hook-adapter.sh` as an event-shape adapter and do not duplicate policy there.
- Codex reports file mutations through `apply_patch`; derive paths only from supported patch headers.
- Command hooks require explicit review through Codex `/hooks` after their definition changes.
- Deploy `hooks.json` as `~/.codex/hooks.json`; edit this repository source, never the symlink target.
