# Skill Design Principles

> Seven core principles that guide all skill creation.

---

## 1. Concise is Key

The context window is a shared resource. Every token has a cost. A skill earns
its tokens only by supplying what the model **cannot** derive on its own — from
its training or by reading the code in front of it. If the model already knows
it, it does not belong in a skill.

**Aggressively cut model-known content first.** Anything the model absorbed in
training — language idioms, standard tool/CLI behavior, generic best practices,
common file formats, Git verbs, well-known config conventions — adds no value
when restated. Telling the model what it already knows changes nothing and only
crowds out the instructions that actually steer it.

**What to omit:**
- General knowledge Claude already knows (e.g., "Markdown uses # for headings")
- Generic filler ("This skill is helpful for...")
- Excessive preamble and qualifiers
- Supporting documents: README.md, CHANGELOG.md, CONTRIBUTING.md

**The test:** Does this token change Claude's behavior? If not, remove it. When
unsure whether the model already knows something, assume it does and cut it.

---

## 2. Degrees of Freedom

Match the specificity of instructions to the nature of the task.

| Freedom | Instruction style | Best for |
|---------|-------------------|----------|
| Low | "ALWAYS use this exact format" | Format-critical, high-repetition tasks |
| Medium | "Follow this structure, adapt as needed" | Tasks with patterns but context variance |
| High | "Use your best judgment" | Creative tasks, highly variable context |

**Decision criteria:**

- **Task fragility**: Must the format be exact? → Low freedom
- **Context dependency**: Should results vary by situation? → High freedom
- **Repetition**: Does the same pattern repeat? → Low freedom

---

## 3. Progressive Disclosure

Split information into 3 tiers. Agents load only what they need.

### Tier 1: Metadata (always loaded)

- Frontmatter fields: `name`, `description`, `disable-model-invocation`, `user-invocable`
- Used by the system for trigger detection and invocation control
- Target: ~100 words or fewer

### Tier 2: SKILL.md body (loaded on trigger)

- Core workflow and execution instructions
- Hard limit: **5,000 words / 500 lines**
- Exceed this? Move content to Tier 3

### Tier 3: Bundled resources (loaded on demand)

- `references/`: detailed rules, examples, checklists
- `scripts/`: automation and validation scripts
- `assets/`: images, diagrams, PDFs
- No size limit

---

## 4. Gotchas Section

Build and maintain a Gotchas section in every skill. This is the highest-signal content in any skill.

**What to include:**
- Common failure points Claude runs into when using the skill
- Edge cases that break expected behavior
- Mistakes that are hard to debug

**How to build it:**
- Start with known failure modes during initial creation
- Update the skill over time as Claude hits new edge cases
- Each gotcha should be actionable: describe the problem AND the correct approach

> Source: [Lessons from Building Claude Code](https://x.com/trq212/article/2033949937936085378) — Thariq (@trq212), 2026-03-18

---

## 5. Setup & Configuration

Some skills need user-specific context before they can run. Use a `config.json` pattern to manage this.

**Pattern:**
1. Check for `config.json` in the skill directory (or `${CLAUDE_PLUGIN_DATA}`)
2. If missing or incomplete, ask the user via AskUserQuestion
3. Store responses in `config.json` for future runs

**Example:** A standup-post skill needs to know which Slack channel to post to. On first run, it asks the user and saves the choice.

**Structured questions:** Instruct Claude to use AskUserQuestion for multiple choice or structured input.

> Source: [Lessons from Building Claude Code](https://x.com/trq212/article/2033949937936085378) — Thariq (@trq212), 2026-03-18

---

## 6. Memory & Data Persistence

Skills can store data across runs using `${CLAUDE_PLUGIN_DATA}` — a stable folder per plugin.

**Storage options:**
- Append-only text log (simplest — e.g., `standups.log`)
- JSON files (structured data)
- SQLite database (complex queries)

**Why not the skill directory?** Data stored in the skill directory may be deleted when the skill is upgraded. Always use `${CLAUDE_PLUGIN_DATA}` for persistent data.

**Example:** A standup-post skill keeps `standups.log` with every post. On next run, Claude reads its own history and reports what changed since yesterday.

> Source: [Lessons from Building Claude Code](https://x.com/trq212/article/2033949937936085378) — Thariq (@trq212), 2026-03-18

---

## 7. On Demand Hooks

Skills can register hooks that activate only when the skill is called and last for the session duration. Use this for opinionated guardrails that would be too noisy if always active.

**Examples:**
- **/careful** — PreToolUse matcher on Bash that blocks `rm -rf`, `DROP TABLE`, `force-push`, `kubectl delete`. Useful when touching prod.
- **/freeze** — blocks Edit/Write outside a specific directory. Useful when debugging to prevent accidentally "fixing" unrelated code.

**When to use:** The skill involves destructive actions, or the user needs temporary constraints on Claude's behavior.

**Implementation:** Define hooks in the skill's frontmatter. They are session-scoped and automatically cleaned up.

> Source: [Lessons from Building Claude Code](https://x.com/trq212/article/2033949937936085378) — Thariq (@trq212), 2026-03-18

---

## What NOT to include

| Type | Example | Reason |
|------|---------|--------|
| Supporting docs | README.md, CHANGELOG.md | Not needed in skill folders |
| General knowledge | "Git is a version control system" | Claude already knows |
| Excessive qualifiers | "This powerful skill will..." | Token waste |
| Self-description | "This skill includes the following:" | Show with instructions instead |
