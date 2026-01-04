---
name: build-environment
description: iOS/macOS 빌드 환경 설정 가이드. 빌드 요청, 프로젝트 설정, 시뮬레이터 실행 시 자동 적용.
---

# iOS/macOS Build Environment

iOS/macOS 프로젝트 빌드 환경과 관련 도구 사용법입니다.

## XcodeBuildMCP (Primary Build Tool)

XcodeBuildMCP를 기본 빌드 도구로 사용합니다. `xcode-dev` agent를 통해 접근합니다.

### 기본 워크플로우
```
1. discover_projs → 프로젝트 검색
2. list_schemes → 스킴 확인
3. session-set-defaults → 설정 저장
4. build_run_sim_error → 빌드 및 실행
```

## Build Tools

### Tuist (선택적)
Tuist를 사용하는 프로젝트의 경우:

```bash
# 프로젝트 생성
tuist generate

# 그래프 보기
tuist graph
```

### Swift Package Manager
```bash
# 빌드
swift build

# 테스트
swift test

# 의존성 업데이트
swift package update
```

## Common Environment Variables

| 변수 | 용도 |
|------|------|
| `DEVELOPER_DIR` | Xcode 경로 지정 |
| `DYLD_FRAMEWORK_PATH` | 프레임워크 검색 경로 |
| `DERIVED_DATA_PATH` | 빌드 산출물 경로 |

## Scheme Selection Guide

| 목적 | 권장 Configuration |
|------|-------------------|
| 일반 개발/디버깅 | Debug |
| 릴리즈 테스트 | Release |
| 프로파일링 | Release (with debug info) |

## Warning Handling

빌드 결과물의 워닝 처리 기준:

### 즉시 수정 (빌드할 때마다)
- unused variable/import 경고
- deprecation 경고 (대체 API가 명확한 경우)
- force unwrapping 경고
- 타입 추론 관련 간단한 경고

### 별도 이슈로 관리
- 대규모 리팩토링 필요한 경고
- 서드파티 라이브러리 관련 경고
- 복잡한 제네릭/프로토콜 관련 경고
- Swift 버전 마이그레이션 필요 경고

## Testing

### 테스트 실행
```bash
# Xcode
xcodebuild test -scheme YourScheme -destination 'platform=iOS Simulator,name=iPhone 15'

# Swift Package
swift test
```

### 테스트 구성
- `.xctestplan` 파일로 테스트 구성 관리
- 샘플 앱 타겟으로 기능별 독립 테스트

## Common Issues

### 빌드 실패
1. DerivedData 삭제: `rm -rf ~/Library/Developer/Xcode/DerivedData`
2. 캐시 정리: `swift package reset`
3. Xcode 재시작

### 시뮬레이터 이슈
1. 시뮬레이터 초기화: `xcrun simctl erase all`
2. 런타임 재설치: Xcode → Preferences → Components

### 코드 서명 이슈
- Xcode에서 Signing & Capabilities 확인
- Apple Developer 계정 연결 확인
- Provisioning Profile 갱신

## Important Notes

- 생성된 `.xcodeproj` 파일 직접 수정 금지 (Tuist 사용 시)
- 프로젝트 설정 변경은 해당 설정 파일 수정 (`Project.swift`, `Package.swift` 등)
- 빌드 도구 변경 시 캐시 정리 권장
