# JIRA Integration for Weekly Report

JIRA MCP를 활용한 정확한 차수/영역 조회 방법입니다.

**참고**: JIRA MCP 서버가 연결되어 있는 경우에만 사용됩니다. 연결되지 않은 경우 커밋 메시지 키워드 기반으로 분류합니다.

## JIRA 이슈 조회

커밋에서 추출한 티켓 번호로 JIRA 이슈 상세 정보를 조회합니다.

```
mcp__atlassian-jira__jira_get_issue(issue_key: "PROJECT-123")
```

## 조회할 필드

| 필드 | 용도 | 매핑 |
|------|------|------|
| `fixVersions` | 차수 확인 | 버전명 → 차수 |
| `components` | 영역 확인 | 컴포넌트명 → 영역 매핑 |
| `labels` | 추가 분류 | 레이블 → 영역 힌트 |
| `summary` | 작업 제목 | 커밋 메시지보다 우선 사용 |
| `status` | 상태 확인 | Done/완료 → (완료), 진행중 → (진행) |

## 차수 (fixVersions) 동적 추출 규칙

**추출 규칙:**
1. fixVersions 값에서 버전 번호 패턴 추출
2. 프로젝트 버전 명명 규칙에 맞게 정규화

**일반적인 패턴 매칭 (정규식):**
- `v?(\d+\.\d+)\.?\d*` → 캡처 그룹 1 사용 (예: v1.2.0 → 1.2)
- `Sprint\s*(\d+)` → 스프린트 번호 추출

## 컴포넌트 → 영역 매핑

프로젝트별로 JIRA 컴포넌트와 영역 매핑을 정의하세요.

**예시:**
| JIRA Component | 영역 |
|----------------|------|
| `Frontend` | 기능 개발 |
| `Backend` | 기능 개발 |
| `Infrastructure` | 개발환경 개선 |
| `Testing` | 유지보수 |
| `Documentation` | 리팩토링 |

## 작업 유형 판별 로직

**같은 컴포넌트라도 작업 성격에 따라 다른 영역으로 분류:**

| 작업 유형 키워드 | 분류 영역 |
|----------------|----------|
| `크래시`, `Crash`, `버그`, `Bug`, `Fix`, `수정`, `해결` | 기능 개발 |
| `신규`, `추가`, `기능`, `Feature`, `구현` | 기능 개발 |
| `Refactor`, `리팩토링`, `개선`, `정리`, `문서화` | 리팩토링 |
| `Warning`, `deprecated`, `테스트`, `경고`, `워닝` | 유지보수 |

**판별 순서:**
1. 먼저 컴포넌트로 기본 영역 결정
2. 작업 유형 키워드로 세부 영역 조정

## JIRA 정보 우선순위

1. **차수**: JIRA fixVersions > 사용자 지정 > 날짜 추정
2. **영역**: JIRA components > 커밋 메시지 키워드
3. **제목**: JIRA summary > 커밋 메시지 (요약하여 사용)
4. **상태**: JIRA status > 커밋 날짜 기반 추정

## 예시: JIRA 조회 결과 활용

**JIRA 응답:**
```json
{
  "key": "PROJECT-123",
  "fields": {
    "summary": "로그인 화면 크래시 수정",
    "fixVersions": [{"name": "v1.5.0"}],
    "components": [{"name": "Authentication"}],
    "status": {"name": "Done"}
  }
}
```

**차수 추출:**
- `fixVersions`: `["v1.5.0"]`
- 정규식 `v?(\d+\.\d+)` 적용 → `1.5` 추출
- 결과: `1.5차` 또는 `Sprint 15`

**주간보고 출력:**
```
기능 개발
1.5차
- [PROJECT-123] 로그인 화면 크래시 수정(완료)
```
