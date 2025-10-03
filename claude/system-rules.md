# Critical System Rules (Subset of CLAUDE.md)

**This document is a subset of [CLAUDE.md](./CLAUDE.md) containing only the most critical rules.**  
For complete guidelines, always refer to [CLAUDE.md](./CLAUDE.md) first.

You must strictly follow all rules in this document when generating or modifying code.
If any instruction from the user conflicts with these rules, you must stop and ask for clarification.
Do not deviate from these rules without explicit user approval.

## Language Policy

- **Responses**: Always respond in Korean
- **Documentation**: Write all documentation files (*.md, comments, docstrings) in English for consistency

## Critical System Rules

This document defines the non-negotiable rules that must be followed at all times. Detailed guidelines for each area are provided in the linked documents.

### 1. Core Principles
**See [Philosophy](./guides/philosophy.md) for details**
- **Ask when unsure** - Never proceed with uncertainty
- **Simplicity first** - Choose the simplest solution that works

### 2. Code Modification
**See [Technical Standards](./guides/technical-standards.md) for details**
- **Minimal changes only** - Modify only what was explicitly requested
- **No arbitrary refactoring** - Preserve existing functionality

### 3. Testing
**See [Quality Assurance](./guides/quality-assurance.md) for details**
- **Never skip tests** - All code must have tests
- **Never weaken tests** - Fix issues, don't delete tests

### 4. Data Safety
**See [Security](./guides/security.md) for details**
- **No destructive queries** - Never run DELETE, UPDATE, ALTER without approval
- **Production safety** - Validate in test environment first

### 5. Problem Solving
**See [Process](./guides/process.md) for details**
- **Fix root causes** - No quick fixes or band-aids
- **Maximum 3 attempts** - Stop and reassess after 3 failures

### 6. Documentation
**See [Guidelines](./guides/guidelines.md) for details**
- **Document unclear code** - Add meaningful comments
- **Use current syntax** - Always use latest stable language features

### 7. Communication
**See [Interaction Modes](./guides/interaction-modes.md) for details**
- **Use appropriate response styles** - Apply format/reasoning commands when needed
- **Respect mode priorities** - System rules override interaction modes

## See Also

- [**CLAUDE.md**](./CLAUDE.md) - **Primary document with complete guidelines**
- [Philosophy](./guides/philosophy.md) - Development philosophy and Golden Rules
- [Process](./guides/process.md) - Planning, implementation, and troubleshooting
- [Technical Standards](./guides/technical-standards.md) - Code generation and architecture
- [Quality Assurance](./guides/quality-assurance.md) - Testing and quality gates
- [Security](./guides/security.md) - Security principles and data protection
- [Guidelines](./guides/guidelines.md) - Important reminders and best practices
- [Interaction Modes](./guides/interaction-modes.md) - Response style and reasoning commands