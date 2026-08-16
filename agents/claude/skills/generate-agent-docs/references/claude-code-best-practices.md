---
source_url: https://code.claude.com/docs/en/best-practices.md
secondary_source_url: https://code.claude.com/docs/en/memory.md
last_upstream_check: 2026-07-27
check_interval_days: 0  # 0 = fetch on every run (user preference: always live; the doc changes often). WebFetch caches per-URL for ~15 min, so this is cheap.
---

# Claude Code Best Practices — Authoritative CLAUDE.md Guidance

This file is the **authoritative source** for how the skill writes and verifies
CLAUDE.md / AGENTS.md / rules. It is the single authoritative
source for the include/exclude rule and the size budget; the research rationale
(ETH Zurich data) is inlined in SKILL.md's Generation Philosophy.

## How this file is used (live fetch first, cache as fallback)

The upstream Claude Code docs change frequently, so the orchestrator does **not**
treat the snapshot below as frozen truth. Policy: **fetch live on every run**
(`check_interval_days: 0`) — no cache-skip window — because freshness is the whole
point. WebFetch caches each URL for ~15 minutes, so repeated runs in one sitting
do not re-hit the network. At skill start (Stage 0 / Generation Philosophy load),
the orchestrator:

0. **Load WebFetch first**: it is a deferred tool — call `ToolSearch` with query
   `select:WebFetch` to load its schema before using it. `allowed-tools` only
   pre-grants permission; without the ToolSearch load the call errors out.
1. **WebFetch `source_url`** (and `secondary_source_url` when CLAUDE.md sizing or
   `/init` behavior is in scope) for the latest guidance.
2. On success: use the fetched content; if it differs materially from the cache
   below, update the cache and bump `last_upstream_check` to today.
3. On **any** failure (tool not loaded, offline, rate limit, layout change): fall
   back to the cached snapshot below and tell the user in one line — *"best-practices
   라이브 로드 실패, 캐시 사용 (last check: <date>)."*

The split across two pages is deliberate: the include/exclude table, prune-test,
and failure patterns live on `best-practices`; the 200-line budget, `/init`
behavior, the AGENTS.md import pattern, and the `.claude/rules/` format live on
`memory`.

---

## Cached snapshot (last verified 2026-07-19)

### ✅ Include / ❌ Exclude (source: best-practices)

| ✅ Include                                            | ❌ Exclude                                          |
| ---------------------------------------------------- | -------------------------------------------------- |
| Bash commands Claude can't guess                     | Anything Claude can figure out by reading code     |
| Code style rules that differ from defaults           | Standard language conventions Claude already knows |
| Testing instructions and preferred test runners      | Detailed API documentation (link to docs instead)  |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently                |
| Architectural decisions specific to your project     | Long explanations or tutorials                     |
| Developer environment quirks (required env vars)     | File-by-file descriptions of the codebase          |
| Common gotchas or non-obvious behaviors              | Self-evident practices like "write clean code"     |

### Prune test — the real gate (source: best-practices)

> Keep it concise. For each line, ask: *"Would removing this cause Claude to make
> mistakes?"* If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your
> actual instructions!

This is the single most important verification criterion. Every produced line of
CLAUDE.md (and every retained line in update mode) must pass it.

Adjacent guidance: CLAUDE.md is loaded every session, so it holds only what
applies broadly. *"For domain knowledge or workflows that are only relevant
sometimes, use skills instead"* — recommend a skill, not a CLAUDE.md section,
for sometimes-relevant workflows.

### Size budget (source: memory)

> **Size**: target under 200 lines per CLAUDE.md file. Longer files consume more
> context and reduce adherence.

- Root CLAUDE.md: soft target ~100 lines (keep it tight), **hard ceiling 200**.
- "Files over 200 lines consume more context and may reduce adherence." When a
  file grows past the ceiling, split into path-scoped `.claude/rules/` rather
  than letting CLAUDE.md sprawl.
- The budget covers what loads at launch: a CLAUDE.md that `@`-imports
  AGENTS.md spends the **combined** line count of both files. Apply the soft
  ~100 / hard 200 budget to CLAUDE.md + imported AGENTS.md together.

### Imports (source: best-practices + memory)

> CLAUDE.md files can import additional files using `@path/to/import` syntax.

- Imported files are **expanded and loaded in full at launch** — `@import` aids
  organization but does **not** reduce context. Use it only for content that
  genuinely belongs in every session.
- Relative paths resolve relative to the importing file, not the working
  directory. Recursive imports allowed, maximum depth 4 hops.
- Import parsing skips code spans and fenced code blocks — wrap a path in
  backticks (`` `@README` ``) to mention it without importing it.

### AGENTS.md — the official cross-agent pattern (source: memory)

> Claude Code reads `CLAUDE.md`, not `AGENTS.md`. If your repository already
> uses `AGENTS.md` for other coding agents, **create a `CLAUDE.md` that imports
> it so both tools read the same instructions without duplicating them. You can
> also add Claude-specific instructions below the import.** Claude loads the
> imported file at session start, then appends the rest.

Official recommended shape (verbatim example from memory.md):

```markdown
@AGENTS.md

## Claude Code

Use plan mode for changes under `src/billing/`.
```

- A symlink (`ln -s AGENTS.md CLAUDE.md`) also works when there is no
  Claude-specific content to add. On Windows prefer the `@AGENTS.md` import
  (symlinks need Administrator/Developer Mode).
- **This skill adopts the import pattern as its default**: AGENTS.md is the
  primary cross-harness project document (Codex and Amp load it natively),
  CLAUDE.md is the Claude-specific layer on top of the import
  (stage3-generator.md Sections A–B).
- `/init` in a repo with an existing AGENTS.md reads it and incorporates the
  relevant parts into the generated CLAUDE.md; it also reads other tool
  configs (`.cursorrules`, `.devin/rules/`, `.windsurfrules`).

> Note: snapshots before 2026-07 recorded a "keep AGENTS.md a pointer link, do
> not `@import` it" stance. The upstream guidance above **supersedes** it for
> repositories whose AGENTS.md serves multiple agents.

### `.claude/rules/` format (source: memory)

- Rule files are plain markdown; the only documented frontmatter field is
  `paths` (a glob array). Rules **without** `paths` load unconditionally at
  launch, with the same priority as `.claude/CLAUDE.md`.
- Path-scoped rules trigger when Claude reads files matching the pattern (not
  on every tool use). Brace expansion is supported (`src/**/*.{ts,tsx}`).
- `.md` files are discovered recursively; symlinked rule files/directories are
  resolved normally (shareable across projects).
- The legacy `description` / `globs` / `alwaysApply` fields are **not** part of
  the documented format — never emit them; migrate them on update.

### CLAUDE.md locations & comments (source: memory)

- Project file may live at `./CLAUDE.md` **or** `./.claude/CLAUDE.md`; personal
  gitignored notes in `./CLAUDE.local.md`; user-global in `~/.claude/CLAUDE.md`.
- Block-level HTML comments (`<!-- ... -->`) are stripped before context
  injection — free channel for human-maintainer notes (preserved inside code
  blocks, though).

### Advisory vs. deterministic — convert rules to hooks (source: best-practices)

> Unlike CLAUDE.md instructions which are advisory, hooks are deterministic and
> guarantee the action happens.

Failure-pattern fix: *"If Claude already does something correctly without the
instruction, delete it or convert it to a hook."* When a candidate CLAUDE.md line
is really a must-run-every-time gate (e.g., run lint before commit), recommend a
hook instead of a CLAUDE.md line.

### `/init` behavior (source: memory) — the baseline this skill refines

> Run `/init` to generate a starting CLAUDE.md automatically. ... **If a CLAUDE.md
> already exists, `/init` suggests improvements rather than overwriting it.**
> Refine from there with instructions Claude wouldn't discover on its own.

- `/init` is a **user-only slash command** — this skill cannot invoke it
  programmatically. The integration is to **consume its output** (an existing
  CLAUDE.md) as the baseline and refine, matching the documented "/init then
  refine over time" workflow.
- `CLAUDE_CODE_NEW_INIT=1` enables an interactive multi-phase flow: `/init` asks
  which artifacts to set up (CLAUDE.md, skills, hooks), explores the codebase
  with a subagent, fills gaps via follow-up questions, and presents a reviewable
  proposal before writing. When the baseline came from this mode, it already did
  subagent exploration + interview — so the skill's refine pass should be **light**
  (discoverability filter, AGENTS.md / contributing-docs/ / rules/, blind review),
  not a full Stage 1 re-analysis.
- `/doctor` (v2.1.206+) proposes trims for a checked-in CLAUDE.md: cuts
  derivable content (directory layouts, dependency lists, architecture
  overviews), keeps pitfalls, rationale, and non-default conventions —
  complementary to this skill's update mode.

### Over-specified CLAUDE.md — the failure to avoid (source: best-practices)

> **The over-specified CLAUDE.md.** If your CLAUDE.md is too long, Claude ignores
> half of it because important rules get lost in the noise. **Fix**: Ruthlessly
> prune. If Claude already does something correctly without the instruction,
> delete it or convert it to a hook.

This is the verifier's primary anti-pattern: long, noisy CLAUDE.md → reduced
adherence. Pruning is not cosmetic; it is correctness.
