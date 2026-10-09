@~/.config/dotrc/agents/rules/AGENTS.md

## Model Quality

- Use `advisor()` only for a specific, high-impact uncertainty where an independent second review would materially change the decision.
- Match effort to phase: low–medium for interviews and sketches, medium for implementation, high for verification, review, and brownfield debugging, xhigh for security review and long autonomous runs.
- Effort fixes hidden edge cases, not misunderstanding: when a failure comes from a wrong premise, fix the spec or contract before raising effort.

## Changes

- Keep changes to what the request needs: report pre-existing bugs, performance concerns, or unrequested extensions as follow-ups instead of fixing them in the same change, and add tests only where the task asks for them or the repository already keeps tests for that kind of change. This limits extras only; implement every requested behavior completely.

## Delegation

- Delegate only independent, context-heavy work; keep synthesis, decisions, and edits on the active model.
- Use `Explore` for multi-file discovery and the local Ollama-backed `gemma` skill for text-only transforms; `gemma` has no remote fallback.
- Files over `SHUNT_MIN_LINES` are blocked by the shunt hook: use `gemma` `bulk-read.sh` to understand them, then targeted `Read` with `offset`/`limit` to edit. Never delegate debugging, architecture, or security-sensitive code to `gemma`.
- When delegating to Codex, choose the OpenAI model and reasoning effort and write the task prompt from `~/.claude/skills/generate-skills/references/openai-models.md`.
- Reserve `Workflow` for large evals, compliance checks, cross-verification, or bulk triage; test a narrow slice and state the token budget first.

## Writing

- Before handing over or seeking approval for Korean prose written for human readers (issue and PR bodies, README, user-facing docs), run the `humanizer` skill in fast mode on the part written or changed when its sentences total 100+ characters. Skip commit messages, chat replies, agent instructions and prompts, managed workflow artifacts, and text that is mostly bullets, tables, or code.

## Compaction

- Preserve modified files, latest verification results, pending approvals, unanswered questions, user decisions and constraints in the user's words, approaches tried or rejected and why, and exact identifiers (paths, commands, numbers); the compact `SessionStart` hook restores `spec.md`, `.research/`, and `.plans/` pointers after compaction.

<!-- CODEGRAPH_START -->
<!-- CODEGRAPH_END -->
