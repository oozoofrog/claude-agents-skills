---
name: modular-di-composition
description: Swift App Composition Root와 Adapter 패턴 구현 가이드. AppDependencies 작성, 모듈 조립, Adapter로 모듈 간 연결, Infrastructure 구현체 생성 시 사용.
---

# App Composition Root Pattern

모든 모듈을 조립하는 단일 지점. 모듈 간 연결은 Adapter로 처리.

## 파일 구조

```
App/
├── Sources/
│   ├── CompositionRoot/
│   │   ├── AppDependencies.swift    # 최종 조립
│   │   └── Adapters.swift           # 모듈 간 연결 Adapter
│   ├── Infrastructure/
│   │   ├── NetworkService.swift     # Core Protocol 구현체
│   │   └── KeychainStorage.swift
│   └── App.swift
```

## AppDependencies

```swift
// App/Sources/CompositionRoot/AppDependencies.swift
import Core
import AuthModule
import PaymentModule
import AnalyticsModule

@MainActor
final class AppDependencies {
    // MARK: - Infrastructure
    private let network: NetworkServiceProtocol
    private let secureStorage: SecureStorageProtocol

    // MARK: - Public Services
    let auth: AuthManaging
    let payment: PaymentProcessing
    let analytics: AnalyticsTracking

    init() {
        // 1. Infrastructure 생성
        self.network = NetworkService(baseURL: Config.apiURL)
        self.secureStorage = KeychainStorage()

        // 2. Auth 모듈 조립
        self.auth = AuthAssembly(
            dependencies: .init(
                network: network,
                secureStorage: secureStorage
            )
        ).assemble()

        // 3. Analytics 모듈 조립
        self.analytics = AnalyticsAssembly(
            dependencies: .init(
                network: network,
                config: .production
            )
        ).assemble()

        // 4. Payment 모듈 조립 (Adapter로 Auth 연결)
        self.payment = PaymentAssembly(
            dependencies: .init(
                network: network,
                userIdProvider: AuthUserIdAdapter(auth: auth)
            )
        ).assemble()
    }
}
```

## Adapters

모듈 간 연결을 위한 Adapter 구현.

```swift
// App/Sources/CompositionRoot/Adapters.swift
import Core
import AuthModule

// Auth → Payment 연결 Adapter
struct AuthUserIdAdapter: UserIdProviding {
    let auth: AuthManaging

    var currentUserId: String? {
        get async { await auth.currentUser?.id }
    }
}

// Auth → Analytics 연결 Adapter
struct AuthAnalyticsAdapter: AnalyticsUserProviding {
    let auth: AuthManaging

    var analyticsUserId: String? {
        get async { await auth.currentUser?.id }
    }

    var userProperties: [String: String] {
        get async {
            guard let user = await auth.currentUser else { return [:] }
            return ["tier": user.tier.rawValue]
        }
    }
}
```

## Testable Init

테스트를 위한 의존성 주입 가능한 생성자.

```swift
// MARK: - Testable Init
extension AppDependencies {
    init(
        network: NetworkServiceProtocol,
        secureStorage: SecureStorageProtocol
    ) {
        self.network = network
        self.secureStorage = secureStorage

        self.auth = AuthAssembly(
            dependencies: .init(network: network, secureStorage: secureStorage)
        ).assemble()

        self.analytics = AnalyticsAssembly(
            dependencies: .init(network: network, config: .test)
        ).assemble()

        self.payment = PaymentAssembly(
            dependencies: .init(
                network: network,
                userIdProvider: AuthUserIdAdapter(auth: auth)
            )
        ).assemble()
    }
}
```

## App Entry Point

```swift
// App/Sources/App.swift
import SwiftUI

@main
struct MyApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}
```

## Composition Root 요약

```
┌─────────────────────────────────────┐
│ AppDependencies                     │
│  ├─ Infrastructure 생성             │
│  ├─ 각 Assembly.assemble() 호출     │
│  └─ Adapter로 모듈 간 연결          │
└─────────────────────────────────────┘
```

## 조립 순서 원칙

1. **Infrastructure 먼저**: Network, Storage 등 기반 서비스
2. **독립 모듈**: 다른 모듈에 의존하지 않는 모듈 (Auth 등)
3. **의존 모듈**: Adapter를 통해 다른 모듈 정보가 필요한 모듈 (Payment 등)

## 체크리스트

- [ ] Infrastructure 구현체 생성
- [ ] 독립 모듈부터 조립
- [ ] 모듈 간 연결이 필요하면 Adapter 생성
- [ ] Testable init 제공
- [ ] App Entry Point에서 AppDependencies 생성
