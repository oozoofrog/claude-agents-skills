# LLM Settings

Claude Code, Codex CLI, OpenCode에서 사용하는 커스텀 agents와 skills 모음입니다.

## 지원 도구

| 도구 | 에이전트 경로 | 스킬 경로 |
|------|--------------|----------|
| Claude Code | `~/.claude/agents/` | `~/.claude/skills/` |
| Codex CLI | `~/.codex/agents/` | `~/.codex/skills/` |
| OpenCode | - | `~/.config/opencode/skill/` |

## 설치 방법

동기화 스크립트를 사용하여 설치합니다:

```bash
# 모든 도구로 동기화
./sync-config.sh push

# 특정 도구만 동기화
./sync-config.sh push --tools claude
./sync-config.sh push --tools claude,codex

# 미리보기 (dry-run)
./sync-config.sh push --dry-run

# 현재 상태 확인
./sync-config.sh status

# 도구에서 프로젝트로 가져오기
./sync-config.sh pull --tools claude
```

## Agents

| Agent | 설명 |
|-------|------|
| `app-design-architect` | 디터 람스의 디자인 철학 기반 앱 디자인 아키텍트 |
| `kent-beck-refactorer` | 켄트 벡의 리팩토링 철학(작은 단계, 행동 보존, Red-Green-Refactor) 기반 코드 개선 |
| `linus-torvalds-reviewer` | Linus Torvalds 스타일의 직설적인 코드 리뷰어 |
| `swift-concurrency-advisor` | Swift Concurrency (async/await, Actor) 전문 어드바이저 |
| `swift-tdd-architect` | Swift/SwiftUI 프로젝트를 위한 TDD 기반 아키텍트 |
| `tech-doc-writer` | 기술 문서 작성 에이전트 |
| `xcode-dev` | Xcode 개발 지원 에이전트 |

## Skills

### 아키텍처

| Skill | 설명 |
|-------|------|
| `modular-di-overview` | Swift 6 모듈화 DI 아키텍처 개요 및 Core 모듈 설계 |
| `modular-di-assembly` | Service 모듈과 Assembly 패턴 구현 가이드 |
| `modular-di-composition` | App Composition Root와 Adapter 패턴 구현 |
| `modular-di-swiftui` | SwiftUI에서 Modular DI 통합 가이드 |
| `modular-di-testing` | Modular DI 아키텍처 테스트 전략 |
| `project-architecture` | iOS 프로젝트 아키텍처 및 의존성 원칙 |

### 개발

| Skill | 설명 |
|-------|------|
| `build-environment` | iOS/macOS 빌드 환경 설정 가이드 |
| `code-review` | Swift/iOS 코드 리뷰 기준 및 SwiftLint 규칙 |
| `swift-conventions` | Swift 코딩 컨벤션과 아키텍처 원칙 |
| `swiftui-design-system` | SwiftUI 디자인 토큰 시스템과 접근성 체크리스트 |

### 방법론

| Skill | 설명 |
|-------|------|
| `tdd-tiny-refactoring-principles` | TDD/작은 리팩토링 원칙 + 코드 스멜 진단/체크리스트 |

### 문서화 & 보고

| Skill | 설명 |
|-------|------|
| `project-context-manager` | 프로젝트 컨텍스트 관리 (project.json) |
| `tech-documentation` | 기술 문서 작성 원칙과 템플릿 |
| `weekly-report` | Git 커밋 히스토리 기반 주간보고 생성 |

## TDD/리팩토링 관련 자료

- Agent: `agents/kent-beck-refactorer.md`
- Skill: `skills/tdd-tiny-refactoring-principles/SKILL.md`
  - `PRINCIPLES.md` - 핵심 원칙
  - `CHECKLIST.md` - 체크리스트
  - `SMELLS.md` - 코드 스멜 & 패턴

## 사용 환경

- Claude Code CLI
- Codex CLI (OpenAI)
- OpenCode
- Swift/SwiftUI 개발 환경

## 라이선스

MIT License
