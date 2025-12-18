# 코드 스멜과 해결 패턴

> 코드 스멜은 "뭔가 잘못됐을 수 있다"는 신호이지, 반드시 문제라는 의미는 아니다.

---

## 1. Bloaters (비대한 코드)

### Long Method (긴 메서드)
**증상**: 메서드가 너무 길어서 한눈에 파악하기 어려움

**해결책**:
- Extract Function: 의미 있는 단위로 분리
- Replace Temp with Query: 임시 변수를 메서드 호출로 대체
- Decompose Conditional: 조건문을 설명적인 메서드로 분리

```swift
// Before
func processOrder(_ order: Order) {
    // 50줄의 코드...
    // 유효성 검사, 재고 확인, 결제 처리, 배송 준비 등
}

// After
func processOrder(_ order: Order) {
    validate(order)
    checkInventory(for: order)
    processPayment(for: order)
    prepareShipment(for: order)
}
```

---

### Large Class (거대한 클래스)
**증상**: 클래스가 너무 많은 책임을 가짐

**해결책**:
- Extract Class: 관련 필드/메서드를 새 클래스로 분리
- Extract Subclass: 특정 경우에만 사용되는 기능 분리
- Extract Interface: 클라이언트가 사용하는 부분만 인터페이스로 추출

**경고 신호**:
- 필드가 10개 이상
- 메서드가 20개 이상
- 클래스 이름에 "Manager", "Handler", "Processor" 등이 포함

---

### Primitive Obsession (기본 타입에 대한 집착)
**증상**: 도메인 개념을 기본 타입으로 표현

```swift
// Before
func createUser(email: String, age: Int, phone: String)

// After
func createUser(email: Email, age: Age, phone: PhoneNumber)
```

**해결책**:
- Replace Primitive with Object: 값 객체로 대체
- Replace Type Code with Subclasses: 타입 코드를 상속으로 대체

---

### Long Parameter List (긴 파라미터 목록)
**증상**: 파라미터가 4개 이상

**해결책**:
- Introduce Parameter Object: 관련 파라미터를 객체로 묶기
- Preserve Whole Object: 객체에서 여러 값을 꺼내지 말고 객체 자체를 전달
- Replace Parameter with Method: 파라미터를 메서드 호출로 대체

```swift
// Before
func createReport(startDate: Date, endDate: Date, format: String,
                  includeCharts: Bool, emailTo: String)

// After
func createReport(config: ReportConfiguration)
```

---

## 2. Object-Orientation Abusers (객체지향 남용)

### Switch Statements (스위치 문)
**증상**: 동일한 switch/if-else가 여러 곳에 반복

**해결책**:
- Replace Conditional with Polymorphism
- Replace Type Code with Strategy
- Replace Type Code with State

```swift
// Before
func calculatePay(_ employee: Employee) -> Double {
    switch employee.type {
    case .engineer: return engineerPay(employee)
    case .salesman: return salesmanPay(employee)
    case .manager: return managerPay(employee)
    }
}

// After
protocol Employee {
    func calculatePay() -> Double
}

class Engineer: Employee {
    func calculatePay() -> Double { ... }
}
```

---

### Temporary Field (임시 필드)
**증상**: 특정 상황에서만 값이 설정되는 필드

**해결책**:
- Extract Class: 임시 필드와 관련 코드를 별도 클래스로
- Introduce Null Object: null 체크 대신 Null 객체 사용

---

### Refused Bequest (거부된 유산)
**증상**: 서브클래스가 부모의 메서드/데이터를 사용하지 않음

**해결책**:
- Replace Inheritance with Delegation: 상속 대신 위임 사용
- Push Down Method/Field: 사용하는 서브클래스로 이동

---

## 3. Change Preventers (변경 방해자)

### Divergent Change (발산적 변경)
**증상**: 하나의 클래스가 여러 이유로 자주 변경됨

> "데이터베이스가 바뀌면 이 세 메서드를 수정하고, 새 금융 상품이 추가되면 이 네 메서드를 수정해야 해"

**해결책**:
- Extract Class: 변경 이유별로 클래스 분리

---

### Shotgun Surgery (산탄총 수술)
**증상**: 하나의 변경을 위해 여러 클래스를 수정해야 함

**해결책**:
- Move Function/Field: 관련 코드를 한 곳으로 모으기
- Inline Class: 너무 분산된 클래스 합치기

---

### Parallel Inheritance Hierarchies (평행 상속 계층)
**증상**: 한 클래스의 서브클래스를 만들 때마다 다른 클래스의 서브클래스도 만들어야 함

**해결책**:
- Move Function/Field: 한 계층이 다른 계층을 참조하도록

---

## 4. Dispensables (불필요한 것들)

### Comments (주석)
**증상**: 코드를 설명하기 위한 주석이 많음

> "주석이 필요하다고 느낄 때, 먼저 코드를 리팩토링해서 주석이 불필요하게 만들어라" - 마틴 파울러

**해결책**:
- Extract Function: 주석이 설명하는 코드를 메서드로 추출
- Rename: 의도를 드러내는 이름으로 변경

```swift
// Before
// 사용자가 프리미엄 회원이고 구매 금액이 10만원 이상인지 확인
if user.membershipType == "premium" && order.total >= 100000 { ... }

// After
if user.isPremium && order.qualifiesForFreeShipping { ... }
```

---

### Duplicate Code (중복 코드)
**증상**: 동일하거나 유사한 코드가 여러 곳에 존재

**해결책**:
- Extract Function: 중복 코드를 함수로 추출
- Pull Up Method: 서브클래스의 중복을 부모로 이동
- Form Template Method: 유사한 알고리즘을 템플릿 메서드로

**주의**: 우연히 같아 보이는 코드는 중복이 아닐 수 있음

---

### Lazy Class (게으른 클래스)
**증상**: 하는 일이 거의 없는 클래스

**해결책**:
- Inline Class: 다른 클래스에 흡수
- Collapse Hierarchy: 불필요한 상속 계층 제거

---

### Dead Code (죽은 코드)
**증상**: 더 이상 사용되지 않는 코드

**해결책**: 삭제. 버전 관리 시스템이 있으니 걱정 말고 삭제.

---

### Speculative Generality (추측성 일반화)
**증상**: "언젠가 필요할 것 같아서" 만든 추상화

**해결책**:
- Collapse Hierarchy: 불필요한 추상 클래스 제거
- Inline Function/Class: 불필요한 위임 제거
- Remove Parameter: 사용하지 않는 파라미터 제거

---

## 5. Couplers (결합도 문제)

### Feature Envy (기능 편애)
**증상**: 메서드가 자신의 클래스보다 다른 클래스의 데이터를 더 많이 사용

```swift
// Before: Order가 Customer의 데이터에 지나치게 의존
class Order {
    func calculateDiscount() -> Double {
        if customer.membershipYears > 5 &&
           customer.totalPurchases > 1000000 &&
           customer.isPremium {
            return 0.2
        }
        return 0
    }
}

// After: 계산 로직을 Customer로 이동
class Customer {
    func discountRate() -> Double {
        if membershipYears > 5 && totalPurchases > 1000000 && isPremium {
            return 0.2
        }
        return 0
    }
}
```

**해결책**: Move Function

---

### Inappropriate Intimacy (부적절한 친밀)
**증상**: 두 클래스가 서로의 private 멤버에 과도하게 접근

**해결책**:
- Move Function/Field: 관련 기능을 한 곳으로
- Extract Class: 공통 관심사를 새 클래스로
- Hide Delegate: 중개자를 통해 접근

---

### Message Chains (메시지 체인)
**증상**: `a.getB().getC().getD().doSomething()`

**해결책**:
- Hide Delegate: 중간 객체를 숨기기
- Extract Function + Move Function: 체인 끝의 코드를 적절한 위치로

---

### Middle Man (중개자)
**증상**: 클래스의 대부분 메서드가 다른 클래스에 위임만 함

**해결책**:
- Remove Middle Man: 직접 호출하도록 변경
- Inline Function: 위임 메서드 인라인화
