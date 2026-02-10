---
# Guide Metadata (YAML Frontmatter)
# Reference: https://agentskills.io/specification#frontmatter-required
name: "[guide-name]"
description: "[이 가이드의 목적을 한 문장으로 설명]"
version: "1.0.0"

# Optional fields
tags: []
context: |
  [문서의 목적과 범위를 상세히 설명합니다]
last_updated: "YYYY-MM-DD"

# Guide-specific fields
metadata:
  role: "[Role Name]"
  priority: "[high/medium/low]"
  applies-to: "[적용 범위 설명]"
  optimized-for: "[현재 사용 중인 모델명 기록. e.g., Claude Sonnet 4, GPT-4o, Gemini 2.5 Pro]"
---

# [Guide Title]

<!-- Responsibilities: role 에 정의된 역할이 수행해야 할 핵심 행동 지침을 나열합니다 -->
## Responsibilities

- **Action 1**: 설명
- **Action 2**: 설명
- **Action 3**: 설명

## Section 1

[본문 내용]

## Section 2

[본문 내용]

<!-- See Also: 항상 AGENTS.md, CLAUDE.md 를 포함하고, 관련 문서를 추가합니다 -->
## See Also

- [**AGENTS.md**](../../AGENTS.md) - Universal AI agent guide
- [**CLAUDE.md**](../../claude/CLAUDE.md) - Claude-specific guidelines

<!-- 아래는 예시입니다. 관련 문서에 맞게 수정하세요 -->
<!-- - [Related Document](./related.md) - Description -->
