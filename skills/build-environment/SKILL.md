---
name: build-environment
description: iOS/macOS 빌드 환경 설정 가이드. 빌드 요청, 프로젝트 설정, 시뮬레이터 실행 시 자동 적용.
allowed-tools:
  - Bash(brew:*)
  - Bash(xcodebuild:*)
  - Bash(xcode-build-server:*)
  - Bash(xcbeautify:*)
  - Bash(swift:*)
  - Bash(tuist:*)
---

# iOS/macOS Build Environment

iOS/macOS 프로젝트 빌드 환경과 관련 도구 사용법입니다.

## 필수 도구 확인 및 설치

이 스킬은 다음 외부 도구를 사용합니다. **빌드 작업 전에 반드시 확인하세요.**

### 필수 도구

| 도구 | 용도 | 설치 명령 |
|------|------|----------|
| `xcode-build-server` | SourceKit-LSP와 Xcode 프로젝트 연동 | `brew install xcode-build-server` |
| `xcbeautify` | xcodebuild 출력 포맷팅 | `brew install xcbeautify` |

### 설치 확인

```bash
command -v xcode-build-server >/dev/null && echo "✓ xcode-build-server" || echo "✗ xcode-build-server 미설치"
command -v xcbeautify >/dev/null && echo "✓ xcbeautify" || echo "✗ xcbeautify 미설치"
```

### 자동 설치

누락된 도구가 있으면 다음 명령으로 설치:

```bash
command -v xcode-build-server >/dev/null || brew install xcode-build-server
command -v xcbeautify >/dev/null || brew install xcbeautify
```

### 전체 설치 (한 번에)

```bash
brew install xcode-build-server xcbeautify
```

### 스크립트로 확인/설치

```bash
# 도구 확인
~/.claude/skills/build-environment/scripts/check-tools.sh

# 누락된 도구 자동 설치
~/.claude/skills/build-environment/scripts/check-tools.sh --install
```

> **참고**: Homebrew가 설치되어 있어야 합니다. 없으면: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

---

## SourceKit-LSP 설정 (OpenCode/에디터 연동)

Swift 프로젝트에서 LSP 기능(자동완성, 정의 이동, 참조 검색 등)을 사용하려면 xcode-build-server 설정이 필요합니다.

### 설치

```bash
brew install xcode-build-server
```

### buildServer.json 생성

프로젝트 루트에서 실행:

```bash
# xcworkspace 사용 시
xcode-build-server config -workspace *.xcworkspace -scheme YourScheme

# xcodeproj만 있는 경우
xcode-build-server config -project *.xcodeproj -scheme YourScheme

# 스킴 자동 감지 (마지막 빌드 스킴 사용)
xcode-build-server config
```

생성되는 `buildServer.json` 예시:

```json
{
  "name": "xcode build server",
  "version": "0.2",
  "bspVersion": "2.0",
  "languages": ["c", "cpp", "objective-c", "objective-cpp", "swift"],
  "argv": ["/opt/homebrew/bin/xcode-build-server"],
  "workspace": "/path/to/YourProject.xcworkspace",
  "build_root": "/path/to/project",
  "scheme": "YourScheme",
  "kind": "xcode"
}
```

### DerivedData 경로 설정 (필수)

LSP가 빌드 인덱스를 찾으려면 DerivedData가 프로젝트 폴더 내에 있어야 합니다.

**Xcode 설정 방법:**
1. Xcode → Settings → Locations → Derived Data
2. "Relative" 선택 또는 프로젝트 내 경로 지정

**xcodebuild 명령어:**

```bash
xcodebuild -scheme YourScheme \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath ./DerivedData \
  build
```

**중요**: `-derivedDataPath ./DerivedData`를 항상 지정하여 프로젝트 폴더 내에 빌드 결과물 생성

### LSP 인덱스 갱신

빌드 후 LSP 인덱스가 자동 갱신됩니다. 수동 갱신이 필요한 경우:

```bash
# Xcode post-build action으로 플래그 동기화
xcode-build-server postaction | bash &
```

### 트러블슈팅

LSP가 심볼을 찾지 못하는 경우:

1. **빌드 먼저 실행**: `xcodebuild build -derivedDataPath ./DerivedData`
2. **buildServer.json 확인**: 프로젝트 루트에 존재하는지 확인
3. **DerivedData 경로 확인**: 프로젝트 폴더 내에 있는지 확인
4. **에디터 재시작**: LSP 서버 재연결

디버그 로그 활성화:

```bash
SOURCEKIT_LOGGING=3 xcode-build-server serve
```

## XcodeBuildMCP (Primary Build Tool)

XcodeBuildMCP를 기본 빌드 도구로 사용합니다. `xcode-dev` agent를 통해 접근합니다.

### 기본 워크플로우

```
1. discover_projs → 프로젝트 검색
2. list_schemes → 스킴 확인
3. session-set-defaults → 설정 저장 (derivedDataPath 포함)
4. build_sim / build_run_sim → 빌드 및 실행
```

### DerivedData 경로 지정

XcodeBuildMCP 사용 시 항상 프로젝트 내 DerivedData 경로를 지정:

```
session-set-defaults:
  derivedDataPath: ./DerivedData
```

또는 빌드 명령에서 직접 지정:

```
build_sim:
  derivedDataPath: ./DerivedData
```

## xcbeautify (빌드 출력 포맷팅)

xcodebuild 출력을 읽기 쉽게 포맷팅합니다.

### 설치

```bash
brew install xcbeautify
```

### 사용법

```bash
# 기본 사용
xcodebuild build -scheme YourScheme -derivedDataPath ./DerivedData | xcbeautify

# 경고/에러만 표시 (조용한 모드)
xcodebuild build ... | xcbeautify --quiet

# 에러만 표시
xcodebuild build ... | xcbeautify --quieter

# CI 환경 (색상 비활성화)
xcodebuild build ... | xcbeautify --disable-colored-output

# JUnit 리포트 생성
xcodebuild test ... | xcbeautify --report junit --report-path ./test-results
```

### CI/CD 렌더러

```bash
# GitHub Actions
xcodebuild ... | xcbeautify --renderer github-actions

# Azure DevOps
xcodebuild ... | xcbeautify --renderer azure-devops-pipelines

# TeamCity
xcodebuild ... | xcbeautify --renderer teamcity
```

### 권장 빌드 명령

```bash
xcodebuild \
  -scheme YourScheme \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath ./DerivedData \
  build 2>&1 | xcbeautify
```

## Build Tools

### Tuist (선택적)

Tuist를 사용하는 프로젝트의 경우:

```bash
tuist generate
tuist graph
```

### Swift Package Manager

```bash
swift build
swift test
swift package update
```

SPM 프로젝트는 별도 설정 없이 sourcekit-lsp가 자동으로 인식합니다.

## Common Environment Variables

| 변수 | 용도 |
|------|------|
| `DEVELOPER_DIR` | Xcode 경로 지정 |
| `DYLD_FRAMEWORK_PATH` | 프레임워크 검색 경로 |
| `DERIVED_DATA_PATH` | 빌드 산출물 경로 |
| `SOURCEKIT_LOGGING` | LSP 디버그 로그 레벨 (0-3) |

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
# Xcode (DerivedData 경로 지정)
xcodebuild test \
  -scheme YourScheme \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath ./DerivedData

# Swift Package
swift test
```

### 테스트 구성
- `.xctestplan` 파일로 테스트 구성 관리
- 샘플 앱 타겟으로 기능별 독립 테스트

## Common Issues

### 빌드 실패
1. DerivedData 삭제: `rm -rf ./DerivedData`
2. 캐시 정리: `swift package reset`
3. Xcode 재시작

### 시뮬레이터 이슈
1. 시뮬레이터 초기화: `xcrun simctl erase all`
2. 런타임 재설치: Xcode → Settings → Components

### 코드 서명 이슈
- Xcode에서 Signing & Capabilities 확인
- Apple Developer 계정 연결 확인
- Provisioning Profile 갱신

### LSP가 작동하지 않는 경우
1. `buildServer.json` 존재 확인
2. 프로젝트 빌드 후 재시도
3. DerivedData가 프로젝트 폴더 내에 있는지 확인
4. 에디터/OpenCode 재시작

## Important Notes

- 빌드 결과물(DerivedData)은 항상 프로젝트 폴더 내에 생성 (`-derivedDataPath ./DerivedData`)
- `buildServer.json`은 프로젝트 루트에 위치해야 LSP가 인식
- 생성된 `.xcodeproj` 파일 직접 수정 금지 (Tuist 사용 시)
- 프로젝트 설정 변경은 해당 설정 파일 수정 (`Project.swift`, `Package.swift` 등)
- 빌드 도구 변경 시 캐시 정리 권장
