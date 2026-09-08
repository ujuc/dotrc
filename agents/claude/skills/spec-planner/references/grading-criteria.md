# Grading Criteria for Spec Planner Output

Use these criteria to self-review an approved architectural `spec.md` before
delivery and handoff to `sprint-contract-negotiator`. Spike and bounded requests
do not need a managed spec. Apply the classification and approval rules in
[the skill](../SKILL.md); this rubric does not expand approved scope.

## Criteria

### 1. Scope Fit

**Question**: Does the spec cover the complete approved product direction?

| Grade | Description |
|-------|-------------|
| Excellent | Spec covers the complete approved direction and explains the capabilities and dependencies needed for its user value |
| Good | Spec covers the approved core and its important supporting capabilities without filler |
| Weak | Spec is a thin wrapper around the input or omits capabilities needed for the stated product outcome |
| Fail | Spec omits approved outcomes or adds unapproved scope |

**Why it matters**: Missing supporting capabilities leaves product behavior
unclear; count-driven additions expand scope without approval.

**Red flags**:
- Capability breadth is unexplained or mismatched to the approved direction
- Supporting capabilities needed for an approved outcome are missing
- Broadening or narrowing the approved direction without a product reason

### 2. Product Clarity

**Question**: Can a non-developer understand the product from this spec?

| Grade | Description |
|-------|-------------|
| Excellent | A product manager, designer, or end user could read this and understand exactly what the product does, who it is for, and why it matters |
| Good | Mostly clear with occasional jargon; a developer could understand it fully, a non-developer with minor confusion |
| Weak | Heavy technical language; reads like an architecture document rather than a product spec |
| Fail | Incomprehensible without technical background; focuses on implementation rather than user value |

**Why it matters**: The spec is a communication document. If it only makes sense to engineers, it has failed its purpose as a product definition.

**Red flags**:
- User stories that describe system behavior instead of user goals
- Overview section that leads with technology choices
- Features described in terms of components rather than user capabilities

### 3. AI Integration

**Question**: Were AI integration opportunities explored?

| Grade | Description |
|-------|-------------|
| Excellent | Explains specific user value and tradeoffs for relevant AI opportunities, or gives a concrete reason AI is not applicable |
| Good | Describes relevant AI user benefit, or states a reasonable non-applicability rationale |
| Weak | Mentions AI generically ("could use AI for recommendations") without specificity |
| Fail | No AI consideration at all, or forces AI where it adds no value |

**Why it matters**: AI capabilities are a force multiplier, but only when applied to problems where they genuinely add value. The Planner should consider AI thoughtfully, not reflexively.

**Red flags**:
- "Add AI" as a feature without explaining what it does
- AI used for tasks that are better solved with deterministic logic
- No consideration of AI at all for a product where it clearly adds value

### 4. Implementation Freedom

**Question**: Do planning and implementation retain technical freedom, or is the spec over-constrained?

| Grade | Description |
|-------|-------------|
| Excellent | Spec defines user-facing behavior and product constraints; planning and implementation retain technical choices within repository and approved product constraints |
| Good | Behavioral specs with only descriptive existing-code context and no new technical prescriptions |
| Weak | Includes database schemas, API route definitions, or framework-specific patterns |
| Fail | Reads like a technical design document; prescribes implementation without a product reason |

**Why it matters**: Unsupported technical prescriptions constrain downstream
planning before repository evidence and implementation tradeoffs are examined.

**Red flags**:
- Database column names or table definitions in the spec
- API endpoint paths with request/response schemas
- Framework-specific component hierarchies
- State management pattern prescriptions
- "Use X library for Y" without alternatives

## Using the Grades

Grades are diagnostic self-review labels, not an additional acceptance gate.
Use weak areas to identify concrete omissions or contradictions within the
approved direction; do not add scope merely to improve a grade. Delivery and
handoff follow the approval and self-review requirements in
[the skill](../SKILL.md), without a composite score or required grade count.

## Self-Evaluation Checklist

Use these prompts to inspect applicable sections under the skill's self-review
requirements; they do not require adding irrelevant template sections:

- [ ] Capability breadth matches the approved product complexity without count-driven filler
- [ ] Every feature has at least one user story with a value clause
- [ ] Overview can be understood by a non-technical stakeholder
- [ ] Data model is conceptual, not schema-level
- [ ] AI integration was explicitly considered (even if conclusion is "not applicable")
- [ ] Dependency/value grouping follows real ordering constraints, not arbitrary stages
- [ ] No implementation details leaked into feature descriptions
- [ ] Visual design direction is concrete when relevant to the product
- [ ] Approved constraints and exclusions are explicit and consistent with scope
