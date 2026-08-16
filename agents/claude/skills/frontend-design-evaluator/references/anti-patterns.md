# AI Slop Anti-Pattern Catalog

These patterns indicate AI-generated or template-derived design. When 3 or more are detected in a single page, cap the Originality score at 4.

## Visual Anti-Patterns

### 1. Purple/Blue Gradient + White Card Combination

The signature AI-generated color scheme. A purple-to-blue gradient background with floating white cards on top. Immediately recognizable as "I asked an AI to make this."

**Detection**: Check the hero section and card containers. If the primary gradient uses colors in the `#6366f1` to `#3b82f6` range with white (`#ffffff`) card backgrounds, flag it.

### 2. Excessive border-radius and Shadow

Every element has `border-radius: 12px+` and `box-shadow` with large blur values. Nothing has sharp edges. The result is a soft, blobby aesthetic that lacks visual tension.

**Detection**: Inspect card and button elements. If border-radius exceeds 12px on non-avatar elements and shadows have blur > 20px, flag it.

### 3. Hero Section + 3-Column Feature Grid Formula

Page structure follows: hero with large heading + subheading + CTA button, then a 3-column grid of feature cards with icons. This is the most common AI-generated landing page layout.

**Detection**: If the page follows hero -> 3-col grid -> testimonials -> CTA footer, and none of these sections break the mold, flag it.

### 4. Meaningless Gradient Text

Headings with CSS `background-clip: text` gradient fills that serve no semantic purpose. The gradient does not reinforce meaning; it exists purely as decoration.

**Detection**: Check if any heading text uses gradient fills. If the gradient does not relate to brand colors or serve an informational purpose, flag it.

### 5. Repetitive Card Grids with Identical Spacing

Cards that are visually identical except for swapped icon/title/description. No variation in card size, emphasis, or layout. The grid is perfectly symmetrical with no hierarchy.

**Detection**: If a card grid has 3+ cards with identical dimensions, padding, and visual weight, with no card emphasized over others, flag it.

### 6. Stock Illustration Style SVG Icon Sets

Outline-style SVG icons from a single icon library (Heroicons, Lucide, Phosphor) used without any customization. Icons are decorative, not informational.

**Detection**: If all icons share the same stroke width, style, and are clearly from one library with no custom modifications, flag it.

### 7. Generic CTA Buttons

"Get Started," "Learn More," "Sign Up Free," "Start Your Journey" buttons that could belong to any product. No personality in copy or visual treatment.

**Detection**: Check all CTA buttons. If the text is generic and could be swapped between any two products without anyone noticing, flag it.

### 8. Overly Symmetrical Layouts

Every section is perfectly centered with equal margins on both sides. No asymmetry, no visual tension, no breaking of the grid. The layout feels like a centered Word document.

**Detection**: If every section uses `text-align: center` or `mx-auto` with no sections breaking to left/right alignment or asymmetric layouts, flag it.

### 9. Default Tailwind Color Palette

Using Tailwind's default color scale (blue-500, gray-100, etc.) without any custom palette. The colors are recognizable to any developer who has used Tailwind.

**Detection**: Inspect computed color values. If they match Tailwind's default palette exactly (e.g., `#3b82f6` for blue-500, `#f3f4f6` for gray-100), flag it.

### 10. Inter/Poppins Font Pairing with No Typographic Personality

Inter or Poppins as the sole font family, used at default weights (400, 600, 700) with no typographic system. These are excellent fonts, but using them with zero customization signals "I did not think about typography."

**Detection**: Check the font stack. If it is Inter or Poppins only, with no secondary typeface, no custom font features (`font-feature-settings`), and no unusual weight combinations, flag it.

## Structural Anti-Patterns

### Layout Formula Detection

Count how many of these structural blocks appear in order:

1. Navbar with logo left, links right
2. Hero section with large text + CTA
3. Social proof bar (logos or testimonials)
4. 3-column feature grid
5. "How it works" numbered steps
6. Pricing table (3 tiers)
7. FAQ accordion
8. Footer with newsletter signup

If 5 or more appear in this order, the page follows the "AI landing page template." Flag it regardless of visual quality.

### Content Pattern Detection

- Headings that follow "Verb Your Noun" pattern ("Transform Your Workflow," "Elevate Your Experience")
- Descriptions that start with "Our platform..." or "We help you..."
- Feature descriptions that all follow the same sentence structure
- Testimonials with generic names and stock-photo-style avatars

## Severity Levels

| Anti-Patterns Found | Impact |
| --- | --- |
| 0-1 | No impact. Individual patterns are not inherently bad. |
| 2 | Warning in report. Suggest alternatives for detected patterns. |
| 3+ | Cap Originality at 4. The design is template-derived regardless of execution quality. |
| 5+ | Cap Originality at 2. Strong recommendation to start from scratch with a custom design direction. |
