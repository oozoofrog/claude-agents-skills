---
name: swiftui-design-system
description: SwiftUI 디자인 토큰 시스템과 접근성 체크리스트. SwiftUI UI 코드 작성, 디자인 리뷰, 접근성 검증 시 자동 적용.
---

# SwiftUI Design System

SwiftUI 프로젝트에서 일관된 디자인과 접근성을 유지하기 위한 가이드입니다.

## Design Principles

### 1. Information Hierarchy First
- 사용자가 **먼저 보는 것** → **읽는 것** → **행동하는 것** 순서 고려
- 시각적 무게로 중요도 표현 (크기, 색상, 대비)

### 2. Consistency via System Thinking
- 간격, 타이포그래피, 색상, 모서리 반경은 일관된 스케일 사용
- 매직 넘버 대신 시맨틱 토큰 활용

### 3. States are Part of Design
- 모든 상태를 디자인해야 함:
  - `loading` (로딩 중)
  - `empty` (데이터 없음)
  - `error` (오류 발생)
  - `disabled` (비활성화)
  - `permission denied` (권한 거부)

### 4. Responsive by Default
- Dynamic Type 지원 필수
- 다양한 화면 크기 대응
- 긴 텍스트/다국어 고려
- RTL (오른쪽→왼쪽) 언어 인식

### 5. Platform Conventions
- 네이티브 패턴 우선 사용
- 커스터마이징은 목적이 있을 때만

## Default Design Tokens (Fallback)

기존 디자인 시스템이 없을 때 사용하는 기본 토큰입니다.

### Spacing Scale (pt)
| Token | Value | Usage |
|-------|-------|-------|
| xs | 4 | 아이콘-텍스트 간격 |
| s | 8 | 관련 요소 간 간격 |
| m | 12 | 그룹 내 요소 간격 |
| l | 16 | 섹션 내 간격 |
| xl | 24 | 섹션 간 간격 |
| xxl | 32 | 주요 영역 구분 |
| xxxl | 40 | 최대 간격 |

### Corner Radius Scale (pt)
| Token | Value | Usage |
|-------|-------|-------|
| s | 8 | 작은 요소 (버튼, 뱃지) |
| m | 12 | 중간 요소 (카드) |
| l | 16 | 큰 컨테이너 |
| xl | 20 | 모달, 시트 |

### Typography
Dynamic Type semantic styles 우선 사용:
- `.largeTitle`, `.title`, `.title2`, `.title3`
- `.headline`, `.subheadline`
- `.body`, `.callout`
- `.caption`, `.caption2`
- `.footnote`

### Semantic Colors
| Token | Purpose |
|-------|---------|
| textPrimary | 주요 텍스트 |
| textSecondary | 보조 텍스트 |
| background | 배경 |
| surface | 카드/컨테이너 배경 |
| surfaceElevated | 높은 elevation 배경 |
| accent | 강조색 (브랜드) |
| destructive | 삭제/위험 액션 |
| border | 테두리 |
| separator | 구분선 |

## Existing System Detection

프로젝트에 기존 디자인 시스템이 있는지 확인하는 패턴:

### Token 패턴
- `Spacing.*`, `Radius.*`, `Typography.*`, `ColorToken.*`
- `Theme.*`, `DesignTokens.*`, `UIConstants.*`
- `AppColor.*`, `AppFont.*`, `AppSpacing.*`

### ViewModifier/Style 패턴
- `.cardStyle()`, `.primaryButtonStyle()`
- Custom `ButtonStyle`, `LabelStyle`

### Component 패턴
- `CardView`, `SectionHeader`, `SettingsRow`
- `Chip`, `Badge`, `EmptyStateView`

**규칙**: 기존 시스템이 있으면 **채택하고 확장**. 새 시스템 도입 금지.

## Accessibility Checklist

### Touch Targets
- 최소 터치 영역: **44pt x 44pt**
- 작은 요소는 `.contentShape()` 또는 패딩으로 확장

### Contrast
- 텍스트 대비 비율 준수 (WCAG AA 기준)
- 고대비 모드 지원 고려

### VoiceOver
- 모든 인터랙티브 요소에 적절한 레이블
- `.accessibilityLabel()`, `.accessibilityHint()`
- 장식용 이미지는 `.accessibilityHidden(true)`

### Reduce Motion
- `@Environment(\.accessibilityReduceMotion)` 확인
- 필수 아닌 애니메이션 비활성화 옵션

### Dynamic Type
- 최대 글씨 크기에서 레이아웃 테스트
- 잘림 없이 표시되는지 확인
- `@ScaledMetric` 활용

### Focus Order
- 논리적 탭 순서 유지
- 커스텀 컨트롤의 포커스 처리

## Component Breakdown

재사용 가능한 컴포넌트 분해 패턴:

| Component | Purpose |
|-----------|---------|
| Card | 관련 정보 그룹 |
| Row | 리스트 아이템 |
| SectionHeader | 섹션 제목 |
| Chip/Badge | 태그, 상태 표시 |
| CTA (Call-to-Action) | 주요 액션 버튼 |
| EmptyState | 데이터 없음 상태 |
| Skeleton | 로딩 플레이스홀더 |

## Verification Checklist

UI 코드 작성 후 확인 사항:

- [ ] Dynamic Type 최대 글씨 크기에서 테스트
- [ ] 긴 텍스트/다국어에서 레이아웃 확인
- [ ] 다크 모드에서 확인
- [ ] VoiceOver 라벨 및 탭 순서 확인
- [ ] 모든 터치 타겟 44pt 이상
- [ ] Reduce Motion 설정 시 동작 확인
- [ ] 작은 화면/큰 화면에서 레이아웃 확인
