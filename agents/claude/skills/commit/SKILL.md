---
name: commit
description: "한국어 Conventional Commits 규칙에 따라 git 커밋을 생성하고, 요청 시 push까지 수행한다. /commit, 커밋해줘, 변경사항 커밋, 커밋하고 푸시해줘, commit, commit and push 요청 시 사용한다."
group: docs
allowed-tools: Bash(git rev-parse:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git -C:*), Bash(git submodule:*), Bash(printf:*), Bash(wc:*), Read, Edit, Glob, Agent
---

# Git Commit

## Model guidance

Route the message draft by staged size ([dispatch routing](../generate-skills/references/model-selection.md#dispatch-routing)): `git diff --cached --shortstat` ≤2 files and ≤40 changed lines → Lightweight (`haiku`/`medium`); otherwise Standard (`sonnet`/`medium`). Mixed scope is a staging question, not a model question. Tell the user the profile in one line. Committing, checks and doc updates stay with you.

## Project skill override

1. Run `git rev-parse --show-toplevel`; outside a repo, skip this section.
2. Check whether `<repo-root>/.claude/skills/commit/SKILL.md` exists.
3. If it exists: read it, **announce once** to the user
   `프로젝트 레벨 commit 스킬을 사용합니다 (<absolute-path>).`, and follow its body
   instead of every section below for this invocation, within the tools already
   granted.
4. Otherwise continue silently. Do not re-check inside submodules.

## Format

`<type>(<scope>): <한국어 제목 -다>`

- Project instructions, a repository `gitmessage`, and its commit hook override these rules.
- **scope**: from the project's AGENTS.md or imported instructions.
- **Subject ≤ 50 characters** including the prefix; Korean declarative `-다` ending (any verb stem); no trailing period.
- **Body**: blank line after the subject, wrapped at 72 characters.
- One change per commit; the subject says what, the body why: never stack clauses with `·`, `및`, `그리고` or `~해`. Split the commit, or move the list into a Why body.
- Pick the most specific type; do not fall back to `chore` when `feat`/`fix`/`refactor`/`perf` fits.
- **Skill size**: when a `SKILL.md` is staged, add a body line
  `SKILL.md <skill>: <HEAD bytes> → <staged bytes> bytes`. A commit that ships a
  skill-diet ends with the trailer `Skill-Diet: <skill-name>`.
- **Attribution**: add `Co-Authored-By` only when the harness supplies the text (Claude Code: `attribution.commit`), verbatim. No `Signed-off-by`.

## Procedure

### Step 0. Submodules first

If `git status` shows a modified submodule, commit inside it first (`git -C <submodule>`, Steps 1–5 and 7–8, no doc updates), push it first if a push was requested, then commit the parent with the new pointer.

### Steps 1–8

1. Read the user's arguments for file paths or instructions.
2. `git status`, then `git diff --stat`; read full `git diff` only for files you need to understand.
3. `git log --oneline -10` for style and scope vocabulary.
4. **Staging scope**: stage the paths the user gave. With no hints, proceed only if every change is one logical unit; if unrelated changes are mixed or the subset is ambiguous, ask before staging.
5. `git add` only the intended files.
6. Structural change → [Doc updates](#doc-updates).
7. **Draft, then check.** Dispatch `Agent` with `subagent_type: "Explore"`, `model`/`effort` from the routing above, and this prompt:

   ```
   Draft a git commit message for the staged diff. Run `git diff --cached` and
   `git log --oneline -10` yourself. Rules: subject `<type>(<scope>): <한국어 제목 -다>`,
   ≤50 characters including the prefix, no trailing period; scopes: {scopes from
   project instructions}; body wrapped at 72 columns with Why/How lines when the
   type is feat or fix, otherwise optional. Return exactly:
   subject: <one line>
   body:
   <lines or empty>
   ```

   If the draft is empty or fails a check, write it yourself. Rewrite until all three pass:

   1. **Length**: `printf '%s' '<subject>' | wc -m` ≤ 50 (characters, not bytes; not `echo -n`). Body: `printf '%s\n' "<body>" | while IFS= read -r l; do [ "${#l}" -gt 72 ] && echo "$l"; done` prints nothing (`awk length` counts bytes on macOS).
   2. **Body policy**:
      - `feat`, `fix`: always, at least one Why line.
      - `refactor`, `perf`: when the motivation is not obvious from the diff.
      - Submodule pointer: one line on what changed in the submodule and why; never `서브모듈을 업데이트하다` alone.
      - Others: optional; consider dropping a body on a trivial change.

      Non-trivial bodies use `Why:` / `How:` blocks of `-` bullets; How names only the key approach.
   3. **Completion test**: `이 커밋이 적용되면 [제목]` must read naturally.

   If the user said `humanize` / `휴머나이저` / `AI 흔적` / `다듬어서`, run the [Humanizer pass](#humanizer-pass-optional) now.
8. Commit with a quoted heredoc so the text is kept as written:

   ```bash
   git commit -m "$(cat <<'EOF'
   <subject>

   <body>
   EOF
   )"
   ```

## Doc updates

Only for structural changes or new external dependencies; skip content-only edits, submodule pointers, and internal `style` or `refactor` changes.

- `AGENTS.md`: only when an undiscoverable workflow, scope policy, deployment target or cross-repository relationship changed; no directory trees or file tables.
- `README.md`: installation steps, symlink targets or external dependencies changed.
- `CLAUDE.md`: an import plus harness-specific rules; never copy `AGENTS.md` into it.
- Edit existing docs only: no new doc files, nothing inside a submodule.
- Show each proposed edit, apply only what the user approves, and stage it with this commit.

## Push (optional)

Only when the user asked for it (`커밋하고 푸시해줘`, `commit and push`, ...).

1. Run in the foreground so an SSH passphrase prompt reaches the user.
2. Push submodules before the parent.
3. On failure: SSH error → suggest `ssh-add`; otherwise relay the error verbatim.

## Summary

After committing (and pushing), print:

```
커밋 완료:
- [submodule] <commit message> (push y/n)
- [parent] <commit message> (push y/n)
파일 N개 변경, +X/-Y줄
```

## Humanizer pass (optional)

Only on request. Skip empty bodies, mostly-bullet or code bodies, `revert`, and submodule pointer summaries. Never touch the subject: its `-다` ending and 50-character limit are format rules.

1. Rewrite the body inline with the smallest changes that remove AI-like prose.
2. Show it and ask: apply, keep the original, or cancel.
3. Recheck facts, the 72-character wrap and the body policy before committing.

## Maintenance

When editing these commit rules, keep [references/gitmessage.md](references/gitmessage.md#maintenance)
aligned with the repository `gitmessage` and `.githooks/commit-msg`, and stage
them together.

## Look up the rest

- Footer tokens, breaking-change notation, type list, example → [references/gitmessage.md](references/gitmessage.md)
- Editing this skill's rules, dotrc `gitmessage` or `.githooks/commit-msg` → [references/gitmessage.md#maintenance](references/gitmessage.md#maintenance)
