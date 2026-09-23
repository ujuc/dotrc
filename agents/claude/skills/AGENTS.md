# Skill Authoring

- Follow `generate-skills/references/frontmatter-spec.md` for skill metadata.
- Write skill bodies in English. `description`, `when_to_use`, user-visible trigger phrases, and target-language corpora or linguistic rulebooks may use their functional language.
- Update `README.md` when a skill's purpose, triggers, model, group, or pipeline role changes.
- Read `README.md` before changing a pipeline component; changes can break downstream contracts.
- Put shared logic in one authoritative skill's `references/` and link to it instead of copying.
- Do not track plugin-generated `learned/` content.
- State each skill's recommended workload profile and escalation conditions using [the model selection guide](generate-skills/references/model-selection.md). Resolve Lightweight, Standard, Advanced, or Frontier to a supported model for the current task; inheritance is a fallback, not the recommendation. Keep native model IDs separate from profile labels, respect explicit user choices, and distinguish advice from actual switching.
- Read the machine-readable workflow surface (artifact paths, writers, archive destinations, cadence, and Superpowers pins) with `workflow-hooks contract`.
- `skill-improver` runs through the SessionStart cadence hook; do not also schedule it with cron.
