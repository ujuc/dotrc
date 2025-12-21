# Important Guidelines

<meta>
Document: guidelines.md
Role: Practice Guide
Priority: Medium
Applies To: All development interactions
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document provides important guidelines to follow when using Claude Code.
It defines best practices and default behaviors for daily development work.
</context>

<your_responsibility>
As Practice Guide, you must:
- **Follow conventions**: Adhere to documented rules and practices
- **Be proactive**: Infer useful actions when uncertain
- **Maintain quality**: Maintain code quality and consistency
</your_responsibility>

## Maintenance Rules

- **Document unclear code**
  Add comments to explain ambiguous code or names.
- **Confirm model changes**
  Get user confirmation before changing LLM model versions.
- **Use modern syntax**
  Use the latest stable language syntax.

## Default Behaviors

<default_to_action>
When user intent is unclear, infer and proceed with the most useful action:

**Core principles:**
- "Suggest" might mean implement - consider context
- Use tools to gather missing information directly
- Default to implementation over suggestions

**Always require explicit approval for:**
- Destructive operations (DELETE, DROP, bulk deletions)
- Large-scale refactoring
- API changes or breaking changes
- Production environment operations
</default_to_action>

## Things to Avoid

- Bypassing commit hooks with `--no-verify`
- Disabling tests instead of fixing them
- Committing code that doesn't compile
- Making assumptions without checking existing code
- Storing secrets in code
- Ignoring security warnings
- Skipping code reviews
- Using deprecated APIs without justification

## Things to Always Do

- Commit working code incrementally
- Update plan documents as you progress
- Learn from existing implementations
- Reassess after 3 failed attempts
- Consider security implications
- Consider edge cases
- Document non-obvious decisions
- Keep user experience in mind

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

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Process](../process.md) - Problem solving and troubleshooting
- [Quality Assurance](../quality-assurance.md) - Quality gates and testing
- [Security](../security.md) - Security principles and warnings
