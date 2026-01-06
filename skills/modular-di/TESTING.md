---
name: modular-di-testing
description: Modular DI 아키텍처 테스트 전략 가이드. Mock 생성, 모듈 단위 테스트, 통합 테스트, Assembly 테스트 작성 시 사용.
---

# Testing Modular DI Architecture

Modular DI 아키텍처에서의 테스트 전략.

## Mock 생성

Core Protocol에 대한 Mock 구현.

```swift
// AuthModuleTests/Mocks/MockNetworkService.swift
import Core

final class MockNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    var requestHandler: ((Endpoint) async throws -> Any)?

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let result = try await requestHandler?(endpoint) as? T else {
            throw MockError.notConfigured
        }
        return result
    }
}

// MockSecureStorage
final class MockSecureStorage: SecureStorageProtocol, @unchecked Sendable {
    private var storage: [String: Data] = [:]

    func save(_ data: Data, for key: String) async throws {
        storage[key] = data
    }

    func load(for key: String) async throws -> Data? {
        storage[key]
    }

    func delete(for key: String) async throws {
        storage.removeValue(forKey: key)
    }
}

enum MockError: Error {
    case notConfigured
}
```

## 모듈 단위 테스트

Assembly를 통해 모듈을 테스트.

```swift
// AuthModuleTests/AuthManagerTests.swift
import XCTest
@testable import AuthModule
import Core

@MainActor
final class AuthManagerTests: XCTestCase {
    func testSignIn() async throws {
        // Given
        let mockNetwork = MockNetworkService()
        mockNetwork.requestHandler = { _ in
            User(id: "1", email: "test@test.com", token: "token")
        }

        let mockStorage = MockSecureStorage()

        let auth = AuthAssembly(
            dependencies: .init(
                network: mockNetwork,
                secureStorage: mockStorage
            )
        ).assemble()

        // When
        let user = try await auth.signIn(email: "test@test.com", password: "1234")

        // Then
        XCTAssertEqual(user.email, "test@test.com")
        XCTAssertTrue(await auth.isAuthenticated)
    }

    func testSignOut() async throws {
        // Given
        let mockNetwork = MockNetworkService()
        mockNetwork.requestHandler = { _ in
            User(id: "1", email: "test@test.com", token: "token")
        }

        let mockStorage = MockSecureStorage()

        let auth = AuthAssembly(
            dependencies: .init(
                network: mockNetwork,
                secureStorage: mockStorage
            )
        ).assemble()

        _ = try await auth.signIn(email: "test@test.com", password: "1234")

        // When
        await auth.signOut()

        // Then
        XCTAssertFalse(await auth.isAuthenticated)
        XCTAssertNil(await auth.currentUser)
    }
}
```

## Adapter 테스트

모듈 간 연결 Adapter 테스트.

```swift
// AppTests/AdapterTests.swift
import XCTest
@testable import App
import Core
import AuthModule

@MainActor
final class AdapterTests: XCTestCase {
    func testAuthUserIdAdapter() async {
        // Given
        let mockNetwork = MockNetworkService()
        mockNetwork.requestHandler = { _ in
            User(id: "user-123", email: "test@test.com", token: "token")
        }
        let mockStorage = MockSecureStorage()

        let auth = AuthAssembly(
            dependencies: .init(network: mockNetwork, secureStorage: mockStorage)
        ).assemble()

        _ = try? await auth.signIn(email: "test@test.com", password: "1234")

        let adapter = AuthUserIdAdapter(auth: auth)

        // When
        let userId = await adapter.currentUserId

        // Then
        XCTAssertEqual(userId, "user-123")
    }
}
```

## App 통합 테스트

전체 의존성 조립 테스트.

```swift
// AppTests/IntegrationTests.swift
import XCTest
@testable import App
import Core

@MainActor
final class IntegrationTests: XCTestCase {
    func testDependenciesInitialization() {
        // Given
        let mockNetwork = MockNetworkService()
        let mockStorage = MockSecureStorage()

        // When
        let deps = AppDependencies(
            network: mockNetwork,
            secureStorage: mockStorage
        )

        // Then
        XCTAssertNotNil(deps.auth)
        XCTAssertNotNil(deps.payment)
        XCTAssertNotNil(deps.analytics)
    }

    func testFullFlow() async throws {
        // Given
        let mockNetwork = MockNetworkService()
        mockNetwork.requestHandler = { endpoint in
            // 엔드포인트에 따라 다른 응답 반환
            if endpoint.path.contains("auth") {
                return User(id: "1", email: "test@test.com", token: "token")
            }
            throw MockError.notConfigured
        }

        let mockStorage = MockSecureStorage()
        let deps = AppDependencies(network: mockNetwork, secureStorage: mockStorage)

        // When
        let user = try await deps.auth.signIn(email: "test@test.com", password: "1234")

        // Then
        XCTAssertEqual(user.id, "1")
        XCTAssertTrue(await deps.auth.isAuthenticated)
    }
}
```

## ViewModel 테스트

```swift
// AppTests/ViewModelTests.swift
import XCTest
@testable import App

@MainActor
final class ViewModelTests: XCTestCase {
    func testHomeViewModelLoadUser() async {
        // Given
        let mockNetwork = MockNetworkService()
        mockNetwork.requestHandler = { _ in
            User(id: "1", email: "test@test.com", token: "token")
        }
        let mockStorage = MockSecureStorage()

        let deps = AppDependencies(network: mockNetwork, secureStorage: mockStorage)
        _ = try? await deps.auth.signIn(email: "test@test.com", password: "1234")

        let viewModel = deps.makeHomeViewModel()

        // When
        await viewModel.loadUser()

        // Then
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.email, "test@test.com")
    }
}
```

## 테스트 체크리스트

- [ ] Core Protocol별 Mock 클래스 생성 (`@unchecked Sendable`)
- [ ] 각 모듈 Assembly를 통한 단위 테스트
- [ ] Adapter 동작 테스트
- [ ] AppDependencies 통합 테스트
- [ ] ViewModel Factory로 생성된 ViewModel 테스트
- [ ] `@MainActor` 어노테이션 적용
