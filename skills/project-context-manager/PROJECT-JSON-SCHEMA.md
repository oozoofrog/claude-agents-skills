# project.json 스키마 정의

프로젝트 컨텍스트를 관리하기 위한 `project.json` 파일의 전체 구조입니다.

```json
{
  "projectMeta": {
    "name": "프로젝트명",
    "description": "프로젝트 설명",
    "version": "현재 버전",
    "startDate": "시작일",
    "lastUpdated": "마지막 업데이트 일시",
    "techStack": ["사용 기술 스택"],
    "repository": "저장소 URL"
  },
  "currentStatus": {
    "phase": "현재 개발 단계 (planning/development/testing/deployment)",
    "activeFeature": "현재 작업 중인 기능",
    "lastSession": {
      "date": "마지막 세션 날짜",
      "summary": "마지막 세션 작업 요약",
      "nextSteps": ["다음 단계 작업 목록"]
    },
    "blockers": ["현재 차단 요소"]
  },
  "features": [
    {
      "id": "feature-001",
      "name": "기능명",
      "description": "기능 설명",
      "status": "planned/in-progress/completed/on-hold",
      "priority": "high/medium/low",
      "dependencies": ["의존성 기능 ID"],
      "tasks": [
        {
          "id": "task-001",
          "description": "작업 설명",
          "status": "todo/in-progress/done",
          "assignedDate": "할당일",
          "completedDate": "완료일"
        }
      ],
      "notes": "추가 메모"
    }
  ],
  "issues": [
    {
      "id": "issue-001",
      "title": "이슈 제목",
      "description": "상세 설명",
      "type": "bug/enhancement/technical-debt/question",
      "severity": "critical/high/medium/low",
      "status": "open/in-progress/resolved/closed",
      "createdDate": "생성일",
      "resolvedDate": "해결일",
      "relatedFeature": "관련 기능 ID",
      "resolution": "해결 방법"
    }
  ],
  "designDecisions": [
    {
      "id": "design-001",
      "title": "결정 제목",
      "context": "결정 배경",
      "decision": "결정 내용",
      "alternatives": ["고려한 대안들"],
      "consequences": "예상 결과",
      "date": "결정일",
      "status": "proposed/accepted/deprecated"
    }
  ],
  "architecture": {
    "overview": "아키텍처 개요",
    "components": [
      {
        "name": "컴포넌트명",
        "responsibility": "책임",
        "dependencies": ["의존성"]
      }
    ],
    "dataFlow": "데이터 흐름 설명",
    "diagrams": ["다이어그램 파일 경로"]
  },
  "conventions": {
    "coding": ["코딩 컨벤션"],
    "naming": ["네이밍 규칙"],
    "fileStructure": "파일 구조 설명",
    "gitWorkflow": "Git 워크플로우"
  },
  "environment": {
    "development": {
      "setup": ["개발 환경 설정 단계"],
      "commands": {
        "install": "설치 명령어",
        "run": "실행 명령어",
        "build": "빌드 명령어",
        "test": "테스트 명령어"
      }
    },
    "variables": ["필요한 환경 변수 목록"]
  },
  "changelog": [
    {
      "date": "변경일",
      "version": "버전",
      "changes": ["변경 사항"]
    }
  ],
  "references": [
    {
      "title": "참고 자료 제목",
      "url": "URL",
      "description": "설명"
    }
  ]
}
```

## 섹션별 설명

| 섹션 | 용도 |
|------|------|
| `projectMeta` | 프로젝트 기본 메타 정보 |
| `currentStatus` | 현재 개발 상태 및 마지막 세션 정보 |
| `features` | 기능 목록 및 하위 작업 추적 |
| `issues` | 버그, 개선사항, 기술부채, 질문 추적 |
| `designDecisions` | ADR(Architecture Decision Records) 스타일 설계 결정 기록 |
| `architecture` | 아키텍처 개요 및 컴포넌트 구조 |
| `conventions` | 코딩/네이밍/Git 워크플로우 규칙 |
| `environment` | 개발 환경 설정 및 명령어 |
| `changelog` | 버전별 변경 이력 |
| `references` | 참고 자료 링크 |

## 필드 규칙

### ID 형식
- features: `feature-XXX`
- issues: `issue-XXX`
- design decisions: `design-XXX`
- tasks: `task-XXX`

### 날짜 형식
- ISO 8601: `YYYY-MM-DD`
- 예: `2025-12-23`

### 상태 값

**features.status:**
- `planned` → `in-progress` → `completed`
- `on-hold` (보류)

**issues.status:**
- `open` → `in-progress` → `resolved` → `closed`

**designDecisions.status:**
- `proposed` → `accepted`
- `deprecated` (폐기)
