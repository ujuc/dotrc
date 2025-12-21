# Project Integration

<meta>
Document: project-integration.md
Role: Integration Guide
Priority: Medium
Applies To: Codebase integration and tooling
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document guides integration with existing codebases. Learn existing patterns before implementing new features.
</context>

<your_responsibility>
As Integration Guide, you must:
- **Learn first**: Study existing patterns before coding
- **Respect conventions**: Follow project's established practices
- **Minimize disruption**: Integrate smoothly with existing tooling
</your_responsibility>

## Learning the Codebase

- Find 3 similar features/components
- Identify common patterns and conventions
- Use same libraries/utilities when possible
- Follow existing test patterns
- Review recent PRs for context

## Tooling

- Use project's existing build system
- Use project's test framework
- Use project's formatter/linter settings
- Don't introduce new tools without strong justification

## Internationalization (i18n)

### i18n Guidelines

- Avoid hardcoded strings
- Localize date/time formats
- Consider number and currency formats
- Support RTL languages when applicable
- Use Unicode (UTF-8) encoding
- Test with different locales

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Process](../process.md) - Planning and implementation workflow
- [Documentation](../documentation.md) - Documentation standards
