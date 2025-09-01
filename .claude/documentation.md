# Documentation Standards

## Code Documentation

- All public APIs must include clear JSDoc/docstring
- Complex algorithms require inline comments
- Update README when adding new features
- Maintain CHANGELOG for major changes

## Architecture Decision Records (ADR)

- Document important technical decisions
- Include alternatives and reasoning
- Specify future re-evaluation points

## Required Project Files

- `PROJECT_STRUCTURE.md`: Directory structure and major modules
- `DEVELOPMENT.md`: Development setup and run instructions
- `CONVENTIONS.md`: Project-specific coding conventions
- `TECH_STACK.md`: Technology stack and versions

## Markdown Formatting Rules
When including copyable markdown blocks in responses, follow these rules:

1. **Outer fence**: Wrap the entire copyable block with `~~~`
2. **Preserve inner fences**: Keep code blocks (```) inside the content unchanged
3. **Prevent conflicts**: Ensure outer and inner fences don't interfere with each other

Example:
~~~markdown
# Title
This is a description.

```python
def example():
    return "inner code block"
```

Additional explanation...
~~~
