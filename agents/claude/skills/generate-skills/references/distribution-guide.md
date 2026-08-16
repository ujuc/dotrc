# Skill Distribution Guide

> How to share, compose, and measure skills across teams.

> Source: [Lessons from Building Claude Code: How We Use Skills](https://x.com/trq212/article/2033949937936085378) — Thariq (@trq212), 2026-03-18

---

## Distribution Methods

| Method | Best for | Trade-off |
|--------|----------|-----------|
| Repo check-in (`.claude/skills/`) | Small teams, few repos | Every checked-in skill adds to model context |
| Plugin marketplace | Larger orgs, many repos | Users choose which to install; scales better |

For smaller teams, checking skills into repos works well. As you scale, an internal plugin marketplace lets teams decide which skills to install, avoiding context bloat.

See [plugin marketplace documentation](https://code.claude.com/docs/en/plugin-marketplaces) for setup details.

---

## Managing a Marketplace

Anthropic uses an organic promotion flow rather than centralized curation:

1. **Sandbox**: Upload skill to a sandbox folder in GitHub; share via Slack or forums
2. **Traction**: Skill owner decides when it has gained enough traction
3. **Promotion**: PR to move skill into the official marketplace

**Warning:** It is easy to create bad or redundant skills. Ensure some method of curation before release.

---

## Composing Skills

Skills can depend on each other. For example, a CSV generation skill might call a file upload skill.

**How it works today:**
- Reference other skills by name in your SKILL.md instructions
- The model will invoke them if they are installed
- Native dependency management is not yet built into marketplaces or skills

**Example:** "After generating the CSV, use the `file-upload` skill to upload it to the shared drive."

---

## Measuring Skills

Track skill usage with a PreToolUse hook that logs invocations.

**What you can measure:**
- Which skills are popular
- Which skills are undertriggering compared to expectations
- Usage trends over time

**Implementation:** PreToolUse hook that logs skill invocations to a central store. See [example gist](https://gist.github.com/ThariqS/24defad423d701746e23dc19aace4de5) for reference code.
