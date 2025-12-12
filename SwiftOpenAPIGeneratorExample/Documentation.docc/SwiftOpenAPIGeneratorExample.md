# SwiftOpenAPIGeneratorExample

Swift OpenAPI Generator와 SwiftUI 앱을 잇는 최소 예제입니다. 스택을 처음 보는 팀원이 바로 도입 여부를 판단하고 실행할 수 있도록 핵심 흐름과 결정 포인트를 정리했습니다.

## 구성 요약
- SwiftUI 한 화면(`ContentFeature`)에서 입력/로딩/결과/에러를 `@State`로 관리하고, 레이아웃은 extension(`ContentFeature+View.swift`)에 둬 읽기 쉽게 유지합니다.
- 의존성은 `Environment(\.appDependencies)`로 한 번 주입하며, 기본값은 `AppDependencies.live()`가 제공하는 라이브 의존성입니다. UI만 빠르게 확인할 때는 `.environment(\.appDependencies, .preview())`로 목 저장소를 명시합니다.
- UI → Service(도메인 포함) → Repository 흐름을 최소 경로로 두고, Repository가 OpenAPI DTO를 도메인으로 매핑하며 Service는 규칙만 적용합니다.
- 네트워크 계층은 생성된 클라이언트(`Client`, `APIProtocol`, `Servers`, `Components`)를 `APIInfra`에서 감싸 도메인이 전송 세부 사항을 몰라도 됩니다.
- OpenAPI 스펙(`api-spec/openapi/openapi.yaml`)과 생성 설정(`Modules/Sources/APITypes/openapi-generator-config.yaml`, `Modules/Sources/APIClient/openapi-generator-config.yaml`)만 관리하고, 생성물은 빌드 시 플러그인이 제공하므로 커밋 대상이 아닙니다.
- `Modules` Swift 패키지에 `AppService`/`AppData`/`AppUI`/`APIInfra`/`APITypes`/`APIClient` 라이브러리 타깃이 정의되어 있으며, `AppUI`는 `AppService`만 참조합니다.
- Swift Package 플러그인 `plugin:OpenAPIGenerator`와 런타임(`OpenAPIRuntime`, `OpenAPIURLSession`)은 패키지 종속성을 통해 자동 연결됩니다.

## Topics
- <doc:GettingStarted>
- <doc:Architecture>
- <doc:OpenAPIWorkflow>
