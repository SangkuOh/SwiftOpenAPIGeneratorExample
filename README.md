# SwiftOpenAPIGeneratorExample

Swift OpenAPI Generator가 만든 클라이언트와 SwiftUI 화면을 잇는 최소 예제입니다. 한 화면에서 입력 → 요청 → 응답 표시까지의 흐름과 OpenAPI 스펙 관리, 환경 분리를 담아 팀원이 바로 복제해 확장할 수 있게 구성했습니다.

## 주요 특징
- SwiftUI `ContentFeature` 한 화면에서 `@State`로 입력/로딩/결과/에러를 관리하고 액션은 동일 타입의 메서드로 분리했습니다.
- 의존성은 `Environment(\.appDependencies)` 한 경로에서 주입하며, `AppDependencies.live/preview`로 프로덕션과 목 구성을 재사용합니다.
- 도메인/서비스/데이터를 `AppDomain`·`AppService`·`AppData`로 분리해 레이어 경계를 명확히 했습니다.
- 네트워크는 `APIInfra`가 `APIClient`/`APITypes` 생성물을 감싸서 AppData만 알도록 하고, UI/도메인은 OpenAPI 세부사항을 모릅니다.
- `Modules` Swift 패키지는 `AppDomain`/`AppService`/`AppData`/`AppUI`/`APIInfra`/`APITypes`/`APIClient` 타깃으로 구성되어 앱 타깃은 `AppUI` 하나만 의존하면 됩니다.
- OpenAPI 스펙은 `api-spec/openapi/openapi.yaml` 한 곳에서 관리하고, 생성 설정은 `Modules/Sources/APITypes/openapi-generator-config.yaml`·`Modules/Sources/APIClient/openapi-generator-config.yaml`로 분리해 types/client를 따로 생성합니다.
- `MockServerTransport`로 네트워크 없이도 동일 코드 경로를 실행하는 프리뷰/테스트 구성을 제공합니다.

## 요구 사항
- Xcode 16 이상(스위프트 테스팅, Swift 6 타겟)과 iOS 17 이상 시뮬레이터 또는 디바이스.
- 기본 스펙은 `http://localhost:8080/api`에 열린 `GET /greet`가 `{"message":"..."}` 형태로 응답한다고 가정합니다. 다른 주소라면 `Config/*.xcconfig`와 `api-spec/openapi/openapi.yaml`의 `servers`를 함께 조정하세요.

## 실행 방법
1) **목(기본)으로 보기**: `SwiftOpenAPIGeneratorExampleApp`에서 `.environment(\.appDependencies, .preview())`를 사용하므로 바로 실행하면 목 응답을 반환합니다. 이름을 입력하고 “Fetch greeting”을 눌러 흐름을 확인하세요.  
2) **실제 API로 보기**: App 진입에서 `.live()`를 주입하거나, 프리뷰·테스트에서도 `.preview(configuration:)`에 원하는 `GreetingAPIConfiguration`을 전달하세요. `Config/Development.xcconfig`의 `API_BASE_URL`/`API_ALLOW_INSECURE_HOSTS`로 베이스 URL과 HTTP 예외를 관리합니다(빈 값이면 스펙의 첫 서버로 폴백, HTTP는 기본 차단).
3) **커스텀 스펙 적용**: `api-spec/openapi/openapi.yaml`과 `Modules/Sources/APITypes`·`Modules/Sources/APIClient`의 생성 설정을 원하는 계약/옵션으로 수정하면 빌드 시 플러그인이 자동 재생성합니다. 생성물은 DerivedData 아래에서만 유지됩니다.

## 프로젝트 구조
- `Modules/Package.swift`: 계층별 라이브러리 타겟을 선언한 Swift 패키지 매니페스트.
- `Modules/Sources/AppUI/`: 입력/액션/상태·에러 표현을 담은 SwiftUI 화면과 `EnvironmentValues` 확장, `AppDependencies`.
- `Modules/Sources/AppService/`: `GreetingService` 유스케이스 인터페이스와 기본 구현.
- `Modules/Sources/AppDomain/`: `GreetingRepository` 인터페이스와 `GreetingEntity`.
- `Modules/Sources/AppData/`: `DefaultGreetingRepository` 구현과 저장소 조립 헬퍼.
- `Modules/Sources/APIInfra/`: API 구성(`APIConfiguration`), `APIEnvironment`, `GreetingAPI` 래퍼, `MockServerTransport`, `RemoteAPIError`.
- `Modules/Sources/APITypes/`: OpenAPI types 전용 타깃 설정 파일.
- `Modules/Sources/APIClient/`: OpenAPI client 전용 타깃 설정 파일.
- `api-spec/openapi/openapi.yaml`: 단일 OpenAPI 스펙 경로.
- `SwiftOpenAPIGeneratorExample/SwiftOpenAPIGeneratorExampleApp.swift`: 앱 엔트리, 의존성 주입.
- `SwiftOpenAPIGeneratorExample/Documentation.docc/`: 아키텍처, 시작 가이드, OpenAPI 워크플로 문서.
- `SwiftOpenAPIGeneratorExample/Assets.xcassets`: 앱 아이콘과 색상 리소스.
- `Config/*.xcconfig`: Info.plist에 주입되는 API 베이스 URL, HTTP 허용 호스트 설정.
- `SwiftOpenAPIGeneratorExampleTests/`: Swift Testing 기반 유닛 테스트(`ContentFeatureLogicTests`).

## OpenAPI 워크플로
- 빌드 시 `APITypes`와 `APIClient` 타깃에서 `OpenAPIGenerator` 플러그인이 각각 types/client를 생성합니다.
 - 생성 과정을 터미널에서 보고 싶다면 루트에서 다음처럼 타깃별로 실행해 로컬 출력물을 확인하세요(커밋 불필요).
 - 각 명령의 마지막 인수는 필수인 스펙 경로입니다(`Modules/Sources/APITypes/openapi.yaml`, `Modules/Sources/APIClient/openapi.yaml`, 모두 `api-spec/openapi/openapi.yaml` 심볼릭 링크).

```sh
swift openapi generate \
  --config Modules/Sources/APITypes/openapi-generator-config.yaml \
  --output .openapi-generator/APITypes \
  Modules/Sources/APITypes/openapi.yaml

swift openapi generate \
  --config Modules/Sources/APIClient/openapi-generator-config.yaml \
  --output .openapi-generator/APIClient \
  Modules/Sources/APIClient/openapi.yaml
```

- 새 엔드포인트를 쓰려면 스펙에 `operationId`를 추가 → `Modules/Sources/APIInfra`에 엔드포인트 모듈 추가/확장 → `APIEnvironment` 프로퍼티로 노출 → 리포지터리·서비스·뷰에서 사용 순으로 확장합니다.

## 테스트
- 스킴: `SwiftOpenAPIGeneratorExample` (빌드 구성: Development). 시뮬레이터 예시는 iPhone 16 / iOS 18.5 기준입니다.
- 기본 원격 호출을 막으려면 `.preview()` 의존성을 주입하거나 `GreetingAPIMockStub`를 전달하세요.
- 표준 출력만 사용하는 xcodebuild 예시:

```sh
DEST_NAME="iPhone 16"
DEST_OS="iOS 18.5"
NSUnbufferedIO=YES xcodebuild \
  -project SwiftOpenAPIGeneratorExample.xcodeproj \
  -scheme "SwiftOpenAPIGeneratorExample" \
  -configuration Development \
  -destination "platform=iOS Simulator,name=${DEST_NAME},OS=${DEST_OS},arch=arm64" \
  -enableCodeCoverage NO \
  test
```

## 참고
- 더 자세한 흐름과 결정 포인트는 `Documentation.docc/*` 문서를, 네트워크 계약은 `api-spec/openapi/openapi.yaml`을 확인하세요.
