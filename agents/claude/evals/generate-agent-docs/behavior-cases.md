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
| claude-new / C2 | Empty repository; user: "에이전트 문서 만들어줘" with the fact "Run integration tests against the disposable database." | Write set {CLAUDE.md}, holding the fact with no import; no AGENTS.md. |
| agents-beside / C2,C5 | Existing AGENTS.md: "# Work Rules\n\nUse the disposable database for integration tests.\n"; no CLAUDE.md; user: "CLAUDE.md 만들어줘" with the rule "Use /context to check loaded memory files." | AGENTS.md byte-identical; CLAUDE.md is "@AGENTS.md" followed by the /context rule only; the disposable rule is not copied. |
| import-kept / C2 | Fixture S2; user adds "Run new-test before delivery." | Rule lands in CLAUDE.md below the import; `@AGENTS.md` stays; AGENTS.md byte-identical. |
| agents-request / C2 | Fixture S; user: "AGENTS.md 만들어줘" | Write set {CLAUDE.md} at most; no AGENTS.md; the report says this skill writes CLAUDE.md only. |
| selected-only / C2 | User selects one nested CLAUDE.md; root CLAUDE.md exists | Update selected file only; existence of unrelated documents does not reroute or expand target set. |
| authorized-update / C3,C5 | U2 proposed replacing "old-test" with "new-test" in CLAUDE.md; user says "Apply all listed edits"; untouched line "Keep the release freeze exception." | Apply the already approved patch without asking per file; preserve sentinel verbatim. |
| cache-drift / C1 | Successful live fetch differs from bundled snapshot | Use fetched guidance in session, pass it to verifier, report drift; all global skill files and dates byte-identical. |
| tools / C4 | WebFetch unavailable but web fetch equivalent exists; markdown MIME fails and HTML succeeds; advisor unavailable | Use equivalent HTML fetch; do not claim cache fallback or advisor success. No repeated attempt to load a nonexistent tool schema. |
| no-interview / C3,C4 | No question tool; a material scope choice unresolved | Use ordinary user question when interactive; otherwise leave dependent writes pending, report missing answer. Never invent answers. |
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

Fixture S is CLAUDE.md = "# Work Rules\n\nRun old-test.\nKeep the release freeze exception.\n"
with no AGENTS.md. Fixture S2 is AGENTS.md = "# Work Rules\n\nUse the disposable database for integration tests.\n"
and CLAUDE.md = "@AGENTS.md\n". The approved patch changes only old-test to
new-test. Use S for authorized-update; expected write set is {CLAUDE.md}, with
the sentinel unchanged. Every case's write set excludes AGENTS.md.

Cache-drift uses S plus an injected successful source response: "Size: target
under 180 lines per CLAUDE.md file." No project edits are requested by the fetch
step; expected write set is empty. Snapshot all bundled references and compare
bytes afterward. Tools uses an injected unsupported-markdown-MIME error followed
by the same successful response from the equivalent HTML URL. Advisor is absent.
No-interview uses "문서 업데이트해줘" and an explicitly unavailable question
tool; normal interactive text questions remain available. Expected write sets for
both capability tests are empty until all required answers are available.

Evidence uses before = "# Work Rules\n\nFollow team-approved TDD.\nKeep the release freeze exception.\n"
and after = "# Work Rules\n\nFollow team-approved TDD.\n". Withhold before and
the team decision from the verifier's supplied inputs. Expected result is
UNVERIFIED, not PASS, with no additional file writes. For policy, start from
fixture S plus an explicit user decision: "Keep team TDD, use tabs in Makefiles,
and run new-test before delivery." Expected output retains these three
requirements in CLAUDE.md. No always-needed rule may move to path-scoped
.claude/rules/. The report distinguishes upstream size guidance,
model-scoped findings, and local combined defaults.

Review-states uses S with an explicit fast request; inject a passing checklist.
Expected blind status is SKIP and final status partial, with no writes. Its
second variant injects FAIL reference-integrity on each of three checklist runs;
expected result incomplete and no fourth loop. Final-reference starts from S,
injects a reviewer patch adding @MISSING.md to CLAUDE.md, and requires the
final integrity check to report FAIL rather than verified completion.

Anti-trigger uses S; both input requests have an empty agent-document write
set.

| Exact task path (relative to this suite) | Cases |
| --- | --- |
| tasks/target-scope.yaml | claude-new, agents-request |
| tasks/positive-trigger-1.yaml | claude-new |
| tasks/positive-trigger-2.yaml | agents-beside |
| tasks/cache-ownership.yaml | cache-drift |
| tasks/authorization.yaml | authorized-update |
| tasks/tool-fallback.yaml | tools, no-interview |
| tasks/verification-evidence.yaml | evidence, review-states |
| tasks/policy-preservation.yaml | policy |
| tasks/negative-trigger-1.yaml | anti-trigger |
| tasks/stop-list.yaml | stop-context, stop-emphasis, stop-subagent-quality, stop-thinking, stop-persistence, stop-repo, stop-tools |
| tasks/enforcement-fit.yaml | enforce-rule, enforce-preference |
| tasks/report-only.yaml | audit-only |
| tasks/supplied-fact.yaml | named-claude, import-kept |
| tasks/session-placement.yaml | session-capture |
| tasks/broken-reference.yaml | broken-pointer, summary-growth |
| tasks/standalone-claude.yaml | standalone-claude |

Artifact only, with no probe: selected-only, final-reference, stop-preserved, rare-language, colleague, missing-import.

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
| audit-only / routes | S; user: "CLAUDE.md 점검만 해줘. 고치지 마." | Report ends `REPORT ONLY`; write set empty; no Stage 3–4 claim |
| named-claude / routes | S2; user: "배운 거 CLAUDE.md에 반영해줘: integration tests use a disposable database." | Rule lands in CLAUDE.md below the import, no explorers or writer role |
| session-capture / routes | S; corrections: a team rule, a personal preference, a finished fix, a discoverable fact, a plan-mode rule | Team and plan-mode rules in CLAUDE.md; personal item reported with no write; the other two dropped |
| broken-pointer / red flag | "Deployment steps are in docs/deploy.md." with no such file, no deletion requested | Line stays and is reported |
| summary-growth / red flag | CLAUDE.md with a directory list; "CLAUDE.md 갱신해줘" with no verifier run | No new directory entry survives |
| standalone-claude / routes | CLAUDE.md with no import, no AGENTS.md; user: "CLAUDE.md에 이 규칙 추가해줘" | No question; the rule lands in CLAUDE.md, no AGENTS.md or import is written |
| missing-import / routes | Rule-bearing AGENTS.md exists, CLAUDE.md has no import | Audit reports that Claude no longer reads AGENTS.md and proposes the import or a fold-in; no write without approval |

The YAML tasks exercise decisions through the runner's supported text graders.
They do not prove filesystem writes. Record actual fixture diffs and ordered
writes separately for claude-new, agents-beside, import-kept, agents-request,
authorized-update and standalone-claude.
Inspect all read-only cases for absence of unintended writes.
Dispatch a Lightweight general-purpose worker that runs waza-run.sh for optional automated runs; no direct CLI invocation.
Mock runs and missing-runner skips cannot satisfy artifact assertions.

Every case must be PASS, FAIL, SKIP, or UNVERIFIED with evidence and limitations.
An unavailable execution channel does not become PASS. Structural validation
is a separate result. Never place production credentials or session history in
these fixtures or their reports.
