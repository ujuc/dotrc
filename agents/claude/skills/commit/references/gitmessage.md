# Git Commit Message Guide

Single source of truth for commit rules used by the `commit` skill.
When this file changes, also update `~/.config/dotrc/gitmessage`
(the global `commit.template`) so manual edits stay in sync.

## Sources

Synthesized from three primary references, adapted for Korean Conventional
Commits ending in a Korean verb declarative `-다`:

- [thoughtbot — Better Commit Messages with a .gitmessage Template](https://thoughtbot.com/blog/better-commit-messages-with-a-gitmessage-template)
- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
- [adeekshith — git-commit-message.sh rules](https://gist.github.com/adeekshith/cd4c95a064977cdc6c50)

## Principles

- Each commit is a **single, stable change** — the repository must work after
  every commit.
- Commits are **independently reviewable**.
- Reveal *why* you changed something, not just *what* changed.
- Priority: **why > what > how**.

## Format

```
<type>(<scope>): <한국어 제목 -다>

<본문>

<이슈 참조·footer>
```

## Subject line — 7 rules

Each rule is a hard check. Fail any one → rewrite the subject.

1. **50 characters or fewer**, including the `<type>(<scope>):` prefix.
2. **End with a Korean verb declarative `-다`**: `추가하다`, `수정하다`,
   `걷어내다`, `지우다`. Any verb stem is
   fine — the hook checks the literal `다` only. Noun endings (`업데이트`,
   `정리함`) and English subjects fail.
3. **No trailing period.**
4. **Blank line between subject and body** when a body exists.
5. **Subject states *what*, body states *why*.** Do not cram "why" into the
   subject by stacking clauses with `·`, `및`, `그리고`, or `~해`.
6. **Do not list multiple changes in one subject** — split into separate
   commits.
7. **Subject test**: read `이 커밋이 적용되면 [제목]` aloud. If the subject does not naturally describe the resulting change, rewrite it.

## Body

Include a body **whenever the reason for the change is not obvious from the
diff**. For `feat` and `fix`, a body is effectively mandatory.

### Why / How structure

For non-trivial commits, use this two-block structure (from thoughtbot):

```
Why:
- <변경이 필요한 이유 — 문제, 제약, 요구>

How:
- <핵심 해결 방식만 — 구현 디테일은 코드에 맡긴다>
```

For trivial additions to a simple `chore` or `docs` commit, a single free-form
sentence in the body is fine. The template is a **guide, not a wall**.

### Body rules

- Wrap at **72 characters per line**.
- Use `-` for bullet lists.
- Explain **what + why**, not **how**. "How" belongs in the code, not the log.
- Contrast with previous behavior when that clarifies intent.

## Footer

One blank line after the body. Each footer line uses the Conventional Commits
1.0.0 token syntax:

- `<word-token>: <value>` (colon + space) — e.g., `Acked-by: Jane Doe`
- `<word-token> #<value>` (space + hash) — e.g., `Refs #42`
- Tokens use hyphens instead of spaces (`Acked-by`, not `Acked by`).

Common tokens: `Closes #<n>`, `Refs #<n>`, `Acked-by: <name>`,
`Reviewed-by: <name>`.

## Commit types

Per Conventional Commits 1.0.0, plus project-specific notes.

| Type       | Use for                                                  |
|------------|----------------------------------------------------------|
| `feat`     | New user-facing feature or capability                    |
| `fix`      | Bug fix                                                  |
| `refactor` | Code restructuring with no behavior change               |
| `perf`     | Performance improvement with no behavior change          |
| `style`    | Formatting only — whitespace, punctuation, casing        |
| `docs`     | Documentation-only changes                               |
| `test`     | Adding or refactoring tests                              |
| `build`    | Build system, package manager, dependency bumps          |
| `ci`       | CI/CD pipeline configuration                             |
| `chore`    | Housekeeping not covered above — submodule pointer, etc. |

Choose the most specific type. Do **not** default to `chore` when a more
specific type fits.

## Breaking changes

Two notations, either works (use only one per commit):

1. **Suffix `!` on the type/scope**: `feat!:` or `feat(api)!:`
2. **Footer**: `BREAKING CHANGE: <설명>` (uppercase required; `BREAKING-CHANGE`
   is a synonym per the spec).

dotrc is a personal config repo, so breaking changes are rare. The notation is
documented for completeness and for projects that consume this skill.

## Anti-patterns

Detected in recent history — treat these as hard failures and rewrite:

- **Catch-all "서브모듈을 업데이트하다"** with no substantive reason.
  → State *what the submodule changed* and *why* in a one-line body.
- **Multi-change subjects** like `generate-skills frontmatter-spec when_to_use·paths·shell 추가를 반영해 서브모듈을 업데이트하다`.
  → Break into separate commits, or move the list into a Why-bulleted body.
- **Escaping to `chore` when `feat`/`fix`/`refactor` fits.**
- **Subjects over 50 characters** that compress the whole body into the title.

## Argument handling

Caller-provided arguments influence the commit:

- **File paths / globs** → limit which files to stage and commit.
- **Freeform instructions** → influence scope, summary, and body.
- **Combined** → honor both file selection and instructions.
- **Ambiguous files** → always ask the user before staging.

## Prohibitions

- Do NOT add `Co-Authored-By` (the system handles this).
- Do NOT add sign-offs (`Signed-off-by`).
- Do NOT push — commit only, unless push was explicitly requested.

## Examples

### Feature (body required)

```
feat(skills): commit 스킬에 제목 50자 자체검증을 추가하다

Why:
- 최근 제목이 70자 이상으로 이탈하여 원칙 회복이 필요하다
- 서브모듈 커밋이 이유 없는 관용어로 반복되고 있다

How:
- Procedure에 제목 길이·body 유무·결과 서술 테스트 3단 검증을 삽입
- Anti-patterns 섹션으로 실패 사례를 명시화
```

### Fix (body required)

```
fix(zshrc): 플러그인 로드 순서 오류를 수정하다

Why:
- PATH 설정이 zimfw 초기화 후에 실행되어 pyenv·rbenv가 동작하지 않았다

How:
- Tools 섹션을 Plugins 섹션 이전으로 이동
```

### Chore — submodule with real reason

```
chore(agents): generate-skills 중복 감지 기능을 반영하다

Why:
- agent-stuff 서브모듈에서 스킬 중복 감지가 추가되어
  스킬 생성 시 기존 항목 덮어쓰기 사고를 예방할 수 있다
```

### Chore — trivial (body optional)

```
chore: .gitignore에 빌드 캐시 경로를 추가하다
```

Note: submodule pointer updates (`chore(agents): ...`) are **not** trivial —
the pointer movement always reflects real changes inside the submodule, so a
one-line body describing what and why is required. See the body requirement
policy in `SKILL.md`.
