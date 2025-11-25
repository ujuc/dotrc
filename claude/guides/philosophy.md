# Philosophy

<meta>
Document: philosophy.md
Role: Philosophy Guide
Priority: High - Foundational principles
Applies To: All development decisions and approaches
</meta>

<context>
This document defines the core development philosophy and guiding principles. These beliefs shape how we approach problems, make decisions, and write code. They provide the "why" behind the technical standards and processes.
</context>

<your_responsibility>
As a developer guided by this philosophy, you must:
- **Question complexity**: Always ask "Is there a simpler way?"
- **Seek clarity**: Never proceed with ambiguous requirements
- **Value maintainability**: Write code that others (including future you) can understand
- **Practice humility**: Ask questions when uncertain, don't assume you know
- **Choose boring**: Prefer proven, stable solutions over cutting-edge experiments
</your_responsibility>

## The Golden Rules (CRITICAL)

- **Ask when unsure** - Do not proceed when uncertain about implementation details
- **Simplicity first** - Do not over-engineer or make things unnecessarily complex
- **Clarity required** - Do not proceed if a request is ambiguous or incomplete
- **Reuse over rebuild** - Prefer stable, widely adopted libraries over custom implementations

## Core Beliefs

- **Incremental progress over big bangs** - Small changes that compile and pass tests
- **Learning from existing code** - Study and plan before implementing
- **Pragmatic over dogmatic** - Adapt to project reality
- **Clear intent over clever code** - Be boring and obvious

## Simplicity Means

- Single responsibility per function/class
- Avoid premature abstractions
- No clever tricks - choose the boring solution
- If you need to explain it, it's too complex

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Technical Standards](../technical-standards.md) - Code generation and architecture
- [Process](../process.md) - Implementation workflow and planning
