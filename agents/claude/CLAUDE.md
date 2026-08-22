@~/.config/dotrc/agents/rules/AGENTS.md

## Model Quality

- Use `advisor()` only when a stronger model can resolve a specific, high-impact uncertainty that would materially change the decision.

## Delegation

- Delegate only independent, context-heavy work; keep synthesis, decisions, and edits on the active model.
- Use `Explore` for multi-file discovery and the local Ollama-backed `gemma` skill for text-only transforms; `gemma` has no remote fallback.
- Reserve `Workflow` for large evals, compliance checks, cross-verification, or bulk triage; test a narrow slice and state the token budget first.

## Compaction

- Preserve modified files, latest verification results, pending approvals, and unanswered questions; the compact `SessionStart` hook restores `.research/` and `.plans/` pointers after compaction.
