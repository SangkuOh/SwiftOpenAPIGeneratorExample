# 아키텍처

## 호출 흐름
1. `ContentFeature`가 `Environment(\.appDependencies)`에서 의존성을 읽고, `@State`로 이름/로딩/결과/에러 상태를 관리합니다.
2. `loadGreeting()` 액션이 `GreetingService.greeting(name:)`을 호출해 도메인 모델 `GreetingEntity`를 받아 UI 상태를 갱신합니다.
3. `DefaultGreetingService`는 `GreetingRepository`에서 받은 도메인 엔터티에 비즈니스 규칙을 적용합니다.
4. `GreetingRepositoryFactory`가 `APIInfra.DefaultAPIEnvironment`를 통해 생성된 `GreetingAPIClient`를 조립하고, 응답 `Components.Schemas.Greeting`을 `GreetingEntity`로 변환해 반환합니다.

## 책임 분리
- UI: `SwiftOpenAPIGeneratorExampleApp.swift`, `Modules/Sources/AppUI/*` — 화면 구성 및 사용자 입력 처리(`@State` + 액션/레이아웃 extension)와 DI 래퍼(`AppDependencies`).
- 서비스/도메인: `Modules/Sources/AppService/*` — 도메인 엔터티, 유스케이스/저장소 인터페이스, 기본 서비스 구현.
- 데이터/네트워크: `Modules/Sources/AppData/*`, `Modules/Sources/APIInfra/*` — 저장소 구현과 생성된 클라이언트를 감싼 API 래퍼, 공통 스텁 세트(`APIMockScenarios`)와 mock transport.
- 계약/설정: `api-spec/openapi/openapi.yaml`, `Modules/Sources/APITypes/openapi-generator-config.yaml`, `Modules/Sources/APIClient/openapi-generator-config.yaml` — API 계약과 생성 옵션의 단일 소스.

## 의존성 조립
- App 타깃에서 `GreetingRepositoryFactory.live/preview`로 저장소를 만든 뒤 `AppDependencies.live(repository:)`에 전달해 `Environment(\.appDependencies)`로 내려보냅니다.
- SwiftUI 프리뷰나 샘플 앱 기본 환경은 `AppDependencies.preview()`가 내부적으로 `APIMockScenarios`+`MockServerTransport` 기반 저장소를 만들어 네트워크 없이 동일 코드 경로를 실행합니다.

## 확장 포인트
- **환경 분리**: `DefaultAPIEnvironment.live/preview/mock` 헬퍼는 스펙의 `servers` 값을 기본으로 사용합니다. 다른 베이스 URL이나 인증이 필요하면 `APIConfiguration`을 조정하거나 `DefaultAPIClient`에 미들웨어, 헤더 삽입, 로깅 등을 추가하세요.
- **테스트 더블**: 프로토콜(`GreetingService`, `GreetingRepository`, `APIProtocol`)을 통해 UI·도메인 테스트에서 네트워크를 대체할 수 있습니다.
- **모킹 표준**: 프리뷰/테스트는 `APIMockScenarios`에 엔드포인트별 스텁을 추가하고, `MockServerTransport`를 사용하는 `GreetingRepositoryFactory.preview(stubs:)` 또는 `AppDependencies.preview(stubs:)`로 조립해 동일한 OpenAPI 호출 경로를 실행합니다.
- **엔드포인트 추가**: 스펙에 새 `operationId`를 추가하면 동일한 이름의 메서드가 `Client`에 생성됩니다. 해당 호출을 담당할 모듈을 `Modules/Sources/APIInfra`에 만들고, `APIEnvironment` 프로퍼티로 노출해 리포지터리·서비스·UI로 연결합니다.
