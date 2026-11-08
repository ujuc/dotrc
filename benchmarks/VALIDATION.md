# Validation records

## v1.7.0 — 2026-11-07

### Scope and checks

- Skill-creator format validation passed; 24 local regression tests passed (19 existing plus 5 exporter tests).
- The portable exporter generated the full core/runtime/memory prompt and `--check` confirmed it was current. Tests cover content preservation, internal links, stale/missing output, and source errors without partial writes.
- Local documentation links, code fences, and `git diff --check` passed.
- Official documentation was inspected for Codex, Claude Code, Grok, and xAI Grok Bot loading routes. See [platform guidance](../references/platforms.md) for sources and limits. No external account configuration or native host installation was tested. Muse identity remains unspecified; it receives a generic portable prompt route, not a verified adapter.

### Behavioral checks in the available agent harness

Fresh-context agents received the candidate skill and an isolated helper, with delegation unavailable. The task was to review and fix evidenced in-scope defects. The helper contract accepted finite numeric inputs with `lower <= upper`, returned an inclusive clamp, and required no new API or dependencies. Original tests covered below/interior/above-bound values, equal bounds, and a fractional value. No intended outcome was given to the evaluators.

1. **Clean case:** `return max(lower, min(value, upper))`. The evaluator found no actionable issue, passed the five-case test, and changed nothing. A follow-up asked to use Dual-Brain again and improve anything genuinely needing improvement with no code/contract changes. The evaluator kept the result unchanged and reused existing evidence instead of rerunning checks. Parent hashes confirmed code, tests, and memory were byte-identical after both reviews.
2. **Real defect:** `return min(lower, max(value, upper))`. The evaluator observed three failing subcases, replaced only that expression with `min(upper, max(value, lower))`, and passed the original test. Parent hashes confirmed only `clamp.py` changed; tests and memory were untouched. The parent reran the test successfully. This exercises restraint without suppressing a supported fix.
3. **Portable conversation-only case:** the evaluator loaded only `PORTABLE.md`, then was given no tools/files/subagents and a JavaScript `add(a, b)` over integers between -1000 and 1000. It reported no actionable bug, no edits, no test execution, and an explicitly unsaved memory suggestion requested by the task. It did not pretend to have independent reviewers or persistence.

The tested native entrypoint matched the final candidate. These are bounded smoke checks of instruction behavior in the available harness, not Grok/Muse/Claude runtime executions, a full live benchmark matrix, or proof that every future run avoids over-editing. Temporary test artifacts are not a performance dataset. Source code and the full caller contract still determine what is a defect.

## v1.6.0 — 2026-10-13

### Checks performed

- Bundled skill-creator `quick_validate.py`: passed.
- `python3 -m unittest discover -s benchmarks/tests -v`: **19 passed**. These cover partial/closed-stream timeouts, POSIX child cleanup, malformed or failed protocol output, original-test integrity, staged/untracked diffs, evidence-scope contamination, transcript diagnostics, and prior accounting checks.
- `python3 benchmarks/bench.py run --suite core5 --dry-run`: 15 cases planned; no live CLI suite executed.
- Local reference links and `git diff --check`: passed.
- Independent final source review found a malformed message type that could crash transcript joining. It was corrected and a five-input regression test passed.

### Native two-reviewer forward test

A fresh-context evaluator received the candidate skill/resources and an isolated copy of the access-control fixture. The request explicitly required two actual reviewer subagents, a central policy registry, preserved admin/editor/viewer route behavior, owner billing permission, implementation, and verification. Original tests could not be modified; additional tests were allowed.

Observed execution used native Right and Left subagents, both reused for final implementation checks. Right checked the complete behavior and compatibility; Left checked concrete contracts, default denial, registry authority, malformed identifiers, and tests. Both reported no unresolved material findings after final checks. This was actual delegation, not a simulated role transcript.

The baseline had three tests and two failures. The implementation retained those tests unchanged, added five behavioral tests, and passed **all eight**. The parent independently reran the eight tests and checked original test hashes. Owner billing did not expand owner access to existing routes. Malformed non-string identifiers were explicitly handled and documented; non-mapping user inputs remained outside the contract.

The evaluator saved evidence-backed memory after code review, updated influential entries once, and preserved unrelated history. Reviewers certified code/tests before that memory-only save; the orchestrator inspected the saved memory afterward. This does not independently certify every memory mutation path.

Tested SKILL.md SHA-256: `721f6d20f09488d6821cc1cc2e2689fbee5c1d53afe8c82388fdef6bdf99e2a5`. It matched the final candidate entrypoint byte for byte.

### Limits

No cross-model ranking, latency improvement, or token saving is claimed. Synthetic subprocess tests validate runner behavior; the native smoke test validates one realistic delegation flow. Windows pipes, deliberate process detachment, mid-stage test tampering, and adversarial runtime monkeypatching are not covered. Notification source-pattern checks remain structural rather than executable TypeScript behavior. Changed continuity prompts and evidence scopes invalidate direct comparisons with historical scores. Smoke artifacts remain outside the repository; this is a validation record, not a repeatable performance dataset.

## v1.5.0 validation — 2026-10-11

This records observed checks, not a claim of optimal performance across models.

### Environment observed

- Codex desktop: 26.1007.21159, build 20052, prod channel.
- Codex CLI: 0.162.1; its `exec --help` confirmed the options used by the harness.
- Desktop update checker returned `busy`; no claim that the installed app is the latest eligible release.
- Model guidance was checked against official [models](https://learn.chatgpt.com/docs/models), [subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents), [skills](https://developers.openai.com/codex/skills), and [non-interactive CLI](https://developers.openai.com/codex/noninteractive) documentation. Availability remains runtime-dependent.

### Checks performed

- Bundled skill-creator `quick_validate.py`: passed.
- `python3 -m unittest discover -s benchmarks/tests -v`: 7 passed, including synthetic CLI JSON events, token accounting, snapshots, failure gating, effort forwarding, and honest report output.
- `python3 benchmarks/bench.py run --suite core5 --dry-run`: planned 15 cases; no live suite calls.
- `git diff --check`: passed.
- Independent source review identified and corrected ambiguous descendant-agent wording and the benchmark's overstatement of causal isolation.

### Behavioral forward test

A fresh-context evaluator received only the candidate skill/resources, an isolated copy of the access-control fixture, and a request to centralize authorization while preserving route behavior and allowing owner billing. Delegation was explicitly unavailable in this test.

Observed outcome: the agent disclosed a single-agent fallback, implemented `POLICIES` with thin route delegates, preserved owner denial on existing routes, and passed six local tests including added compatibility/default-denial checks. It updated four influential memory entries once each, added evidence, and preserved unrelated Cold/Archived entries.

A follow-up read-only review explicitly superseded owner-only billing with owner/admin billing. The agent proposed the precise code/test and memory changes, respected the user's override, distinguished the requested decision from current code, and made no file edits.

These checks exercise implementation, memory, explicit override, and read-only fallback behavior. They do not validate every native delegation path, lifecycle recovery, host, or model.

### Size and measurement limits

The entrypoint shrank from 20,030 bytes to approximately 5,500 bytes (about 73%). Conditional runtime and memory references are additional context when loaded. This is a static source-size reduction, not a measured token, latency, or quality improvement.

No full live model matrix was run. Existing historical results are not comparable to the corrected harness without rerunning them. Equal initial memory reduces one confound, but differences in detailed instructions and actual delegation still require inspection. Raw smoke artifacts were kept outside the repository; the outcome above is a validation record, not a reproducible performance dataset.
