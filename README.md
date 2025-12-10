# SwiftOpenAPIGeneratorExample

Swift OpenAPI Generator가 만든 클라이언트와 SwiftUI 화면을 잇는 최소 예제입니다. 한 화면에서 입력 → 요청 → 응답 표시까지의 흐름, OpenAPI 스펙 관리, 환경 분리를 모두 담아 팀원이 바로 복제해 확장할 수 있게 구성했습니다.

## 주요 특징
- SwiftUI `ContentFeature` 한 화면에서 `@State`로 입력/로딩/결과/에러를 관리하고 액션은 동일 타입의 메서드로 분리했습니다.
- 의존성은 `Environment(\.appDependencies)` 한 경로에서 주입하며, `AppDependencies.live/preview`로 프로덕션과 목 구성을 재사용합니다.
- 도메인(`GreetingService`, `GreetingRepository`, `GreetingEntity`)과 데이터(`DefaultGreetingRepository`)를 나눠 테스트·모킹이 쉽습니다.
- 네트워크는 생성된 `Client`·`APIProtocol`을 감싼 `RemoteAPI`로 얇게 래핑해 전송 세부 사항을 UI/도메인이 알 필요 없게 했습니다.
- OpenAPI 스펙(`Networking/openapi.yaml`)과 생성 설정(`Networking/openapi-generator-config.yaml`)만 관리하고, 생성물은 빌드 시 플러그인이 준비하므로 커밋 대상이 아닙니다.
- `MockServerTransport`로 네트워크 없이도 동일 코드 경로를 실행하는 프리뷰/테스트 구성을 제공합니다.

## 요구 사항
- Xcode 16 이상(스위프트 테스팅, Swift 6 타겟)과 iOS 17 이상 시뮬레이터 또는 디바이스.
- 기본 스펙은 `http://localhost:8080/api`에 열린 `GET /greet`가 `{"message":"..."}` 형태로 응답한다고 가정합니다. 다른 주소라면 `Config/*.xcconfig`와 `Networking/openapi.yaml`의 `servers`를 함께 조정하세요.

## 실행 방법
1) **목(기본)으로 보기**: `SwiftOpenAPIGeneratorExampleApp`에서 `.environment(\.appDependencies, .preview())`를 사용하므로 바로 실행하면 목 응답을 반환합니다. 이름을 입력하고 “Fetch greeting”을 눌러 흐름을 확인하세요.  
2) **실제 API로 보기**: App 진입에서 `.live()`를 주입하거나, 프리뷰·테스트에서도 `.preview(configuration:)`에 원하는 `APIConfiguration`을 전달하세요. `Config/Development.xcconfig`의 `API_BASE_URL`/`API_ALLOW_INSECURE_HOSTS`로 베이스 URL과 HTTP 예외를 관리합니다(빈 값이면 스펙의 첫 서버로 폴백, HTTP는 기본 차단).
3) **커스텀 스펙 적용**: `Networking/openapi.yaml`과 `Networking/openapi-generator-config.yaml`를 원하는 계약/옵션으로 수정하고 빌드하면 플러그인이 자동 재생성합니다. 생성물은 DerivedData 아래에서만 유지됩니다.

## 프로젝트 구조
- `SwiftOpenAPIGeneratorExampleApp.swift`: 앱 엔트리, 의존성 주입.
- `UI/ContentFeature.swift`(+View): 입력/액션/상태·에러 표현.
- `Domain/`: `GreetingService`/`GreetingRepository` 인터페이스와 `GreetingEntity`.
- `Data/DefaultGreetingRepository.swift`: `RemoteAPI` 호출 후 도메인 엔터티로 매핑.
- `Environment/`: `AppDependencies` 조립(라이브/목), `EnvironmentValues` 확장.
- `Networking/RemoteAPI.swift`: `APIConfiguration` 유효성 검사, 생성된 `Client` 래퍼, 에러 매핑.
- `Networking/MockServerTransport.swift`: 요청 기록·매칭 기반 목 트랜스포트와 `greetingResponse` 기본 스텁.
- `Networking/openapi.yaml` / `openapi-generator-config.yaml`: OpenAPI 계약과 생성 설정의 단일 소스.
- `Config/*.xcconfig`: Info.plist에 주입되는 API 베이스 URL, HTTP 허용 호스트 설정.
- `Documentation.docc/`: 아키텍처, 시작 가이드, OpenAPI 워크플로 문서.
- `SwiftOpenAPIGeneratorExampleTests/`: Swift Testing 기반 유닛 테스트(`ContentFeatureLogicTests`).

## OpenAPI 워크플로
- 스펙을 수정하면 빌드 시 `plugin:OpenAPIGenerator`가 `types`·`client`를 내부 접근자로 생성합니다.
- 생성 과정을 터미널에서 보고 싶다면 루트에서 다음을 실행해 로컬 출력물을 확인하세요(커밋 불필요).

```sh
swift openapi generate \
  --config SwiftOpenAPIGeneratorExample/Networking/openapi-generator-config.yaml \
  --output .openapi-generator \
  SwiftOpenAPIGeneratorExample/Networking/openapi.yaml
```

- 새 엔드포인트를 쓰려면 스펙에 `operationId`를 추가 → `RemoteAPI`에 대응 메서드 래핑 → 리포지터리/서비스/뷰에서 사용 순으로 확장합니다.

## 테스트
- 스킴: `SwiftOpenAPIGeneratorExample` (빌드 구성: Development). 시뮬레이터 예시는 iPhone 16 / iOS 18.5 기준입니다.
- 기본 원격 호출을 막으려면 `.preview()` 의존성을 주입하거나 `MockServerTransport` 스텁을 전달하세요.
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
- 더 자세한 흐름과 결정 포인트는 `Documentation.docc/*` 문서를, 네트워크 계약은 `Networking/openapi.yaml`을 확인하세요.
