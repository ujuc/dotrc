# Important Guidelines

## Maintenance Rules (CRITICAL)

- **Document unclear code** - Do not leave unclear code or ambiguous names undocumented
- **Confirm model changes** - Do not change the LLM model version without user confirmation
- **Use current syntax** - Do not use outdated language syntax, always use latest stable

## NEVER

- Use `--no-verify` to bypass commit hooks
- Disable tests instead of fixing them
- Commit code that doesn't compile
- Make assumptions - verify with existing code
- Store secrets in code
- Ignore security warnings
- Skip code reviews
- Use deprecated APIs without justification

## ALWAYS

- Commit working code incrementally
- Update plan documentation as you go
- Learn from existing implementations
- Stop after 3 failed attempts and reassess
- Consider security implications
- Think about edge cases
- Document non-obvious decisions
- Keep the user experience in mind

## Emergency Procedures

### When Things Break

1. Don't panic
2. Check recent changes
3. Review error logs
4. Isolate the problem
5. Create minimal reproduction
6. Document findings
7. Implement fix with tests
8. Post-mortem for learning

### Getting Help

- After 3 attempts, ask for guidance
- Provide context and what you've tried
- Share error messages and logs
- Explain your understanding of the problem
- Be open to different approaches

## See Also

- [**CLAUDE.md**](./CLAUDE.md) - Primary document with complete guidelines
- [System Rules](./system-rules.md) - Critical system-wide rules
- [Process](./process.md) - Problem solving and troubleshooting
- [Quality Assurance](./quality-assurance.md) - Quality gates and testing
- [Security](./security.md) - Security principles and warnings
