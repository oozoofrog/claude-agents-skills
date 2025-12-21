---
name: modular-di-swiftui
description: SwiftUI에서 Modular DI 통합 가이드. Environment로 의존성 주입, ViewModel Factory 패턴, View에서 서비스 접근 시 사용.
---

# SwiftUI Integration with Modular DI

SwiftUI에서 AppDependencies를 활용하는 패턴.

## Environment 활용

### Environment Key 정의

```swift
// App/Sources/Environment/DependenciesEnvironment.swift
import SwiftUI

extension EnvironmentValues {
    @Entry var dependencies: AppDependencies?
}
```

### Root에서 주입

```swift
struct RootView: View {
    let dependencies: AppDependencies

    var body: some View {
        ContentView()
            .environment(\.dependencies, dependencies)
    }
}
```

### 하위 View에서 사용

```swift
struct ProfileView: View {
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        Button("Sign Out") {
            Task {
                await dependencies?.auth.signOut()
            }
        }
    }
}
```

## ViewModel Factory 패턴

AppDependencies에서 ViewModel을 생성하는 Factory 메서드 제공.

```swift
// App/Sources/CompositionRoot/AppDependencies+ViewModels.swift
extension AppDependencies {
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(auth: auth, analytics: analytics)
    }

    func makePaymentViewModel(amount: Decimal) -> PaymentViewModel {
        PaymentViewModel(payment: payment, amount: amount)
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(auth: auth)
    }
}
```

### View에서 Factory 사용

```swift
struct HomeView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: HomeViewModel?

    var body: some View {
        Group {
            if let viewModel {
                HomeContentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            viewModel = dependencies?.makeHomeViewModel()
        }
    }
}
```

## 대안: Observable ViewModel

```swift
@Observable
final class HomeViewModel {
    private let auth: AuthManaging
    private let analytics: AnalyticsTracking

    var isLoading = false
    var user: User?

    init(auth: AuthManaging, analytics: AnalyticsTracking) {
        self.auth = auth
        self.analytics = analytics
    }

    func loadUser() async {
        isLoading = true
        user = await auth.currentUser
        isLoading = false
    }
}

struct HomeView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: HomeViewModel?

    var body: some View {
        Group {
            if let viewModel {
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let user = viewModel.user {
                        Text("Hello, \(user.name)")
                    }
                }
                .task {
                    await viewModel.loadUser()
                }
            }
        }
        .onAppear {
            viewModel = dependencies?.makeHomeViewModel()
        }
    }
}
```

## Navigation과 함께 사용

```swift
struct ContentView: View {
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Profile") {
                    if let deps = dependencies {
                        ProfileView(viewModel: deps.makeProfileViewModel())
                    }
                }
                NavigationLink("Payment") {
                    if let deps = dependencies {
                        PaymentView(viewModel: deps.makePaymentViewModel(amount: 100))
                    }
                }
            }
        }
    }
}
```

## 체크리스트

- [ ] EnvironmentValues에 `@Entry var dependencies` 정의
- [ ] RootView에서 `.environment(\.dependencies, dependencies)` 주입
- [ ] AppDependencies에 ViewModel Factory 메서드 추가
- [ ] View에서 `@Environment(\.dependencies)` 사용
- [ ] ViewModel은 `@Observable` 매크로 활용
