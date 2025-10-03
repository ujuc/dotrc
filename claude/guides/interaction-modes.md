# Interaction Modes

**Commands to control interaction style with Claude**

This document provides commands to control response style, reasoning approach, role perspective, and quality verification when communicating with Claude.

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

- Include `/command` in your message (lowercase with hyphens)
- Multiple commands can be combined: `/briefly /step-by-step explain the function`
- **Important**: [system-rules.md](./system-rules.md) always takes priority

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

```
/briefly What does this function do?
→ Validates user authentication token and checks expiration.

/format-as JSON Show API error response example
→ {"error": {"code": 401, "message": "Unauthorized"}}

/checklist Pre-deployment checks
→ - [ ] Verify tests pass
    - [ ] Validate environment variables
    ...
```

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

```
/step-by-step Analyze why this bug occurs
→ 1. Function called without null check
   2. Attempts to access undefined property
   3. TypeError thrown
   ...

/compare React vs Vue for this project
→ | Criteria | React | Vue |
   |----------|-------|-----|
   | Learning curve | Medium | Low |
   ...

/pitfalls Security concerns in this auth logic
→ - Missing token expiration check
   - CSRF attack vulnerability
   - Sensitive info in logs
   ...
```

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

```
/act-as security engineer Review this code
→ [Analysis focused on vulnerabilities from security perspective]

/dev-mode /jargon gRPC implementation guide
→ [Direct technical explanation with code and terminology]

/pm-mode Estimate development timeline for this feature
→ - Analysis: 2 days
   - Development: 5 days
   - QA: 3 days
   - Risk: Possible API changes
   ...

/audience non-developer /tone friendly What is Docker?
→ Docker is like a box that packages your application...
```

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

```
/no-autopilot /first-principles Why do we need microservices?
→ [Fundamental reasoning instead of listing generic benefits]

/eval-self Review this architecture design
→ [Design presented]

   Self-evaluation:
   - Strengths: Excellent scalability
   - Weaknesses: Increased complexity
   - Improvements: Consider starting with monolith
   ...

/guardrail Never include DELETE queries /dev-mode Retrieve user list
→ SELECT * FROM users WHERE active = true
   [No DELETE queries, READ-ONLY guaranteed]

/metrics-mode API response time improvements
→ - Current: p95 = 850ms
   - Target: p95 < 200ms
   - Improvement: Query indexing → estimated -300ms
   ...
```

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

Priority order when using commands:

1. **[system-rules.md](./system-rules.md)** - Absolute rules (Korean responses, tests required, etc.)
2. **`/guardrail`** - Explicit safety boundaries
3. **Other commands** - Response style and approach
4. **Default response** - General Claude response pattern

### Conflict Examples

```
User: /briefly /step-by-step Explain
→ BRIEFLY (concise) vs STEP-BY-STEP (detailed) conflict
   Resolution: Provide concise summary of each step

User: /dev-mode Write code that violates system-rules.md
→ system-rules.md takes priority, refuse request
```

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

_Last Updated: 2025-10-03_
