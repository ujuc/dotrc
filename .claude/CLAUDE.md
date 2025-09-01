# Claude Development Guidelines — PRIMARY DOCUMENT

**This is the primary entry point for all Claude development guidelines.**  
Start here to understand the complete development standards and practices.

## Document Hierarchy

```
CLAUDE.md (You are here - Main entry point)
├── system-rules.md (Critical rules subset)
└── Domain-specific guidelines (Detailed documentation)
```

## Critical System Rules (MUST FOLLOW)

- [**System Rules**](./system-rules.md) - **Non-negotiable rules that must be strictly followed (Korean responses required)**
  - This is a subset of critical rules extracted for quick reference
  - All rules in system-rules.md are mandatory

## Core Documents

### Development Philosophy & Process
- [**Philosophy**](./philosophy.md) - Core beliefs and simplicity principles
- [**Process**](./process.md) - Planning, implementation flow, and troubleshooting
- [**Guidelines**](./guidelines.md) - Important reminders and emergency procedures

### Technical Implementation
- [**Technical Standards**](./technical-standards.md) - Architecture, code quality, and error handling
- [**Quality Assurance**](./quality-assurance.md) - Code review, decision framework, and quality gates
- [**Documentation**](./documentation.md) - Code documentation and project file requirements

### Operations & Security
- [**Security**](./security.md) - Security principles and data protection
- [**Performance**](./performance.md) - Optimization guidelines and considerations
- [**Monitoring**](./monitoring.md) - Logging standards and best practices

### Collaboration
- [**Version Control**](./version-control.md) - Git workflow and commit message format
- [**Project Integration**](./project-integration.md) - Codebase learning, tooling, and i18n

## How to Use This Documentation

1. **First Time**: Read this file (CLAUDE.md) completely
2. **Quick Reference**: Check [system-rules.md](./system-rules.md) for critical rules
3. **Deep Dive**: Explore specific domain documents as needed
4. **Cross-Reference**: Use "See Also" sections in each document for related topics

## Priority Order

When guidelines conflict, follow this priority:
1. CLAUDE.md (this document)
2. system-rules.md (critical subset)
3. Domain-specific documents
4. Project-specific overrides (if explicitly stated)

---

_Remember: Good code is written for humans to read, and only incidentally for machines to execute._

_Last Updated: 2025-09-01_