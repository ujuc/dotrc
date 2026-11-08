# Skill Authoring

- Follow `ujuc/skills/generate-skills/references/frontmatter-spec.md` for skill metadata.
- `skill-diet/` and `dual-brain/` are git subtrees of upstream release tags: keep their text verbatim (only the `group` line is local). Update `skill-diet` with `ujuc/skills/generate-skills/scripts/skill-diet-upstream`; update `dual-brain` with `git subtree pull --prefix=agents/claude/skills/dual-brain <url> <tag> --squash`.
- `egm/` is the unpacked upstream `egm-claude-<version>.zip` release asset: keep it verbatim, add no `group` lines, and update it by replacing the whole directory with a checksum-verified newer zip.
- Write skill bodies in English. `description`, `when_to_use`, user-visible trigger phrases, and target-language corpora or linguistic rulebooks may use their functional language.
- Update `README.md` when a skill's purpose, triggers, model, group, or pipeline role changes.
- Read `README.md` before changing a pipeline component; changes can break downstream contracts.
- Put shared logic in one authoritative skill's `references/` and link to it instead of copying.
- State each skill's recommended workload profile and escalation conditions using [the model selection guide](ujuc/skills/generate-skills/references/model-selection.md).
- Worker roles a skill dispatches live in `references/roles/<role>.md`; dispatch built-in `Explore` (read-only) or `general-purpose` with per-call `model`/`effort` from `ujuc/skills/generate-skills/references/model-selection.md#dispatch-routing`. Do not create `~/.claude/agents/` definitions.
- `Explore` workers load no CLAUDE.md, so a role file must carry every rule its worker needs.
