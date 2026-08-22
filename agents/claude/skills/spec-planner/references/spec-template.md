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

[Continue for every capability needed by the approved product direction. Do not add filler to meet a fixed count.]

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

## Dependency & Value Ordering

| Stage | Capabilities | Dependency / user value rationale |
|-------|--------------|-----------------------------------|
| 1 | [Capability group] | [Why this must come first] |
| 2 | [Capability group] | [What it consumes and enables] |
| ... | [Only as many stages as the scope needs] | [Ordering rationale] |

### Ordering Rationale
[Explain the dependency chain and how each stage creates user value. This is not a schedule or implementation plan.]
```

## Example: Filling the Template

For the blog's "RetroForge" tile map editor, the spec included:

**Overview excerpt**: A browser-based retro game level editor for creating tile-based maps, placing entity spawn points, defining animations, and exporting game-ready data.

**Capabilities included** (an example of a broad product vision, not a required count):
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

**Example dependency grouping**:
- Sprint 1: Features 1-4 (core editing loop)
- Sprint 2: Features 5-8 (creation workflows)
- Sprint 3: Features 9-12 (power user features)
- Sprint 4: Features 13-15 (polish and preview)

Note how the example's size follows its approved product direction. Smaller architectural products can have fewer capabilities; scope fit and clarity matter more than count. The spec remains at product level without prescribing rendering technology, state libraries, or file schemas.
