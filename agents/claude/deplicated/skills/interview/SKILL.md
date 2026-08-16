---
name: interview
description: Interview user in-depth to create a detailed specification document. Use when the user asks to "interview me", "인터뷰해줘", "스펙 작성해줘", "요구사항 정리해줘", or needs to create a detailed spec through interactive Q&A.
argument-hint: [instructions]
allowed-tools: AskUserQuestion, Write
model: sonnet
version: 1.0.0
metadata:
  role: "Interactive Requirements Gathering"
  priority: "High"
  applies-to: "Any project requiring detailed requirements analysis"
  optimized-for: "Claude 4.5 (Sonnet/Opus)"
  last-updated: "2026-02-01"
  context: |
    This skill is auto-discovered by Claude when users need to create detailed specifications
    through interactive interviews. It uses the AskUserQuestion tool to conduct in-depth Q&A
    sessions, then generates comprehensive spec files.
---

# Interview Skill

This skill conducts in-depth interviews with users to create detailed specification documents.

## Purpose

The interview skill helps users:

- **Clarify requirements**: Ask probing questions about technical implementation
- **Explore UI/UX**: Gather detailed user experience requirements
- **Identify concerns**: Uncover potential issues and tradeoffs
- **Document decisions**: Create comprehensive specification files

## Workflow

This skill is designed to integrate with a multi-stage development workflow:

1. **Interview** (this skill) → Create detailed spec through Q&A
2. **Plan Mode** → Generate implementation plan from spec
3. **Implementation** → Execute plan with coding agent

## Instructions

### Phase 1: Receive Instructions

1. Accept user-provided instructions through `$ARGUMENTS` parameter
2. Parse and understand the scope of the specification needed
3. Identify key areas that require clarification

### Phase 2: Conduct In-Depth Interview

**Interview Guidelines**:

1. **Use AskUserQuestion tool** for every clarification needed
2. **Ask non-obvious questions** - Don't ask things that are already clear
3. **Cover all critical areas**:
   - Technical implementation details
   - Architecture and design patterns
   - UI/UX requirements and user flows
   - Performance and scalability concerns
   - Security considerations
   - Error handling strategies
   - Testing approach
   - Deployment and maintenance
   - Edge cases and tradeoffs

4. **Continue iteratively** until all aspects are thoroughly explored
5. **Dig deeper** when answers are vague or incomplete
6. **Challenge assumptions** to uncover hidden requirements

**Question Quality**:

- ✅ "사용자가 로그인 실패 3회 후에는 어떻게 처리할까요? 계정 잠금? 대기 시간?"
- ✅ "API 응답 시간 SLA는? 타임아웃 전략은?"
- ❌ "로그인 기능이 필요한가요?" (너무 명확한 질문)

### Phase 3: Create Specification Document

Once the interview is complete:

1. **Synthesize all gathered information**
2. **Write comprehensive spec file** using the Write tool
3. **Structure the document** with clear sections:
   - Overview/Purpose
   - Requirements (Functional & Non-functional)
   - Technical Architecture
   - UI/UX Design
   - Data Models
   - API Specifications
   - Error Handling
   - Security Considerations
   - Performance Requirements
   - Testing Strategy
   - Deployment Plan
   - Open Questions/Future Considerations

4. **Include context from interview** - Reference user's answers
5. **Highlight tradeoffs and decisions** made during discussion
6. **Suggest file name**: `spec-{feature-name}-{date}.md`

## Example Usage

**User Request**:

```
인터뷰해줘. 새로운 사용자 인증 시스템을 만들려고 해.
```

**Interview Flow**:

1. Ask about authentication method (OAuth, JWT, session-based?)
2. Ask about password requirements and security policy
3. Ask about MFA requirements
4. Ask about session management and timeout strategy
5. Ask about error handling (failed login, expired tokens)
6. Ask about user flows (signup, login, logout, password reset)
7. Ask about integration points (existing systems, APIs)
8. Ask about performance requirements (concurrent users, response time)
9. Ask about monitoring and logging needs
10. ... (continue until complete)

**Output**:

- Detailed spec file: `spec-user-authentication-2026-02-01.md`

## Tips for Effective Interviews

### For Users

- **Be specific**: Provide context and constraints upfront
- **Think ahead**: Consider edge cases when answering
- **Ask back**: If unsure, ask Claude to explain the question
- **Iterate**: Don't expect perfection in first draft

### For Claude

- **Be thorough**: Don't skip obvious areas just because they seem standard
- **Be persistent**: Keep asking until answers are clear
- **Be practical**: Focus on actionable requirements
- **Be structured**: Group related questions together
- **Confirm understanding**: Summarize key points before moving to next area

## Language Policy

- **Questions**: Use the same language as user's request (Korean ↔ Korean, English ↔ English)
- **Spec document**: Default to user's language unless specified otherwise
- **Technical terms**: Use industry-standard English terms even in Korean docs

## Integration with Other Skills

This skill works best when combined with:

- **Plan Mode**: Use generated spec to create detailed implementation plan
- **commit**: Commit the spec file with proper message
- **review**: Review generated spec for completeness

## See Also

- [Planning workflow](../guides/process.md) - How to use specs in development process
- [Documentation standards](../guides/documentation-guidelines.md) - Spec writing best practices
