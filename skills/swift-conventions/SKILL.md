---
name: swift-conventions
description: Swift 코드 작성 시 적용할 코딩 컨벤션과 아키텍처 원칙. Swift/SwiftUI 코드 작성, 리뷰, 리팩토링 시 자동 적용.
---

# Swift Coding Conventions

Swift/SwiftUI 프로젝트에서 일관된 코드 품질을 유지하기 위한 컨벤션입니다.

## Target Versions

- **Swift**: 6.0+
- **iOS**: 18.0+ (또는 프로젝트 요구사항에 맞춤)
- **Xcode**: 16.0+

## Formatting

- **들여쓰기**: 4-space (탭 사용 금지)
- **타입 이름**: UpperCamelCase (예: `UserProfile`, `WorkoutSession`)
- **멤버 이름**: camelCase (예: `userName`, `fetchWorkouts()`)
- **상수/변수**: camelCase (예: `let maxRetryCount = 3`)
- **열거형 케이스**: camelCase (예: `.loading`, `.failed`)

## Documentation

- 중요한 public API에는 `///` DocC 주석 사용
- 복잡한 로직에는 인라인 주석으로 "왜" 설명
- 매직 넘버 대신 명명된 상수 사용

## Architecture (MVVM)

### View Layer
- SwiftUI Views는 **thin**하게 유지
- 비즈니스 로직 없이 렌더링에만 집중
- 복잡한 뷰는 작은 컴포넌트로 분해

### ViewModel Layer
- 상태(State)와 비즈니스 로직 담당
- `@Observable` 또는 `ObservableObject` 사용
- View와 1:1 또는 N:1 관계

### Model Layer
- 순수 데이터 구조
- Value types 선호 (struct/enum)

## Dependency Injection

- **Protocol-driven DI** 패턴 사용
- 외부 시스템은 프로토콜로 추상화:
  - API 클라이언트
  - 저장소 (UserDefaults, CoreData, etc.)
  - 시간/날짜 (Clock protocol)
  - UUID 생성
  - Analytics, Logging

```swift
// Good
protocol WorkoutRepository {
    func fetch() async throws -> [Workout]
}

class WorkoutViewModel {
    private let repository: WorkoutRepository

    init(repository: WorkoutRepository) {
        self.repository = repository
    }
}

// Bad - 직접 의존
class WorkoutViewModel {
    func fetch() async throws -> [Workout] {
        return try await URLSession.shared.data(from: url)
    }
}
```

## Concurrency (Swift 6)

### Strict Concurrency
- Swift 6의 **complete strict concurrency checking** 활성화 권장
- `Sendable` 준수 필수 (데이터 레이스 방지)
- Actor isolation 명확히 정의

### MainActor 규칙
- UI 상태 변경은 반드시 `@MainActor`에서 실행
- ViewModel은 `@MainActor` 또는 `@Observable` 사용
- 비동기 작업은 격리하고 취소 가능하게

```swift
@MainActor
@Observable
class WorkoutViewModel {
    var workouts: [Workout] = []
    var isLoading = false

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            workouts = try await repository.fetch()
        } catch {
            // handle error
        }
    }
}
```

### Task 관리
- 뷰 생명주기에 맞춰 Task 취소
- `task(id:)` 또는 `@State private var task: Task<Void, Never>?` 활용
- `withTaskCancellationHandler`로 취소 처리

### Actor 사용
- 공유 mutable 상태는 Actor로 보호
- `nonisolated` 키워드로 필요시 격리 해제

```swift
actor DataCache {
    private var cache: [String: Data] = [:]

    func get(_ key: String) -> Data? {
        cache[key]
    }

    func set(_ key: String, data: Data) {
        cache[key] = data
    }
}
```

## Type Design

- **Value types 선호**: 도메인 모델은 struct/enum
- **싱글톤 최소화**: 필요시 프로토콜로 래핑
- **전역 상태 회피**: 명시적 의존성 주입
- **불변성 선호**: `let` > `var`, 필요할 때만 가변

## Error Handling

- 의미 있는 Error 타입 정의
- Result 타입 또는 async throws 일관되게 사용
- 복구 가능한 에러와 불가능한 에러 구분

## Testing Considerations

- 테스트하기 어려우면 설계 변경 (seams 도입)
- Test doubles: Fake/Spy 선호 (heavy mocking 회피)
- 시간 의존 코드는 Clock 프로토콜 주입
- Swift Testing framework 사용 권장 (`@Test`, `#expect`)
