# Documentation Standards

<meta>
Document: documentation.md
Role: Documentation Guide
Priority: Medium
Applies To: All code documentation and comments
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document defines documentation standards for code, APIs, and project files. Good documentation helps others understand and maintain the codebase.
</context>

<your_responsibility>
As Documentation Guide, you must:
- **Document the why**: Explain reasoning, not just what the code does
- **Keep docs current**: Update documentation with code changes
- **Use examples**: Include practical, working examples
- **Follow standards**: Apply consistent formatting and structure
</your_responsibility>

## Documentation Principles

- **Clear and concise**: Write for humans first, be direct and simple
- **Purpose-driven**: Always explain WHY, not just WHAT
- **Example-oriented**: Include practical examples when possible
- **Maintenance-aware**: Keep documentation close to code
- **Version-controlled**: Treat docs as code, track changes

## Code Comments

### When to Comment
- Complex algorithms or business logic
- Non-obvious design decisions
- Workarounds and temporary solutions (with TODO)
- Performance optimizations
- Security considerations

### Comment Guidelines
- Write comments BEFORE the code, not after
- Explain WHY, not WHAT (code shows what)
- Keep comments up-to-date with code changes
- Use proper grammar and punctuation
- Mark technical debt with TODO/FIXME/HACK

## API Documentation

### Essential Elements
- **Purpose**: What the API/function does
- **Parameters**: Type, format, and constraints
- **Return values**: Type and possible values
- **Errors**: Possible exceptions and error codes
- **Examples**: Real-world usage scenarios
- **Deprecation**: Version and migration path

### Best Practices
- Document edge cases and limitations
- Include authentication/authorization requirements
- Specify rate limits and quotas
- Provide both success and error examples
- Keep examples simple but realistic

## Architecture Decision Records (ADR)

### ADR Structure
1. **Title**: Short noun phrase
2. **Status**: Proposed/Accepted/Deprecated/Superseded
3. **Context**: The issue motivating this decision
4. **Decision**: The change we're proposing/doing
5. **Consequences**: What becomes easier or harder
6. **Alternatives**: Other options considered

### When to Write ADRs
- Significant architectural changes
- Technology stack decisions
- Major refactoring decisions
- Security model changes
- Data model changes

## Project Documentation Files

### Essential Files
- **CLAUDE.md**: Project overview, quick start, basic usage
- **CONTRIBUTING.md**: How to contribute, coding standards
- **CHANGELOG.md**: Version history and changes
- **LICENSE**: Legal terms and conditions

### Architecture Documentation
- **ARCHITECTURE.md**: System design and components
- **API.md**: API specifications and endpoints
- **DATABASE.md**: Schema and data model
- **DEPLOYMENT.md**: Deployment process and configuration

### Development Documentation
- **DEVELOPMENT.md**: Local setup and development workflow
- **TESTING.md**: Testing strategy and instructions
- **SECURITY.md**: Security considerations and practices
- **TROUBLESHOOTING.md**: Common issues and solutions

## Markdown Formatting Standards

### Document Structure
- Use hierarchical headings (# > ## > ###)
- One H1 per document
- Consistent heading capitalization
- Logical section ordering

### Code Blocks
When including copyable markdown blocks in responses:

1. **Outer fence**: Wrap the entire copyable block with `~~~`
2. **Preserve inner fences**: Keep code blocks (```) inside unchanged
3. **Language hints**: Always specify language after ```

Example:
~~~markdown
# Title
Description text here.

```python
def example():
    return "code block with language hint"
```

Additional explanation...
~~~

### Formatting Guidelines
- Use lists for multiple items (3+ items)
- Bold for emphasis, italics for new terms
- Link to external resources when helpful
- Include table of contents for long documents
- Use relative links for internal references

## Change Management

### Version Documentation
- Maintain CHANGELOG.md following Keep a Changelog format

- Group changes by type: Added, Changed, Deprecated, Removed, Fixed, Security
- Include release date and version number
- Link to relevant issues/PRs

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Technical Standards](../technical-standards.md) - Code quality and standards
- [Version Control](../version-control.md) - Git workflow and commit messages

### Documentation Reviews
- Review docs with code changes
- Check for accuracy and completeness
- Verify examples still work
- Update version numbers and dates
- Remove outdated information

### Migration Guides
- Document breaking changes clearly
- Provide step-by-step migration instructions
- Include before/after examples
- Estimate migration effort
- Offer automation scripts when possible