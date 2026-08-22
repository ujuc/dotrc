---
name: prompting-assist
description: "사용자가 LLM에 보낼 프롬프트를 개선·리뷰·피드백받고 싶어할 때 사용. Anthropic 공식 프롬프팅 지침과 로컬 워크플로 계약을 구분해 진단한다. '프롬프트 개선해줘', '이 프롬프트 리뷰해줘', '프롬프팅 팁', '/prompting' 등 명시적 어구에만 발동하며, 일반 대화 속 '프롬프트'라는 단어만으로는 발동하지 않는다."
group: writing
model: sonnet
allowed-tools: Read, Edit, AskUserQuestion, ToolSearch, WebFetch, Bash(workflow-hooks:*)
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

If the model is unknown, use current general Claude guidance and state the
assumption without inventing an exact model version.

For prompts that operate the managed lifecycle, run `workflow-hooks contract`
and preserve its artifact paths, sole writers, and excluded controllers unless
the user explicitly asks to redesign that contract.

### Stage 2: Reference Load

The diagnostic baseline is the **inline checklist in Stage 3**. For current,
authoritative phrasing and code snippets, **live-fetch** Anthropic's living
prompting best-practices reference:

```
https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
```

On Claude Code, `WebFetch` is deferred: load it with `ToolSearch` (query
`select:WebFetch`) before fetching. Other harnesses use their equivalent web
read/search tool. If no web tool exists, use the inline checklist and label the
result offline. Reusable official snippets may be quoted as examples.

On **any** failure (tool not loaded, offline, rate limit, layout change), fall back to the Stage 3 inline checklist and tell the user in one line: "Anthropic 가이드 라이브 페치 실패 — 인라인 체크리스트 기반으로 진단합니다."

### Stage 3: Diagnosis

Judge pass / fail per checklist category:

| Category | Source | Key question |
|----------|--------|--------------|
| Clarity & specificity | Anthropic | Is the desired outcome explicit? Are scope and exceptions clear? |
| Context & motivation | Anthropic | Is the reason for each constraint stated? |
| Examples | Anthropic | Are representative examples present where behavior is hard to describe? |
| Structure | Anthropic | Are content types separated clearly, using XML tags when useful? |
| Role & identity | Anthropic | Does a role add task-relevant context rather than decoration? |
| Output control | Anthropic | Is the desired output shape stated positively and concretely? |
| Thinking & effort | Anthropic | Does the effort setting match task difficulty without requesting visible chain-of-thought? |
| Tool use & agentic | Anthropic | Is action-vs-suggestion intent clear, with tools named when needed? |
| Managed workflow | Local contract | Does an agentic prompt preserve canonical paths, writers, and approval boundaries? |
| Engineering restraint | Local rule | Does it avoid test hard-coding, defensive bloat, and needless abstraction pressure? |

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
- **Evidence-backed.** Attribute Anthropic guidance only to the fetched
  reference. Label managed-workflow and engineering-restraint recommendations
  as local contract/rule safeguards rather than Anthropic guidance.
- **Language preservation.** Keep the prompt's original language in the artifact. Diagnosis and explanation follow the conversation language (default Korean).
- **Brevity.** Diagnosis report: 1–2 lines per category. Strip filler.
- **Model-version awareness.** Successive Claude model generations diverge in non-trivial ways. When the target model is unknown, state the assumption and proceed.

## References

- [Anthropic prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) — living primary reference; live-fetch per Stage 2
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
            category and label official vs local provenance correctly?
  Pass: Each recommendation has an anchor and only fetched guidance is
        attributed to Anthropic.
  Fail: Any recommendation lacks an anchor or presents a local rule as
        Anthropic guidance.

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
