# Claude Code Agents & Skills

Claude Code의 user scope에서 사용하는 커스텀 agents와 skills 모음입니다.

## 설치 방법

`~/.claude/` 디렉토리에 복사하여 사용합니다:

```bash
# agents 복사
cp -r agents/*.md ~/.claude/agents/

# skills 복사
cp -r skills/* ~/.claude/skills/
```

## Agents

| Agent | 설명 |
|-------|------|
| `kent-beck-refactorer` | 켄트 벡의 리팩토링 철학(작은 단계, 행동 보존, Red-Green-Refactor) 기반 코드 개선 에이전트 |
| `swift-tdd-architect` | Swift/SwiftUI 프로젝트를 위한 TDD 기반 아키텍트 에이전트 |
| `swiftui-design-engineer` | SwiftUI 뷰 생성 및 디자인 개선 에이전트 |
| `tech-doc-writer` | 기술 문서 작성 에이전트 |
| `xcode-dev` | Xcode 개발 지원 에이전트 |

## Skills

| Skill | 설명 |
|-------|------|
| `build-environment` | iOS/macOS 빌드 환경 설정 가이드 |
| `code-review` | Swift/iOS 코드 리뷰 기준 및 SwiftLint 규칙 |
| `kent-beck-principles` | 켄트 벡의 TDD/단순 설계/리팩토링 원칙 + 코드 스멜 진단/체크리스트 |
| `project-architecture` | iOS 프로젝트 아키텍처 및 의존성 원칙 |
| `swift-conventions` | Swift 코딩 컨벤션과 아키텍처 원칙 |
| `swiftui-design-system` | SwiftUI 디자인 토큰 시스템과 접근성 체크리스트 |
| `tech-documentation` | 기술 문서 작성 원칙과 템플릿 |
| `weekly-report` | Git 커밋 히스토리 기반 주간보고 생성 |

## Kent Beck 관련 자료

- Agent: `agents/kent-beck-refactorer.md`
- Skill: `skills/kent-beck-principles/SKILL.md` (상세 문서: `PRINCIPLES.md`, `CHECKLIST.md`, `SMELLS.md`)

## 사용 환경

- Claude Code CLI
- Swift/SwiftUI 개발 환경

## 라이선스

MIT License
