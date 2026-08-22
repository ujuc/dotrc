# Cross-Harness Workflow Hooks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Share the existing workflow hooks across Claude Code, Codex, Amp, and Pi, and archive completed research and plan artifacts into durable project documentation.

**Architecture:** A Bash core receives normalized JSON and owns all deterministic policy. Claude and Codex use shell adapters, while Amp and Pi use thin native TypeScript adapters that invoke the same core. Planning skills declare source relationships and call a deterministic archive action only after final verification passes.

**Tech Stack:** Bash 3.2+, jq, Claude Code command hooks, Codex hooks JSON, Amp Plugin API, Pi Extension API.

**Spec:** `agents/docs/superpowers/specs/2026-08-22-cross-harness-workflow-hooks-design.md`

## Global Constraints

- Work directly on `main`; do not create branches or PRs.
- Keep all policy logic in `agents/hooks/workflow-hooks.sh`; adapters only translate events and results.
- Do not overwrite existing files under `docs/research/` or `docs/plans/`.
- Archive only after every plan item and final verification pass.
- Keep unrelated pending changes in `README.md`, `scripts/install.sh`, and `zshrc` untouched.
- Keep skill bodies and new technical documentation in English.
- Deploy global adapter files through documented symlinks, never copies.

---

### Task 1: Shared Hook Core and Contract Tests

**Files:**
- Create: `agents/hooks/workflow-hooks.sh`
- Create: `agents/hooks/test-workflow-hooks.sh`

**Interfaces:**
- Consumes: normalized JSON on stdin with `cwd`, `prompt`, and `files` fields.
- Produces: JSON `{ "message"?: string, "notice"?: string, "block"?: boolean, "moved"?: string[] }` and a zero exit for evaluated policies; malformed input or failed archival exits non-zero with a diagnostic.

- [x] **Step 1: Write the failing contract test**

Cover cadence, clarification, annotation classification, artifact context, inactive type checking, declared-source archival, legacy same-feature archival, missing-source rejection, and destination-collision rejection. Use a temporary directory and assert that rejected archives leave every source in place.

```bash
result=$(printf '%s' '{"prompt":"문서를 업데이트해줘"}' | "$CORE" clarify)
jq -e '.message | contains("업데이트/변경사항")' <<<"$result"

printf '%s' '{"cwd":"'"$fixture"'","plan":".plans/plan-demo.md"}' |
  "$CORE" archive
test -f "$fixture/docs/plans/plan-demo.md"
test -f "$fixture/docs/research/research-demo.md"
```

- [x] **Step 2: Run the test and verify it fails because the core is absent**

Run: `bash agents/hooks/test-workflow-hooks.sh`

Expected: non-zero with `workflow-hooks.sh` missing.

- [x] **Step 3: Implement the normalized core**

Implement these subcommands:

```text
cadence    -> due notice based on ~/.claude/.last_skill_improver_run
clarify    -> advisory message for 업데이트 or 변경사항
annotation -> advisory message when files include .research/*.md or .plans/plan-*.md
context    -> active artifact paths and first Markdown headings
typecheck  -> Python/Rust/Go diagnostics while .plans/.implementing exists
archive    -> preflight and move plan plus declared research sources
```

Use Bash and jq only. Keep all path matches restricted to the active `cwd` and
require archive research paths to match `.research/research-*.md` exactly.

- [x] **Step 4: Run core tests and shell syntax checks**

Run:

```bash
bash -n agents/hooks/workflow-hooks.sh agents/hooks/test-workflow-hooks.sh
bash agents/hooks/test-workflow-hooks.sh
```

Expected: every assertion passes and temporary fixtures are removed.

### Task 2: Claude and Codex Adapters

**Files:**
- Modify: `agents/claude/hooks/skill-improver-cadence.sh`
- Modify: `agents/claude/hooks/clarify-update-word.sh`
- Modify: `agents/claude/hooks/annotation-review-prompt.sh`
- Modify: `agents/claude/hooks/polyglot-typecheck.sh`
- Modify: `agents/claude/hooks/preserve-research-context.sh`
- Modify: `agents/claude/settings.json`
- Modify: `agents/claude/CLAUDE.md`
- Create: `agents/codex/AGENTS.md`
- Create: `agents/codex/hook-adapter.sh`
- Create: `agents/codex/hooks.json`

**Interfaces:**
- Consumes: native Claude/Codex command-hook JSON.
- Produces: native `additionalContext` or exit-code-2 feedback without duplicating core policy.

- [x] **Step 1: Convert each Claude script to a thin adapter**

Build normalized JSON with jq, invoke
`$HOME/.config/dotrc/agents/hooks/workflow-hooks.sh`, and convert the result:

```bash
result=$(printf '%s' "$normalized" | "$CORE" typecheck) || exit 0
if [ "$(jq -r '.block // false' <<<"$result")" = true ]; then
  jq -r '.message' <<<"$result" >&2
  exit 2
fi
```

- [x] **Step 2: Restore Claude context after compaction**

Move `preserve-research-context.sh` from `PreCompact` to a second
`SessionStart` matcher for `compact`; emit
`hookSpecificOutput.additionalContext`. Update the Claude compaction guidance to
name the post-compaction hook.

- [x] **Step 3: Add Codex configuration and adapter**

Configure:

```json
{
  "hooks": {
    "SessionStart": [],
    "UserPromptSubmit": [],
    "PostToolUse": []
  }
}
```

Use `SessionStart(startup|resume|clear)` for cadence,
`SessionStart(compact)` for context restoration, `UserPromptSubmit` for
clarification, and `PostToolUse(Edit|Write)` for both annotation review and type
checking. Parse Codex `apply_patch` headers into normalized file paths.

- [x] **Step 4: Verify both command-hook surfaces**

Run:

```bash
bash -n agents/claude/hooks/*.sh agents/codex/hook-adapter.sh
jq -e '.hooks.SessionStart and .hooks.UserPromptSubmit and .hooks.PostToolUse' agents/codex/hooks.json
codex features list | grep '^hooks[[:space:]].*true'
```

Expected: shell syntax and JSON validation pass; Codex reports stable hooks enabled.

### Task 3: Amp and Pi Native Adapters

**Files:**
- Create: `agents/amp/plugins/workflow-hooks.ts`
- Create: `agents/pi/AGENTS.md`
- Create: `agents/pi/extensions/workflow-hooks.ts`

**Interfaces:**
- Consumes: Amp Plugin API and Pi Extension API lifecycle events.
- Produces: notices, model-visible context, and failed tool feedback by invoking the shared core through child processes.

- [x] **Step 1: Add a reusable process helper inside each native adapter**

Each adapter serializes normalized input and invokes:

```text
$HOME/.config/dotrc/agents/hooks/workflow-hooks.sh <subcommand>
```

Parse stdout as the core result. Log malformed output and continue for advisory
policies; type-check diagnostics remain model-visible.

- [x] **Step 2: Map Amp events**

- `session.start`: run cadence and retain any due notice for the next turn.
- `agent.start`: inject cadence, clarification, and active-artifact context.
- `tool.result`: use `filesModifiedByToolCall()` for annotation and typecheck.
- On type-check failure, return an error result while preserving the completed edit.

- [x] **Step 3: Map Pi events and portable skills**

- `resources_discover`: add `~/.claude/skills/`.
- `session_start`: run cadence.
- `before_agent_start`: inject clarification.
- `tool_result`: evaluate `write` and `edit` paths.
- `session_compact`: set a restore flag.
- `context`: append one artifact-context message after that flag is set.

- [x] **Step 4: Load-check native adapters**

Run Amp's plugin loader for the Amp source. Start Pi with the extension and a
no-inference operation such as `--list-models`; fail on TypeScript load errors.

### Task 4: Planning Pipeline Archival Contract

**Files:**
- Modify: `agents/claude/skills/annotate-plan/SKILL.md`
- Modify: `agents/claude/skills/implement-plan/SKILL.md`
- Modify: `agents/claude/skills/README.md`
- Modify: `agents/docs/superpowers/specs/2026-08-22-cross-harness-workflow-hooks-design.md`

**Interfaces:**
- Consumes: exact research paths under `## Research Sources`.
- Produces: completed sources under `docs/research/` and `docs/plans/`, with transient workflow files removed only after a successful archive.

- [x] **Step 1: Make research provenance part of plan generation**

Insert this required section after `## Acceptance Criteria`:

```markdown
## Research Sources
- `.research/research-example.md`
```

Use `None` when no source was used. Require exact paths and prohibit listing
research that did not inform the plan.

- [x] **Step 2: Add archive completion steps**

After the final verifier reports no FAIL, call:

```bash
printf '%s' "$archive_input" |
  "$HOME/.config/dotrc/agents/hooks/workflow-hooks.sh" archive
```

Pass the active plan and stable item slugs. On archive failure, remove
`.plans/.implementing`, report the conflict or invalid source, and do not claim
workflow completion. Never call archive on blocker, RESET, cancellation, or
failed-verifier paths.

- [x] **Step 3: Update the pipeline catalog and corrected compaction design**

Document that successful implementation promotes source artifacts to
`docs/research/` and `docs/plans/`. Correct the design's Claude event mapping
from `PreCompact` to `SessionStart(source=compact)` based on the official hook
contract.

- [x] **Step 4: Validate changed skills**

Run:

```bash
bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/annotate-plan
bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/implement-plan
```

Then run the `skill-improver` workflow for both targets and address only
findings that preserve the approved archival contract.

### Task 5: Deployment, Documentation, and Final Verification

**Files:**
- Modify: `agents/README.md`
- Modify: `agents/AGENTS.md`
- Create externally: `~/.codex/hooks.json` symlink
- Create externally: `~/.config/amp/plugins/workflow-hooks.ts` symlink
- Create externally: `~/.pi/agent/extensions/workflow-hooks.ts` symlink

**Interfaces:**
- Consumes: tracked adapter files.
- Produces: active global harness integrations and reproducible deployment documentation.

- [x] **Step 1: Document ownership and deployment paths**

Add `hooks/`, `codex/`, and `pi/` to the agent configuration structure and list
all three exact symlink targets. Explain Codex's `/hooks` trust review.

- [x] **Step 2: Create safe symlinks**

Preflight every destination: accept an absent destination or the exact desired
symlink, but stop on any regular file or different link. Then create parent
directories and links with `ln -sfn`.

- [x] **Step 3: Run combined verification**

Run core tests, shell syntax checks, JSON parsing, both skill validators, Amp
load, Pi load, symlink target checks, `git diff --check`, and a scoped diff
review. Confirm unrelated dirty files are unchanged.

- [x] **Step 4: Commit requested implementation files only**

Stage the hook core, adapters, planning skills, agent documentation, settings,
and previously requested agent-guidance cleanup. Exclude `README.md`,
`scripts/install.sh`, and `zshrc`.

```bash
git commit -m "feat(agents): 공용 워크플로 훅을 연동하다"
```
