# Skill review checklist

> Only the semantic and trigger checks that the automated validator (`scripts/validate-skill`) cannot do. Form checks (kebab-case, length, reserved prefix, etc.) are already handled there and are not repeated here.

For full specifications see:

- Frontmatter fields: `references/frontmatter-spec.md`
- Description writing & examples: `references/description-examples.md`
- Folder structure rules: `references/skill-structure.md`

---

## Trigger tuning

### Under-triggering (skill is not loaded)

Symptoms:
- The skill is not auto-loaded even when the user makes a related request.
- The user has to invoke `/skill-name` manually every time.

Fixes:
- Add **phrases the user actually says** to `description`.
- Include synonyms, abbreviations, and colloquial variants.
- Example: "PR 만들어줘", "풀리퀘 생성", "pull request".

### Over-triggering (loaded for unrelated requests)

Symptoms:
- Loaded for unrelated work.
- The user disables the skill.

Fixes:
- Add a negative trigger: `"Do NOT use for simple data exploration"`.
- Tighten the scope.
- Drop overly generic words (e.g., "help", "manage").

---

## Semantic checks

Automation only checks form. The items below need human judgment.

### `description`

- [ ] WHAT (what it does) is stated.
- [ ] WHEN (when to use it) is stated.
- [ ] Trigger phrases the user actually says are present.
- [ ] Doesn't lead with overly generic words ("help", "manage") that risk over-triggering.

### Body instructions

- [ ] Each step is concrete (runnable commands, specific criteria).
- [ ] Failure modes and recovery are covered.
- [ ] Input/output examples are present.
- [ ] Tools used are named (Read, Bash, AskUserQuestion, ...).

### Structure

- [ ] All `references/` paths point to real files.
- [ ] If body exceeds 500 lines, identify content to split into `references/`.
