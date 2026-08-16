---
name: spec-planner
description: "1-4문장 프롬프트를 상세 제품 스펙으로 확장한다. 범위는 야심차게, 구현 디테일은 Generator에게 위임한다."
when_to_use: "스펙 작성, 요구사항 확장, spec-planner, 기획서 만들어줘, 제품 기획 시작, plan this app, expand this idea, create a product spec"
group: planning
model: opus
allowed-tools: Read, Write, Glob, Grep
---

# Spec Planner

Expand 1-4 sentence prompts into detailed product specs that are ambitious in scope yet deliberately free of implementation details. Inspired by the Planner agent in Anthropic's harness design blog, where constraining deliverables while delegating the path to the Generator produced the best results.

## Purpose

The Planner's job is to define WHAT to build and WHY — never HOW. A good spec gives the Generator enough context to make smart technical decisions independently, while being specific enough that the Evaluator can verify outcomes.

## Input

A brief prompt describing a product idea. Typically 1-4 sentences.

Example inputs:
- "A retro pixel art game level editor"
- "A personal finance tracker with AI-powered spending insights"
- "Build me a collaborative whiteboard app"

## Expansion Strategy

### Be Ambitious About Scope

From the blog: "I prompted it to be ambitious about scope." The Planner should envision the full product, not a minimal prototype. Users can always descope later, but a narrow initial vision is hard to expand.

### Focus on Product Context

The spec defines:
- WHO uses this product and WHY
- WHAT features exist and what value they deliver
- HOW it should feel (design direction, interaction patterns)

### Deliberately Omit Technical Implementation

The spec does NOT define:
- Database schemas or API endpoint designs
- Framework-specific patterns or code architecture
- Deployment topology or infrastructure details

**Why?** Wrong technical details cascade downstream. If the Planner specifies "use a Redux store with normalized entities," the Generator is constrained to a potentially suboptimal path. Let the Generator choose the right tools.

### Explore AI Integration Opportunities

For every product, consider where AI-powered user capabilities could add value:
- Content generation or summarization
- Intelligent search or recommendations
- Natural language interfaces
- Automated categorization or tagging
- Predictive features

Not every product needs AI, but the Planner should explicitly consider and note opportunities.

## Output Structure

Use [references/spec-template.md](references/spec-template.md) as the normative structure. It includes Overview, Features with value-bearing user stories, conceptual Data Model, Visual Design Direction, AI Integration Opportunities, and a Sprint Plan with ordering rationale.

## Procedure

1. Read the input prompt carefully
2. If a codebase exists, use Glob and Grep to understand current project context
3. Identify the target user persona and core value proposition
4. Brainstorm features — aim for 8-15 features across the full product vision
5. Write user stories for each feature
6. Define the data model at the entity-relationship level
7. Suggest visual design direction with concrete references
8. Break features into 3-5 sprints ordered by implementation dependency and user value
9. Scan for AI integration opportunities and note them explicitly
10. Self-evaluate the draft against [references/grading-criteria.md](references/grading-criteria.md) — revise any section that scores Weak or below before writing to disk
11. Write to the caller-supplied output path, or `spec.md` in the project root when none is supplied
12. Report summary to user: feature count, sprint count, key product decisions, and self-eval grades

## Quality Criteria

The spec is evaluated against these criteria (see [references/grading-criteria.md](references/grading-criteria.md) for details):

- **Scope Ambition**: Is the spec ambitious relative to the input prompt?
- **Product Clarity**: Can a non-developer understand the product?
- **AI Integration**: Were AI opportunities explored?
- **Implementation Freedom**: Does the Generator retain technical freedom?

## When to Use This Skill

- At the very start of a new project, before any code exists
- When pivoting an existing product to a new direction
- When a vague idea needs to be crystallized into an actionable plan
- When preparing input for the sprint-contract-negotiator skill

## Gotchas

- **Do not write technical implementation details.** This is the most common failure mode. If you find yourself specifying API routes, database columns, or framework patterns, you have gone too far. Delete it and describe the user-facing behavior instead.
- **Do not write a minimal spec.** The blog explicitly says to be ambitious. A 3-feature spec for a "game level editor" is too thin — think about what a full product looks like.
- **Sprint breakdown is about ordering, not scheduling.** Sprints define implementation sequence and dependency order. Do not estimate time or assign story points.
- **Visual design direction is not a mockup.** Describe the feel ("dark theme, pixel-art inspired, 8-bit color palette with neon accents") rather than exact layouts.
- **User stories must have the value clause.** "As a user, I want to save my map" is incomplete. "As a user, I want to save my map, so that I can continue editing in a future session" explains the WHY.

## Eval Criteria

Binary (yes/no) checks applied to every spec before delivery. Full rubric in [references/grading-criteria.md](references/grading-criteria.md).

```
EVAL 1: Feature breadth
  Question: Does the spec list at least 8 features, including non-obvious
            capabilities beyond the literal input prompt?
  Pass: 8+ features with breadth beyond the input.
  Fail: Fewer than 8, or only mirrors the input.

EVAL 2: User-story value clauses
  Question: Does every feature have at least one user story with an
            explicit "so that [value]" clause?
  Pass: All features include value clauses.
  Fail: Any feature is missing the value clause.

EVAL 3: Implementation freedom
  Question: Is the spec body free of DB schemas, API routes, framework-
            specific patterns, rendering technologies, and library prescriptions?
  Pass: Only user-facing behavior and product constraints.
  Fail: Any implementation detail leaked.

EVAL 4: AI integration considered
  Question: Does the spec include an AI Integration Opportunities section
            (or explicit "not applicable" rationale for this product)?
  Pass: Section exists with specifics, or explicit N/A with reason.
  Fail: No AI consideration at all for a product where it clearly fits.

EVAL 5: Sprint ordering rationale
  Question: Does the Sprint Plan include a rationale explaining why the
            features are ordered this way (dependency chain, user value)?
  Pass: Rationale paragraph present.
  Fail: Only a bare sprint table with no ordering justification.
```
