# Stage 1: Project Analyzer

> Defines how the orchestrator dispatches the explorer role
> (references/roles/explorer.md) up to four times and merges the results. The
> role is read-only — findings return as each agent's final message.
> Tier 2 reference — loaded during Stage 1 execution.

---

Use SKILL.md's capability mapping for all tool/model examples below. When
independent roles are unavailable, analyze directly and record coverage gaps.
Do not assume Claude tool names exist in another host. Preserve original target
contents, evidence paths and user decisions for the Stage 4 handoff.

## Complexity Assessment

Run a quick glob before spawning agents to determine whether the project is complex or simple.

### Complex Project (spawn 3 agents)

Criteria — any one sufficient:

- 3 or more distinct package-manager config types present
- Monorepo detected: `workspaces` field in package.json/pnpm-workspace.yaml, or `packages/`, `apps/` directories with child package files
- Submodule detected: `.gitmodules` file present
- 3 or more top-level directories each containing their own package file

### Simple Project (detect directly, no agents)

All of the following:

- 2 or fewer distinct config file types
- No monorepo indicators
- No `.gitmodules`
- Single top-level package or flat configuration directory

For simple projects, read files directly and proceed to the Merge Protocol section.

---

## Agent Definitions

Dispatch the explorer role (`references/roles/explorer.md`) once per focus,
all **in one message** with `subagent_type: "Explore"`,
`run_in_background: true`, and `model`/`effort` from
[dispatch routing](../../generate-skills/references/model-selection.md#dispatch-routing):
Standard by default, Lightweight only for literal inventory, Advanced for
cross-package relationships or conflicting instructions. Resolve supported,
permitted host model IDs; never pass capability levels as identifiers.
Disclose unavailable switching and use the shared guide's fallback.

Prompt template:

```
Read <abs>/references/roles/explorer.md first and follow it.
Focus: {config|structure|docs}.
Target: {target_path}.
```

| Focus | Skip condition |
| --- | --- |
| `config` | 2 or fewer config files visible from a single glob |
| `structure` | Flat single-package repository with no workspace or submodule indicators |
| `docs` | No documentation files (CLAUDE.md, AGENTS.md, .cursor/rules/, CONTRIBUTING.md) and no CI config detected in the initial glob |

**Collection rule**: the role is read-only and returns its findings as its
final message; the orchestrator collects them from the Agent tool result or
its completion notification. If an agent dies or returns nothing, note the gap
and continue with what exists.

---

## Optional: Explore-Deep (Stage 2 overlap)

**Trigger**: Large monorepo (5+ packages) or Stage 1 results leave unresolved structural questions.

**Timing**: Spawn during Stage 2 AskUserQuestion wait — runs in parallel with user response time.

**Skip condition (broad)**: Stage 1 results are sufficient, project is small or medium, or user response arrives quickly.

Same role, `Focus: deep`, Advanced routing:

```
Read <abs>/references/roles/explorer.md first and follow it.
Focus: deep.
Target: {target_path}.
Gaps:
1. {specific_gap_1} — e.g., "Determine relationship between packages/core and packages/cli"
2. {specific_gap_2} — e.g., "Find external service dependencies (DB connections, API calls)"
```

---

## Merge Protocol

After all launched agents complete, execute the following steps before advancing to Stage 2.

### Step 1: Collect Findings

Gather each launched agent's final message from its Agent tool result or
completion notification:

- config-explorer findings
- structure-explorer findings
- docs-explorer findings
- Explore-Deep findings (if spawned)

If a result is missing (agent skipped, died, or returned nothing), record the
gap explicitly and continue with what exists.

### Step 2: Classify Discoverability

For every detected fact, classify it:

| Class | Definition | Action |
|-------|-----------|--------|
| **Discoverable** | Readable from code/config | Usually omit; retain explicit team requirements or necessary non-obvious command selection |
| **Undiscoverable** | Requires project context beyond code | Shared candidates go to AGENTS.md; only Claude-specific additions go to CLAUDE.md |

### Step 3: Separate Facts from Assumptions

- **Fact**: Directly observed from a file (cite source)
- **Assumption**: Inferred from patterns or absence of evidence — mark with `[ASSUMPTION]` and verify in Stage 2 interview

### Step 4: List Stage 2 Questions

Enumerate items that Stage 1 could not determine. These become Stage 2 interview questions.

### Step 5: Prepare Nested Instruction Candidates

For shared package differences, propose nested AGENTS.md first; its selected
Claude companion imports it. Existing shared ancestor coverage can suffice when
only Claude-specific differences remain. Do not classify general build/test
commands as Claude-only content.

If the structure-explorer detected monorepo packages or submodules, prepare this table for the Stage 2 interview:

| Path | Type | Existing CLAUDE.md | Recommended |
|------|------|-------------------|-------------|
| e.g., packages/core | monorepo package | No | Yes — if package has distinct agent workflow rules |
| e.g., tools/cli | monorepo package | Yes (12 lines) | Update — existing file is outdated |
| e.g., infra/ | submodule | No | Inspect independent checkout scope; shared rules belong in AGENTS.md |

### Step 6: Present Summary to User

Show the merged analysis before proceeding to Stage 2. Include:

1. Detected project type and structure
2. Discoverable vs undiscoverable classification (brief list)
3. Facts vs assumptions (flag assumptions clearly)
4. Items that need Stage 2 questions
5. Nested CLAUDE.md candidate table (if applicable)

Nothing is persisted to disk — the merged analysis exists only in the main
agent's context. There is no cleanup step.
