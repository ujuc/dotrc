# Contributing to Dual-Brain

The skill source is `SKILL.md` plus its referenced resources. Keep the main entrypoint focused on decisions that change agent behavior; move conditional details into linked references. Preserve automatic discovery unless a change explicitly concerns invocation policy.

## Changes and validation

- Keep README and the memory/runtime contracts consistent with behavior changes.
- Preserve capability-based tool selection and the user's model choice. Do not freeze a model catalog into mandatory spawn instructions.
- Let independent reviews overlap, but reconcile consequential claims before delivery. Give each writer clear ownership.
- Test memory absence, conflicting claims, explicit user overrides, read-only scope, and metadata updates when those behaviors change.
- Use an isolated realistic task to validate substantive prompt changes. State whether it exercised actual delegation or a local fallback. Never infer model-wide gains from a single smoke test.
- Include a clean case and an unchanged repeat review when changing review behavior. Verify that a real defect is still fixed; do not reward finding counts or the size of the diff.
- Keep `PORTABLE.md` generated from the core and runtime/memory sources: run `python3 scripts/export_portable.py` and `python3 scripts/export_portable.py --check`. Document native support separately from prompt import and actual host execution. Do not invent host paths.
- For benchmark code, run `python3 -m unittest discover -s benchmarks/tests -v` and `python3 benchmarks/bench.py run --suite core5 --dry-run`. Live runs are separate and consume model time.

Install at `~/.agents/skills/dual-brain` for current Codex local discovery, or update an existing discovered installation in place. Avoid duplicate skill copies.

Create a branch and open a PR describing the problem, resulting behavior, and validation. Include material limitations, such as unsupported runtimes or unmeasured performance. Follow the [Code of Conduct](CODE_OF_CONDUCT.md) and [security policy](SECURITY.md).
