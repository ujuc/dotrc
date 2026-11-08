---
name: 🐛 Bug report
about: The skill misbehaves, mishandles memory, ignores the protocol, or the agents drift out of role
title: "[Bug] "
labels: bug
assignees: ''
---

## Description

A clear description of what went wrong.

## The task you gave

What did you ask Dual-Brain to do? Paste the prompt / trigger you used.

```
（e.g. use dual brain to design a rate limiter）
```

## Expected behavior

What you expected to happen (e.g. Memory Intake loads relevant context, Right Brain grills first, then Left Brain verifies against real code/docs/memory).

## Actual behavior

What actually happened. If memory was skipped, stale memory was trusted, a brain skipped a step, drifted out of role, or the order broke, describe it.

## Project memory

- Was `.dual-brain/MEMORY.md` present? yes / no
- Did the skill read it, ignore it, misapply it, or save an incorrect update?
- Did it choose the wrong tier (Hot / Warm / Cold / Archived) or update `refs`, `last_referenced`, or `last_verified` incorrectly?
- Did the memory contain stale, contradictory, overgrown, or sensitive content?
- Did the skill fail to ask what memory should be removed or adjusted after saving?

## Environment

- Claude Code version:
- OS:
- Skill version / commit:

## Additional context

Logs, screenshots, relevant memory excerpts with secrets removed, or anything else that helps.
