# Cross-Harness Workflow Hooks and Artifact Archival — Design

Date: 2026-08-22
Status: Approved

## 1. Context

Claude Code currently owns five global workflow hooks:

- skill-improver cadence notification;
- ambiguous update-word clarification;
- research and plan review reminder;
- implementation-time polyglot type checking;
- research and plan context restoration around compaction.

The behavior should also be available in Codex, Amp, and Pi without maintaining
four independent policy implementations. The research-to-plan-to-implementation
pipeline also leaves completed source artifacts in `.research/` and `.plans/`
instead of promoting them to durable project documentation.

## 2. Goals

- Keep hook policy in one harness-neutral implementation.
- Use each harness's native lifecycle API through thin adapters.
- Preserve the current Claude behavior.
- Move only the active plan and its declared research sources after every plan
  item and the final verification pass.
- Store durable artifacts in `docs/research/` and `docs/plans/`.
- Avoid overwriting existing documentation or moving unrelated research.

## 3. Non-Goals

- Perfect event parity where a harness exposes no corresponding lifecycle event.
- Replacing each harness's permissions or trust system.
- Archiving blocker, debugger, verifier, baseline, or cycle artifacts as durable
  documentation.
- Automatically trusting new Codex hooks on the user's behalf.
- Modifying the repository root installer while it has unrelated pending work.

## 4. Architecture

### 4.1 Shared hook core

`agents/hooks/workflow-hooks.sh` is the canonical policy implementation. It
accepts a normalized JSON object on standard input and exposes one subcommand per
policy. It emits a small JSON result containing optional model-visible context,
user-visible notice text, or blocking diagnostics.

The core owns:

- cadence date calculation and skill count;
- Korean update-word detection;
- research and plan path classification;
- active artifact title collection;
- language-specific type-check command selection and execution.

Harness adapters own only event translation and the harness-specific output
shape.

### 4.2 Harness adapters

| Harness | Adapter | Native events |
| --- | --- | --- |
| Claude Code | Existing `agents/claude/hooks/*.sh` wrappers | `SessionStart`, `UserPromptSubmit`, `PostToolUse`; `SessionStart(source=compact)` restores context |
| Codex | `agents/codex/hook-adapter.sh` and `hooks.json` | `SessionStart`, `UserPromptSubmit`, `PostToolUse`; `SessionStart(source=compact)` restores context |
| Amp | `agents/amp/plugins/workflow-hooks.ts` | `session.start`, `agent.start`, `tool.result`; active artifact pointers are injected at each `agent.start` because Amp has no compaction event |
| Pi | `agents/pi/extensions/workflow-hooks.ts` | `session_start`, `before_agent_start`, `tool_result`, `session_compact`, `context` |

Codex's `apply_patch` payload is converted into a list of paths from the patch
headers. Amp uses `filesModifiedByToolCall()`. Pi uses the built-in `write` and
`edit` tool inputs.

Pi's extension also contributes `~/.claude/skills/` through
`resources_discover`, preserving one portable skill source.

### 4.3 Deployment

Tracked sources are deployed with file symlinks:

| Source | Destination |
| --- | --- |
| `agents/codex/hooks.json` | `~/.codex/hooks.json` |
| `agents/amp/plugins/workflow-hooks.ts` | `~/.config/amp/plugins/workflow-hooks.ts` |
| `agents/pi/extensions/workflow-hooks.ts` | `~/.pi/agent/extensions/workflow-hooks.ts` |

Codex requires the user to review changed command hooks through `/hooks` before
it runs them. Amp and Pi adapters use their global native extension locations.

## 5. Artifact Association and Archival

`annotate-plan` writes a mandatory `## Research Sources` section containing the
exact `.research/research-*.md` paths used to produce the plan, or `None` when no
research source was used.

After all todo items are checked and the final verifier reports no `FAIL`,
`implement-plan` performs an all-or-nothing archive preflight:

1. Resolve the active plan and its declared research sources.
2. For a legacy plan without `## Research Sources`, accept only an existing
   `.research/research-{feature}.md` fallback.
3. Reject paths outside `.research/` and reject missing declared sources.
4. Create `docs/research/` and `docs/plans/` only after the source set is valid.
5. Stop before moving anything when any destination already exists.
6. Move research sources first and the active plan last.
7. Remove only workflow-owned verifier, blocker, debugger, baseline, cycle, and
   implementation-flag files associated with the completed plan.

Failure, blocker, RESET, cancellation, or final-verifier failure paths never
archive source artifacts.

## 6. Error Handling

- Advisory hook failures are logged or surfaced without blocking normal work.
- Type-check failures become model-visible blocking feedback where the harness
  supports it; file edits are not rolled back.
- A missing checker remains a real diagnostic instead of being silently
  interpreted as success.
- Archive conflicts never overwrite existing docs and never partially move a
  source set.
- Claude and Codex restore context after compaction through `SessionStart`
  because their pre-compaction events do not inject model context.
- Amp's lack of a compaction hook is handled by concise per-turn artifact
  pointers rather than an unsupported emulation.

## 7. Verification

1. Run shell syntax checks for the shared core and Claude/Codex wrappers.
2. Exercise every core subcommand with normalized JSON fixtures.
3. Verify Codex hook JSON and feature availability, then inspect discovery with
   the installed symlink; trust remains a manual `/hooks` action.
4. Load the Amp plugin through Amp's plugin loader.
5. Start Pi with the extension in a no-inference command and confirm it loads.
6. Validate `annotate-plan` and `implement-plan` with the repository skill
   validator, then run `skill-improver` as required by repository guidance.
7. Run a temporary archive fixture covering success, legacy fallback, missing
   sources, and destination collisions without touching real project artifacts.
8. Run `git diff --check` and review only requested files before committing.

## 8. Rollout

1. Add the shared core and convert Claude hooks into adapters.
2. Add Codex, Amp, and Pi native adapters.
3. Add the deployment symlinks and document them in `agents/README.md`.
4. Update the planning skills and their pipeline documentation.
5. Validate each adapter and the archival contract.
6. Commit implementation separately from this design record.
