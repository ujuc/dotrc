# Grading Criteria for Spec Planner Output

Quality evaluation criteria for Planner-generated specs. Use these to self-evaluate before delivering the spec to the user or passing it to the Generator.

## Criteria

### 1. Scope Ambition

**Question**: Is the spec sufficiently ambitious relative to the input prompt?

| Grade | Description |
|-------|-------------|
| Excellent | Spec envisions a full product with 10+ features, explores non-obvious capabilities, and imagines the product at maturity |
| Good | Spec covers 6-9 features with reasonable breadth beyond the obvious interpretation |
| Weak | Spec is a thin wrapper around the input — only 3-5 features that anyone would list |
| Fail | Spec is narrower than the input prompt or adds no new insight |

**Why it matters**: From the blog — "I prompted it to be ambitious about scope." A narrow spec produces a narrow product. The Planner's job is to envision the full possibility space.

**Red flags**:
- Feature count under 6 for a non-trivial product
- No features beyond what was explicitly mentioned in the input
- "MVP" or "minimal" language that constrains scope prematurely

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
| Excellent | Identifies 2-3 specific, high-value AI integration points with clear user benefit; explains what AI adds that traditional approaches cannot |
| Good | Identifies 1-2 AI opportunities that are relevant and clearly described |
| Weak | Mentions AI generically ("could use AI for recommendations") without specificity |
| Fail | No AI consideration at all, or forces AI where it adds no value |

**Why it matters**: AI capabilities are a force multiplier, but only when applied to problems where they genuinely add value. The Planner should consider AI thoughtfully, not reflexively.

**Red flags**:
- "Add AI" as a feature without explaining what it does
- AI used for tasks that are better solved with deterministic logic
- No consideration of AI at all for a product where it clearly adds value

### 4. Implementation Freedom

**Question**: Does the Generator have technical freedom, or is the spec over-constrained?

| Grade | Description |
|-------|-------------|
| Excellent | Spec defines only user-facing behavior and product constraints; the Generator retains all technical choices |
| Good | Behavioral specs with only descriptive existing-code context and no new technical prescriptions |
| Weak | Includes database schemas, API route definitions, or framework-specific patterns |
| Fail | Reads like a technical design document; Generator has no meaningful implementation choices |

**Why it matters**: From the blog — "Constrain deliverables, delegate the path to the Generator." Wrong technical details cascade downstream, forcing the Generator into suboptimal paths.

**Red flags**:
- Database column names or table definitions in the spec
- API endpoint paths with request/response schemas
- Framework-specific component hierarchies
- State management pattern prescriptions
- "Use X library for Y" without alternatives

## Composite Score

For a spec to be considered production-ready:
- All four criteria must score Good or above
- At least two criteria must score Excellent
- No criteria may score Fail

If any criterion scores Weak or below, revise the spec before proceeding to the Generator.

## Self-Evaluation Checklist

Before delivering the spec, verify:

- [ ] Feature count is appropriate for product complexity (typically 8-15)
- [ ] Every feature has at least one user story with a value clause
- [ ] Overview can be understood by a non-technical stakeholder
- [ ] Data model is conceptual, not schema-level
- [ ] AI integration was explicitly considered (even if conclusion is "not applicable")
- [ ] Sprint breakdown follows dependency order, not arbitrary grouping
- [ ] No implementation details leaked into feature descriptions
- [ ] Visual design direction references concrete existing products
- [ ] Exclusions section is not needed (Planner defines what IS in scope; contract defines what is NOT)
