## What does this PR change?

A short summary of the change.

## Why?

The motivation — what problem it solves or what it improves.

## Type of change

- [ ] 🐛 Bug fix (skill behaves correctly again)
- [ ] 💡 Persona / protocol improvement
- [ ] 🧩 New debate pattern or variant
- [ ] 🗂️ Project memory behavior
- [ ] 📖 Docs / README
- [ ] 🔧 Other

## How was it tested?

Describe a real task you ran with the updated skill and what you observed (e.g. "asked it to design X — Memory Intake loaded prior constraints, Right Brain grilled the assumptions, Left Brain caught a race condition against the real docs, synthesis combined both").

If memory behavior changed, note which cases you tested:

- [ ] No `.dual-brain/MEMORY.md`
- [ ] Valid project memory
- [ ] Hot / Warm / Cold / Archived tier behavior
- [ ] `refs`, `last_referenced`, and `last_verified` metadata
- [ ] Stale or contradictory memory
- [ ] Overgrown memory requiring compaction
- [ ] Sensitive content in memory
- [ ] Trivial task with no memory update needed

## Checklist

- [ ] `SKILL.md` keeps the fixed order (memory intake → Right Brain grills → Left Brain verifies → dual synthesis → memory auto-save/compaction → review prompt).
- [ ] The `description:` frontmatter still accurately reflects when the skill triggers.
- [ ] README is updated if behavior changed.
- [ ] Memory changes, if any, are auto-saved only for durable non-sensitive project context and followed by a review prompt.
- [ ] `.dual-brain/MEMORY.md` is treated as advisory context, not absolute truth.
- [ ] Memory compaction, if relevant, keeps decision-value, updates tiers, and archives stale noise.
- [ ] I tested this against at least one real task.
