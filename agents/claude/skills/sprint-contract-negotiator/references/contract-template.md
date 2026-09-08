# Sprint Contract Criteria Guide

Use this guide when drafting or repairing acceptance criteria. The canonical
contract template and audit-file formats live in
[file-format.md](file-format.md); do not maintain a second format here. For a
complete draft → review → final example, read
[negotiation-example.md](negotiation-example.md).

## Criteria Writing Rule

Every criterion MUST follow this pattern:

**Subject + Verb + Observable Result + Verification Method**

| Component | Description | Example |
|-----------|-------------|---------|
| Subject | The feature or UI element being tested | "Rectangle fill tool" |
| Verb | The action the user performs | "allows click-drag" |
| Observable Result | The observable outcome | "to fill rectangular area with selected tile" |
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

### Complete Criteria Examples

| Criterion | Test Method |
|-----------|-------------|
| Rectangle fill tool allows click-drag to fill a rectangular area with the selected tile | Select a tile, drag from (1,1) to (5,5), and verify all 25 cells contain that tile |
| A 100×100 map becomes interactive within 2 seconds after Open Map | Open the 100×100 fixture and compare the Open Map and first accepted interaction timestamps |
| Clicking Delete on a selected entity removes it from canvas and entity list | Select fixture entity E, click Delete, and confirm E is absent from both views |
| POST /api/maps returns 201 with a map ID for a valid documented request | Submit the valid request fixture and inspect response status and map ID; use this only when the endpoint is already approved scope |
| Undo reverses the last 10 actions in LIFO order | Perform 10 distinct fixture actions, invoke Undo 10 times, and compare every intermediate state with the saved prior state |

These illustrate the four-part quality rule. The Evaluator still checks each
criterion against the approved scope and its actual verification method.

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

## Coverage Guidance

Choose criterion count from actual sprint complexity, never a fixed minimum.
Cover approved core behavior, relevant edge cases, and feature interactions.
Do not invent behavior to fill a quota. If the sprint boundary is unclear,
follow the escalation rule in [the skill](../SKILL.md) before drafting more
criteria.
