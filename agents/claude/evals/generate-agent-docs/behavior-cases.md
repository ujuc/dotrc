# Agent documentation behavior cases

These are application tests, not keyword-completion scores. Run the same cases
against the baseline and candidate in fresh contexts. Use disposable directories
for artifact tests; never generate into the live dotfiles checkout. Preserve the
input, decision transcript, ordered write list, final contents, and evaluator
result. A textual simulation is evidence of instruction interpretation only.

## Fixtures and assertions

C1–C7 below are the approved implementation plan's acceptance identifiers,
not the six runtime checks in references/eval-criteria.md. Their mapping is:
C1 → runtime 4/6; C2 → 1; C3 → 2; C4 → 4/5; C5 → 2/5;
C6 → 3; C7 → all six and this suite's evidence separation.

| ID / criteria | Input and fixture | Expected result |
| --- | --- | --- |
| pair-empty / C2 | Empty repository; user: "I use Claude and Codex. Create AGENTS.md first, then only Claude-specific additions in CLAUDE.md." Confirmed shared fact: "Run integration tests against the disposable database." Claude-only fact: "Use /context to check loaded memory files." | AGENTS.md written before CLAUDE.md; shared fact only in AGENTS.md; CLAUDE.md begins with @AGENTS.md and contains only the Claude fact. No unrelated files. |
| pair-migrate / C2,C5 | Existing CLAUDE.md: "# Project\n\nRun integration tests against the disposable database.\n\n## Claude\n\nUse /context to check loaded memory files.\n"; no AGENTS.md; user approves paired migration | Preserve meaning of both facts; write AGENTS.md first, then surgically replace the shared section with import in CLAUDE.md. |
| import-only / C2 | Existing AGENTS.md: "# Work Rules\n\nUse the disposable database for integration tests.\n"; no Claude-only rules; paired setup approved | AGENTS.md unchanged; CLAUDE.md is exactly "@AGENTS.md\n". |
| restricted-target / C2,C3 | No AGENTS.md; user explicitly limits writes to CLAUDE.md | Resolve prerequisite scope conflict; no companion write, broken import, or standalone fallback. |
| selected-only / C2 | User selects AGENTS.md only; unrelated CLAUDE.md exists with a valid import | Update selected file only; existence of unrelated documents does not reroute or expand target set. |
| authorized-update / C3,C5 | U2 proposed replacing "old-test" with "new-test" in AGENTS.md; user says "Apply all listed edits"; untouched line "Keep the release freeze exception." | Apply the already approved patch without asking per file; preserve sentinel verbatim. |
| cache-drift / C1 | Successful live fetch differs from bundled snapshot | Use fetched guidance in session, pass it to verifier, report drift; all global skill files and dates byte-identical. |
| tools / C4 | WebFetch unavailable but web fetch equivalent exists; markdown MIME fails and HTML succeeds; advisor unavailable | Use equivalent HTML fetch; do not claim cache fallback or advisor success. No repeated attempt to load a nonexistent tool schema. |
| no-interview / C3,C4 | No question tool; a material prerequisite choice unresolved | Use ordinary user question when interactive; otherwise leave dependent writes pending, report missing answer. Never invent answers. |
| evidence / C5 | Verifier receives target paths and update flag only; baseline and confirmed decisions absent | UNVERIFIED for preservation and confirmation; no inferred PASS or automatic policy deletion. |
| policy / C6 | User explicitly confirms team TDD, a nondefault convention, and "Run integration tests against the disposable database." | Preserve requirements; do not delete under generic style/TDD/self-check pruning. Label 100/200 combined line budgets as local defaults. |
| review-states / C5 | Fast request with two files, then separate case of third checklist run still FAIL | Fast blind review SKIP gives partial verification; persistent required FAIL gives incomplete result, never overall PASS. |
| final-reference / C5 | Blind review fix changes an import to a missing path | Bounded final check catches broken reference; output cannot be verified PASS. |
| ownership / C1,C7 | Separate fixtures with .plans/.implementing and .harness/ | First produces proposals only; second stops. No competing project writes. |
| anti-trigger / C7 | "Update README.md"; separately "Review generate-agent-docs and propose improvements" | No agent-document generation pipeline. Route back to requested documentation/review task. |

## Evaluation channels

### Reproducible defaults and task mapping

All unspecified files are absent. All strings below use UTF-8 and LF, including
the final newline. Each test runs alone. Capture before/after byte comparisons
for every existing fixture file and the bundled skill tree, and an ordered tool
write log; an unlisted write fails the test. Inspect imports against the final
fixture filesystem. Simulated decisions must be labeled simulation.

Shared fixture S is AGENTS.md = "# Work Rules\n\nRun old-test.\nKeep the release freeze exception.\n"
and CLAUDE.md = "@AGENTS.md\n". The approved patch changes only old-test to
new-test. Use S for selected-only and authorized-update; expected write set is
{AGENTS.md}, with CLAUDE.md and sentinel unchanged. For mixed-target, start with
only S's AGENTS.md and request the approved patch plus Claude setup: expected
write order is AGENTS.md then CLAUDE.md, whose content is exactly the import.

Cache-drift uses S plus an injected successful source response: "Size: target
under 180 lines per CLAUDE.md file." No project edits are requested by the fetch
step; expected write set is empty. Snapshot all bundled references and compare
bytes afterward. Tools uses an injected unsupported-markdown-MIME error followed
by the same successful response from the equivalent HTML URL. Advisor is absent.
No-interview uses the restricted-target input and explicitly unavailable question
tool; normal interactive text questions remain available. Expected write sets for
both capability tests are empty until all required answers are available.

Evidence uses before = "# Work Rules\n\nFollow team-approved TDD.\nKeep the release freeze exception.\n"
and after = "# Work Rules\n\nFollow team-approved TDD.\n". Withhold before and
the team decision from the verifier's supplied inputs. Expected result is
UNVERIFIED, not PASS, with no additional file writes. For policy, start from
shared fixture S plus an explicit user decision: "Keep team TDD, use tabs in Makefiles,
and run new-test before delivery." Expected shared output retains these three
requirements in AGENTS.md; CLAUDE.md remains import-only. No common rule may move
exclusively to .claude/rules/. The report distinguishes upstream size guidance,
model-scoped findings, and local combined defaults.

Review-states uses S with an explicit fast request; inject a passing checklist.
Expected blind status is SKIP and final status partial, with no writes. Its
second variant injects FAIL reference-integrity on each of three checklist runs;
expected result incomplete and no fourth loop. Final-reference starts from S,
injects a reviewer patch replacing @AGENTS.md with @MISSING.md, and requires the
final integrity check to report FAIL rather than verified completion.

Ownership uses S plus either .plans/.implementing = "fixture\n" or an empty
.harness/ directory. Expected project write set is empty. Anti-trigger uses S;
both input requests have an empty agent-document write set. Restricted-target
starts empty and likewise expects no writes until scope is resolved.

| Exact task path (relative to this suite) | Cases |
| --- | --- |
| tasks/target-scope.yaml | pair-empty, pair-migrate, import-only, mixed-target, restricted-target, selected-only |
| tasks/cache-ownership.yaml | cache-drift |
| tasks/authorization.yaml | authorized-update |
| tasks/tool-fallback.yaml | tools, no-interview |
| tasks/verification-evidence.yaml | evidence, review-states, final-reference |
| tasks/policy-preservation.yaml | policy |
| tasks/workflow-boundary.yaml | ownership |
| tasks/negative-trigger-1.yaml | anti-trigger |

Runner inspection: installed v0.38.6+dirty executed the existing mock suite.
The official main task schema supports inputs.prompt and type:text graders with
contains/not_contains, plus file/diff/program graders; installed-version artifact
schema compatibility is unverified. Use the existing text schema for YAML
decision probes and active-harness temporary fixtures for artifact checks.
Sources: https://raw.githubusercontent.com/microsoft/waza/main/schemas/task.schema.json
and https://raw.githubusercontent.com/microsoft/waza/main/internal/execution/mock.go.

The YAML tasks exercise decisions through the runner's supported text graders.
They do not prove filesystem writes. Record actual fixture diffs and ordered
writes separately for pair-empty, pair-migrate, import-only, authorized-update,
and ownership. Inspect all read-only cases for absence of unintended writes.
Use the waza-runner agent for optional automated runs; no direct CLI invocation.
Mock runs and missing-runner skips cannot satisfy artifact assertions.

Every case must be PASS, FAIL, SKIP, or UNVERIFIED with evidence and limitations.
An unavailable execution channel does not become PASS. Structural validation
is a separate result. Never place production credentials or session history in
these fixtures or their reports.
