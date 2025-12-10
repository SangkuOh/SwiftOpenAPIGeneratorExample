# Repository Guidelines
주의: 이 문서는 저장소 운영·개발 규칙의 단일 소스입니다. README 등 다른 문서는 요약/참조만 제공하며, 상충 시 본 문서를 기준으로 합니다.

## 언어 규칙
- 모든 설명과 대화는 한국어로 답변합니다.
- 코드/터미널 출력/에러 메시지는 원문을 유지하되, 위아래로 한국어 설명을 덧붙입니다.
- 커밋 메시지, 주석, README도 한국어로 작성하되, 코드 식별자(클래스/함수명)는 영어 관례를 따릅니다.

## Swift/iOS Coding Standards
- 언어/프레임워크: Swift 6 + SwiftUI.
- 디자인/문서: Apple API Design Guidelines, Human Interface Guidelines, 공개 API는 한국어 DocC(///).
- 형식: 4-space 들여쓰기, 줄 길이 ~120자.
- 동시성: async/await·Task 우선, UI 갱신은 @MainActor에서 처리하고 필요 시 Task 취소를 명시적으로 다룹니다.
- 의존성 주입: EnvironmentValues 확장(`appDependencies`)을 통해 live/preview 구성을 공유합니다.
- 계층: Service/Repository/Domain을 분리하고 Repository는 테스트 가능한 실제 구현과 목을 제공합니다.
- 네트워크: OpenAPI Generator가 만든 `Client`/`APIProtocol`은 `RemoteAPI` 래퍼를 통해 사용하며, 생성물은 커밋하지 않습니다(`openapi.yaml`·`openapi-generator-config.yaml`만 관리).

## Architecture Overview
- 화면: `ContentFeature` 뷰가 입력/로딩/결과/에러 상태를 `@State`로 관리하고, 액션은 동일 타입의 extension에 둡니다(@MainActor).
- 의존성: `Environment(\.appDependencies)`에서 `GreetingService` 등 의존성을 읽어 `.live()`와 `.preview()` 구성을 재사용합니다.
- 데이터: `GreetingService` → `GreetingRepository` → `DefaultGreetingRepository`가 `RemoteAPI`를 호출하고 `GreetingEntity`로 매핑합니다.
- 네트워크 테스트: `MockServerTransport`로 네트워크 없이 동일 경로를 실행합니다. 새 엔드포인트는 OpenAPI 스펙에 `operationId`를 추가한 뒤 `RemoteAPI`와 Repository/Service를 확장합니다.

## Testing
- 프레임워크: Swift Testing. 로직 변경 시 happy/edge 테스트를 추가하거나 기존 테스트를 갱신합니다.
- 네트워크: 테스트/프리뷰는 기본 `.preview()` 의존성이나 `MockServerTransport` 스텁으로 외부 호출을 막습니다.
- 실행 예시:
```
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
- 결과/아티팩트: 표준출력만 사용하며 커스텀 결과 번들/로그 파일 등 추가 아티팩트를 만들지 않습니다.

## Git/작업 흐름
- 기본 브랜치는 `main`입니다. 작업 브랜치는 `feature/*`, `fix/*`, `chore/*` 등으로 분리하고 필요 시 `main` 위로 rebase합니다.
- 커밋: Gitmoji + type + [scope] + 요약 형식을 권장합니다. 한 커밋에는 한 목적만 담고 로직 변경 시 테스트를 포함합니다.
- PR: 한 가지 목적에 집중하고 자동 생성 파일은 포함하지 않습니다. UI 변경 시 Before/After를 첨부하고 merge commit을 유지합니다.
- 삭제/대규모 이동 등 비가역 변경은 사전 확인 후 진행합니다. 사용자 요청 전에는 PR 생성/병합/푸시를 수행하지 않습니다.
