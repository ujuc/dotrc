# Codex Hook Configuration

- Keep `hooks.json` limited to Codex event wiring.
- Command hooks require explicit review through Codex `/hooks` after their definition changes.
- Deploy `hooks.json` as `~/.codex/hooks.json`; edit this repository source, never the symlink target.
