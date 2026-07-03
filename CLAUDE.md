# Project Overview

Personal macOS development environment configuration. Pure configuration repository — no build or test toolchain. Structure, deployment model, and operational gotchas: see [AGENTS.md](./AGENTS.md).

# Work Rules

- Commit directly to `main` (no branches/PRs)
- Korean Conventional Commits ending with `-하다`, e.g. `feat(zshrc): starship 프롬프트 설정을 추가하다`
- **Types**: follow the `gitmessage` template (authoritative list — do not duplicate here)
- **Scopes**: zshrc (incl. zimrc), agents, zed, scripts, docs, or omit for root-level changes

# References

- **[AGENTS.md](./AGENTS.md)** — Repository structure, operational gotchas, and boundaries
- **[agents/CLAUDE.md](./agents/CLAUDE.md)** — AI agent configuration (submodule)
