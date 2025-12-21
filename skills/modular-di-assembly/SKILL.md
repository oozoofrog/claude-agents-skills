---
name: modular-di-assembly
description: Swift Service 모듈과 Assembly 패턴 구현 가이드. 새 Service 모듈 생성, Assembly 클래스 작성, Dependencies 구조체 정의, 모듈 Public Interface 설계 시 사용.
---

# Service Module Assembly Pattern

각 Service 모듈의 구조와 Assembly 패턴 구현 가이드.

## Service 모듈 구조

```
AuthModule/
├── Sources/
│   ├── Public/
│   │   ├── AuthInterface.swift      # Protocol 정의
│   │   └── AuthAssembly.swift       # Assembly + Dependencies
│   └── Internal/
│       └── AuthManager.swift        # 실제 구현
```

## 1. Public Interface

외부에 노출되는 Protocol 정의.

```swift
// AuthModule/Sources/Public/AuthInterface.swift
import Core

public protocol AuthManaging: Sendable {
    var isAuthenticated: Bool { get async }
    var currentUser: User? { get async }
    func signIn(email: String, password: String) async throws -> User
    func signOut() async
}
```

## 2. Assembly (모듈의 Composition Root)

```swift
// AuthModule/Sources/Public/AuthAssembly.swift
import Core

public struct AuthAssembly {
    // 이 모듈이 필요로 하는 의존성
    public struct Dependencies {
        public let network: NetworkServiceProtocol
        public let secureStorage: SecureStorageProtocol

        public init(
            network: NetworkServiceProtocol,
            secureStorage: SecureStorageProtocol
        ) {
            self.network = network
            self.secureStorage = secureStorage
        }
    }

    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // 모듈의 Public Interface 반환
    public func assemble() -> AuthManaging {
        AuthManager(
            network: dependencies.network,
            storage: dependencies.secureStorage
        )
    }
}
```

## 3. Internal Implementation

외부에 노출되지 않는 Actor 기반 구현체.

```swift
// AuthModule/Sources/Internal/AuthManager.swift
import Core

actor AuthManager: AuthManaging {
    private let network: NetworkServiceProtocol
    private let storage: SecureStorageProtocol
    private var _currentUser: User?

    init(network: NetworkServiceProtocol, storage: SecureStorageProtocol) {
        self.network = network
        self.storage = storage
    }

    var isAuthenticated: Bool { _currentUser != nil }
    var currentUser: User? { _currentUser }

    func signIn(email: String, password: String) async throws -> User {
        let user: User = try await network.request(
            .post("/auth/login", body: ["email": email, "password": password])
        )
        _currentUser = user
        try await storage.save(user.token.data(using: .utf8)!, for: "auth_token")
        return user
    }

    func signOut() async {
        _currentUser = nil
        try? await storage.delete(for: "auth_token")
    }
}
```

## 다른 모듈 정보가 필요한 경우

모듈 간 직접 의존 없이 Core의 작은 Protocol로 연결.

```swift
// PaymentModule/Sources/Public/PaymentAssembly.swift
import Core

public struct PaymentAssembly {
    public struct Dependencies {
        public let network: NetworkServiceProtocol
        public let userIdProvider: UserIdProviding  // Auth 직접 의존 X

        public init(
            network: NetworkServiceProtocol,
            userIdProvider: UserIdProviding
        ) {
            self.network = network
            self.userIdProvider = userIdProvider
        }
    }

    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    public func assemble() -> PaymentProcessing {
        PaymentService(
            network: dependencies.network,
            userIdProvider: dependencies.userIdProvider
        )
    }
}
```

## Assembly 패턴 요약

```
┌─────────────────────────────────────┐
│ ModuleAssembly                      │
│  ├─ Dependencies (struct)           │
│  │   └─ Core Protocols만 의존       │
│  └─ assemble() -> Public Interface  │
└─────────────────────────────────────┘
```

## 새 Service 모듈 체크리스트

- [ ] Public Interface Protocol 생성 (`Sendable` 준수)
- [ ] Assembly struct 생성
- [ ] Dependencies struct 정의 (Core Protocol만 의존)
- [ ] `assemble()` 메서드로 구현체 반환
- [ ] Internal 구현체를 Actor로 구현
