---
name: prompting-assist
description: "사용자가 LLM에 보낼 프롬프트를 개선·리뷰·피드백받고 싶어할 때 사용. Anthropic 공식 프롬프팅 모범 사례에 근거한 체크리스트로 진단하고 개선안을 제시한다. '프롬프트 개선해줘', '이 프롬프트 리뷰해줘', '프롬프팅 팁', '/prompting' 등 명시적 어구에만 발동하며, 일반 대화 속 '프롬프트'라는 단어만으로는 발동하지 않는다."
group: writing
model: sonnet
allowed-tools: Read, Edit, AskUserQuestion, ToolSearch, WebFetch
---

# Prompting Assist

## Purpose

Diagnose a user-authored prompt against Anthropic's official prompting best practices and propose concrete improvements. Activates only when prompt authoring / improvement is the explicit subject — not whenever the word "prompt" appears.

## Trigger Policy

Korean trigger phrases are kept verbatim because they must match user utterances directly.

**Activate on:**
- "프롬프트 개선해줘"
- "이 프롬프트 리뷰해줘" / "이 프롬프트 피드백 줘"
- "프롬프팅 팁 알려줘"
- `/prompting`
- "system prompt 개선해줘"

**Do NOT activate on:**
- "프롬프트가 너무 길어서..." (word appears ≠ improvement request)
- "프롬프트 엔지니어링이 뭐야?" (concept question)
- "이 프롬프트 의미가 뭐야?" (interpretation request)

If intent is ambiguous, ask one clarifying question first: "이 프롬프트를 개선해드릴까요, 아니면 의미를 설명해드릴까요?"

**vs `ecc:prompt-optimizer`:** if that plugin skill is installed, its English trigger surface ("improve my prompt", "optimize prompt") overlaps this skill's. The split: `prompting-assist` **diagnoses and rewrites** the prompt directly against Anthropic best practices; `ecc:prompt-optimizer` is **advisory-only** — it maps the request to ECC components and returns a paste-ready prompt without executing. Prefer `prompting-assist` for "review / improve this prompt"; route to `prompt-optimizer` only when the user explicitly wants ECC-component matching.

## Workflow

### Stage 1: Context Collection

1. **Acquire the prompt source.**
   - If already pasted into chat, confirm the range.
   - If a file path is given, `Read` it.
   - If absent, request once: "어떤 프롬프트를 보고 싶으신가요?"

2. **Collect the minimum necessary context** via `AskUserQuestion` (batch the questions, do not re-ask):
   - Target model: Claude family / another LLM / unknown
   - Primary use case: one-shot / agentic / tool-calling / long-context / coding
   - Hard constraints: response length / cost / latency / output format

If the model is unknown, default to the latest available Claude model and state the assumption explicitly.

### Stage 2: Reference Load

The diagnostic baseline is the **inline checklist in Stage 3** (10 categories). For current, authoritative phrasing and code snippets, **live-fetch** Anthropic's official prompt engineering guide:

```
https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview
```

`WebFetch` is a **deferred tool** — load its schema first with `ToolSearch` (query `select:WebFetch`), then fetch. The overview links to per-technique pages (be clear and direct, multishot examples, chain-of-thought, XML tags, system prompts, prefill, prompt chaining, long-context tips); fetch the ones relevant to the failing categories. Reusable code snippets from the guide can be quoted verbatim as improvement examples.

On **any** failure (tool not loaded, offline, rate limit, layout change), fall back to the Stage 3 inline checklist and tell the user in one line: "Anthropic 가이드 라이브 페치 실패 — 인라인 체크리스트 기반으로 진단합니다."

### Stage 3: Diagnosis

Judge pass / fail per checklist category:

| Category | Key question |
|----------|--------------|
| Clarity & specificity | Is the desired outcome explicit? Are scope and exceptions clear? |
| Context & motivation | Is the reason for each constraint stated? |
| Examples | Are 3–5 examples present for few-shot tasks? Are they wrapped in `<example>`? |
| Structure | Are content types separated by XML tags? Is long context at the top, query at the bottom? |
| Role & identity | Does the system prompt assign a role? |
| Output control | Is the language prescriptive (do) rather than prohibitive (don't)? Is there no reliance on last-turn prefill? |
| Thinking & effort | Does the effort setting match task difficulty? Is there no aggressive over-trigger wording? |
| Tool use & agentic | Is the action-vs-suggest intent clear? Is parallel intent marked? |
| Long-horizon | Is state held in structured files? Are completion criteria verifiable? |
| Anti-patterns | No test hard-coding, no over-defensive coding, no pressure toward needless abstraction? |

For each failing item, record a **short justification + improvement direction**. Cite the checklist category (or a specific section of the fetched Anthropic guide).

### Stage 4: Proposal

Pick the proposal format by change magnitude:

- **Small fix** (≤ 3 items): per-section diff
  ```
  Before: "Make it better"
  After:  "Refactor the loop to use parallel tool calls (see Parallel tool-call prompt)."
  Why:    Clarity & specificity (§Stage 3), Tool use (§parallel)
  ```
- **Full rewrite** (multiple failures): the improved prompt in full + a bullet list of key changes

**Prefer presenting options** when the user has a real choice: lay out "Option A (terse)" vs "Option B (strict)".

Close with a one-line checklist coverage report: "10개 범주 중 7개 합격, 3개 개선 반영."

## Constraints

- **Preserve original intent.** Never change what the user is trying to do — only raise quality.
- **Evidence-backed.** Do not assert anything outside Anthropic's official guidance. Every recommendation maps to a checklist category (or a section of the fetched Anthropic guide).
- **Language preservation.** Keep the prompt's original language in the artifact. Diagnosis and explanation follow the conversation language (default Korean).
- **Brevity.** Diagnosis report: 1–2 lines per category. Strip filler.
- **Model-version awareness.** Successive Claude model generations diverge in non-trivial ways. When the target model is unknown, state the assumption and proceed.

## References

- [Anthropic prompt engineering overview](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview) — primary reference; live-fetch per Stage 2 (per-technique pages are linked from the overview)
- The **Stage 3 inline checklist** is the offline fallback baseline when the live fetch fails

## Gotchas

1. **`WebFetch` is deferred — load it first.** `allowed-tools` only pre-grants permission; the tool is not callable until its schema is loaded via `ToolSearch` (`select:WebFetch`). On any fetch failure, fall back to the Stage 3 inline checklist and say so in one line — never block the diagnosis on the network.

2. **Do not over-trigger.** The description intentionally encodes do/don't patterns. Treat the word "prompt" in a user sentence as a keyword, not an invocation. Default to one clarifying question when the intent is ambiguous.

3. **Never edit the prompt in place without consent.** `Edit` is in `allowed-tools` for cases where the prompt lives in a file the user asked to be improved. Always show the proposal first, then apply the edit only after explicit confirmation.

4. **Model-version drift.** Successive Claude generations differ enough (extended thinking defaults, parallel tool-call norms, effort tuning) that a checklist pass tuned for one generation can be a near-fail for another. When unknown, default to the latest available model and state the assumption.

## Eval Criteria

```
EVAL 1: Trigger precision
  Question: Given a user utterance that only contains the word "프롬프트" without
            an improvement-request framing, does the skill decline to activate
            (or ask a clarifying question) instead of running a full diagnosis?
  Pass: Skill does not run Stage 2–4 without an explicit improvement intent.
  Fail: Skill begins full diagnosis on mere keyword presence.

EVAL 2: Reference grounding
  Question: Does every improvement recommendation cite a specific checklist
            category (or a section of the fetched Anthropic guide)?
  Pass: Each recommendation has an anchor (category name or §section).
  Fail: Any recommendation is stated without a reference anchor.

EVAL 3: Intent preservation
  Question: Does the proposed prompt preserve the user's original goal,
            scope, and persona?
  Pass: Target task, constraints, and role remain intact; only phrasing/
        structure/specificity changes.
  Fail: Meaning drifts — task narrowed/broadened, constraints dropped, or
        persona replaced.

EVAL 4: Proposal structure
  Question: Is the proposal formatted per Stage 4 (Before/After diff for
            small fixes, full rewrite + key changes for larger ones) and
            closed with a one-line coverage report?
  Pass: Format matches change magnitude; coverage line present.
  Fail: Format mismatched, or coverage report missing.

EVAL 5: Language fidelity
  Question: Is the rewritten prompt in the same language as the original,
            with diagnosis written in the conversation language?
  Pass: Prompt language preserved; diagnosis in conversation language.
  Fail: Prompt translated silently, or diagnosis in the wrong language.
```
