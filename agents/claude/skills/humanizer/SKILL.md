---
name: humanizer
argument-hint: "[--strict | redo] [텍스트 또는 파일 경로] [장르: ...] [강도: ...]"
description: |
  AI가 쓴 글의 흔적을 자연스러운 사람의 글로 바꾸는 윤문 오케스트레이터(한국어 주력).
  Fast(단일 호출, 디폴트)·Strict(4인 파이프라인, 정밀) 듀얼 트랙 + Redo(부분·재윤문) 모드. 의미 불변·과윤문 가드·등급 자동 채점.
  트리거: AI 글 자연스럽게, AI 티 제거, ChatGPT 문체, 번역투 고쳐, 사람이 쓴 것처럼 윤문, 휴머나이저, redo, 2차 윤문, --strict.
group: writing
model: sonnet
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
  - Agent
---

# Humanizer — AI-Writing-Trace Removal Orchestrator

Finds AI-generated traces in Korean/English text and rewrites them into natural human prose.
Dual track: Fast mode (default, single call) and Strict mode (4-agent pipeline).

## Phase 0 — Context check and mode decision

On start, print this as the first line:

```
humanizer v2.0 — {fast|strict|redo} 모드 / run_id: {YYYY-MM-DD-NNN} / 언어: {ko|en|mixed}
```

**Mode priority:**

1. User says `redo`, or "특정 카테고리만 다시" / "이 문단만" / "2차 윤문" → **redo**
2. User says `--strict`, or "정밀 모드" / "4인 파이프라인" → **strict**
3. Korean input over 8,000 chars → **strict auto-upgrade** (one-line notice to the user)
4. English-only input → **fast forced** (strict is Korean-only)
5. Otherwise → **fast (default)**

**Optional arguments (given in natural language):**

- `장르: 칼럼|리포트|블로그|공적` — auto-estimated from the first 300 chars if omitted
- `강도: 보수|기본|적극` — default `기본`
- `최소심각도: S1|S2|S3` (strict) or `P1|P2|P3` (fast English) — default S2/P2. S1 includes only level 1; S2 includes levels 1–2; S3 includes all three.

## Phase 1 — Input capture and run_id

1. Create `_workspace/{YYYY-MM-DD-NNN}/` under cwd. NNN is the day's sequence.
2. Save the input text to `01_input.txt`.
3. Estimate genre from the first 300 chars (an explicit user value wins).
4. Detect language: Hangul ratio 70%+ → ko, Latin ratio 70%+ → en, else mixed.
5. On redo, reuse the most recent `_workspace/` subdir when the user signals "이전 거 다시".

## Fast mode (default)

### Korean input

Call the `humanize-monolith` agent once via the `Agent` tool.

Call arguments:
```
input_path: <abs path>/_workspace/{run_id}/01_input.txt
quick_rules_path: <resolved absolute skill path>/references/quick-rules.md
output_dir: <abs path>/_workspace/{run_id}
genre_hint: 칼럼 | 리포트 | 블로그 | 공적 | null
```

The monolith runs detection → rewrite → self-validation → output in one call and writes
`final.md` + `summary.md`. It calls no other sub-agent.

### English input (fast-only track)

The monolith is Korean-only, so the orchestrator handles English inline from this body.

1. Load `references/patterns-en.md` + `references/patterns-common.md`.
2. Decide the application bar via the content-type matrix below.
3. First-pass scan with the catalog cheat-sheet; assign severity (P1/P2/P3).
4. Fix — P1 always, P2 by context, P3 optional. Apply the 30/50% change-rate guard.
5. Run the 6-item self-check (same as Korean) — on violation, roll back that edit and retry.
6. Write `final.md` + `summary.md`. Same summary format as the monolith.

### Mixed input

Do not split Korean to the monolith and English to inline handling. Process the **whole text
inline as the English fast track** (the monolith is Korean-only and would damage English spans).

### Fast response format

After writing the artifacts, return these four briefly to the user:

1. One-line status: `완료. 변경률 X% / 등급 Y / 자체검증 N/6 통과`
2. The rewritten body (final.md content as a markdown block)
3. summary.md's key tables (metrics + category detection + self-check)
4. If the grade is B or lower, note "정밀 검증이 필요하면 `--strict`로 4인 파이프라인 실행 가능"

**Default wall-clock target:** ≤ 5,000 chars in 2–3 min, 8,000 chars in 5–7 min.

## Strict mode (`--strict` or over-8,000-char auto-upgrade)

**Korean only.** If `--strict` arrives with English input, force fast + notice:
"strict 모드는 한국어 전용입니다. 영어는 fast 모드만 지원합니다."

### Phase A — Detection

Call `humanize-detector` with absolute `input_path`, `taxonomy_path`, and `output_path` plus `run_id`, `genre_hint`, `min_severity`, and `include_document_level: true`. It writes `02_detection.json`.

### Phase B — Rewrite (up to 3 loops)

Call `humanize-rewriter` with absolute `original_path`, `source_path`, `detection_path`, `playbook_path`, `rewrite_path`, and `diff_path`. `original_path` is always `01_input.txt`; round 1 also uses it as source, while later rounds use the prior candidate as source and receive the current review path. Use matching versions: `03_rewrite.md` + `03_rewrite_diff.json`, then `_v2`, then `_v3`. Change rate is always final candidate versus `original_path`.

### Phase C — Parallel verification (agent team)

Call the `Agent` tool twice in parallel with the current round's absolute paths:

- `humanize-fidelity-auditor` → `04_fidelity_audit{_vN}.json` (13-item semantic equivalence)
- `humanize-naturalness-reviewer` → `05_naturalness_review{_vN}.json` (residual + over-polish)

### Phase C verdict

Precedence: any `hold_and_report` from either verifier stops first; otherwise fidelity `fail`, then `conditional_pass`, then the naturalness result.

| fidelity | naturalness | verdict | follow-up |
|---|---|---|---|
| full_pass | accept / accept_with_note | **final approval** | Phase D |
| full_pass | rewrite_round_2 | **2nd rewrite** | re-call Phase B (target finding) |
| full_pass | rollback_and_rewrite | **rollback then rewrite** | tell the rewriter to roll back the edit |
| full_pass | hold_and_report | **hold** | recommend human review |
| conditional_pass | - | **retry rolled-back edits only** | re-call Phase B |
| fail | - | **full rework** | full re-call of Phase B |
| hold_and_report | - | **hold** | ask for human review; do not rewrite |

On a 2nd/3rd rewrite, split versions as `03_rewrite_v2.md` / `03_rewrite_v3.md`.
**After 3 loops unresolved → `hold_and_report`** — recommend human review.

### Phase D — Final output

1. Copy `03_rewrite_vN.md` or `03_rewrite.md` to `final.md`.
2. Generate `summary.md` (same format as fast mode), copying any `unclassified_candidates` from the final naturalness JSON.
3. Return the four-part response to the user (same as fast).

## Redo mode (`/humanizer redo [instruction]`)

Identify the most recent `_workspace/{run_id}/` (notice and exit if none). For English/mixed runs, redo the current `final.md` through the inline fast track and re-run its checks. For Korean fast runs lacking strict artifacts, scan `final.md` into `02_detection.json` before Phase B and use `final.md` as the prior candidate; fidelity still compares the new candidate with immutable `01_input.txt`.

**Parse the user instruction.** In the table, “targeted rerun” means strict Phase B for Korean and the equivalent inline fast edit/check for English or mixed text.

| User utterance | Handling |
|---|---|
| "특정 카테고리만 다시" / "번역투만" / "관용구만" | targeted rerun for that category only |
| "이 문단만" / "두 번째 문단만" | targeted rerun for that range only |
| "2차 윤문" / no instruction | current language track over all residual findings |
| "강도 낮춰" / "보수적으로" | `min_severity = S1` (S1 only) |
| "강도 높여" | `min_severity = S3` (S1+S2+S3) |
| "장르 바꿔서 X" | new run_id + changed genre_hint, restart from Phase A |
| "이 변경 되돌려줘" | apply the matching fidelity-auditor rollback directive |

Re-call `humanize-rewriter` + re-verify. Output is `03_rewrite_v2.md` (or v3).
**Max round 3.** Beyond that, `hold_and_report` for human review.

## Safety net (all modes)

Invariants and guards the orchestrator applies for inline English/mixed handling and for strict
verdicts. Each sub-agent also enforces its own copy inside its system prompt — that duplication
is intentional, because agents run in isolated contexts and a local copy raises compliance.
**When changing any value below, run `scripts/check-consistency` to keep every copy in sync.**

### Supreme rule — meaning invariance

Facts, claims, numbers, dates, proper nouns, and quotations match the source 100%. Any
violation triggers immediate rollback, in both the monolith and strict tracks. Genre never
drifts (a column does not become an essay); register is preserved (formal stays formal — an
AI tell is grammar and rhetoric, not formality itself).

### Change-rate guard

- change rate = Levenshtein distance(final candidate, immutable `01_input.txt`) / original length, across all rounds.
- **over 30% → warning** (recorded in summary.md).
- **over 50% → hard stop, roll back to the last safe version** (`over_polish_aborted: true`).

### Do-NOT list (excluded from both detection and rewrite)

- Proper nouns, product/model/org names (GPT-4, Claude 3, Gemini, etc.).
- Numbers, dates, units, percentages.
- Direct quotes inside double quotation marks.
- Legal/regulatory text.
- Math/chemistry/statistics notation.
- Industry-standard English acronyms (LLM, GPU, MCP, API, SDK, etc.).

### 6-item self-check (immediately after rewrite)

1. Proper nouns / numbers / dates / quotes 100% preserved.
2. Change rate recorded; over 30% is a warning and over 50% is a hard stop.
3. No genre drift (a column does not turn into an essay or literary piece).
4. Register preserved (formal source → formal output; do not drop to casual).
5. Zero residual S1 patterns (Korean) or P1 patterns (English).
6. No artificial expressions (no metaphor/rhetoric absent from the source added in rewrite).

On violation: roll back the edit → rewrite → re-check, at most once. If a meaning/protected-token violation or the 50% ceiling remains, output the last safe version (or original) instead. Only unresolved style checks may ship with "자가검증 미통과 N건" in summary.md.

### Grade (auto-scored A–D)

- **A**: S1/P1 residual 0, S2/P2 residual ≤ 2, change rate 10–25%, self-check 6/6.
- **B**: S1/P1 residual 0, S2/P2 residual ≤ 4, self-check 5+/6.
- **C**: S1/P1 residual 1–2 or self-check ≤ 4/6 → recommend strict mode.
- **D**: S1/P1 residual 3+ or change rate over 50% → recommend stopping.

### Operating rules

- **No auto-loading.** Do not auto-parse other files (project CLAUDE.md, etc.) to infer options.
- **Back up prior artifacts.** If `final.md` / `summary.md` already exist, back them up with a
  `_prev` suffix before writing new ones.

## Content-type matrix

Genre changes the application bar. Decide in this order:

1. User specified → follow it.
2. Infer from file extension/path (e.g. `README.md` → technical doc, under `blog/` → blog).
3. Infer from content (code-block ratio, tone, format).
4. If unclear, confirm with AskUserQuestion.

| Type | Application bar | Voice handling |
|------|-----------------|-------------|
| **블로그/에세이** | Apply all patterns | Match source voice only; do not add stance or 1st person |
| **기술 문서** | Clarity first. Remove modifiers/filler | X — no emotion/personality. Precise and dry |
| **마케팅/카피** | Cut unsupported hype; retain only evidence already in the source | Match source brand voice only |
| **학술/리포트** | Accuracy and sourcing. Remove weasel words | X — keep objective tone |
| **코드 주석** | Brevity first. Remove unnecessary explanation | X |
| **SNS/캐주얼** | Remove excess formality when the source is casual | Match source voice only |

## Pattern catalog reference

Read by language and mode:

| Mode | Lang | Catalog |
|---|---|---|
| Fast | ko | `references/quick-rules.md` (loaded directly by the monolith) |
| Fast | en | `references/patterns-en.md` + `references/patterns-common.md` |
| Fast | mixed | the English catalogs above + `references/patterns-ko.md` |
| Strict | ko | `references/taxonomy-ko.md` (SSOT, loaded by the detector) + `references/playbook-ko.md` (prescriptions, loaded by the rewriter) |

`patterns-ko.md` has a K↔A-J mapping table at the top for cross-referencing IDs between the
fast and strict tracks.

## References

- Korean fast rulebook: `references/quick-rules.md` (S1·S2 core + 6-item self-check + grade criteria)
- Korean strict SSOT: `references/taxonomy-ko.md` (10 categories × 40+ patterns)
- Korean strict prescriptions: `references/playbook-ko.md` (per-category replacement recipes)
- Korean fast catalog: `references/patterns-ko.md` (K1–K19 + mapping table)
- English fast catalog: `references/patterns-en.md` (E1–E19)
- Common patterns: `references/patterns-common.md` (C1–C6)

## Sub-agents (used by both strict and fast)

- `humanize-monolith` — Fast Korean single call
- `humanize-detector` — Strict Phase A
- `humanize-rewriter` — Strict Phase B (also used by redo)
- `humanize-fidelity-auditor` — Strict Phase C-1
- `humanize-naturalness-reviewer` — Strict Phase C-2

These live in `~/.config/dotrc/agents/claude/agents/` (= `~/.claude/agents/`).

## Consistency check

Safety-net values (4-agent count, 30/50% guard, grade A–D thresholds, 6-item self-check, max 3
rewrite loops) are duplicated across this file, `quick-rules.md`, and the sub-agent definitions
by design. Run `scripts/check-consistency` after changing any of them to catch drift.

## Acknowledgements

The strict pipeline, fast monolith, rulebooks, and sub-agent definitions are adapted from [`epoko77-ai/im-not-ai`](https://github.com/epoko77-ai/im-not-ai) v1.5 under the MIT License. See [`LICENSE-THIRD-PARTY`](./LICENSE-THIRD-PARTY) for provenance and local changes.
