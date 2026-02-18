# Session Context

## User Prompts

### Prompt 1

Implement the following plan:

# Plan: agents/claude/scripts/ 디렉토리 제거

## Context

`agents/claude/scripts/` 디렉토리에는 markdown 문서 포맷을 검증하는 린터(`lint-docs.sh`)와 이를 git pre-commit hook으로 연결하는 스크립트(`pre-commit-lint`)가 있다. 사용자가 이 스크립트들을 제거하려 하므로, 스크립트 파일뿐 아니라 이를 참조하는 모든 곳을 함께 정리해야 한다.

## 삭제 대상 파일

| 파일 | 설명 |
| ----...

