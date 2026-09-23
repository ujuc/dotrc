@~/.config/dotrc/agents/rules/AGENTS.md

## Model Quality

- Use `advisor()` only for a specific, high-impact uncertainty where an independent second review would materially change the decision.

## Changes

- Keep changes to what the request needs: report pre-existing bugs, performance concerns, or unrequested extensions as follow-ups instead of fixing them in the same change, and commit tests only where the task asks for them or the repository already keeps tests for that kind of change. This limits extras only; implement every requested behavior completely.

## Delegation

- Delegate only independent, context-heavy work; keep synthesis, decisions, and edits on the active model.
- Use `Explore` for multi-file discovery and the local Ollama-backed `gemma` skill for text-only transforms; `gemma` has no remote fallback.
- Files over `SHUNT_MIN_LINES` are blocked by the shunt hook: use `gemma` `bulk-read.sh` to understand them, then targeted `Read` with `offset`/`limit` to edit. Never delegate debugging, architecture, or security-sensitive code.
- Reserve `Workflow` for large evals, compliance checks, cross-verification, or bulk triage; test a narrow slice and state the token budget first.

## Compaction

- Preserve modified files, latest verification results, pending approvals, unanswered questions, user decisions and constraints in the user's words, approaches tried or rejected and why, and exact identifiers (paths, commands, numbers); the compact `SessionStart` hook restores `.research/` and `.plans/` pointers after compaction.

<!-- CODEGRAPH_START -->
<!-- CODEGRAPH_END -->
