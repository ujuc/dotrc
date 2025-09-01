# Security Principles

## Database and Data Safety (CRITICAL)

- **No destructive queries without approval** - Do not run DELETE, UPDATE, ALTER without explicit consent
- **Production safety** - Do not apply bulk data changes directly in production without validation
- **Test first** - Verify changes in test/staging environment before production

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
