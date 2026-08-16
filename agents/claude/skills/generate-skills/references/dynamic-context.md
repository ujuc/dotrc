# Dynamic Context Injection

> Inject shell command output directly into SKILL.md at load time using `!`command`` syntax.

---

## Syntax

```markdown
!`shell-command`
```

Claude Code executes the command **before** the skill prompt reaches the model. The placeholder is replaced with the command's stdout. The model only sees the result.

---

## Example: PR Summary Skill

```yaml
---
name: pr-summary
description: >-
  Pull request changes summary. Use for /pr-summary, "PR summary".
---

## PR context
- Diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`
- Comments: !`gh pr view --comments`

## Task
Summarize this pull request based on the context above.
```

## Example: Commit Skill with Pre-loaded Context

```yaml
---
name: commit
description: >-
  Generate git commits. Use for /commit, "commit changes".
---

## Current state
- Changes: !`git diff --stat`
- Recent commits: !`git log --oneline -10`

## Task
Create a commit based on the changes above.
```

---

## Available Variables

Combine with these built-in substitutions:

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed to the skill |
| `$ARGUMENTS[N]` / `$N` | Positional argument access |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Skill directory path |

---

## When to Use

**Good fit** (always-needed, fixed context):

- Git state: `!`git status --short``, `!`git log --oneline -5``
- Environment info: `!`node --version``, `!`python --version``
- Project metadata: `!`cat package.json | jq '.name, .version'``
- Current branch: `!`git branch --show-current``

**Bad fit** (conditional or user-dependent):

- Commands that vary based on user input (use tool calls instead)
- Long-running commands (delays skill loading)
- Commands that may fail in some environments (error output leaks into prompt)

---

## Caveats

1. **Always executed**: runs every time the skill loads, regardless of whether the output is needed
2. **Failure handling**: if the command fails, stderr/error output is injected as-is into the prompt
3. **No conditional logic**: cannot branch based on command results at the template level
4. **Loading latency**: slow commands (network calls, large file scans) delay skill availability
5. **Security**: avoid commands that expose secrets — output goes directly into the prompt
