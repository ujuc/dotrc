# Git Commit Message Guide

Detail for the [commit skill](../SKILL.md). Priority in a message: why > what > how.

## Format

```
<type>(<scope>): <한국어 제목 -다>

<본문: Why / How>

<footer>
```

- The `-다` ending is a verb stem plus `다` (`추가하다`, `걷어내다`, `지우다`); noun endings (`업데이트`, `정리함`) and English subjects fail. The dotrc hook checks only the final `다`.
- Subject says what; the body says why. Contrast with the previous behavior when it clarifies intent.

## Types

`feat · fix · refactor · perf · style · docs · test · build · ci · chore` (Conventional Commits 1.0.0). `chore` covers submodule pointers and other housekeeping no other type fits.

## Footer

One blank line after the body. Tokens use hyphens for spaces: `<token>: <value>` (`Acked-by: <name>`, `Reviewed-by: <name>`) or `<token> #<value>` (`Closes #42`, `Refs #13`).

## Breaking changes

Use one notation per commit: `!` after the type or scope (`feat!:`, `feat(api)!:`), or a `BREAKING CHANGE: <설명>` footer (uppercase; `BREAKING-CHANGE` is a synonym).

## Example

```
feat(skills): commit 스킬에 제목 50자 자체검증을 추가하다

Why:
- 최근 제목이 70자 이상으로 이탈하여 원칙 회복이 필요하다
- 서브모듈 커밋이 이유 없는 관용어로 반복되고 있다

How:
- Procedure에 제목 길이·body 유무·결과 서술 테스트 3단 검증을 삽입
- Anti-patterns 섹션으로 실패 사례를 명시화
```

## Maintenance

In dotrc, the root `gitmessage` and `.githooks/commit-msg` are authoritative; keep this skill aligned with them on: the type list, 50/72 limits, the `-다` ending, the Why/How body, footer token syntax, and breaking-change notation. Stage the skill and source changes in the same commit. Ask before changing `gitmessage`; it is used globally.
