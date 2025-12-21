# Interaction Modes

<meta>
Document: interaction-modes.md
Role: Interaction Controller
Priority: Medium
Applies To: All user interactions and responses
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document provides commands to control response style, reasoning approach, role perspective, and quality verification when communicating with Claude. These commands modify HOW Claude responds, but do NOT override WHAT rules Claude must follow (see system-rules.md).
</context>

<your_responsibility>
As Interaction Controller, you must:
- **Apply mode modifiers**: Adjust response style according to active commands
- **Respect priority**: Never let modes override system rules
- **Handle conflicts**: Resolve conflicting modes appropriately
- **Maintain clarity**: Ensure modes enhance, not obscure, communication
- **Be flexible**: Adapt modes to context and user needs
</your_responsibility>

**Commands to control interaction style with Claude**

## 💬 Help System

### `/help` - Show all available commands
Display complete list of interaction mode commands organized by category

### `/help [category]` - Show category-specific commands
Available categories:
- `/help format` - Output format and style commands
- `/help reasoning` - Reasoning and analysis commands
- `/help role` - Role and perspective commands
- `/help quality` - Quality and verification commands

### Examples
```
/help                    # Show all commands
/help format            # Show only format commands
/help reasoning         # Show only reasoning commands
```

---

## 🚀 Quick Start

### First Time Users

**Don't know where to start?**
```
/help
```

**Need a quick answer?**
```
/briefly [question]
```

**Want simple explanation?**
```
/eli5 [topic]
```

**Need deep analysis?**
```
/deep [topic]
```

### Common Combinations

**Quick code:**
```
/briefly /code [request]
```

**Beginner explanation:**
```
/eli5 /tone friendly [concept]
```

**Decision making:**
```
/compare /swot /multi-perspective [topic]
```

**Document summary:**
```
/tldr [long text]
```

**Action plan:**
```
/step-by-step /checklist [task]
```

---

## Usage

<usage_rules>
- Include `/command` in your message (lowercase with hyphens)
- Multiple commands can be combined: `/briefly /step-by-step explain the function`
- **IMPORTANT**: [system-rules.md](../system-rules.md) ALWAYS takes priority over interaction modes
- Modes control response STYLE, not core BEHAVIOR
- When modes conflict with rules, rules win
</usage_rules>

---

## 📤 Output Format & Style

Commands to control output format and presentation style

| Command | Purpose | Use Case |
|---------|---------|----------|
| `/eli5` | Explain as if to a 5-year-old | Understanding complex concepts for the first time |
| `/tldr` | Summarize long text in a few lines | Quick review of documents, logs, long explanations |
| `/exec-summary` | Give a short executive-style summary | Decision-making with key information only |
| `/briefly` | Reply in one or two concise sentences | Quick checks or Yes/No answers |
| `/checklist` | Turn the answer into a checklist of actions | Task planning, deployment procedures, verification items |
| `/format-as` | Enforce a specific format (table, JSON, YAML, etc.) | Data structuring, API response examples |
| `/begin-with` | Force the answer to start with given text | Template writing, consistent opening patterns |
| `/end-with` | Force the answer to end with given text | Signatures, template closings |
| `/schema` | Generate a structured outline or data model | DB schema, API specs, class structure design |
| `/rewrite-as` | Rephrase in a requested style | Changing document tone, code refactoring |

### Examples

<examples>
<example command="/briefly">
<input>/briefly What does this function do?</input>
<output>Validates user authentication token and checks expiration.</output>
<note>Single sentence, direct answer</note>
</example>

<example command="/format-as">
<input>/format-as JSON Show API error response example</input>
<output>{"error": {"code": 401, "message": "Unauthorized"}}</output>
<note>Structured format as requested</note>
</example>

<example command="/checklist">
<input>/checklist Pre-deployment checks</input>
<output>
- [ ] Verify tests pass
- [ ] Validate environment variables
- [ ] Check database migrations
- [ ] Review security settings
</output>
<note>Actionable items in checkbox format</note>
</example>
</examples>

---

## 🧠 Reasoning & Analysis

Commands to control reasoning process and analysis approach

| Command | Purpose | Use Case |
|---------|---------|----------|
| `/step-by-step` | Lay out reasoning steps in order | Complex problem solving, algorithm explanation |
| `/chain-of-thought` | Request a brief outline of reasoning steps | Understanding thought process |
| `/first-principles` | Rebuild the answer from basics | Fundamental understanding or new approach needed |
| `/compare` | Place two or more items side by side | Technology selection, library comparison, architecture decisions |
| `/multi-perspective` | Show several points of view | Decisions involving diverse stakeholders |
| `/parallel-lenses` | Examine the topic from several angles at once | Comprehensive analysis, risk assessment |
| `/swot` | Give strengths, weaknesses, opportunities, and threats | Technology adoption review, project evaluation |
| `/pitfalls` | List likely traps, errors, and edge cases | Code review, security review, stability checks |
| `/context-stack` | Keep multiple layers of context active | Understanding complex systems, legacy code analysis |
| `/deliberate-thinking` | Slow down and reason carefully | Important decisions, complex bug analysis |
| `/reflective-mode` | Briefly reflect on and refine the answer | Answer quality improvement, self-verification |
| `/systematic-bias-check` | Point out possible biases and gaps | Fairness review, diversity considerations |

### Examples

<examples>
<example command="/step-by-step">
<input>/step-by-step Analyze why this bug occurs</input>
<output>
1. Function called without null check
2. Attempts to access undefined property
3. TypeError thrown
4. Stack trace halts execution
</output>
<note>Sequential reasoning with numbered steps</note>
</example>

<example command="/compare">
<input>/compare React vs Vue for this project</input>
<output>
| Criteria | React | Vue |
|----------|-------|-----|
| Learning curve | Medium | Low |
| Ecosystem | Large | Growing |
| Performance | Excellent | Excellent |
</output>
<note>Side-by-side comparison table</note>
</example>

<example command="/pitfalls">
<input>/pitfalls Security concerns in this auth logic</input>
<output>
- Missing token expiration check
- CSRF attack vulnerability
- Sensitive info in logs
- No rate limiting on login attempts
</output>
<note>List of potential issues to watch for</note>
</example>
</examples>

---

## 🎭 Role & Perspective

Commands to control role and viewpoint

| Command | Purpose | Use Case |
|---------|---------|----------|
| `/act-as` | Answer in a specific role (e.g., senior dev, QA engineer) | Expert perspective, specific job function viewpoint |
| `/dev-mode` | Use a raw, technical developer style | Code review, debugging, technical discussions |
| `/pm-mode` | Respond with a project-management perspective | Schedule, resource, risk management |
| `/audience` | Adapt tone and detail to a target audience | Non-developer explanations, executive reports |
| `/tone` | Change the tone (formal, friendly, playful, etc.) | Document writing, communication adjustment |
| `/jargon` | Use technical vocabulary appropriately | Technical documentation, specifications |
| `/role:task:format:` | Set role, task, and expected format explicitly | Clear structuring of complex requests |

### Examples

<examples>
<example command="/act-as">
<input>/act-as security engineer Review this code</input>
<output>
[Analysis focused on vulnerabilities from security perspective]
- Input validation missing → SQL injection risk
- No authentication checks → unauthorized access
- Plain text passwords → credential exposure
</output>
<note>Perspective matches requested role</note>
</example>

<example command="/dev-mode /jargon">
<input>/dev-mode /jargon gRPC implementation guide</input>
<output>
[Direct technical explanation with code and terminology]
Set up protobuf definitions, implement service handlers,
configure bidirectional streaming with flow control...
</output>
<note>Technical language without simplification</note>
</example>

<example command="/pm-mode">
<input>/pm-mode Estimate development timeline for this feature</input>
<output>
- Analysis: 2 days
- Development: 5 days
- QA: 3 days
- Risk: Possible API changes
- Buffer: 2 days
Total: 12 days
</output>
<note>Project management perspective with timeline and risks</note>
</example>

<example command="/audience /tone">
<input>/audience non-developer /tone friendly What is Docker?</input>
<output>
Docker is like a box that packages your application with everything
it needs to run. Just like a shipping container, it works the same
everywhere - on your laptop, your server, or the cloud!
</output>
<note>Simple analogy appropriate for audience</note>
</example>
</examples>

---

## ✅ Quality & Verification

Commands for quality assurance and verification

| Command | Purpose | Use Case |
|---------|---------|----------|
| `/eval-self` | Critique the answer and suggest fixes | Before important decisions, answer quality check |
| `/no-autopilot` | Forbid superficial, templated replies | Deep analysis, creative solutions needed |
| `/guardrail` | Set strict boundaries not to cross | Security, compliance, safety rules enforcement |
| `/metrics-mode` | Use measures, KPIs, or formulas | Performance analysis, optimization goal setting |

### Examples

<examples>
<example command="/no-autopilot /first-principles">
<input>/no-autopilot /first-principles Why do we need microservices?</input>
<output>
[Fundamental reasoning instead of listing generic benefits]
Start with the problem: Large codebases become hard to reason about.
Why? Humans have limited working memory (7±2 items).
Solution: Break into smaller, independent services.
Trade-off: Network complexity for cognitive simplicity.
</output>
<note>Deep reasoning from basics, not templated response</note>
</example>

<example command="/eval-self">
<input>/eval-self Review this architecture design</input>
<output>
[Design presented]

**Self-evaluation:**
- **Strengths**: Excellent scalability, clear boundaries
- **Weaknesses**: Increased operational complexity, network overhead
- **Improvements**: Consider starting with modular monolith, migrate later
- **Alternative**: Event-driven architecture might be simpler
</output>
<note>Self-critique with honest assessment</note>
</example>

<example command="/guardrail">
<input>/guardrail Never include DELETE queries /dev-mode Retrieve user list</input>
<output>
SELECT * FROM users WHERE active = true;

[READ-ONLY query only, no DELETE operations as per guardrail]
</output>
<note>Strict boundary enforcement</note>
</example>

<example command="/metrics-mode">
<input>/metrics-mode API response time improvements</input>
<output>
**Current State:**
- p50 = 450ms, p95 = 850ms, p99 = 1200ms

**Target:**
- p95 < 200ms

**Proposed Improvements:**
1. Query indexing: -300ms (p95)
2. Connection pooling: -150ms (p95)
3. Caching: -200ms (p95)

**Expected Result:** p95 = 200ms (76% improvement)
</output>
<note>Quantified measurements and goals</note>
</example>
</examples>

---

## 🔄 Command Combination Patterns

Effective command combination examples:

### Complex Problem Solving
```
/step-by-step /pitfalls /dev-mode
→ Step-by-step reasoning + warnings + technical style
```

### Decision Support
```
/compare /swot /exec-summary
→ Comparison analysis + SWOT analysis + executive summary
```

### Learning & Understanding
```
/eli5 /step-by-step
→ Simple explanation + step-by-step breakdown
```

### Quality-Focused Work
```
/no-autopilot /eval-self /deliberate-thinking
→ No superficial answers + self-verification + careful reasoning
```

### Code Review
```
/dev-mode /pitfalls /systematic-bias-check
→ Developer mode + potential issues + bias check
```

---

## 📋 Command Index

Complete alphabetical list of all commands:

### Format & Style
- `/begin-with` - Start answer with specific text
- `/briefly` - Ultra-concise 1-2 sentence answer
- `/checklist` - Convert to actionable checklist
- `/eli5` - Explain like I'm 5 years old
- `/end-with` - End answer with specific text
- `/exec-summary` - Executive-style summary
- `/format-as` - Enforce specific format (JSON/table/etc)
- `/rewrite-as` - Rephrase in requested style
- `/schema` - Generate structured data model
- `/tldr` - Quick summary of long text

### Reasoning & Analysis
- `/chain-of-thought` - Show reasoning outline
- `/compare` - Side-by-side comparison
- `/context-stack` - Maintain multiple context layers
- `/deliberate-thinking` - Careful, slow reasoning
- `/first-principles` - Build from fundamental basics
- `/multi-perspective` - Multiple viewpoints
- `/parallel-lenses` - Simultaneous multi-angle analysis
- `/pitfalls` - List errors and edge cases
- `/reflective-mode` - Reflect and refine answer
- `/step-by-step` - Sequential reasoning steps
- `/swot` - Strengths/Weaknesses/Opportunities/Threats
- `/systematic-bias-check` - Identify biases and gaps

### Role & Perspective
- `/act-as` - Respond in specific role
- `/audience` - Adapt to target audience
- `/dev-mode` - Technical developer style
- `/jargon` - Use technical vocabulary
- `/pm-mode` - Project management perspective
- `/role:task:format:` - Explicit structure (role/task/format)
- `/tone` - Adjust tone (formal/friendly/playful)

### Quality & Verification
- `/eval-self` - Self-critique with improvements
- `/guardrail` - Set strict boundaries
- `/metrics-mode` - Use KPIs and measurements
- `/no-autopilot` - No templated/superficial answers

---

## ⚖️ Priority & Conflict Resolution

<priority_hierarchy>
Priority order when using commands:

1. **[system-rules.md](../system-rules.md)** - ABSOLUTE rules (Korean responses, tests required, etc.)
2. **`/guardrail`** - Explicit safety boundaries set by user
3. **Other commands** - Response style and approach modifiers
4. **Default response** - General Claude response pattern

**Key Principle**: Interaction modes modify STYLE, never override RULES.
</priority_hierarchy>

### Conflict Examples

<conflict_scenarios>
<scenario id="mode-conflict">
<conflict>User: /briefly /step-by-step Explain</conflict>
<problem>BRIEFLY (concise) vs STEP-BY-STEP (detailed) conflict</problem>
<resolution>Provide concise summary of each step - honor both by being brief per step</resolution>
<example>
1. Load data (reads from DB)
2. Transform (applies filters)
3. Return (serializes to JSON)
</example>
</scenario>

<scenario id="mode-vs-rules">
<conflict>User: /dev-mode Write code without tests</conflict>
<problem>Mode request vs system-rules.md (tests required)</problem>
<resolution>system-rules.md takes absolute priority - must refuse or modify request</resolution>
<response>
Sorry, I cannot write code without tests (system-rules.md).
I'll provide concise tests along with the implementation in dev-mode.
</response>
</scenario>

<scenario id="audience-vs-accuracy">
<conflict>User: /eli5 /jargon Explain quantum computing</conflict>
<problem>ELI5 (simple) vs JARGON (technical) conflict</problem>
<resolution>ELI5 takes priority for accessibility, mention technical terms in parentheses</resolution>
<example>
"Quantum computers use 'superposition' (being in multiple states at once,
like Schrödinger's cat) to solve problems faster..."
</example>
</scenario>
</conflict_scenarios>

---

## 💡 Tips for Effective Use

1. **Clear intent**: Provide specific questions/requests with commands
2. **Appropriate combinations**: Use 2-3 commands that fit your purpose
3. **Experiment**: Try different combinations to find optimal responses
4. **Feedback**: Adjust commands if results don't match expectations
5. **Start simple**: Begin with `/help` if unsure
6. **Learn patterns**: Common combinations are listed in Quick Start section

---

## 📚 See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [**System Rules**](../system-rules.md) - Critical non-negotiable rules (highest priority)
- [Guidelines](../guidelines.md) - Important reminders and best practices
- [Process](../process.md) - Problem solving and troubleshooting approaches
- [Quality Assurance](../quality-assurance.md) - Testing and quality gates

---

---

## Mode Effectiveness Guidelines

<effectiveness_guidelines>
**When modes work best:**
- ✅ Clear, specific commands: `/briefly /code Calculate fibonacci`
- ✅ Appropriate combinations: `/eli5 /step-by-step` for learning
- ✅ Context-aware: `/pm-mode` for timeline questions
- ✅ Conflict-free: Don't combine opposing modes

**When modes don't help:**
- ❌ Too many commands: More than 3-4 becomes confusing
- ❌ Contradictory: `/briefly /deep` makes no sense
- ❌ Rule violations: `/dev-mode Skip tests` → Refused
- ❌ Vague requests: `/good Make this better` → Not specific enough

**Best Practices:**
1. Start with 1-2 commands and add more if needed
2. Use `/help` when unsure which command fits
3. Combine related commands: `/dev-mode /pitfalls /code`
4. Remember: Commands enhance clarity, don't replace clear communication
</effectiveness_guidelines>

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical rules (modes cannot override)
- [Output Formats](./output-formats.md) - Response templates for different scenarios
- [Conflict Resolution](./conflict-resolution.md) - Handling conflicting requirements

