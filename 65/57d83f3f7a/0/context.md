# Session Context

## User Prompts

### Prompt 1

Implement the following plan:

# Plan: generate-claude-md SKILL.md 3계층 참조 구조로 리팩토링

## Context

현재 `generate-claude-md` 스킬은 2계층 출력 구조(`CLAUDE.md → agent_docs/`)를 사용한다.
이를 3계층(`CLAUDE.md → AGENTS.md → contributing-docs/`)으로 확장하여:

- CLAUDE.md는 Claude 전용 최소 가이드로 유지
- AGENTS.md는 모든 AI 에이전트가 활용할 수 있는 범용 프로젝트 가이드 (agents.md 표준)
- contributing-docs/는...

### Prompt 2

nested 된 CLAUDE.md 파일을 생성하는 분에 대해서도 추가했으면하는데. 이거는 새로운 SKILL을 만드는게 좋을까?

### Prompt 3

[Request interrupted by user for tool use]

