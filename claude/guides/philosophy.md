# Philosophy

<meta>
Document: philosophy.md
Role: Philosophy Guide
Priority: High - Foundational principles
Applies To: All development decisions and approaches
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document defines the core development philosophy and guiding principles. These beliefs shape how we approach problems, make decisions, and write code. They provide the "why" behind the technical standards and processes.
</context>

<your_responsibility>
As a developer guided by this philosophy, you must:
- **Question complexity**: Always ask "Is there a simpler way?"
- **Seek clarity**: Never proceed with ambiguous requirements
- **Value maintainability**: Write code that others (including future you) can understand
- **Practice humility**: Ask questions when uncertain, don't assume you know
- **Choose boring**: Prefer proven, stable solutions over cutting-edge experiments
</your_responsibility>

## The Golden Rules (CRITICAL)

- **Ask when unsure** - Do not proceed when uncertain about implementation details
- **Simplicity first** - Do not over-engineer or make things unnecessarily complex
- **Clarity required** - Do not proceed if a request is ambiguous or incomplete
- **Reuse over rebuild** - Prefer stable, widely adopted libraries over custom implementations

## Core Beliefs

- **Incremental progress over big bangs** - Small changes that compile and pass tests
- **Learning from existing code** - Study and plan before implementing
- **Pragmatic over dogmatic** - Adapt to project reality
- **Clear intent over clever code** - Be boring and obvious

## Simplicity Means

<simplicity_definition>
단순함은 게으름이 아니라 명확함입니다. 다음 원칙을 따르세요:

**구조적 단순함:**
- 함수/클래스당 하나의 책임
- 조기 추상화 금지 - 세 번 반복될 때까지 기다리세요
- 똑똑한 트릭 대신 지루하고 명확한 솔루션 선택

**인지적 단순함:**
- 설명이 필요하면 너무 복잡한 것입니다
- 코드를 읽는 사람이 추측할 필요가 없어야 합니다
- 암시적보다 명시적이 낫습니다

**범위 단순함:**
- 요청된 것만 구현하세요
- "하는 김에" 추가 기능을 넣지 마세요
- 미래 요구사항을 예측하여 설계하지 마세요
- 현재 작업에 필요한 최소한의 복잡도만 사용하세요
</simplicity_definition>

<claude4_note>
Claude 4.5는 과잉 설계 경향이 있을 수 있습니다.
추가 파일 생성, 불필요한 추상화, 요청되지 않은 유연성 추가를 경계하세요.
항상 "이것이 정말 필요한가?"를 먼저 질문하세요.
상세한 가이드: [Technical Standards - 과잉 엔지니어링 방지](./technical-standards.md)
</claude4_note>

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Technical Standards](../technical-standards.md) - Code generation and architecture
- [Process](../process.md) - Implementation workflow and planning
