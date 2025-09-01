# Technical Standards

## Code Generation Rules (CRITICAL)

- **Minimal changes only** - Do not change unrelated parts of the code
- **No arbitrary refactoring** - Apply only the minimal required changes
- **Preserve functionality** - Do not use "file size" as an excuse to change logic
- **Reuse existing code** - Search thoroughly and reuse existing functionality
- **Clear naming** - Use descriptive, semantically clear names
- **Secure practices** - Never hardcode secrets or environment variables
- **Environment awareness** - Respect development, test, and production differences

## Architecture Principles

- **Composition over inheritance** - Use dependency injection
- **Interfaces over singletons** - Enable testing and flexibility
- **Explicit over implicit** - Clear data flow and dependencies
- **Test-driven when possible** - Never disable tests, fix them

## Code Quality

- **Every commit must**:
  - Compile successfully
  - Pass all existing tests
  - Include tests for new functionality
  - Follow project formatting/linting

- **Before committing**:
  - Run formatters/linters
  - Self-review changes
  - Ensure commit message explains "why"

## Error Handling

- Fail fast with descriptive messages
- Include context for debugging
- Handle errors at appropriate level
- Never silently swallow exceptions

## See Also

- [**CLAUDE.md**](./CLAUDE.md) - Primary document with complete guidelines
- [System Rules](./system-rules.md) - Critical system-wide rules
- [Philosophy](./philosophy.md) - Development philosophy and principles
- [Quality Assurance](./quality-assurance.md) - Code review and testing
- [Security](./security.md) - Security practices and data safety
