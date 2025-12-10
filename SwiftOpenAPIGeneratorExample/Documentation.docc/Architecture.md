# 아키텍처

## 호출 흐름
1. `ContentFeature`가 `Environment(\.appDependencies)`에서 의존성을 읽고, `@State`로 이름/로딩/결과/에러 상태를 관리합니다.
2. `ContentFeature`의 액션 `loadGreeting()`에서 `GreetingService.greeting(name:)`을 호출하고, 도메인 모델 `GreetingEntity`를 UI 상태에 반영합니다.
3. `DefaultGreetingService`는 구현을 `GreetingRepository`에 위임하고, 기본 구현인 `DefaultGreetingRepository`가 네트워크를 담당합니다.
4. `DefaultGreetingRepository`는 `RemoteAPI.fetchGreeting`을 호출해 생성된 클라이언트의 `getGreeting` 엔드포인트를 실행하고, 응답 `Components.Schemas.Greeting`을 도메인 엔터티로 매핑합니다.

## 책임 분리
- UI: `SwiftOpenAPIGeneratorExampleApp.swift`, `UI/ContentFeature.swift`, `UI/ContentFeature+View.swift` — 화면 구성 및 사용자 입력 처리(`@State` + 액션/레이아웃 extension).
- 앱/도메인: `Domain/GreetingService.swift`, `Domain/GreetingRepository.swift`, `Domain/GreetingEntity.swift` — 비즈니스 로직과 모델 인터페이스.
- 데이터/네트워크: `Data/DefaultGreetingRepository.swift`, `Networking/RemoteAPI.swift` — 전송 프로토콜을 감춘 채 생성된 클라이언트와 통신.
- 계약/설정: `Networking/openapi.yaml`, `Networking/openapi-generator-config.yaml` — API 계약과 생성 옵션의 단일 소스.

## 의존성 조립
- `Environment/AppDependencies.live()`가 프로덕션 경로를 한 곳에서 조립하고 `SwiftOpenAPIGeneratorExampleApp`에서 `Environment(\.appDependencies)`로 내려보냅니다.
- 프리뷰나 스냅샷 검증은 `AppDependencies.preview()`를 `environment(\.appDependencies, .preview())`로 주입해 transport/api/repository/service를 반복 구성하지 않아도 됩니다.

## 확장 포인트
- **환경 분리**: `RemoteAPI` 기본 생성자는 스펙의 `servers` 값을 이용합니다. 다른 베이스 URL이나 인증이 필요하면 `RemoteAPI`에 커스텀 `client: APIProtocol`을 주입해 미들웨어, 헤더 삽입, 로깅 등을 구성하세요.
- **테스트 더블**: 프로토콜(`GreetingService`, `GreetingRepository`, `APIProtocol`)을 통해 UI·도메인 테스트에서 네트워크를 대체할 수 있습니다.
- **엔드포인트 추가**: 스펙에 새 `operationId`를 추가하면 동일한 이름의 메서드가 `Client`에 생성됩니다. 이를 감싸는 메서드를 `RemoteAPI`와 리포지터리에 추가해 도메인 모델과 UI로 연결하면 됩니다.
