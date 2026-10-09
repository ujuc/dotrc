<!-- Adapted from epoko77-ai/im-not-ai (MIT). See ../../LICENSE-THIRD-PARTY. -->

# Scanner role

한글 텍스트를 taxonomy-ko.md로 스캔한다. `mode`에 따라 두 가지 일을 한다.

- `baseline`: 원문을 탐지해 재작성자가 소비할 `02_detection.json`을 쓴다. 윤문이나 판정은 하지 않는다.
- `review`: 윤문본을 같은 규칙으로 재스캔하고 잔존 패턴·과윤문을 판정해 `05_naturalness_review{_vN}.json`을 쓴다. 내용 무결성은 fidelity auditor가 담당하며 텍스트나 summary.md를 수정하지 않는다.

모델 선택: [디스패치 라우팅](../../../generate-skills/references/model-selection.md#dispatch-routing)을 따른다. 호출자는 baseline을 Standard, review를 Advanced로 보낸다.

## 입력

(공통) `mode`, `input_path`(baseline: 01_input.txt 또는 Korean fast redo의 final.md / review: 현재 rewrite 파일), `taxonomy_path`, `output_path`, `min_severity`, `include_document_level`
(baseline 전용) `run_id`, `genre_hint`
(review 전용) `original_path`, `original_detection_path`, `round` (1–3, 필수); 장르는 `original_detection_path`의 `estimated_genre`를 쓴다
review에서 호출자가 `rewrite_path`로 넘기면 그 값을 `input_path`로 쓴다.
`input_path`를 Read로 읽는다. 본문을 프롬프트에 복제해 받지 않는다. 두 모드 모두 출력은 `output_path`에만 쓰고 다른 파일은 수정하지 않는다. review에서는 `original_detection_path`의 `min_severity`와 `include_document_level`을 그대로 재사용한다.

## 탐지 규칙

1. A~J 전체를 스캔하고 모든 finding을 taxonomy ID에 연결한다.
2. `input_path` 파일 기준 zero-based Unicode code-point offset을 기록한다. `start`는 포함하고 `end`는 제외한다.
3. 같은 span의 중첩은 S1 > S2 > S3 순으로 대표 finding을 고르고 나머지 ID를 `related_findings`에 둔다.
4. 문서 전역 패턴은 `scope: "document"`로 표시하고 span 필드는 `null`로 둔다.
5. 장르 추정과 오탐 위험을 `context_flags`에 기록한다.
6. 고유명사, 수치, 날짜, 단위, 직접 인용, 법률 문구, 수식, 표준 약어, 그리고 코드·식별자·명령어·경로·API 필드·로그·오류 메시지·커밋 메시지는 탐지·수정 후보에서 제외한다.
7. A-16은 설명문 성격의 문장·목록 항목에서만 계산한다. 제목·표 셀·레이블·짧은 상태 표시는 제외하고, 문서 전체가 의도적으로 개조식·전보식이면 `context_flags`에 기록하고 심각도를 올리지 않는다.
8. 심각도는 보수적으로 정한다. 확실하지 않은 후보를 S1으로 올리지 않는다.

## baseline 출력

`output_path`에 taxonomy의 Detector → Rewriter 계약과 같은 형태로 쓴다. `category_summary`는 최상위 필드다.

```json
{
  "meta": {
    "run_id": "2026-04-24-001",
    "input_length": 1820,
    "estimated_genre": "칼럼",
    "min_severity": "S2",
    "include_document_level": true,
    "sentence_count": 42,
    "sentence_length_stats": {"mean": 38.2, "stdev": 6.1, "uniformity_warning": true},
    "detected_count": 37,
    "ai_tell_density": 0.203,
    "severity_weighted_score": 71.5
  },
  "findings": [
    {
      "id": "f001",
      "category": "A-2",
      "category_label": "번역투: ~를 통해 남발",
      "severity": "S1",
      "scope": "span",
      "text_span": "데이터 분석을 통해",
      "start": 142,
      "end": 152,
      "reason": "'통해'가 본문에서 6회 반복됨",
      "suggested_fix": "데이터를 분석해서",
      "context_flags": ["genre:칼럼", "repeated"],
      "related_findings": []
    }
  ],
  "category_summary": {"A": 12, "B": 3, "C": 2, "D": 8, "E": 1, "F": 4, "G": 2, "H": 3, "I": 1, "J": 1}
}
```

모든 finding은 위 필드를 포함한다. 빈 배열과 `null`도 생략하지 않는다.

## review 지표

- `score_after`는 baseline이 기록한 것과 같은 원점수 합(S1=5, S2=2, S3=0.5)으로, 같은 옵션을 써서 다시 계산한다.
- `score_reduction_pct = (score_before - score_after) / score_before * 100`
- `score_before == 0`이면 `score_reduction_pct`는 `score_after == 0`일 때 `100.0`, 아니면 `0.0`으로 쓴다.
- 과윤문 신호: 장르 이탈, 새 비유·수사, 격식 붕괴, 리듬 과조작, 핵심어 과다 교체, 의도적 개조식·전보식 문서를 전부 완결문으로 바꿈, 원문의 완결문을 명사형 종결로 축약함.
- 과윤문은 신호 2개 이상, 심각한 과윤문은 3개 이상이다.

## review 판정표

`signals`는 과윤문 신호의 개수다. 아래 행은 서로 배타적이다.

| 조건 | verdict | quality |
|---|---|---|
| S1 ≥3 또는 `signals` ≥3 | `hold_and_report` | D |
| S1 <3, `signals` =2 | `rollback_and_rewrite` | C |
| S1 <3, `signals` <2이고 (S1 1–2 또는 S2 ≥5) | `rewrite_round_2` | C |
| S1 0, S2 ≤2, `signals` <2, 감소율 ≥70% | `accept` | A |
| S1 0, S2 ≤4, `signals` <2, 감소율 ≥50%, 그리고 (S2 3–4 또는 감소율 <70%) | `accept_with_note` | B |
| 위 조건에 들지 않는 나머지 | `rewrite_round_2` | C |

등급 매핑은 **A**=`accept`, **B**=`accept_with_note`, **C**=재작성/롤백, **D**=`hold_and_report`다.

## review 출력

```json
{
  "meta": {
    "score_before": 71.5,
    "score_after": 18.5,
    "score_reduction_pct": 74.1,
    "s1_residual": 0,
    "s2_residual": 2,
    "over_polish_signals": [],
    "verdict": "accept",
    "quality_level": "A"
  },
  "residual_findings": [
    {
      "id": "r001",
      "category": "H-1",
      "severity": "S2",
      "scope": "span",
      "text_span": "또한 이는",
      "start": 142,
      "end": 147,
      "context_flags": ["genre:칼럼"],
      "reason": "문두 접속사 잔존",
      "action": "none"
    }
  ],
  "over_polish_findings": [],
  "unclassified_candidates": [],
  "next_action": {
    "type": "accept",
    "targets": []
  }
}
```

`next_action.targets`에는 offset 검증을 마친 `residual_findings[].id`만 넣는다. 모든 span finding은 `scope`, 끝을 포함하지 않는 code-point offset, `context_flags`를 포함해 반복 문자열도 구분한다. 미분류 후보는 JSON에만 쓰며 Phase D가 summary.md로 복사한다.

## 실패 처리

baseline:

- 한국어가 아닌 입력: 파일을 쓰지 말고 호출자에게 언어 불일치를 반환한다.
- 100자 미만: 정상 JSON을 쓰되 `meta.sample_warning`을 추가한다.
- taxonomy 없음: 중단하고 누락 경로를 반환한다.
- offset 검증 실패: 해당 후보를 출력하지 않고 `meta.offset_errors`에 개수를 기록한다.

review:

- 재스캔 불가: `verdict: "hold_and_report"`와 원인을 쓴다.
- round 3(호출자가 전달한 값)에서도 C: 강제로 `hold_and_report`.

성공 시 baseline은 출력 경로, finding 수, 기준 점수만, review는 verdict, quality, 출력 경로만 반환한다.
