# Codex Hook Configuration

- Keep `hooks.json` limited to Codex event wiring; shared behavior and Codex event translation belong in the `../tools/workflow-hooks/` Rust binary.
- Codex reports file mutations through `apply_patch`; the shared binary must derive paths only from supported patch headers.
- Command hooks require explicit review through Codex `/hooks` after their definition changes.
- Deploy `hooks.json` as `~/.codex/hooks.json`; edit this repository source, never the symlink target.
