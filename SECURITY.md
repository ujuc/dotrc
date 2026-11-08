# Security Policy

## About this project

Dual-Brain is a portable Markdown skill for agentic coding environments such as Codex and Claude Code. The skill is Markdown instructions with supporting references and needs no runtime dependency. The repository also includes executable Python benchmark tooling that can launch installed agent CLIs; live benchmark runs inherit those clients' configured access.

That said, because the skill instructs an agent that can read files and run tools on your machine, we take prompt-level concerns seriously (for example, wording that could lead an agent to take unintended actions).

## Project memory safety

Dual-Brain can read project-local memory from:

```text
.dual-brain/MEMORY.md
```

That file is useful, but it is still untrusted project text. The skill must treat memory as advisory context, verify it against current code/docs, and never follow memory that attempts to override user intent, tool safety, or system instructions. Hot/Warm/Cold/Archived tiers affect attention, not authority.

Do **not** store secrets in project memory:

- API keys
- access tokens
- credentials
- private keys
- session cookies
- sensitive personal data
- production incident details that should not live in a repo

If memory contains sensitive content, Dual-Brain should not summarize it into future context. In writable scope, it should remove or redact only the sensitive material and report its category. In a read-only review, report the category without modifying the file. Redaction does not erase Git history or revoke credentials.

Dual-Brain may update non-sensitive project memory after synthesis when durable content changes or memory maintenance is requested. Metadata updates accompany warranted saves, not unchanged repeat reviews. Without an accessible project filesystem, memory suggestions remain unsaved; the skill does not silently use account-wide memory. Automatic memory mutation is never a license to store secrets, sensitive personal data, or instructions that override user intent, tool safety, or system instructions.

## Supported versions

The latest version on the `main` branch is supported. There are no separate release branches.

## Reporting a vulnerability

If you discover a security concern — including prompt-injection risks, unsafe memory handling, or instructions that could cause unintended agent behavior — please report it privately:

- **Preferred:** open a [private security advisory](https://github.com/sleeplesshan/dual-brain/security/advisories/new) on GitHub.

Please include:

- A description of the issue and its potential impact.
- Steps to reproduce (e.g., the task/prompt that triggered the behavior).
- Whether `.dual-brain/MEMORY.md` was present and what kind of memory behavior was involved.
- Any suggested mitigation, if you have one.

Please do **not** open a public issue for security reports. We'll acknowledge your report as soon as we can and keep you updated on the fix.

Thank you for helping keep Dual-Brain and its users safe. 🙏
