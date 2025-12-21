---
name: modular-di-overview
description: Swift 6 모듈화 DI 아키텍처 개요와 Core 모듈 설계 원칙. 새 프로젝트 DI 구조 설계, 모듈 구조 계획, Core 모듈 Protocol 정의, 모듈 간 의존성 격리 시 사용.
---

# Modular DI Architecture Overview

Swift 6 Concurrency 환경에서 모듈화된 앱의 의존성 주입(DI) 아키텍처 가이드.

## 모듈 구조

```
App Module (Composition Root - 최종 조립)
    │
    ├── ServiceA Module (Auth)
    ├── ServiceB Module (Payment)
    └── ServiceC Module (Analytics)
    │
Core Module (공통 Protocol, 유틸리티)
```

## 핵심 원칙

1. **Service 모듈들은 서로 직접 의존하지 않는다**
2. **모든 모듈은 Core만 의존한다**
3. **App 모듈에서 최종 조립한다**
4. **모듈 간 연결은 Core의 Protocol과 Adapter로 해결한다**

## Core Module 설계

공통 Protocol과 유틸리티만 정의. 구현체는 포함하지 않는다.

### 파일 구조

```
CoreModule/
├── Sources/
│   └── Protocols/
│       ├── NetworkServiceProtocol.swift
│       ├── SecureStorageProtocol.swift
│       └── UserIdProviding.swift
```

### Protocol 정의 예시

```swift
// CoreModule/Sources/Protocols/NetworkServiceProtocol.swift
public protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

// CoreModule/Sources/Protocols/SecureStorageProtocol.swift
public protocol SecureStorageProtocol: Sendable {
    func save(_ data: Data, for key: String) async throws
    func load(for key: String) async throws -> Data?
    func delete(for key: String) async throws
}

// 모듈 간 연결을 위한 작은 Protocol
public protocol UserIdProviding: Sendable {
    var currentUserId: String? { get async }
}
```

## Core Protocol 설계 원칙

1. **Sendable 준수**: Swift 6 Concurrency를 위해 모든 Protocol은 `Sendable`
2. **최소 인터페이스**: 필요한 메서드만 정의
3. **모듈 연결용 Protocol**: 모듈 간 데이터 전달을 위한 작은 Protocol 분리 (`UserIdProviding` 등)

## 새 모듈 추가 시 Core 체크리스트

- [ ] 해당 모듈이 필요로 하는 공통 Protocol이 Core에 있는가?
- [ ] 다른 모듈과 연결이 필요하다면 연결용 작은 Protocol을 Core에 정의했는가?
- [ ] 모든 Protocol이 `Sendable`을 준수하는가?
