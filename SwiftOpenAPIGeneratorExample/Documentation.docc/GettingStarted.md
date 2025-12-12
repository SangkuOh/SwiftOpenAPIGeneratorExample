# 시작하기

## 필수 조건
- Xcode 16 이상(Swift Testing, Swift 6 타깃)과 iOS 17 시뮬레이터 또는 디바이스.
- 백엔드가 `http://localhost:8080/api`에서 `GET /greet?name=` 요청에 `{"message": "..."}` 형태로 응답하도록 준비되어 있어야 합니다. 다른 주소라면 `Config/Development.xcconfig`·`Config/Release.xcconfig`의 `API_BASE_URL`을 바꾸고, 생성물과 맞추려면 `api-spec/openapi/openapi.yaml`의 `servers`도 함께 조정하세요.
- 프로덕션에서는 HTTPS를 기본으로 사용하고, 로컬 개발 시에만 필요한 경우에만 HTTP를 허용하세요. HTTP 예외는 `.xcconfig`의 `API_ALLOW_INSECURE_HOSTS`로 관리합니다.

## 샘플 실행
1. 백엔드를 기동한 상태라면 기본 Environment가 `AppDependencies.live()`로 채워지므로 바로 실제 API 흐름을 확인할 수 있습니다. 네트워크 없는 환경에서 UI만 검증하려면 `ContentFeature().environment(\.appDependencies, .preview())`로 목 의존성을 명시하세요. 시나리오별로 응답을 바꾸려면 `APIMockScenarios`에서 스텁을 만든 뒤 `AppDependencies.preview(stubs:)`로 주입하면 됩니다. OpenAPI 경로를 따라가며 목을 쓰고 싶다면 `GreetingRepositoryFactory.preview()/live`로 저장소를 만든 뒤 `AppDependencies.live(repository:)`로 감싸 전달합니다.
2. `SwiftOpenAPIGeneratorExample.xcodeproj`를 열고 기본 타깃을 선택한 뒤 시뮬레이터/디바이스를 지정합니다.
3. 실행하면 `ContentFeature`에서 이름을 입력하고 “Fetch greeting”을 눌러 생성된 클라이언트가 만든 요청과 응답 처리를 확인할 수 있습니다.

## 자신의 API로 바꾸기
1. `api-spec/openapi/openapi.yaml`에 실제 OpenAPI 스펙을 반영하고, 서버 URL을 원하는 환경(개발/스테이징/프로덕션)으로 맞춥니다.
2. 생성 옵션이 필요하면 `Modules/Sources/APITypes/openapi-generator-config.yaml`(types)와 `Modules/Sources/APIClient/openapi-generator-config.yaml`(client)에서 접근 제어, 이름 전략, `additionalImports` 등을 조정합니다.
3. 빌드하면 `Modules` 패키지의 `plugin:OpenAPIGenerator`가 스펙을 읽어 타깃별로 types/client를 재생성합니다. 생성물은 DerivedData 아래에 위치하며 저장소에 커밋되지 않습니다.
4. 새 엔드포인트를 쓰려면 `Modules/Sources/APIInfra`에 전용 모듈(프로토콜+구현)을 추가하고, `APIEnvironment`에 프로퍼티로 노출한 뒤 리포지터리에서 이를 사용해 도메인 엔터티로 매핑하세요.

## API 베이스 URL과 환경 분리
– 앱은 `GreetingRepositoryFactory.live(configuration:, transport:)` 또는 `.preview(stubs:)`로 저장소를 만든 뒤 `AppDependencies.live(repository:)`로 감싸 `Environment(\.appDependencies)`에 전달합니다. 기본 Environment 값은 `AppDependencies.live()`가 제공하는 라이브 의존성을 사용합니다. Info.plist의 `API_BASE_URL`/`API_ALLOW_INSECURE_HOSTS`(Config/*.xcconfig에서 채움)을 읽어 사용하며, 설정되지 않았을 때만 OpenAPI 스펙의 `servers[0]`로 되돌아갑니다.
- `APIConfiguration`은 HTTPS만 허용하며, `API_ALLOW_INSECURE_HOSTS`(콤마 구분)를 비워 두면 HTTP를 전부 거부합니다. 값을 지정하면 해당 호스트에 한해 HTTP를 허용하고, 값이 없을 때만 기본 로컬 예외(`localhost`, `127.0.0.1`)를 적용합니다.

## 생성물 직접 살펴보기
- 터미널에서 생성 과정을 확인하려면 로컬 폴더로 출력하도록 실행하세요. 예)

```sh
swift openapi generate --config Modules/Sources/APITypes/openapi-generator-config.yaml --output .openapi-generator/APITypes
swift openapi generate --config Modules/Sources/APIClient/openapi-generator-config.yaml --output .openapi-generator/APIClient
```

- 출력물을 커밋할 필요는 없으며, 변경점 비교나 디버깅에만 활용하면 됩니다.
