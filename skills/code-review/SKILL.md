---
name: code-review
description: Swift/iOS 커밋/PR 규칙, SwiftLint 규칙, 코드 리뷰 기준. 커밋, PR 작성, 코드 리뷰 시 자동 적용.
---

# Code Review & Commit Guidelines

Swift/iOS 프로젝트의 커밋, PR, 코드 리뷰 규칙입니다.

## Commit Convention

### 커밋 메시지 형식

프로젝트에서 이슈 트래커를 사용하는 경우:
```
[TICKET-NUMBER] 기능 설명
```

또는 Conventional Commits:
```
type(scope): 설명

feat: 새로운 기능 추가
fix: 버그 수정
refactor: 리팩토링
docs: 문서 수정
test: 테스트 추가/수정
chore: 빌드/도구 변경
```

### 예시
```
[PROJECT-123] 프로필 화면 크래시 수정
feat(auth): 소셜 로그인 기능 추가
fix: 이미지 피커 메모리 누수 수정
```

### 주의사항
- Git 커밋/PR 메시지에 "Generated with Claude Code" 추가 금지
- "Co-Authored-By: Claude" footer 추가 금지

## PR Guidelines

### 필수 포함 사항
- 변경 사항 요약
- 영향받은 모듈 명시
- 연관 이슈 링크 (있는 경우)
- UI 변경 시 스크린샷/영상 첨부

### PR 체크리스트
- [ ] 린터 (SwiftLint 등) 결과 확인
- [ ] 빌드 성공 확인
- [ ] 테스트 성공 확인
- [ ] 보안 이슈 확인
- [ ] 후속 작업 정리

## SwiftLint Rules

프로젝트의 `.swiftlint.yml` 파일을 참조하세요.

### 일반적인 길이 제한
| 항목 | Warning | Error |
|------|---------|-------|
| 줄 길이 | 120자 | 200자 |
| 함수 본문 | 50줄 | 100줄 |
| 파일 길이 | 400줄 | 1000줄 |

### 복잡도
| 항목 | Warning | Error |
|------|---------|-------|
| cyclomatic_complexity | 10 | 20 |
| function_parameter_count | 5 | 8 |
| nesting.type_level | 2 | 3 |

### 권장 활성화 규칙
- `sorted_imports`
- `vertical_parameter_alignment_on_call`
- `force_cast`: warning
- `force_try`: warning
- `identifier_name`: 변수명 규칙
- `type_name`: 타입명 규칙

## Code Review Severity

### Must (필수 수정)
- 크래시 가능성
- 보안 취약점
- 데이터 손실 위험
- 아키텍처 원칙 위반
- 린터 error 레벨 위반

### Should (권장 수정)
- 성능 이슈
- 코드 가독성 저하
- 테스트 누락
- 린터 warning 레벨 위반

### Nit (선택 사항)
- 스타일 개선
- 네이밍 개선 제안
- 리팩토링 제안

## Pre-Commit Checklist

1. 린터 실행 및 수정
2. 변경된 파일 관련 테스트 실행
3. 빌드 확인
4. 커밋 메시지 형식 확인
5. 민감 정보 포함 여부 확인 (API 키, 비밀번호 등)

## Code Review Best Practices

### 리뷰어로서
- 코드의 의도를 먼저 이해
- 질문 형식으로 피드백 ("이렇게 하면 어떨까요?" vs "이건 틀렸어요")
- 구체적인 개선 예시 제공
- 긍정적인 피드백도 함께

### 작성자로서
- PR 설명을 상세히 작성
- 복잡한 로직에 코멘트 추가
- 피드백에 열린 자세로 응답
- 큰 변경은 작은 PR로 분리
