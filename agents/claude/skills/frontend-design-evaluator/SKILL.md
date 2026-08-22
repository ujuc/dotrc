---
name: frontend-design-evaluator
description: "Chrome에서 실행 중인 프론트엔드 결과물을 Design Quality, Originality, Craft, Visual Usability 기준으로 평가한다."
when_to_use: "디자인 평가, UI 리뷰, frontend-design-evaluator, 디자인 검수해줘, evaluate this design, rate my frontend, AI slop check 요청 시 사용한다. 루프의 판별자(evaluator)로도 호출된다."
group: verify
model: sonnet
allowed-tools: Read Write Bash ToolSearch advisor mcp__claude-in-chrome__tabs_context_mcp mcp__claude-in-chrome__tabs_create_mcp mcp__claude-in-chrome__navigate mcp__claude-in-chrome__read_page mcp__claude-in-chrome__get_page_text mcp__claude-in-chrome__javascript_tool mcp__claude-in-chrome__resize_window
---

# Frontend Design Evaluator

Acts as the discriminator in a Generator-Evaluator loop. Score the live page honestly — inflated scores waste iteration cycles. For the pipeline that drives the loop, see the `multi-agent-orchestrator` skill.

## Prerequisite: live Chrome access

Chrome browser tools are MCP **deferred tools**. They are NOT callable until loaded.

Before starting the first evaluation:

1. Load the tools with `ToolSearch` (comma-joined list):
   ```
   select:mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__tabs_create_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__read_page,mcp__claude-in-chrome__get_page_text,mcp__claude-in-chrome__javascript_tool,mcp__claude-in-chrome__resize_window
   ```
2. Call `tabs_context_mcp` first to discover existing tabs. Only reuse a tab if the user explicitly asks.
3. If the extension is unresponsive or returns errors twice in a row, stop and ask the user to switch browsers or restart the extension.

Do NOT evaluate from source code, Figma exports, or static screenshots. Runtime styles (CSS-in-JS, dynamic themes, media queries) are invisible outside the browser.

## Contract Preflight

Run `"${WORKFLOW_HOOKS_BIN:-$HOME/.local/bin/workflow-hooks}" contract`. Verify `artifacts.design_report.writer == "frontend-design-evaluator"` and read its report pattern. If unavailable, stop and report:

```bash
cargo install --locked --path "$HOME/.config/dotrc/agents/tools/workflow-hooks" --root "$HOME/.local"
```

For a managed run, read canonical `spec.md`, `.sprint/contract.md`, `.plans/plan-{feature}.md`, and `.plans/.verify-final-{feature}.md`. Stop if `.harness/` exists; ask the user to resolve that legacy state manually and never migrate it. This skill owns only design evaluation. `qa-evaluator` owns functional acceptance, and `multi-agent-orchestrator` owns synthesis.

## Evaluation Criteria

Design Quality and Originality carry 2x weight because technical polish without vision produces forgettable interfaces.

| Criterion | Weight | Focus |
| --- | --- | --- |
| **Design Quality** | 2x | Cohesive mood: do colors, typography, layout, and images form one identity? |
| **Originality** | 2x | Intentional human choices vs. template/AI patterns. |
| **Craft** | 1x | Hierarchy, spacing, contrast, color harmony — fundamentals. |
| **Visual Usability** | 1x | Visual affordance, hierarchy, readability, responsive composition, and state legibility. Do not retest business behavior or functional acceptance. |

Full 1–10 rubric per criterion: see [references/design-criteria.md](references/design-criteria.md).

```
weighted_score = (design_quality * 2 + originality * 2 + craft + visual_usability) / 6
```

## Evaluation Process

1. **Navigate every page and major state** in the live browser. Check both light/dark if both exist — score the worse.
2. **5-second impression** before scoring: what is this? primary action? professional? unique?
3. **AI slop detection** — scan against [references/anti-patterns.md](references/anti-patterns.md). 3+ patterns → cap Originality at 4; 5+ → cap at 2.
4. **Score each criterion 1–10** with specific element references (selectors, component names, or concrete descriptions). For scores < 7, include fix suggestions.
5. **Calibrate** against anchors before committing scores:
   - 3: default Create React App
   - 5: a well-filled Tailwind template
   - 7: portfolio site with distinct identity
   - 9: Awwwards / FWA-tier craft

For a managed verdict, PASS requires weighted average ≥ 7, every design criterion ≥ 7, and no Critical or Major visual-usability issue. Scores never override a severe issue. Functional failures discovered incidentally are evidence links for QA, not design-owned acceptance judgments.

## Iteration Directive

Every report ends with a directive for the next round, picked from the score trend. See [references/iteration-strategy.md](references/iteration-strategy.md) for the full decision matrix and stop conditions.

Quick reference:
- First round → use `Baseline`; do not infer a trend without a prior round.
- Trend **up** → "Refine. Focus on [weak areas]."
- Trend **stagnant / declining** → "Pivot. Current direction plateaued. Try [alternative]."
- Weighted average **≥ 7** with no criterion below 7 → "Polish phase. Address: [micro-details]."

Replace every bracketed placeholder with concrete content before emitting the directive (e.g., "Originality and Craft", "brutalist editorial layout", "hero h1 leading"). Emitting literal `[weak areas]` or `[alternative]` is a failure mode.

## Output Format

```
## Design Evaluation Report

**URL**: <url>
**Iteration**: <round> of <planned>
**Viewports tested**: <e.g., 375px, 1280px / light, dark>
**Trend**: Baseline / Improving / Stagnant / Declining

### Scores

| Criterion        | Weight | Score | Trend |
| ---------------- | ------ | ----- | ----- |
| Design Quality   | 2x     | X/10  | +/-/= |
| Originality      | 2x     | X/10  | +/-/= |
| Craft            | 1x     | X/10  | +/-/= |
| Visual Usability | 1x     | X/10  | +/-/= |
| **Weighted Avg** |        | X/10  |       |

### AI Slop Detection
- [ ] <pattern> detected
(or "No anti-patterns detected")

### Design Quality Assessment
<observations with element references>

### Originality Assessment
<observations, template/AI pattern identification>

### Craft Assessment
<typography, spacing, color, contrast>

### Visual Usability Assessment
<affordance, hierarchy, state legibility, responsive composition>

### Iteration Directive
<refine / pivot / polish with specifics>

### Priority Fixes for Next Iteration
1. <most impactful>
2. <second>
3. <third>
```

Write stdout only for standalone evaluation. In a managed orchestrator run, write exactly `.plans/.design-{feature}-r{round}.md` after validating it against the embedded contract. Include exact feature, round, plan, acceptance contract, final verifier, URL, evidence, criterion verdicts, and Overall PASS/FAIL. Do not write QA or synthesized evaluation files.

## Advisor Escalation

Call `advisor()` with no arguments (full context forwards automatically) at these decision points:

- **AI Slop borderline** — 2–3 patterns detected and unsure whether to cap Originality.
- **Refine vs. pivot** — scores stagnant but not obviously broken.
- **Near-threshold calls** — weighted average 6.5–7.0; the next round's mode depends on this judgment.

Treat advisor as an inflation guard, not a default — it is expensive.

## Gotchas

- **Mobile viewport is not optional.** Evaluate at 375px unless the app declares desktop-only. Broken mobile caps Design Quality at 5.
- **Loading states matter.** A blank white flash on navigation is a Craft deduction.
- **Originality ≠ novelty.** A well-executed classic design scores high if choices are intentional. Score "a designer made deliberate choices," not "I have never seen this before."
- **Keep feedback outcome-focused.** Return evidence and concrete visual outcomes to `implement-plan`; do not ask it to optimize for rubric vocabulary.
