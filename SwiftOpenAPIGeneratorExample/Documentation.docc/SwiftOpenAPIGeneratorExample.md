# SwiftOpenAPIGeneratorExample

Swift OpenAPI Generator와 SwiftUI 앱을 잇는 최소 예제입니다. 스택을 처음 보는 팀원이 바로 도입 여부를 판단하고 실행할 수 있도록 핵심 흐름과 결정 포인트를 정리했습니다.

## 구성 요약
- SwiftUI 뷰 하나(`ContentView.swift`)에서 `@State`를 관리하고, 액션은 별도 파일의 extension(`ContentView+Actions.swift`)으로 분리해 단순 흐름을 유지합니다.
- 의존성은 `Environment(\.appDependencies)`로 한 번만 주입해 App/Preview/Test 모두 동일한 조립 경로를 사용합니다.
- 도메인(`GreetingService`, `GreetingRepository`, `GreetingEntity`)과 데이터(`DefaultGreetingRepository`)를 분리해 테스트와 모킹이 쉽습니다.
- 네트워크 계층은 생성된 클라이언트(`Client`, `APIProtocol`, `Servers`)를 `RemoteAPI.swift`에서 얇게 감싸 도메인이 전송 세부 사항을 몰라도 됩니다.
- OpenAPI 스펙(`Networking/openapi.yaml`)과 생성 설정(`Networking/openapi-generator-config.yaml`)만 관리하고, 생성물은 빌드 시 플러그인이 제공하므로 커밋 대상이 아닙니다.
- Swift Package 플러그인 `plugin:OpenAPIGenerator`와 런타임(`OpenAPIRuntime`, `OpenAPIURLSession`)이 이미 프로젝트에 연결되어 있습니다.

## Topics
- <doc:GettingStarted>
- <doc:Architecture>
- <doc:OpenAPIWorkflow>
