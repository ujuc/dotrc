# Chrome Integration Patterns for QA Evaluation

Chrome integration is a built-in Claude Code feature that uses the Claude in Chrome extension. It is NOT Playwright MCP. Do not confuse the two.

## Basics

### Navigation

Navigate to a URL by instructing Chrome to open it. The Chrome integration provides tools to:

- Open URLs in the active tab
- Take screenshots of the current page
- Click elements by their text content or position
- Fill form fields
- Read page content and DOM state

### Authentication State

Chrome shares the user's browser session. If the user is logged into the application, the evaluator will also be logged in. This is useful for testing authenticated features without needing credentials.

## Exploration Strategy

### Phase 1: Happy Path (Main Workflows)

1. Navigate to the app's entry point (usually `/` or `/dashboard`).
2. Identify primary navigation elements (nav bar, sidebar, tabs).
3. Walk through each main workflow end-to-end:
   - For a todo app: create item, view list, edit item, complete item, delete item.
   - For an e-commerce app: browse products, add to cart, checkout.
   - For a dashboard: view data, apply filters, export.
4. Screenshot each major state transition.

### Phase 2: Input Edge Cases

For every form or input field discovered in Phase 1:

- **Empty submission**: Submit with no input.
- **Minimum input**: Single character.
- **Maximum input**: 10,000+ characters (paste a long string).
- **Special characters**: `<script>alert(1)</script>`, `'; DROP TABLE users;--`, emoji, Unicode.
- **Number fields**: Negative numbers, zero, extremely large numbers, decimal precision.
- **Date fields**: Past dates, far future dates, invalid formats.

### Phase 3: Error States

- Navigate to non-existent routes (e.g., `/this-does-not-exist`).
- Click back/forward rapidly.
- Double-click submit buttons.
- Open the same resource in two tabs and modify it in both.
- If there is a loading state, screenshot it (it often reveals layout issues).

### Phase 4: Visual Inspection

- Resize viewport to 320px wide (mobile).
- Resize viewport to 768px wide (tablet).
- Resize viewport to 1440px wide (desktop).
- Check for horizontal scrollbars at each size.
- Verify text remains readable and buttons remain clickable.
- Look for overlapping elements, clipped text, broken images.

## Screenshot Best Practices

- **Before and after**: Capture the state before an action and after.
- **Annotate context**: When referencing a screenshot in the report, describe what the screenshot shows.
- **Capture console**: If the browser console shows errors, screenshot it.
- **Full page vs viewport**: For layout issues, full-page screenshots are more useful.

## API Endpoint Testing with curl

For backend verification, use `curl` directly:

```bash
# Check health endpoint
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health

# Test POST with valid data
curl -s -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name": "test item"}' | head -c 500

# Test POST with empty body
curl -s -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{}' -w "\n%{http_code}"

# Test with invalid JSON
curl -s -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d 'not json' -w "\n%{http_code}"

# Check response headers
curl -sI http://localhost:3000/api/items
```

### What to Verify in API Responses

- Correct HTTP status codes (201 for creation, 400 for bad input, 404 for missing resources).
- Consistent response body structure (always has `data`, `error`, or both).
- Proper Content-Type headers.
- No stack traces or internal details leaked in error responses.

## GIF Recording for Bug Documentation

When a bug involves interaction sequence or animation issues, a GIF recording provides clearer evidence than static screenshots:

1. Use Chrome's built-in screen recording if available.
2. Record the sequence of actions leading to the bug.
3. Reference the recording in the evaluation report.

GIF evidence is especially valuable for:
- Race conditions visible in UI
- Animation glitches
- State inconsistencies during rapid interaction
- Hover/focus state bugs that disappear on screenshot
