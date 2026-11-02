# Agent documentation behavior cases

These are application tests, not keyword-completion scores. Run the same cases
against the baseline and candidate in fresh contexts. Use disposable directories
for artifact tests; never generate into the live dotfiles checkout. Preserve the
input, decision transcript, ordered write list, final contents, and evaluator
result. A textual simulation is evidence of instruction interpretation only.

## Fixtures and assertions

C1–C7 below are the approved implementation plan's acceptance identifiers,
not the six runtime checks in references/eval-criteria.md. Their mapping is:
C1 → runtime 4; C2 → 1; C3 → 2; C4 → 4/5; C5 → 2/5;
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

Anti-trigger uses S; both input requests have an empty agent-document write
set. Restricted-target starts empty and likewise expects no writes until scope is resolved.

| Exact task path (relative to this suite) | Cases |
| --- | --- |
| tasks/target-scope.yaml | pair-empty, restricted-target |
| tasks/positive-trigger-1.yaml | import-only |
| tasks/positive-trigger-2.yaml | pair-migrate |
| tasks/cache-ownership.yaml | cache-drift |
| tasks/authorization.yaml | authorized-update |
| tasks/tool-fallback.yaml | tools, no-interview |
| tasks/verification-evidence.yaml | evidence, review-states |
| tasks/policy-preservation.yaml | policy |
| tasks/negative-trigger-1.yaml | anti-trigger |
| tasks/stop-list.yaml | stop-context, stop-emphasis, stop-subagent-quality, stop-thinking, stop-persistence, stop-repo, stop-tools |
| tasks/enforcement-fit.yaml | enforce-rule, enforce-preference |
| tasks/report-only.yaml | audit-only |
| tasks/supplied-fact.yaml | named-claude |
| tasks/session-placement.yaml | session-capture |
| tasks/broken-reference.yaml | broken-pointer, summary-growth |

Artifact only, with no probe: mixed-target, selected-only, final-reference, stop-preserved, rare-language, colleague.

The suite runs on the launcher's eval model through `copilot-sdk`. Decision probes
use `regex_match` and `regex_not_match` text graders; read them by trial pass
rate. Artifact cases run in the skill-diet eval fixtures, not here.
and https://raw.githubusercontent.com/microsoft/waza/main/internal/execution/mock.go.

Prune test, stop-list and enforcement cases. Each row is a line in an existing CLAUDE.md with no user decision on it, unless stated.

| ID / check | Fixture line | Expected result |
| --- | --- | --- |
| stop-context / 9 | "Keep the context window small." | Cut |
| stop-emphasis / 9 | "IMPORTANT: YOU MUST read the guide." | Cut or rewritten plainly |
| stop-subagent-context / 9 | "Use subagents to protect context." | Cut |
| stop-subagent-quality / 9 | "Delegate for a better answer." | Cut; a fresh independent reviewer line stays |
| stop-thinking / 9 | "Think harder." | Cut |
| stop-persistence / 9 | "Keep going until done." | Cut; "run pnpm test until it passes" stays |
| stop-repo / 9 | "src/ holds the app." | Cut; a misleading legacy directory note stays |
| stop-tools / W9 | "Minimize tool calls." | Cut; a team limit on a named tool stays |
| stop-preserved / 9 | "Think harder" with a recorded user decision | PASS with a note, not removed |
| enforce-rule / 10 | "Never edit src/gen/." | Line stays, hook or deny rule recommended |
| enforce-preference / 10 | "Prefer named exports." | Line stays, no enforcement recommended |
| rare-language / stage3 | Repository written in a lesser-known language | Document says what it is and links its documentation |
| colleague / stage3 | Instruction only the author can follow | Rewritten so a reader with minimal context can follow it |
| audit-only / routes | S; user: "AGENTS.md 점검만 해줘. 고치지 마." | Report ends `REPORT ONLY`; write set empty; no Stage 3–4 claim |
| named-claude / routes | S; user: "배운 거 CLAUDE.md에 반영해줘: integration tests use a disposable database." | Rule lands in AGENTS.md, report says so, no explorers or writer role; "CLAUDE.md만" keeps it in CLAUDE.md |
| session-capture / routes | S; corrections: a team rule, a personal preference, a finished fix, a discoverable fact, a plan-mode rule | Team rule in AGENTS.md, plan-mode rule in CLAUDE.md, personal item reported with no write, the other two dropped; write set is those two files |
| broken-pointer / red flag | "Deployment steps are in docs/deploy.md." with no such file, no deletion requested | Line stays and is reported |
| summary-growth / line check | AGENTS.md with a directory list; "AGENTS.md 갱신해줘" with no verifier run | Report lists a `Line check`; no new directory entry survives |

The YAML tasks exercise decisions through the runner's supported text graders.
They do not prove filesystem writes. Record actual fixture diffs and ordered
writes separately for pair-empty, pair-migrate, import-only, and authorized-update.
Inspect all read-only cases for absence of unintended writes.
Dispatch a Lightweight general-purpose worker that runs waza-run.sh for optional automated runs; no direct CLI invocation.
Mock runs and missing-runner skips cannot satisfy artifact assertions.

Every case must be PASS, FAIL, SKIP, or UNVERIFIED with evidence and limitations.
An unavailable execution channel does not become PASS. Structural validation
is a separate result. Never place production credentials or session history in
these fixtures or their reports.
