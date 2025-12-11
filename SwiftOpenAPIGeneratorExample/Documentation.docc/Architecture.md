# 아키텍처

## 호출 흐름
1. `ContentFeature`가 `Environment(\.appDependencies)`에서 의존성을 읽고, `@State`로 이름/로딩/결과/에러 상태를 관리합니다.
2. `loadGreeting()` 액션이 `GreetingService.greeting(name:)`을 호출해 도메인 모델 `GreetingEntity`를 받아 UI 상태를 갱신합니다.
3. `DefaultGreetingService`는 `GreetingRepository` 프로토콜을 통해 데이터 계층에 위임하고, 기본 구현인 `DefaultGreetingRepository`가 네트워크를 담당합니다.
4. `GreetingRepositoryFactory`가 `APIInfra.APIEnvironments`를 통해 생성된 `GreetingAPIClient`를 조립하고, 응답 `Components.Schemas.Greeting`을 도메인 엔터티로 매핑합니다.

## 책임 분리
- UI: `SwiftOpenAPIGeneratorExampleApp.swift`, `Modules/Sources/AppUI/*` — 화면 구성 및 사용자 입력 처리(`@State` + 액션/레이아웃 extension)와 DI 래퍼(`AppDependencies`).
- 서비스/도메인: `Modules/Sources/AppService/*`, `Modules/Sources/AppDomain/*` — 비즈니스 로직 인터페이스와 엔터티 정의.
- 데이터/네트워크: `Modules/Sources/AppData/*`, `Modules/Sources/APIInfra/*` — 저장소 구현과 생성된 클라이언트를 감싼 API 래퍼.
- 계약/설정: `api-spec/openapi/openapi.yaml`, `Modules/Sources/APITypes/openapi-generator-config.yaml`, `Modules/Sources/APIClient/openapi-generator-config.yaml` — API 계약과 생성 옵션의 단일 소스.

## 의존성 조립
- `AppDependencies.live()`가 프로덕션 경로를 한 곳에서 조립하고 `SwiftOpenAPIGeneratorExampleApp`에서 `Environment(\.appDependencies)`로 내려보냅니다.
- 프리뷰나 스냅샷 검증은 `AppDependencies.preview()`를 `environment(\.appDependencies, .preview())`로 주입해 transport/api/repository/service를 반복 구성하지 않아도 됩니다.

## 확장 포인트
- **환경 분리**: `APIEnvironments` 헬퍼는 스펙의 `servers` 값을 기본으로 사용합니다. 다른 베이스 URL이나 인증이 필요하면 `APIConfiguration`을 조정하거나 `DefaultAPIClient`에 미들웨어, 헤더 삽입, 로깅 등을 추가하세요.
- **테스트 더블**: 프로토콜(`GreetingService`, `GreetingRepository`, `APIProtocol`)을 통해 UI·도메인 테스트에서 네트워크를 대체할 수 있습니다.
- **엔드포인트 추가**: 스펙에 새 `operationId`를 추가하면 동일한 이름의 메서드가 `Client`에 생성됩니다. 해당 호출을 담당할 모듈을 `Modules/Sources/APIInfra`에 만들고, `APIEnvironment` 프로퍼티로 노출해 리포지터리·서비스·UI로 연결합니다.
