# Important Guidelines

<meta>
Document: guidelines.md
Role: Practice Guide
Priority: Medium
Applies To: All development interactions
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

## Maintenance Rules

- **Document unclear code**
  모호한 코드나 이름은 주석으로 설명을 추가하세요.
- **Confirm model changes**
  LLM 모델 버전 변경 시 사용자에게 먼저 확인받으세요.
- **Use modern syntax**
  최신 안정 버전의 언어 문법을 사용하세요.

## Default Behaviors

<default_to_action>
사용자 의도가 불명확할 때는 가장 유용한 행동을 추론하여 진행하세요:

**Core principles:**
- "제안해줘"라고 해도 구현이 의도일 수 있습니다 - 맥락을 고려하세요
- 도구를 사용하여 부족한 정보를 직접 파악하세요
- 제안보다는 구현을 기본으로 하세요

**Always require explicit approval for:**
- 파괴적 작업 (DELETE, DROP, 대규모 삭제)
- 대규모 리팩토링
- API 변경이나 Breaking changes
- 프로덕션 환경 작업
</default_to_action>

## Things to Avoid

- `--no-verify`로 커밋 훅 우회
- 테스트 수정 대신 비활성화
- 컴파일되지 않는 코드 커밋
- 기존 코드 확인 없이 가정하기
- 코드에 시크릿 저장
- 보안 경고 무시
- 코드 리뷰 생략
- 정당한 이유 없이 deprecated API 사용

## Things to Always Do

- 점진적으로 작동하는 코드 커밋
- 진행하면서 계획 문서 업데이트
- 기존 구현에서 학습
- 3회 시도 실패 후 재평가
- 보안 영향 고려
- 엣지 케이스 고려
- 비자명한 결정 문서화
- 사용자 경험 염두

## Emergency Procedures

### When Things Break

1. Don't panic
2. Check recent changes
3. Review error logs
4. Isolate the problem
5. Create minimal reproduction
6. Document findings
7. Implement fix with tests
8. Post-mortem for learning

### Getting Help

- After 3 attempts, ask for guidance
- Provide context and what you've tried
- Share error messages and logs
- Explain your understanding of the problem
- Be open to different approaches

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Process](../process.md) - Problem solving and troubleshooting
- [Quality Assurance](../quality-assurance.md) - Quality gates and testing
- [Security](../security.md) - Security principles and warnings
