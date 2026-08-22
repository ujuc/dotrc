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

## Functional Usability

Measures whether users can discover and complete workflows, understand validation and navigation, and operate the product across supported viewports. Visual identity, originality, typography, spacing craft, and color harmony belong to `frontend-design-evaluator`.

| Score | Description |
| ----- | ----------- |
| 1-3 | Primary actions are undiscoverable or blocked. Navigation, labels, validation, or viewport behavior prevents task completion. |
| 4-5 | Main actions can be completed, but confusing navigation, feedback, or responsive behavior causes repeated mistakes. |
| 6-7 | Primary workflows are understandable across common viewports with only minor discoverability or feedback issues. |
| 8-10 | Users can predict, discover, complete, and recover from every contracted workflow without functional confusion across supported viewports. |

**Key test**: Can a user unfamiliar with the implementation find the primary action, understand system feedback, recover from errors, and complete the task at each supported viewport?

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
