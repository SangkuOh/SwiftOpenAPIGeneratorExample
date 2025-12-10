# OpenAPI 워크플로

## 스펙
- 계약은 `Networking/openapi.yaml`에 정의되어 있습니다. 이 예제는 `GET /greet`가 `{"message": "..."}`를 반환한다는 단순 계약을 사용합니다.
- 런타임 기본 URL은 `.xcconfig`(`Config/Development.xcconfig`, `Config/Release.xcconfig`)의 `API_BASE_URL` 값이 Info.plist로 전달되어 `RemoteAPI`에서 읽힙니다. 비워두면 OpenAPI 스펙의 첫 서버(`Servers.server1()`, 기본 `http://localhost:8080/api`)로 되돌아갑니다. `API_ALLOW_INSECURE_HOSTS`(콤마 구분)가 비어 있으면 HTTP를 전부 거부하고, 설정되지 않은 경우에만 로컬 호스트(`localhost`, `127.0.0.1`)를 허용합니다.

## 생성 설정
- `Networking/openapi-generator-config.yaml`는 `types`와 `client`를 생성하고, `internal` 접근 제어 및 `idiomatic` 이름 전략을 사용하도록 지정합니다.
- Xcode 타깃에 추가된 `plugin:OpenAPIGenerator`가 빌드 시 해당 설정과 스펙을 읽어 생성물을 준비합니다. 별도 커밋은 필요 없습니다.
- 스펙이 커질수록 `generate` 목록에 `server`를 추가하거나 접근 제어를 `public`으로 바꾸면 프레임워크화하기 쉬워집니다.

## 생성된 타입 활용
- 생성물에서 제공하는 핵심 타입은 `Client`, `Servers`, `APIProtocol`, 그리고 `Components.Schemas.*` 구조체입니다.
- `RemoteAPI`는 이들을 다음처럼 사용합니다:

```swift
let transport = URLSessionTransport()
let serverURL = try Servers.server1() // openapi.yaml의 servers[0]
let client = Client(serverURL: serverURL, transport: transport)
let response = try await client.getGreeting(query: .init(name: name))
```

## 재생성 사이클
1. 스펙(`openapi.yaml`)을 수정하거나 생성 옵션(`openapi-generator-config.yaml`)을 변경합니다.
2. 빌드하면 플러그인이 자동으로 재생성합니다. 생성된 메서드/타입 이름은 `operationId`와 스키마 이름에 따라 결정됩니다.
3. 래퍼(`RemoteAPI`)와 리포지터리에서 새 메서드를 호출하도록 연결하고, 필요하면 도메인 모델을 추가합니다.
4. UI·뷰모델을 업데이트해 새 데이터를 표시합니다. 네트워크 없는 환경에서는 `GreetingRepository`를 목으로 바꿔 빠르게 검증할 수 있습니다.
