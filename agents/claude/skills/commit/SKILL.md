---
name: commit
description: "한국어 Conventional Commits 규칙에 따라 git 커밋을 생성한다. 서브모듈 변경 감지·우선 커밋, 문서 자동 업데이트, push, 요약까지 포함하며, 프로젝트에 자체 commit 스킬이 있으면 전체 워크플로를 그쪽에 위임한다. /commit, 커밋해줘, 변경사항 커밋, 커밋하고 푸시해줘 요청 시 사용한다."
group: docs
model: sonnet
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git -C:*), Bash(git submodule:*), Bash(bash:*), Read, Edit, Glob
---

# Git Commit

Generate commits per the project's Korean Conventional Commits convention.

## Project skill override

Before running `Format` / `Procedure` below, check whether the current
repo ships its own commit skill and defer to it if so. This lets a project
override the global Korean Conventional Commits convention with its own
rules without editing this user-level skill.

1. **Find the repo root.** Run `git rev-parse --show-toplevel`. If the
   command fails (not inside a git repo), skip this section entirely and
   continue with the user-level workflow.
2. **Probe for a project commit skill.** Check whether
   `<repo-root>/.claude/skills/commit/SKILL.md` exists (use Glob).
3. **If it exists:**
   - Read the file with the Read tool.
   - Announce once to the user (Korean):
     `프로젝트 레벨 commit 스킬을 사용합니다 (<absolute-path>).`
   - Follow that SKILL.md's body for the rest of this invocation. Treat
     it as authoritative — its `description`, `allowed-tools`, and body
     override the user-level rules. Do **not** also run the user-level
     `Format`, `Procedure`, `Doc updates`, `Push`, `Summary`, `Maintenance`,
     `Gemma delegation`, or `Humanizer pass` sections; the project skill
     is intentionally taking over the entire workflow.
   - The user's original arguments (file paths, push hint, humanizer
     hint, ...) remain in conversation context, so the project skill
     can read them as it would normally.
4. **If it does not exist** (or only the directory exists without a
   `SKILL.md` file): silently continue with the rest of this
   user-level skill. Do not announce anything.

**Edge cases:**

- The probe path is always relative to `git rev-parse --show-toplevel`,
  not `pwd`. This makes the override work correctly when the user runs
  `/commit` from a subdirectory.
- Submodules: when the user-level Step 0 dispatches into a submodule,
  the override check is **not re-run** for the submodule. The override
  is per-invocation, not per-repo within an invocation. This avoids
  surprising mid-flow handoffs and keeps the parent invocation's
  authority consistent.
- Worktrees: `git rev-parse --show-toplevel` returns the worktree's
  own root, so each worktree can have its own `.claude/skills/commit/`.

## Format

`<type>(<scope>): <한국어 제목 -다>`

- **scope**: follow the scopes defined in the project's AGENTS.md or imported project instructions.
- **Subject ≤ 50 characters** (including `<type>(<scope>):` prefix).
- **Body wrapped at 72 characters**, blank line separating subject and body.
- **Verb declarative `-다` ending** on the subject — any verb stem, no trailing period.
- Full rule set, type table, footer syntax, breaking-change notation, and
  anti-patterns live in `references/gitmessage.md`. Consult it for any case
  not covered by the one-line summary above.

## Procedure

### Step 0. Detect submodule changes

1. Run `git status` and check whether any submodule is reported as modified (modified content, new commits).
2. If a submodule has changes, **process the submodule first**:
   - Inspect with `git -C <submodule> status` and `git -C <submodule> diff`.
   - Stage and commit inside the submodule using Steps 1–5, 7, and 8 below; skip parent documentation updates.
   - If the user asked for a push, push the submodule first.
3. Once the submodule is done, return to the parent repo and proceed including the updated submodule pointer.

### Steps 1–8. Parent repo commit

1. Read the user's arguments for file paths or instructions.
2. Inspect changes with `git status`, then `git diff --stat` to see file-level scope. Run full `git diff` only for files whose body you actually need to understand — this keeps token usage bounded on large change sets.
3. Run `git log --oneline -10` to learn the recent commit style and scope vocabulary. Increase to `-20` only when the last 10 commits look atypical.
4. **Staging scope**: if the user passed file paths, stage those. If no hints were given and `git status` shows a coherent set (all changes belong to the same logical unit), proceed. If unrelated changes are mixed in — or the intended subset is ambiguous — ask before staging.
5. Stage only the intended files with `git add`.
6. If structural changes are detected, run an incremental doc update (see "Doc updates" below).
7. **Draft the message, then self-check before committing.** Apply all three checks in order — failing any one means rewrite the draft:

   1. **Subject length ≤ 50 characters** (including `<type>(<scope>):` prefix). Verify with `printf '%s' '<subject>' | wc -m` — Unicode character count, not bytes. `echo -n` is unreliable across shells; always use `printf '%s'`.
   2. **Body required?** Follow the policy below. If the change requires a body and the draft has none, add a Why / How block. If the change is trivial and the draft has a body, consider removing it.
   3. **Completion test**: read `이 커밋이 적용되면 [제목]` aloud. If it does not describe the resulting change naturally, rewrite the subject.

   **Body requirement policy:**

   | Type                                   | Body                                                                        |
   |----------------------------------------|-----------------------------------------------------------------------------|
   | `feat`, `fix`                          | **Always** — at minimum a single "Why" line                                 |
   | `refactor`, `perf`                     | When the motivation (structure, perf target) is not obvious from the diff  |
   | `docs`, `style`, `test`, `build`, `ci` | Optional                                                                    |
   | `chore(agents)` (submodule pointer)    | **One-line summary** of what changed in the submodule and why — no "업데이트하다"만 |
   | Other `chore`                          | Optional                                                                    |

   **After the three-check pass, if the user hinted `humanize` / `휴머나이저` / `AI 흔적` / `다듬어서`, run the "Humanizer pass (optional)" section before Step 8.**

8. Commit using a heredoc:

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <한국어 제목>

<body — follow the Body requirement policy above>
EOF
)"
```

## Doc updates

After staging, inspect documentation only for structural changes or new external dependencies. Skip content-only edits, submodule pointer updates, and internal `style` or `refactor` changes.

- Update `AGENTS.md` only when an undiscoverable workflow, scope policy, deployment target, or cross-repository relationship changed. Do not add directory trees or file tables that the repository exposes directly.
- Update `README.md` when installation steps, symlink targets, or external dependencies changed.
- Keep `CLAUDE.md` as an import plus harness-specific rules; do not duplicate `AGENTS.md` content there.
- Show any proposed documentation edit to the user, apply only the approved change, and stage it with the intended commit.

## Push (optional)

If the user explicitly asks to push as part of the request (`커밋하고 푸시해줘`, `commit and push`, ...):

1. **Run in the foreground** (so the SSH passphrase prompt actually reaches the user).
2. If submodules exist, push the submodule first, then the parent repo.
3. On push failure:
   - SSH-related error → suggest the user run `ssh-add`.
   - Other errors → relay the error message verbatim.
4. Do NOT push when push wasn't explicitly requested.

## Summary

After commit (and push, if any), output a concise summary:

```
커밋 완료:
- [submodule] <commit message> (push y/n)
- [parent] <commit message> (push y/n)
파일 N개 변경, +X/-Y줄
```

The summary block is shown to the user, so the labels stay in Korean.

## Prohibitions

- Do NOT add `Co-Authored-By` (the system handles this).
- Do NOT stage files when the intended set is ambiguous — ask first instead of guessing.
- Do NOT modify docs inside a submodule.
- Do NOT create new doc files (incremental edits to existing docs only).
- Do NOT push unless explicitly requested.
- Do NOT pack multiple changes into one subject with `·`, `및`, `그리고` — split into separate commits instead.
- Do NOT commit submodule pointer updates with a body-less catch-all subject (`서브모듈을 업데이트하다` alone). Always include a one-line body describing *what the submodule changed and why*.
- Do NOT default to `chore` when `feat` / `fix` / `refactor` / `perf` actually fits.
- Do NOT run humanizer on the commit subject — the `-다` verb-declarative ending is a format rule, not prose, and any edit risks the 50-char budget.

## Maintenance — rule source sync

`references/gitmessage.md` is the single source of truth for commit rules.
Whenever it is edited, also update `~/.config/dotrc/gitmessage`
(the global `commit.template`, used when the user runs `git commit` in an
editor). Items that must stay aligned across both files:

- Type list (`feat · fix · refactor · perf · style · docs · test · build · ci · chore`)
- 50 / 72 character limits
- `-다` verb declarative ending rule
- Body "Why / How" hint structure
- Footer token syntax (`Closes #`, `Refs #`, `Acked-by:`)
- Breaking change notation (`<type>!:` or `BREAKING CHANGE:` footer)

Stage both files together in the same commit so the two views never diverge.

## Gemma delegation (optional)

For very large changes (`git diff --cached --shortstat` ≥ 500 lines, ≥ 10 files changed, or the user gives a hint like `큰 diff` / `요약해서 커밋` / `gemma로 정리`), the body draft can be pre-summarized by Gemma through local Ollama. The subject and final body remain Claude-authored and reviewed.

Call pattern, fallback rules, and result usage follow `references/gemma-delegation.md`.

## Humanizer pass (optional)

Run only when the user asks to humanize the commit text. Skip empty bodies, structured bodies whose lines are mostly bullets or code, `revert`, and `chore(agents)` pointer summaries.

1. Rewrite the body inline with the smallest wording changes that remove AI-like prose; never include the subject.
2. Show the rewritten body and ask whether to apply it, keep the original, or cancel.
3. Recheck factual fidelity, the 72-character wrap, and the body requirement before committing.

The subject is never humanized because its `-다` ending and 50-character limit are format constraints.
