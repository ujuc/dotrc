# Worked Example — Two Negotiation Rounds

This is an end-to-end two-round example for a small sprint. It anchors the format rules from `file-format.md` in something concrete.

## Input Spec

> "Add a tile-based map editor to the level designer. It needs a fill tool and a way to delete entities."

## `.sprint/contract-draft-1.md` (Generator)

```markdown
# Contract Draft 1 — Tile Editor v1

## Sprint Goal
Ship the level designer's first usable tile editor with fill and delete primitives.

## Implementation Scope
1. Rectangle fill tool — paint a rectangular area with the selected tile
2. Entity delete — remove a selected entity from the canvas
3. Tile palette — choose the active tile

## Verification Criteria

| # | Criterion | Expected Behavior | Test Method |
|---|-----------|-------------------|-------------|
| 1 | Fill tool works correctly | Tiles get painted | Try it in the editor |
| 2 | Delete removes entities | Entities disappear | Click delete |
| 3 | Tile palette shows every tile from an imported 12-tile fixture | Twelve distinct selectable tiles are visible | Import the fixture and count the palette entries |
| 4 | Performance is acceptable | Fast enough | Try a big map |
| 5 | Selecting a palette tile marks it as active | One tile has a visible selected state | Select two tiles in sequence and observe the indicator move |
| 6 | Reverse-direction fill paints the normalized rectangle | Dragging bottom-right to top-left fills the same cells as the opposite drag | Perform both drags on an empty 5×5 area and compare the painted cells |
| 7 | Fill at a map edge changes only in-bounds cells | No tile appears outside the map and no error is shown | Drag a fill rectangle across the top-left boundary |
| 8 | Delete with no selected entity leaves the map unchanged | No entity disappears and the editor remains usable | Clear selection, press Delete, then select another entity |

## Exclusions
- Multi-layer editing
- Undo/redo history

## Changes from Previous Draft
Initial draft.
```

## `.sprint/contract-review-1.md` (Evaluator)

```markdown
# Contract Review 1 — Tile Editor v1

Reviewed: contract-draft-1.md

## Verdicts

| # | Verdict | Reason |
|---|---------|--------|
| 1 | REJECT | Missing observable result and verification method: "works correctly" and "Try it" are not externally testable. Specify the input gesture and expected canvas state. |
| 2 | REJECT | Missing subject specificity and observable result: identify the selected entity, both affected views, and the confirmation step. |
| 3 | ACCEPT | Fixture, visible count, and verification method are explicit. |
| 4 | REJECT | Missing observable threshold and verification method: define a map size and latency. |
| 5 | ACCEPT | Selection action, visible result, and verification sequence are explicit. |
| 6 | ACCEPT | Direction, normalized result, and comparison method are explicit. |
| 7 | ACCEPT | Boundary action and externally visible result are explicit. |
| 8 | ACCEPT | Empty-selection precondition, invariant result, and follow-up check are explicit. |

## Summary
- Accepted: 5
- Rejected: 3
- Escalation triggered: no
```

## `.sprint/contract-draft-2.md` (Generator, addressing review)

```markdown
# Contract Draft 2 — Tile Editor v1

## Sprint Goal
Ship the level designer's first usable tile editor with fill and delete primitives.

## Implementation Scope
1. Rectangle fill tool — paint a rectangular area with the selected tile
2. Entity delete — remove a selected entity from the canvas
3. Tile palette — choose the active tile

## Verification Criteria

| # | Criterion | Expected Behavior | Test Method |
|---|-----------|-------------------|-------------|
| 1 | Rectangle fill tool allows click-drag to paint a rectangular region with the selected tile | Every cell inside the dragged rectangle shows the selected tile after mouseUp | Select a tile, drag from (1,1) to (5,5), and confirm 25 cells changed |
| 2 | Clicking the trash icon on a selected entity removes it from the canvas and entity list | The selected entity vanishes from both views and selection clears | Select entity E, click trash, and confirm E is absent from both views |
| 3 | Tile palette shows every tile from an imported 12-tile fixture | Twelve distinct selectable tiles are visible | Import the fixture and count the palette entries |
| 4 | A 100×100 map becomes interactive within 500 ms after Open Map | The first canvas interaction is accepted within 500 ms | Open the 100×100 fixture and compare open/input timestamps |
| 5 | Selecting a palette tile marks it as active | One tile has a visible selected state | Select two tiles in sequence and observe the indicator move |
| 6 | Reverse-direction fill paints the normalized rectangle | Dragging bottom-right to top-left fills the same cells as the opposite drag | Perform both drags on an empty 5×5 area and compare the painted cells |
| 7 | Fill at a map edge changes only in-bounds cells | No tile appears outside the map and no error is shown | Drag a fill rectangle across the top-left boundary |
| 8 | Delete with no selected entity leaves the map unchanged | No entity disappears and the editor remains usable | Clear selection, press Delete, then select another entity |

## Exclusions
- Multi-layer editing
- Undo/redo history

## Changes from Previous Draft
- #1: rewrote per review-1#1 — added gesture, observable result, and exact cell count
- #2: rewrote per review-1#2 — named the trigger, affected views, and selection-clear result
- #4: rewrote per review-1#4 — added a 500 ms threshold, fixture size, and timestamp method
```

## `.sprint/contract-review-2.md` (Evaluator)

```markdown
# Contract Review 2 — Tile Editor v1

Reviewed: contract-draft-2.md

## Verdicts

| # | Verdict | Reason |
|---|---------|--------|
| 1 | ACCEPT |  |
| 2 | ACCEPT |  |
| 3 | ACCEPT |  |
| 4 | ACCEPT |  |
| 5 | ACCEPT |  |
| 6 | ACCEPT |  |
| 7 | ACCEPT |  |
| 8 | ACCEPT |  |

## Summary
- Accepted: 8
- Rejected: 0
- Escalation triggered: no
```

## `.sprint/contract.md` (final)

```markdown
# Sprint Contract — Tile Editor v1

## Sprint Goal
Ship the level designer's first usable tile editor with fill and delete primitives.

## Implementation Scope
1. Rectangle fill tool — paint a rectangular area with the selected tile
2. Entity delete — remove a selected entity from the canvas
3. Tile palette — choose the active tile

## Verification Criteria

| # | Criterion | Expected Behavior | Test Method |
|---|-----------|-------------------|-------------|
| 1 | Rectangle fill tool allows click-drag to paint a rectangular region with the selected tile | Every cell inside the dragged rectangle shows the selected tile after mouseUp | Select a tile, drag from (1,1) to (5,5), and confirm 25 cells changed |
| 2 | Clicking the trash icon on a selected entity removes it from the canvas and entity list | The selected entity vanishes from both views and selection clears | Select entity E, click trash, and confirm E is absent from both views |
| 3 | Tile palette shows every tile from an imported 12-tile fixture | Twelve distinct selectable tiles are visible | Import the fixture and count the palette entries |
| 4 | A 100×100 map becomes interactive within 500 ms after Open Map | The first canvas interaction is accepted within 500 ms | Open the 100×100 fixture and compare open/input timestamps |
| 5 | Selecting a palette tile marks it as active | One tile has a visible selected state | Select two tiles in sequence and observe the indicator move |
| 6 | Reverse-direction fill paints the normalized rectangle | Dragging bottom-right to top-left fills the same cells as the opposite drag | Perform both drags on an empty 5×5 area and compare the painted cells |
| 7 | Fill at a map edge changes only in-bounds cells | No tile appears outside the map and no error is shown | Drag a fill rectangle across the top-left boundary |
| 8 | Delete with no selected entity leaves the map unchanged | No entity disappears and the editor remains usable | Clear selection, press Delete, then select another entity |

## Exclusions
- Multi-layer editing
- Undo/redo history

## Negotiation History
- Draft 1 (2026-04-18): 8 proposed, 5 accepted, 3 rejected
- Draft 2 (2026-04-18): 3 revised, 8 accepted, 0 rejected
- Final (2026-04-18): 8 criteria agreed in 2 rounds
```

## What This Example Illustrates

1. Reject reasons name a missing part of the four-part rule.
2. Changes cite stable review and criterion IDs.
3. All final criteria are externally testable.
4. The third round is skipped because round 2 passes.
