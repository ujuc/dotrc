# Stage 1: Project Analyzer

How the orchestrator dispatches the explorer role
(`references/roles/explorer.md`) up to four times and merges the results.

Use SKILL.md's Session capabilities for all tool/model examples below; do not
assume Claude tool names exist in another host. When independent roles are
unavailable, analyze directly and record coverage gaps. Preserve original target
contents, evidence paths and user decisions for the Stage 4 handoff.

## Complexity Assessment

Run a quick glob before spawning agents.

**Complex (spawn 3 agents)** if any holds:

- 3+ distinct package-manager config types
- Monorepo: a `workspaces` field in package.json/pnpm-workspace.yaml, or
  `packages/`, `apps/` directories with child package files
- `.gitmodules` present
- 3+ top-level directories with their own package file

**Neither list fits**: read directly, and dispatch the explorers only if that
leaves gaps.

**Simple (no agents)** if all hold: 2 or fewer distinct config file types, no
monorepo indicators, no `.gitmodules`, a single top-level package or flat
configuration directory. Read files directly and go to the Merge Protocol.

## Agent Definitions

Dispatch the explorer once per focus, all **in one message**, with
`subagent_type: "Explore"`, `run_in_background: true`, and `model`/`effort` from
[dispatch routing](../../generate-skills/references/model-selection.md#dispatch-routing):
Standard by default, Lightweight only for literal inventory, Advanced for
cross-package relationships or conflicting instructions. Resolve supported,
permitted host model IDs; never pass capability levels as identifiers.
Disclose unavailable switching and use the shared guide's fallback.

```
Read <abs>/references/roles/explorer.md first and follow it.
Focus: {config|structure|docs}.
Target: {target_path}.
```

| Focus | Skip when |
| --- | --- |
| `config` | 2 or fewer config files visible from a single glob |
| `structure` | Flat single-package repository with no workspace or submodule indicators |
| `docs` | No documentation files (CLAUDE.md, AGENTS.md, .cursor/rules/, CONTRIBUTING.md) and no CI config detected in the initial glob |

## Optional: Explore-Deep (Stage 2 overlap)

Spawn in the background while the Stage 2 question is pending, for a large
monorepo (5+ packages) with structural questions Stage 1 left unresolved. Skip
when Stage 1 suffices, the project is small or medium, or the user responds
quickly. A late result merges into the analysis before Stage 3, and its confirmed facts
reach the writer with the rest. Same role, Advanced routing:

```
Read <abs>/references/roles/explorer.md first and follow it.
Focus: deep.
Target: {target_path}.
Gaps:
1. {specific_gap} — e.g., "Determine relationship between packages/core and packages/cli"
```

## Merge Protocol

After the Stage 1 dispatches complete, before Stage 2:

1. **Collect** each dispatch's final message from its Agent tool result or completion notification. If one was
   skipped, died or returned nothing, record the gap explicitly and continue with
   what exists.
2. **Classify** every detected fact:

   | Class | Definition | Action |
   |-------|-----------|--------|
   | **Discoverable** | Readable from code/config | Usually omit; retain explicit team requirements and the exact test, typecheck and lint commands |
   | **Undiscoverable** | Requires project context beyond code | CLAUDE.md |

3. **Separate** facts (directly observed; cite the source file) from
   assumptions (inferred from patterns or absence of evidence): mark those
   `[ASSUMPTION]` and verify them in the Stage 2 interview.
4. **List** what Stage 1 could not determine as Stage 2 interview questions.
5. **Nested candidates**: propose a nested CLAUDE.md for package differences.
   Existing ancestor coverage can suffice when no package difference remains.
   Do not classify general build/test commands as Claude-only content. If the
   structure findings show monorepo packages or submodules, prepare this table
   for the Stage 2 interview:

   | Path | Type | Existing CLAUDE.md | Recommended |
   |------|------|-------------------|-------------|
   | e.g., packages/core | monorepo package | No | Yes — if package has distinct agent workflow rules |
   | e.g., tools/cli | monorepo package | Yes (12 lines) | Update — existing file is outdated |
   | e.g., infra/ | submodule | No | Inspect independent checkout scope; its own CLAUDE.md owns its rules |

6. **Present** the merged analysis to the user before Stage 2: detected project
   type and structure, a brief discoverable/undiscoverable list, facts vs
   flagged assumptions, items needing Stage 2 questions, and the nested
   candidate table if applicable. It stays only in the main agent's context;
   persist nothing to disk.
