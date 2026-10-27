---
name: humanizer
argument-hint: "[--strict | redo] [텍스트 또는 파일 경로] [장르: ...] [강도: ...]"
description: |
  AI가 쓴 글의 흔적을 자연스러운 사람의 글로 바꾸는 윤문 오케스트레이터(한국어 주력, 영어는 fast만).
  AI 글 자연스럽게, AI 티 제거, ChatGPT 문체 고쳐, 번역투 고쳐, 사람이 쓴 것처럼 윤문, 휴머나이저, humanize, remove AI tone, 2차 윤문, /humanizer 요청 시 사용한다. 요청이 없어도 이슈·PR 본문, README, 사용자용 문서처럼 사람이 읽을 한국어 글을 새로 쓰거나 고쳤고 그 부분의 문장이 100자 이상이면, 내보내거나 승인받기 직전에 그 부분만 fast 모드로 사용한다(커밋 메시지, 대화 답변, 에이전트 지침·프롬프트, 불릿·표·코드 위주 글은 제외). redo·--strict는 모드 인자다.
group: writing
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

<!-- Adapted from epoko77-ai/im-not-ai and snflkd/fluent-korean (MIT). See LICENSE-THIRD-PARTY. -->

# Humanizer

Rewrites AI-writing traces in Korean or English text into natural prose. Fast mode is one pass; strict mode is a Korean-only 3-agent pipeline.

## Model guidance

Standard suits explicit, bounded wording changes; Advanced suits tone and meaning-preservation judgment in any mode; Lightweight suits literal protected-token checks only. Recommend Frontier when meaning conflicts survive Advanced review. Workers follow [dispatch routing](../generate-skills/references/model-selection.md#dispatch-routing).

## Start

Print this as the first line:

```
humanizer v2.0 — {fast|strict|redo} 모드 / run_id: {YYYY-MM-DD-NNN} / 언어: {ko|en|mixed}
```

**Mode** (first match wins):

1. `redo`, "특정 카테고리만 다시", "이 문단만", "2차 윤문" → redo
2. `en` or `mixed` input → fast. Strict is Korean-only; if it was asked for, tell the user: "strict 모드는 한국어 전용입니다. 영어는 fast 모드만 지원합니다."
3. `--strict`, "정밀 모드", "3인 파이프라인" → strict
4. Korean over 8,000 chars → strict, with a one-line notice
5. Otherwise → fast

**Proactive run** (no user request): fast only.

- Input is only the span written or changed this turn, never untouched text.
- Korean over 8,000 chars → skip with a one-line notice; never upgrade to strict.
- Never ask for genre; use 기술 문서 when steps 1–3 of the content-type matrix do not decide.
- Hand over `final.md` and report one status line instead of the four-part response.
- On grade C/D or a worker HOLD, keep the original and say so.

**Options** (natural language):

- `장르: 칼럼|리포트|블로그|공적` — otherwise estimated from the first 300 chars
- `강도: 보수|기본|적극` — default `기본`
- `최소심각도: S1|S2|S3` (strict) or `P1|P2|P3` (fast English) — default S2/P2; each level includes all more severe ones

## Run setup

1. Create `${XDG_STATE_HOME:-$HOME/.local/state}/agents/humanizer/{run_id}/` (NNN = the day's sequence) and save the input as `01_input.txt`.
2. Detect language from prose only: drop fenced code, inline code and URLs, then count Hangul syllables and Latin letters. Hangul 70%+ → ko, Latin 70%+ → en, else mixed; nothing left → return the input unchanged. Korean prose whose only English is code, paths or identifiers is `ko`.
3. Rename an existing `final.md` / `summary.md` with a `_prev` suffix before writing new ones.
4. Take options only from the user; do not parse other files (project CLAUDE.md, etc.) to infer them.

## Fast mode

**Korean:** dispatch the monolith once: `Agent`, `subagent_type: "general-purpose"`, Advanced, prompt "Read `<abs>/references/roles/monolith.md` first and follow it." plus:

```
input_path: <run dir>/01_input.txt
quick_rules_path: <abs skill dir>/references/quick-rules.md
output_dir: <run dir>
genre_hint: 칼럼 | 리포트 | 블로그 | 공적 | null
```

It writes `final.md` and `summary.md` and returns only metadata.

**English or mixed:** handle the whole text inline; the monolith is Korean-only, so never split Korean spans out to it.

1. Load [patterns-en.md](references/patterns-en.md) (E1–E20) and [patterns-common.md](references/patterns-common.md) (C1–C6); for mixed, also [patterns-ko.md](references/patterns-ko.md) (K1–K19) for the Korean sentences.
2. Set the bar with the content-type matrix.
3. Scan and assign P1/P2/P3. Fix P1 always, P2 by context, P3 optionally.
4. Apply the change-rate guard and the 6-item self-check below.
5. Write `final.md` (body only) and `summary.md`: metrics, category counts before/after, self-check results, grade, main edits, residual findings.

**Response** — after writing the files, return briefly:

1. `완료. 변경률 X% / 등급 Y / 자체검증 N/6 통과`
2. `final.md` as a markdown block
3. summary.md's metrics, category and self-check tables
4. On grade B or lower: "정밀 검증이 필요하면 `--strict`로 3인 파이프라인 실행 가능"

Without an `Agent` tool, run Korean fast inline: follow the English steps above with quick-rules.md as the catalog and S1/S2/S3 severities. Strict needs `Agent`: say so and fall back to fast only with the user's approval.

## Strict and redo

Strict and redo rewrite at most 3 rounds; unresolved after round 3 → `hold_and_report` and recommend human review. Phases and verdicts: [references/strict.md](references/strict.md). Redo uses the most recent run directory (also for "이전 거 다시").

"Targeted rerun" means Phase B for Korean, or the matching inline edit and check for English or mixed.

| User says | Handling |
|---|---|
| "특정 카테고리만 다시" / "번역투만" / "관용구만" | targeted rerun for that category |
| "이 문단만" / "두 번째 문단만" | targeted rerun for that range |
| "2차 윤문" / no instruction | the language track over all residual findings |
| "강도 낮춰" / "보수적으로" | `min_severity = S1` |
| "강도 높여" | `min_severity = S3` |
| "장르 바꿔서 X" | new run_id with the new genre_hint, restart from Phase A |
| "이 변경 되돌려줘" | apply the matching fidelity-auditor rollback directive |


## Safety net

Applies inline and to strict verdicts. Workers keep their own copies; after changing a value here, run `scripts/check-consistency`.

**Meaning invariance** overrides everything. Facts, claims, numbers, dates, proper nouns and quotations match the source exactly; a violation rolls back the edit. Genre and register stay (formality is not an AI tell).

- Completing a sentence adds no tense: `일부 요청 지연 가능성` → `일부 요청의 지연 가능성이 있습니다`, never `지연될 가능성` or `지연되었을 가능성`.
- Brevity prescriptions (`줄임`, `삭제`, `종결만 직결`) never truncate a complete sentence into a `명사형 종결`: `검토했습니다` → `검토.` makes the A-16 tell and turns a fact into a label. Shorten inside a completed sentence.
- Decision-strength words (`검토`, `예정`, `가능성`, `방향`, `판단`) stay unchanged.

**Protected** (never detected or edited): proper nouns and product/model/org names; numbers, dates, units, percentages; direct quotes in double quotes; legal text; math/chemistry/statistics notation; standard acronyms (LLM, GPU, MCP, API, SDK); code, identifiers, commands, paths, API fields, logs, error messages and commit messages (`retry_count`, `/etc/app.yaml`), byte-identical.

**Change-rate guard:** Levenshtein distance(final candidate, `01_input.txt`) / original length, across all rounds. Over 30% → warning in summary.md; over 50% → roll back to the last safe version and set `over_polish_aborted: true`.

**6-item self-check** after each rewrite:

1. Proper nouns, numbers, dates, quotes and protected tokens unchanged.
2. Change rate recorded (over 30% warns, over 50% stops).
3. No genre drift (a column does not become an essay).
4. Register kept (formal stays formal).
5. Zero residual S1 (Korean) or P1 (English) patterns.
6. No metaphor, rhetoric or claim absent from the source.

On a violation, roll back that edit and retry once. If a meaning or protected-token violation or the 50% ceiling remains, output the last safe version (or the original). Only unresolved style checks may ship, as "자가검증 미통과 N건" in summary.md.

**Grade:**

- **A**: S1/P1 residual 0, S2/P2 residual ≤ 2, change rate 10–25%, self-check 6/6.
- **B**: S1/P1 residual 0, S2/P2 residual ≤ 4, self-check 5+/6.
- **C**: S1/P1 residual 1–2 or self-check ≤ 4/6 → recommend strict.
- **D**: S1/P1 residual 3+ or change rate over 50% → recommend stopping.

## Content-type matrix

Decide the type in this order: the user's word; the path (`README.md` → 기술 문서, under `blog/` → 블로그); the content (code-block ratio, tone, format); otherwise ask with AskUserQuestion, or as plain text if it is unavailable, and wait.

| Type | Bar | Voice |
|------|-----|-------|
| **블로그/에세이** | All patterns | Match the source; add no stance or 1st person |
| **기술 문서** | Clarity first; remove modifiers and filler | None; precise and dry |
| **마케팅/카피** | Cut unsupported hype; keep only evidence in the source | Match the source brand voice |
| **학술/리포트** | Accuracy and sourcing; remove weasel words | None; objective |
| **코드 주석** | Brevity; remove needless explanation | None |
| **SNS/캐주얼** | Remove excess formality when the source is casual | Match the source |

## Look up

- Korean fast catalog → [quick-rules.md](references/quick-rules.md) (the monolith reads it)
- Strict pipeline or redo → [strict.md](references/strict.md)

## Acknowledgements

The strict pipeline, fast monolith, rulebooks, and role files are adapted from [`epoko77-ai/im-not-ai`](https://github.com/epoko77-ai/im-not-ai) v1.5 under the MIT License. Taxonomy patterns `A-16` and `A-17`, the protected-token expansion, and the tense-injection guard are adapted from [`snflkd/fluent-korean`](https://github.com/snflkd/fluent-korean), also MIT. See [`LICENSE-THIRD-PARTY`](./LICENSE-THIRD-PARTY) for provenance and local changes.
