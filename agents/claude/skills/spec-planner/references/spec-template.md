# Spec Template

Based on the "RetroForge" spec structure from Anthropic's harness design blog.

## Standard Format

```markdown
# [Product Name] — [Tagline]

## Overview
[Product vision: 2-3 paragraphs.
- Paragraph 1: What is this product and who is it for?
- Paragraph 2: What core problem does it solve? What is the value proposition?
- Paragraph 3: What makes this product unique or worth building?]

## Features

### 1. [Feature Name]
[Why users need this: 1-2 sentences explaining the user value, not the implementation]

User Stories:
- As a [user type], I want to [action], so that [value]
- As a [user type], I want to [action], so that [value]

### 2. [Feature Name]
[Why users need this]

User Stories:
- As a [user type], I want to [action], so that [value]

### 3. [Feature Name]
...

[Continue for all features — aim for 8-15 total]

## Data Model

### Core Entities
- **[Entity A]**: [What it represents, key attributes conceptually]
- **[Entity B]**: [What it represents]

### Relationships
- [Entity A] has many [Entity B]
- [Entity C] belongs to [Entity A] and references [Entity B]

Note: This is a conceptual model. The Generator decides schema details.

## Visual Design Direction

### Design Language
[Overall aesthetic: modern/retro/minimal/playful/professional]

### Color Direction
[Primary mood, contrast level, dark/light preference]
Example: "Dark base with vibrant accent colors — think Figma's dark mode meets pixel art palettes"

### Typography Direction
[Font personality: monospace/rounded/sharp/handwritten]
Example: "Monospace for code-adjacent UI, rounded sans-serif for labels and navigation"

### Reference Apps
[2-3 existing products that capture aspects of the desired feel]
Example: "Aseprite for the tool palette density, Figma for the collaboration UX, Notion for the sidebar navigation"

## AI Integration Opportunities
- [Opportunity 1]: [How AI adds value to this feature]
- [Opportunity 2]: [How AI adds value to this feature]

## Sprint Plan

| Sprint | Features | Focus |
|--------|----------|-------|
| 1 | [Feature 1, Feature 2] | Core foundation — minimum viable interaction loop |
| 2 | [Feature 3, Feature 4, Feature 5] | Primary user workflows |
| 3 | [Feature 6, Feature 7, Feature 8] | Power features and polish |
| 4 | [Feature 9, Feature 10] | AI integration and advanced features |
| 5 | [Remaining features] | Edge cases, performance, and launch readiness |

### Sprint Ordering Rationale
[1-2 sentences explaining why features are ordered this way — usually based on dependency chains and user value delivery]
```

## Example: Filling the Template

For the blog's "RetroForge" tile map editor, the spec included:

**Overview excerpt**: A browser-based retro game level editor for creating tile-based maps, placing entity spawn points, defining animations, and exporting game-ready data.

**Features included** (15 total across the full product):
1. Tile palette with selectable tiles
2. Interactive map grid with click-to-place
3. Rectangle fill tool for bulk tile placement
4. Entity spawn point placement and management
5. Animation frame editor
6. Layer management (foreground/background)
7. Map save/load with file export
8. Undo/redo system
9. Grid zoom and pan
10. Tile sheet import
11. Map metadata editor
12. Collision layer painting
13. Minimap navigation
14. Keyboard shortcuts
15. Real-time animation preview

**Sprint breakdown**:
- Sprint 1: Features 1-4 (core editing loop)
- Sprint 2: Features 5-8 (creation workflows)
- Sprint 3: Features 9-12 (power user features)
- Sprint 4: Features 13-15 (polish and preview)

Note how the spec describes features at the product level without prescribing rendering technology, state libraries, or file schemas.
