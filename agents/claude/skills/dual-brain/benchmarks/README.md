# Dual-Brain Benchmark Harness

This directory contains a reproducible benchmark scaffold for comparing:

- Codex `single-agent` vs. Codex `dual-brain`
- quality gains vs. reasoning overhead
- hallucination defense under trap prompts
- multi-session weighted memory persistence via `.dual-brain/MEMORY.md`

The benchmark measures correctness, automated repair attempts, elapsed time, and reported usage separately. It does not presume a quality or speed advantage, or measure actual human correction effort.

The harness is intentionally plain Python: no package install, no hidden telemetry, no external test runner beyond the local CLIs and each fixture's own tests.

## Quick Start

List available scenarios:

```bash
python3 benchmarks/bench.py list
```

Run the default five-case suite:

```bash
python3 benchmarks/bench.py run --suite core5
```

Preview the suite without spending model time:

```bash
python3 benchmarks/bench.py run --suite core5 --dry-run
```

Summarize an existing run:

```bash
python3 benchmarks/bench.py summarize benchmarks/runs/<run-id>
```

## Core Suite

`core5` runs five benchmark cases:

- `notifications/main`
- `notifications/trap`
- `billing/trap`
- `notifications/memory`
- `access_control/memory`

Each case runs three strategies:

- `codex_single_no_memory`
- `codex_single_memory` (equal-memory control)
- `codex_dual_memory`

That keeps the default run short enough to repeat, while still covering ordinary refactoring, trap-prompt defense, and memory persistence.

## Matrix

The default matrix is Codex-only:

- `codex_single_no_memory`
- `codex_single_memory` (equal-memory control)
- `codex_dual_memory`

Only `single_no_memory` workspaces remove `.dual-brain/` before the agent runs, so the baseline cannot use Dual-Brain project memory. Dual-Brain workspaces keep `.dual-brain/MEMORY.md`, including Hot/Warm/Cold/Archived tiers and refs/recency metadata.

Claude Code entries are available only as optional compatibility runs:

```bash
python3 benchmarks/bench.py run --suite core5 --include-claude
python3 benchmarks/bench.py run --suite core5 --matrix compatibility
```

## Outputs

Each run writes:

- `results.json`
- `benchmark_results.md`
- per-attempt raw CLI logs
- test output
- evaluator output
- git diffs

The Markdown file is the artifact to read first; the JSON file is for plotting or later analysis.

See [RESULTS.md](RESULTS.md) for a tracked early benchmark snapshot. Raw run directories are local-only and ignored by Git.

The Markdown report is quality-first:

- pass/fail
- first-pass correctness
- repair loops
- trap defense
- memory persistence
- scenario-specific memory text checks (not a complete audit of tiering or metadata)
- separate cost summary for first agent message latency, case elapsed time, reported tokens, and cost when available

## Safety

The harness copies fixtures into isolated workspaces under `benchmarks/runs/`. It initializes a fresh Git repo per case so diffs are easy to inspect. It does not depend on hidden platform telemetry; token counts come from CLI JSON when exposed.

`benchmarks/runs/` is intentionally ignored. Treat it as local raw evidence: useful for inspection, too bulky and environment-specific for the repository.

## Measurement contract

The default suite plans 15 cases. Compare `codex_single_memory` against `codex_dual_memory` to hold initial memory availability and the shared summary of the advisory contract constant. Dual-Brain additionally loads detailed skill guidance, so instruction differences remain; this is not perfect causal isolation of agent count. The no-memory comparison combines memory and orchestration effects. Automated retries are a proxy for repair burden, not a measurement of human effort. No speed or quality advantage is assumed.

Dual runs receive an exact `.benchmark-skill/SKILL.md` snapshot plus the repository's `references/`, `scripts/`, and `assets/` resources. SHA-256 hashes are recorded per case so a stale global installation cannot silently substitute for the checked-out skill. The prompt instructs the agent to read that snapshot; inspect raw logs to verify actual skill use and delegation.

Pin a CLI-supported model and reasoning effort for reproducibility:

```bash
python3 benchmarks/bench.py run --codex-model YOUR_MODEL --codex-reasoning-effort high
python3 -m unittest discover -s benchmarks/tests -v
```

Model and effort are passed through and recorded as **requested**, not claimed as resolved runtime values. Omitted settings use the CLI configuration; record your CLI version and configuration alongside published runs. Desktop model availability does not guarantee CLI access.

Codex total tokens are reported input plus output. Cached input and reasoning output are subset breakdowns, not additional totals. Missing usage is `null`/unknown, never a zero-cost success. Usage is limited to the CLI report; delegated-agent usage inclusion is not independently verified. Cost is unknown unless every attempt reports it. First agent message latency is event arrival time, **not TTFT**. Case elapsed time includes tests and evaluation after workspace preparation. Old JSON remains readable, but old timing and token fields retain their historical limitations.

A failed CLI or evaluator cannot pass a case merely because existing tests pass. Codex must emit a completed turn and completed agent message without protocol failure; compatibility runs require a successful result object. Memory sessions must all exit successfully. No live model calls are made by unit tests or `--dry-run`.

Original fixture test files must retain their bytes throughout the case; agents can add tests. Detected modification or deletion at a stage boundary permanently fails the case, even if a later attempt restores the file. This is an integrity check, not isolation against malicious code: transient changes restored within one stage or runtime test monkeypatching are not detected.

The subprocess runner captures partial output and enforces timeouts even without a trailing newline or after streams close early. On POSIX it cleans up the spawned process group; this does not cover processes that deliberately detach. The current pipe-selector runner is validated on macOS/POSIX, not Windows. Final diffs include staged changes and untracked files without changing the index.

## Evidence boundaries

Implementation pattern checks exclude tests, the skill snapshot, project memory, hidden/generated files, and external symlink targets. Memory is inspected only by an explicit memory-file check. Transcript keywords are diagnostic: saying “memory” or “verified” cannot determine whether an implementation passes.

Source patterns are structural smoke checks. In particular, the notification fixture does not execute TypeScript delivery behavior, and its checks may accept a no-op or reject a valid alternative layout. Read the implementation and use executable contract tests before making broader correctness claims.

Continuity scenarios ask the agent to preserve existing decisions while evaluating untrusted old suggestions. They do not score obedience to memory above an explicit user override. These corrected scenarios and evidence scopes are not directly comparable to historical scores.
