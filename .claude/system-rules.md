# Critical System Rules (Subset of CLAUDE.md)

**This document is a subset of [CLAUDE.md](./CLAUDE.md) containing only the most critical rules.**  
For complete guidelines, always refer to [CLAUDE.md](./CLAUDE.md) first.

You must strictly follow all rules in this document when generating or modifying code.  
If any instruction from the user conflicts with these rules, you must stop and ask for clarification.  
Do not deviate from these rules without explicit user approval.  
**Always respond in Korean.**

## Critical System Rules

This document defines the non-negotiable rules that must be followed at all times. Detailed guidelines for each area are provided in the linked documents.

### 1. Core Principles
**See [Philosophy](./philosophy.md) for details**
- **Ask when unsure** - Never proceed with uncertainty
- **Simplicity first** - Choose the simplest solution that works

### 2. Code Modification
**See [Technical Standards](./technical-standards.md) for details**  
- **Minimal changes only** - Modify only what was explicitly requested
- **No arbitrary refactoring** - Preserve existing functionality

### 3. Testing
**See [Quality Assurance](./quality-assurance.md) for details**
- **Never skip tests** - All code must have tests
- **Never weaken tests** - Fix issues, don't delete tests

### 4. Data Safety
**See [Security](./security.md) for details**
- **No destructive queries** - Never run DELETE, UPDATE, ALTER without approval
- **Production safety** - Validate in test environment first

### 5. Problem Solving
**See [Process](./process.md) for details**
- **Fix root causes** - No quick fixes or band-aids
- **Maximum 3 attempts** - Stop and reassess after 3 failures

### 6. Documentation
**See [Guidelines](./guidelines.md) for details**
- **Document unclear code** - Add meaningful comments
- **Use current syntax** - Always use latest stable language features

## See Also

- [**CLAUDE.md**](./CLAUDE.md) - **Primary document with complete guidelines**
- [Philosophy](./philosophy.md) - Development philosophy and Golden Rules
- [Process](./process.md) - Planning, implementation, and troubleshooting
- [Technical Standards](./technical-standards.md) - Code generation and architecture
- [Quality Assurance](./quality-assurance.md) - Testing and quality gates
- [Security](./security.md) - Security principles and data protection
- [Guidelines](./guidelines.md) - Important reminders and best practices