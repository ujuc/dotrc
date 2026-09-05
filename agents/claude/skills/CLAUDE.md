# Skill Authoring

- Follow `generate-skills/references/frontmatter-spec.md` for skill metadata.
- Write skill bodies in English. `description`, `when_to_use`, user-visible trigger phrases, and target-language corpora or linguistic rulebooks may use their functional language.
- Update `README.md` when a skill's purpose, triggers, model, group, or pipeline role changes.
- Read `README.md` before changing a pipeline component; changes can break downstream contracts.
- Put shared logic in one authoritative skill's `references/` and link to it instead of copying.
- Do not track plugin-generated `learned/` content.
- Use `opus` for planning or orchestration, `sonnet` for deterministic execution, and `haiku` for mechanical rendering. Use `sonnet` with `advisor()` for independent review when needed.
- Read the machine-readable workflow surface with `workflow-hooks contract`; `agents/workflow-contract.json` is canonical for artifact paths, writers, archive destinations, cadence, and Superpowers pins.
- Chrome-dependent skills must load deferred tool schemas with `ToolSearch` before calling them.
- `skill-improver` runs through the SessionStart cadence hook; do not also schedule it with cron.
