# Skill routing

Boundaries for requests that more than one skill could claim. Invoke the skill the matching line names.

- Checking an existing skill for defects (점검, 감사, 개선, 최적화) goes to `ujuc:skill-improver`, which also applies the mechanical fixes it finds. A change the request already names (생성, 수정, 업데이트, 최신화, 다이어트) goes to `ujuc:generate-skills`.
- A request to create or change CLAUDE.md goes to `ujuc:generate-agent-docs`, which runs the built-in `/init` itself when the file is missing; invoke `init` directly only when the user types `/init`.
