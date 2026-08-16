# Sprint Contract Template

## Standard Format

```markdown
# Sprint Contract — [Sprint Name]

## Sprint Goal
[One sentence: what value does this sprint deliver to the user?]

## Implementation Scope
1. [Feature Name] — [What it does in 1 sentence]
2. [Feature Name] — [What it does in 1 sentence]
...

## Verification Criteria

| # | Criterion | Expected Behavior | Test Method |
|---|-----------|-------------------|-------------|
| 1 | [Subject + Verb + Expected Result] | [Observable outcome] | [Manual test / API call / UI interaction] |
| 2 | ... | ... | ... |

## Exclusions
- [Item explicitly NOT included in this sprint]
- [Item deferred to future sprint]

## Negotiation History
- Draft 1: [date] — [N] criteria proposed, [M] rejected
- Draft 2: [date] — [N] criteria revised, [M] rejected
- Final: [date] — [N] criteria agreed
```

## Criteria Writing Rule

Every criterion MUST follow this pattern:

**Subject + Verb + Expected Result + Verification Method**

| Component | Description | Example |
|-----------|-------------|---------|
| Subject | The feature or UI element being tested | "Rectangle fill tool" |
| Verb | The action the user performs | "allows click-drag" |
| Expected Result | The observable outcome | "to fill rectangular area with selected tile" |
| Verification Method | How to confirm it works | "Manual: select tile, click-drag rectangle, verify all cells filled" |

## Good vs Bad Criteria Examples

### Bad Criteria (will be REJECTED by Evaluator)

| Criterion | Why It Fails |
|-----------|-------------|
| "The editor works" | No subject specificity, no expected result, not testable |
| "Performance is acceptable" | "Acceptable" is subjective, no measurable threshold |
| "Error handling is implemented" | Describes implementation, not observable behavior |
| "The API is RESTful" | Architectural constraint, not a testable criterion |
| "Code is clean and well-structured" | Code quality is not externally testable |

### Good Criteria (will be ACCEPTED by Evaluator)

| Criterion | Why It Passes |
|-----------|-------------|
| "Rectangle fill tool allows click-drag to fill rectangular area with selected tile" | Specific subject, clear action, observable result |
| "Map loads within 2 seconds for a 100x100 grid" | Measurable threshold, specific scenario |
| "Clicking Delete on selected entity removes it from canvas and entity list" | Two observable outcomes, specific trigger |
| "POST /api/maps returns 201 with map ID when given valid JSON body" | Exact endpoint, status code, response format |
| "Undo reverses the last 10 actions in correct LIFO order" | Specific depth, defined ordering |

## Real Examples from Blog (Sprint 3 — 27 Criteria)

These examples show the level of specificity that made the Evaluator effective:

| Contract Criterion | Evaluator Finding |
|---|---|
| Rectangle fill tool allows click-drag to fill area | FAIL — Tool only places tiles at drag start/end. fillRectangle exists but not triggered on mouseUp |
| User can select and delete entity spawn points | FAIL — Delete handler requires both selection and selectedEntityId, but clicking only sets one |
| User can reorder animation frames via API | FAIL — PUT /frames/reorder route defined after /{frame_id}, FastAPI matches 'reorder' as integer |

### Why These Examples Matter

1. **The criterion was specific enough** that the Evaluator could identify the exact failure mode
2. **The finding references actual code** (fillRectangle, selectedEntityId, route ordering) — showing the Evaluator tested deeply
3. **The failure is actionable** — the Generator knows exactly what to fix without ambiguity

## Criteria Count Guidelines

| Sprint Complexity | Suggested Criteria Count | Rationale |
|-------------------|-------------------------|-----------|
| Small (1-3 features) | 8-12 | Core behaviors + edge cases |
| Medium (4-5 features) | 15-25 | Feature interactions matter |
| Large (6+ features) | 25-40 | Broad behavior and interaction coverage |

Fewer than eight criteria usually leaves behavior gaps. More than 40 suggests splitting the sprint.
