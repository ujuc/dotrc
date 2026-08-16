# Evaluation Criteria — Scoring Rubric

Each criterion is scored on a 1-10 scale. Scores are absolute, not relative to project maturity.

## Product Depth

Measures whether features have real interactive depth or are display-only stubs.

| Score | Description |
| ----- | ----------- |
| 1-3 | Core features are non-functional or display-only. Buttons exist but do nothing. Data is hardcoded. Users cannot complete any meaningful action. |
| 4-5 | Basic features work but significant gaps remain. Some CRUD operations function while others are stubs. Data persists inconsistently. |
| 6-7 | Most features have interactive depth. Users can complete primary workflows. Minor features may still be stubs but are clearly marked as such. |
| 8-10 | All advertised features are fully interactive. State changes persist correctly. Edge cases are handled. No stubs remain. |

**Key test**: Can a user complete a real task end-to-end, or does the feature only look like it works?

## Functionality

Measures whether core workflows execute correctly including edge cases.

| Score | Description |
| ----- | ----------- |
| 1-3 | Core workflows are broken. Crashes, data loss, or incorrect results on the happy path. Application may not start reliably. |
| 4-5 | Happy path works for most features but edge cases break. Error handling is absent or incorrect. Some data corruption on unusual inputs. |
| 6-7 | Happy path and common edge cases work. Error messages are present. Rare edge cases may fail gracefully. No data corruption. |
| 8-10 | Production quality. All workflows handle valid, invalid, and edge-case inputs. Errors are informative. Recovery is graceful. Concurrent usage works. |

**Key test**: What happens with empty inputs, extremely long strings, special characters, and rapid repeated submissions?

## Visual Design

Measures layout, spacing, color harmony, responsiveness, and visual completeness.

| Score | Description |
| ----- | ----------- |
| 1-3 | Broken layout. Overlapping elements, invisible text, missing styles. Unusable on any viewport size. |
| 4-5 | Layout functions but feels unfinished. Inconsistent spacing, misaligned elements, poor color choices. Responsive breakpoints missing or broken. |
| 6-7 | Clean, consistent layout. Good spacing and color harmony. Responsive behavior works for common viewport sizes. Minor visual polish issues. |
| 8-10 | Visually polished. Consistent design language. Smooth transitions. Works perfectly across all viewport sizes. Attention to micro-details (loading states, empty states, hover effects). |

**Key test**: Resize the browser to mobile, tablet, and desktop widths. Do all elements remain usable?

## Code Quality

Measures runtime behavior: console errors, API responses, error handling.

| Score | Description |
| ----- | ----------- |
| 1-3 | Console errors on every page load. API calls return 500s. Unhandled promise rejections. Memory leaks visible in short sessions. |
| 4-5 | Occasional console warnings. Some API error responses lack proper status codes. Error boundaries exist but show generic messages. |
| 6-7 | No console errors in normal usage. API responses use correct status codes. Error handling covers common failure modes. Minor warnings on edge cases. |
| 8-10 | Zero console errors or warnings. All API responses are well-structured with appropriate status codes. Error handling is comprehensive. Network failures degrade gracefully. |

**Key test**: Open the browser console before navigating. Are there errors? Check the Network tab for failed requests.

---

## Feedback Writing Patterns

### Good Feedback (Specific, Actionable)

> FAIL -- Rectangle fill tool only places tiles at drag start/end points instead of filling the region. `fillRectangle` function exists in TileEditor.tsx:245 but is not triggered properly on mouseUp event. Expected: dragging a rectangle fills all tiles within the selection. Actual: only first and last tile are placed.

> FAIL -- Login form accepts empty password and returns 200 OK. `validateCredentials` in auth.controller.ts:89 does not check for empty string. Expected: 400 Bad Request with validation error. Actual: 200 OK with null user object.

> FAIL -- Dashboard chart overlaps sidebar at viewport width below 768px. The chart container in Dashboard.tsx uses fixed width (800px) instead of responsive units. Expected: chart reflows within available space. Actual: horizontal scroll appears and sidebar is partially hidden.

### Bad Feedback (Vague, Unactionable)

> "The fill tool has some issues and could be improved."

> "Login could use better validation."

> "The responsive design needs work."

These are useless to a Generator. Every piece of feedback must answer: what is broken, where is it broken, what should happen instead, and what actually happens.
