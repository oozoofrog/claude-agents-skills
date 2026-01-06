---
name: modular-di
description: Modular DI (Dependency Injection) Architecture 종합 가이드. Swift 6 Concurrency 및 모듈화 지원.
---

# Modular DI Architecture

Swift 6 Concurrency와 모듈화를 지원하는 의존성 주입 아키텍처입니다.

## 문서 목록

1. **[Overview](OVERVIEW.md)**
   - 아키텍처 개요, Core 모듈 설계, 기본 원칙

2. **[Assembly Pattern](ASSEMBLY.md)**
   - Service 모듈 내부 구조, Public Interface, Assembly 구현

3. **[Composition Root](COMPOSITION.md)**
   - App 모듈에서의 조립, Adapter 패턴, AppDependencies

4. **[SwiftUI Integration](SWIFTUI.md)**
   - Environment 주입, ViewModel Factory, View 연동

5. **[Testing](TESTING.md)**
   - Mocking 전략, 단위/통합 테스트, 테스트 체크리스트

## 빠른 참조

```
App
 ├── CompositionRoot (AppDependencies, Adapters)
 ├── Features (ViewModels, Views)
 └── Infrastructure (NetworkService, Storage)
      │
      ▼
   Service Modules (Auth, Payment...)
      │ Use
      ▼
     Core (Protocols)
```

## 사용법

새로운 모듈을 추가하거나 DI 구조를 잡을 때 각 상황에 맞는 하위 문서를 참조하세요.
