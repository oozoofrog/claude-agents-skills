---
name: project-architecture
description: iOS 프로젝트 아키텍처, 계층 구조, 의존성 원칙. 아키텍처 질문, 모듈 구조 파악, 의존성 분석 시 자동 적용.
---

# iOS Project Architecture

iOS/macOS 프로젝트의 일반적인 아키텍처와 모듈 구조 가이드입니다.

## Layer Architecture

일반적인 iOS 프로젝트의 계층 구조:

```
Foundation/Core: Common, DesignSystem, SharedAssets, DependencyContainer
      ↓
Shared Base: SharedBase (App, App Extension 공통 코드)
      ↓
App Base: AppBase (App 전용 공통 코드)
      ↓
Service Base: ServiceBase (서비스 간 공유 모듈)
      ↓
Feature Modules: Profile, Settings, Home, Search 등
      ↓
App Target: MainApp, NotificationServiceExtension, ShareExtension 등
```

## Project Structure Detection

프로젝트 구조를 파악하기 위한 명령어:

```bash
# Xcode 프로젝트 의존성 확인
xcodebuild -list -project YourProject.xcodeproj

# 워크스페이스 스킴 목록
xcodebuild -list -workspace YourWorkspace.xcworkspace

# SPM 의존성 그래프
swift package show-dependencies

# Tuist 프로젝트 그래프 (Tuist 사용 시)
tuist graph
```

## Dependency Principles

### 하향식 의존만 허용
```
Feature → AppBase → SharedBase → Core
```

### 서비스 간 직접 참조 금지
```swift
// ❌ Profile 모듈에서 불가
import SearchFeature

// ✅ 공유 로직은 AppBase에 프로토콜 선언 후 DependencyContainer로 주입
protocol SearchServiceProtocol {
    func search(query: String) async throws -> [SearchResult]
}
```

### 공유 로직 패턴
1. Base 모듈에 프로토콜 선언
2. 구현체를 DependencyContainer로 등록
3. 필요한 모듈에서 주입받아 사용

## Common Module Types

| Layer | 역할 | 예시 |
|-------|------|------|
| Core | 공통 유틸리티, 확장 | Common, Extensions, Utilities |
| DesignSystem | UI 컴포넌트, 토큰 | DesignSystem, UIComponents |
| SharedAssets | 이미지, 색상, 문자열 | Assets, Resources |
| DI | 의존성 주입 | DependencyContainer, Swinject |
| Network | API 클라이언트 | NetworkKit, APIClient |
| Data | 저장소, 캐시 | DataStore, Repository |
| Feature | 기능 모듈 | Profile, Settings, Home |

## Module Structure (SPM)

```
MyProject/
├── Package.swift
├── Sources/
│   ├── Core/
│   ├── DesignSystem/
│   ├── Features/
│   │   ├── Profile/
│   │   ├── Settings/
│   │   └── Home/
│   └── App/
└── Tests/
    ├── CoreTests/
    └── FeatureTests/
```

## Module Structure (Tuist)

```
MyProject/
├── Tuist/
│   └── ProjectDescriptionHelpers/
├── Projects/
│   ├── App/
│   │   └── Project.swift
│   ├── Core/
│   │   └── Project.swift
│   └── Features/
│       ├── Profile/
│       └── Settings/
└── Workspace.swift
```

## Adding New Module Checklist

1. 적절한 위치에 모듈 디렉토리 생성
2. `Package.swift` 또는 `Project.swift`에 모듈 정의 추가
3. 적절한 계층에 의존성 설정
4. 서비스 간 직접 참조 피하기
5. 공유 로직은 Base 모듈에 프로토콜로 추상화
6. 테스트 타겟 생성

## Architecture Patterns

### Feature Module 구조 (MVVM)
```
Feature/
├── Sources/
│   ├── Presentation/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── Domain/
│   │   ├── Models/
│   │   └── UseCases/
│   └── Data/
│       ├── Repositories/
│       └── DataSources/
└── Tests/
```

### Coordinator Pattern
```swift
protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    func start()
}
```

## Dependency Analysis

프로젝트의 의존성을 분석하려면:

1. **Import 문 검색**
   ```bash
   grep -r "^import " Sources/ | sort | uniq -c | sort -rn
   ```

2. **순환 의존성 확인**
   - A → B → C → A 형태의 순환 참조 없는지 확인
   - 순환 발견 시 프로토콜로 의존성 역전

3. **모듈 크기 분석**
   ```bash
   find Sources/ -name "*.swift" | xargs wc -l | sort -n
   ```

## Anti-Patterns

### ❌ 피해야 할 패턴
- Feature 모듈 간 직접 의존
- Core 모듈이 Feature 모듈 참조
- 거대한 단일 모듈 (God Module)
- 순환 의존성

### ✅ 권장 패턴
- 프로토콜 기반 의존성 역전
- 단방향 의존 흐름
- 작은 단위의 모듈 분리
- 명확한 모듈 책임
