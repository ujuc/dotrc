# Security Principles

## Database and Data Safety (CRITICAL)

- **No destructive queries without approval** - Do not run DELETE, UPDATE, ALTER without explicit consent
- **Production safety** - Do not apply bulk data changes directly in production without validation
- **Test first** - Verify changes in test/staging environment before production

## Environment Variables and .env Files

- **Never read or display .env file contents** - These files contain sensitive credentials
- **Only read environment variable names** - If needed, list variable names without values
- **Do not include .env files in commits** - Always add to .gitignore
- **Use placeholders for examples** - When documenting, use `YOUR_API_KEY` instead of actual values

## Basic Security

- Validate and sanitize all inputs
- Never log sensitive information
- Manage secrets with environment variables
- Follow OWASP Top 10 guidelines
- Apply principle of least privilege

## Data Protection

- Encrypt sensitive data at rest and in transit
- Use secure communication protocols
- Implement proper authentication and authorization
- Regular security audits and dependency updates

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Technical Standards](../technical-standards.md) - Secure coding practices
- [Guidelines](../guidelines.md) - Security warnings and best practices
