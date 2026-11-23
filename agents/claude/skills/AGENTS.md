# Skill Authoring

- Follow `ujuc/skills/generate-skills/references/frontmatter-spec.md` for skill metadata.
- `skill-diet/` and `dual-brain/` are git subtrees of upstream release tags: keep their text verbatim. Update `skill-diet` with `ujuc/skills/generate-skills/scripts/skill-diet-upstream`; update `dual-brain` with `git subtree pull --prefix=agents/claude/skills/dual-brain <url> <tag> --squash`.
- Register each tagged subtree or release-asset skill in `ujuc/skills/generate-skills/scripts/upstream-check` so skill checks report its new releases. A reference that caches upstream pages names them in `source_url`/`secondary_source_url`/`spec_url`/`source_urls` with a `source_sha256` block, which `upstream-check` compares; refresh the block with `upstream-check hashes <file>` only after reviewing the content.
- `egm/` is the unpacked upstream `egm-claude-<version>.zip` release asset: keep it verbatim and update it by replacing the whole directory with a checksum-verified newer zip.
- Write skill bodies in English. `description`, `when_to_use`, user-visible trigger phrases, and target-language corpora or linguistic rulebooks may use their functional language.
- Update `README.md` when a skill's purpose, triggers, model, or pipeline role changes.
- Read `README.md` before changing a pipeline component; changes can break downstream contracts.
- Put shared logic in one authoritative skill's `references/` and link to it instead of copying.
- When two skills can claim the same request, record the boundary in `../rules/skill-routing.md` (loaded in every session as `~/.claude/rules/`) instead of widening either `description`.
- State each skill's recommended workload profile and escalation conditions using [the model selection guide](ujuc/skills/generate-skills/references/model-selection.md).
