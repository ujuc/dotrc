---
name: prompting-assist
description: "LLM 프롬프트를 Anthropic 프롬프팅 모범사례 기반 체크리스트로 진단하고 Before/After diff 또는 전체 재작성안을 제시한다. 사용자가 LLM에 보낼 프롬프트를 개선·리뷰·피드백받고 싶어할 때 사용. '프롬프트 개선해줘', '이 프롬프트 리뷰해줘', '이 프롬프트 피드백 줘', 'system prompt 개선해줘', '프롬프팅 팁', 'improve my prompt', 'review this prompt', '/prompting-assist' 등 명시적 어구에만 발동하며, 일반 대화 속 '프롬프트'라는 단어만으로는 발동하지 않는다."
group: writing
allowed-tools: Read, Edit, AskUserQuestion, ToolSearch, WebFetch
---

# Prompting Assist

## Model guidance

Use Standard for bounded prompt edits; Advanced suits conflicting instructions, evaluation design, or a complex prompt's failure analysis.
Recommend Frontier only when coupled failures survive Advanced analysis; the model being advised on remains the user's target, separate from the reviewing agent.
Apply the [shared selection guide](../generate-skills/references/model-selection.md) to similar work and host-supported model choices.

## Trigger Policy

Run only when improving a prompt is the explicit request. Activate on "프롬프트 개선해줘", "이 프롬프트 리뷰해줘" / "이 프롬프트 피드백 줘", "프롬프팅 팁 알려줘", "system prompt 개선해줘" and `/prompting-assist`; with no prompt given, Stage 1 asks for it.

Do not activate on:
- "프롬프트가 너무 길어서..." (the word appears, no improvement request)
- "프롬프트 엔지니어링이 뭐야?" (concept question)
- "이 프롬프트 의미가 뭐야?" (interpretation request)

If intent is ambiguous, first ask only: "이 프롬프트를 개선해드릴까요, 아니면 의미를 설명해드릴까요?"

If `ecc:prompt-optimizer` is installed, its triggers overlap. It only maps the request to ECC components and returns a paste-ready prompt; route there only when the user explicitly wants ECC-component matching.

## Workflow

### Stage 1: Context Collection

1. **Get the prompt.** Pasted: confirm the range. File path: `Read` it. Absent: ask once, "어떤 프롬프트를 보고 싶으신가요?"
2. **Ask in one batch** with `AskUserQuestion` (or one plain-text message if unavailable), never re-asking:
   - Target model: specific Claude model (name/version) / Claude family only / another LLM / unknown
   - Use case: one-shot / agentic / tool-calling / long-context / coding
   - Hard constraints: length / cost / latency / output format

If the model is unknown, use current general Claude guidance and state that assumption; never invent an exact model version.

### Stage 2: Reference Load

Live-fetch Anthropic's best-practices page:
`https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices`

If Stage 1 names a current Claude model, also fetch the guide its row in the page's "Model-specific guidance" table links to (never a stored URL), and apply it before the general techniques. No row: say so and use the general page.

On Claude Code, load `WebFetch` first with `ToolSearch` (`select:WebFetch`); elsewhere use the host's web tool. Never block on the network.

On **any** failure (no web tool, tool not loaded, offline, rate limit, layout change), diagnose with the Stage 3 checklist and tell the user in one line: "Anthropic 가이드 라이브 페치 실패 — 인라인 체크리스트 기반으로 진단합니다."

### Stage 3: Diagnosis

Mark each category pass or fail. Only Model carry-over may be N/A.

| Category | Key question |
|----------|--------------|
| Clarity & specificity | Is the desired outcome explicit? Are scope and exceptions clear? |
| Context & motivation | Is the reason for each constraint stated? |
| Examples | Are representative examples present where behavior is hard to describe? |
| Structure | Are content types separated clearly, using XML tags when useful? |
| Role & identity | Does a role add task-relevant context rather than decoration? |
| Output control | Is the desired output shape stated positively and concretely? |
| Thinking & effort | Does the effort setting match task difficulty without requesting visible chain-of-thought? |
| Tool use & agentic | Is action-vs-suggestion intent clear, with tools named when needed? |
| Model carry-over | Does the prompt keep instructions for an earlier model's habits that the fetched model guide says to remove (narration suppression, blanket anti-formatting rules, thinking toggles)? Remove those before adding new ones. N/A unless Stage 2 fetched a model guide for a Claude target. |
| Engineering restraint (local rule) | Does it avoid test hard-coding, defensive bloat, and needless abstraction pressure? |

Keep the report to 1–2 lines per category. For each failure, give a justification and improvement direction, citing the category or a section of a fetched guide. Attribute to Anthropic only what the fetched pages say; label Engineering restraint as a local rule. Official snippets from them may be quoted as examples.

### Stage 4: Proposal

- **Small fix** (≤ 3 items): per-section diff
  ```
  Before: "Make it better"
  After:  "Run independent tool calls in parallel; keep dependent calls sequential."
  Why:    Stage 3: Clarity & specificity; Tool use & agentic
  ```
- **Full rewrite** (more failures): the whole improved prompt plus key changes as bullets.

When the user has a real choice, offer options such as "Option A (terse)" vs "Option B (strict)".

End with one coverage line counting only non-N/A categories: "적용 10개 범주 중 8개 합격, 2개 개선 반영." (with Model carry-over N/A: "적용 9개 범주 중 8개 합격, 1개 개선 반영.")

## Constraints

- **Preserve intent.** Keep the user's goal, scope, constraints and persona; change only quality.
- **Language.** The prompt stays in its original language; diagnosis follows the conversation language (default Korean).
- **Consent before editing.** For a prompt in a file, show the proposal first and `Edit` only after explicit confirmation.
