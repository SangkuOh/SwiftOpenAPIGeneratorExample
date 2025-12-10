# Repository Guidelines
주의: 이 문서는 저장소 운영·개발 규칙의 단일 소스입니다. README 등 다른 문서는 요약/참조만 제공하며, 상충 시 본 문서를 기준으로 합니다.
## 언어 규칙
- 모든 설명과 대화는 한국어로 답변합니다.
- 코드/터미널 출력/에러 메시지는 원문을 유지하되, 위아래로 한국어 설명을 덧붙입니다.
- 커밋 메시지, 주석, README도 한국어로 작성하되, 코드 식별자(클래스/함수명)는 영어 관례를 따릅니다.


## Swift/iOS Coding Standards

- **언어/프레임워크:** Swift 6 + SwiftUI.
- **디자인/문서:** Apple API Design Guidelines, Human Interface Guidelines, 공개 API는 한국어 DocC(///).
- **형식:** 4‑space 들여쓰기, 줄 길이 ~120자.
- **동시성:** async/await·AsyncSequence 우선, 취소는 CancellationBag(뷰는 CancellationBagView). Combine은 시스템 경계(URLSession, NotificationCenter)에 한정.
- **의존성 주입:** EnvironmentValues 확장 + @Entry.
- **데이터 접근:** Repository 프로토콜(실제 구현 + mock).
- **서비스 레이어:** 외부 연동은 Service로 분리.
- **명명 규칙:** 변수/함수/타입은 Apple 컨벤션을 따름.

## Architecture Overview

- 아키텍처 상세 규칙은 **Swift/iOS Coding Standards**를 단일 소스로 따릅니다.
- 화면 단위는 ViewModel이 이벤트/상태를 관리합니다.
- 전역 상태는 Store 모듈의 @Observable 싱글톤이 담당합니다.
- 외부 연동은 Service, 데이터는 Repository 계층으로 분리합니다.
- 비동기 작업은 CancellationBag으로 취소 가능하게 관리합니다.

### Agentic eagerness presets
```
<context_gathering>
빠르게 핵심 컨텍스트만 모은 뒤 행동 가능 시점에서 멈춘다. 중복 검색 금지, 한 번의 병렬 배치로 후보 압축.
</context_gathering>
```
```
<persistence>
요청이 완전히 해결될 때까지 자율 지속. 불확실하면 합리적 가정 후 진행하고 가정/근거를 기록한다.
</persistence>
```

### Tool preambles
```
<tool_preambles>
목표 재진술 → 단계별 계획 → 단계별 진행 한 줄 보고 → 완료 요약(+계획 변경 사항)
</tool_preambles>
```

 

### Safety & handback
- 삭제/대규모 이동·치환/비가역 변경은 **명시적 확인** 없이는 금지.
- 같은 검색의 무의미한 재시도 금지. 애매하면 계획 요약 후 확인 질문.
- 사용자 명시 요청 전에는 커밋 작성, PR 생성, 브랜치 병합 등 저장소 이력 변경 작업을 수행하지 않습니다. (로컬 변경만 허용, 푸시/머지 금지)

### iOS preflight 체크리스트
- 대상 파일/타입/심볼, 영향 범위(호출자/프로토콜) 목록화
- 메인 액터/UI 업데이트 경계, 취소(CancellationBag) 점검
- 접근성 라벨/트레이트, AppLogger 레벨 확인
- 신규/변경 경로의 최소 happy/edge 테스트 필요



## Testing

- Swift의 async/await 및 구조적 동시성 기반 테스트를 사용합니다.
- Service/Repository는 mock 구현을 우선 사용해 I/O 의존성을 분리합니다.
- **로직의 추가·변경·삭제가 있는 경우**, Testing 프레임워크로 최소 단위 테스트(happy/edge)를 **반드시** 추가하거나 기존 테스트를 수정/삭제하여 일관성을 유지합니다(회귀 방지).
- 테스트 코드 작성 이후에는 항상 테스트코드 실행을 통해 검증을 합니다.
- 모듈화/테스트 용이성을 위해 ServiceRunnable 및 Repository 추상화를 준수합니다.
- Combine은 시스템 경계에서만 사용합니다(자세한 규칙은 _Swift/iOS Coding Standards_ 참조).

### 실행
- scheme: puraxel Tests
- 기본 대상: iPhone 16 / iOS 18.5 (필요 시 다른 조합 선택)
- 최소 타깃: iOS 17
- Xcode 선택: 전역 스위치 대신 `DEVELOPER_DIR` 환경변수로 지정합니다(관리자 권한 불필요). 스크립트(`scripts/test.sh`)는 자동으로 안정판→베타 순으로 탐색하여 설정합니다.
- 기본 규칙: 테스트 실행 시 추가 아티팩트(별도 결과 번들/로그 파일)를 생성하지 않습니다.
  - `-resultBundlePath`를 사용해 커스텀 결과 번들(.xcresult)을 만들지 않습니다. Xcode가 DerivedData에 생성하는 기본 번들은 허용되나, 보고는 표준출력 파싱을 우선합니다.
  - `xcbeautify --output-file`·파일로 리디렉션 저장 등을 사용하지 않습니다.
  - 표준출력만을 사용하여 결과를 보고합니다.

#### 범용 실행 스크립트(권장)
[설명] 다양한 개발 환경에서 동일한 규칙으로 테스트를 실행하기 위한 표준 스크립트입니다. Xcode 선택(안정판→베타 폴백), 시뮬레이터 선택(정확 매칭 실패 시 가용 iPhone 1순위), 사전 부팅, 요약 출력(이모지)을 자동화합니다.

```
bash scripts/test.sh

# 환경 변수로 재정의 가능
PROJECT="puraxel/puraxel.xcodeproj" \
SCHEME="puraxel Tests" \
CONFIG="Development" \
DEST_NAME="iPhone 16" \
DEST_OS="iOS 18.5" \
bash scripts/test.sh
```

참고: 스크립트는 전역 전환(`xcode-select --switch`)을 사용하지 않으며, 표준출력만을 사용합니다. Apple Silicon에서 `-destination "...,arch=arm64"`를 자동 지정합니다.

#### 명령(커버리지 비활성/사전 부팅)
[설명] 아래 명령은 시뮬레이터를 사전 부팅하고 테스트를 실행합니다. arch 경고를 피하려면 `arch=arm64`를 함께 지정합니다.
```
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer

# 1) 대상 시뮬레이터 선택(예: iPhone 16 / iOS 18.5)
UDID="8D1A3C02-F03D-45DB-82DF-19125DE6A24D"  # 필요 시 원하는 UDID로 교체

# 2) 시뮬레이터 워밍업(콜드 스타트 회피)
xcrun simctl boot "$UDID" || true
xcrun simctl bootstatus "$UDID" -b

# 3) 테스트 실행(커버리지 비활성/아키텍처 명시)
NSUnbufferedIO=YES xcodebuild \
  -project puraxel/puraxel.xcodeproj \
  -scheme "puraxel Tests" \
  -configuration Development \
  -destination "id=$UDID,arch=arm64" \
  -enableCodeCoverage NO \
  -quiet \
  test
```

#### 표준 출력 요약(이모지)
[설명] xcodebuild 표준출력을 즉시 파싱해 요구 포맷(이모지)으로 집계합니다.
```
# 실행과 집계를 분리하여 명확히 출력(파일 생성 없음)
start=$(date +%s)
OUT=$(NSUnbufferedIO=YES xcodebuild \
  -project puraxel/puraxel.xcodeproj \
  -scheme "puraxel Tests" \
  -configuration Development \
  -destination "id=$UDID,arch=arm64" \
  -enableCodeCoverage NO \
  -quiet \
  test 2>&1)
dur=$(( $(date +%s) - start ))

PASSED=$(printf "%s" "$OUT" | awk '/^Test case .* passed/ {p++} END {print p+0}')
FAILED=$(printf "%s" "$OUT" | awk '/^Test case .* failed/ {f++} END {print f+0}')
SKIPPED=$(printf "%s" "$OUT" | awk '/^Test case .* skipped/ {s++} END {print s+0}')

echo "✅ 성공: $PASSED"
echo "❌ 실패: $FAILED"
echo "⏭️ 스킵: $SKIPPED"
echo "🧪 스킴: puraxel Tests"
echo "📱 대상: ${DEST_NAME:-iPhone 16} / ${DEST_OS:-iOS 18.5}"
echo "⏱️ 소요시간: ${dur}s"

# 실패 테스트가 있으면 식별자 목록을 추가 출력(선택)
if [ "$FAILED" -gt 0 ]; then
  printf "%s" "$OUT" | awk '/^\t-\[.*\]$/ {print "🔴 실패 테스트: "$0}'
fi
```

#### 장애 진단(자주 묻는 질문)
- 증상: `xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance`
  - 원인: 활성 개발자 디렉터리가 CLT를 가리킴. Xcode CLI 미설치가 아님.
  - 조치: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` 또는 `/Applications/Xcode-beta.app/Contents/Developer`를 설정하여 재시도. 스크립트는 자동으로 처리합니다.
- 증상: 라이선스 미수락으로 인한 실패
  - 조치: `sudo xcodebuild -license accept` 후 재시도(한 번만 필요).
- 증상: 사용 가능한 iOS 런타임/시뮬레이터 없음
  - 조치: Xcode > Settings > Platforms에서 해당 iOS 런타임 설치 후 `xcrun simctl list devices available`로 재확인.

### 파일 생성 금지(중요)
- 테스트 실행 시 아래 항목을 새로 만들지 않습니다.
  - 커스텀 결과 번들(`-resultBundlePath`로 생성되는 별도 `.xcresult`), 임의 로그 파일(`.log`), 임시 스냅샷/첨부 파일
  - 리포지토리 내 `.build-logs/`, `Reports/` 등 커스텀 출력 디렉터리
- 예외: Xcode가 자동으로 `~/Library/Developer/Xcode/DerivedData`에 생성하는 기본 `.xcresult`/캐시는 허용합니다(리포지토리 외부, 수동 정리 금지).
  - 보고/집계는 표준출력 파싱을 우선하며, `xcresulttool` 등은 필요 시 보조 수단으로만 사용합니다.

### 결과(표준 출력 포맷)
- 아래 이모지 약속으로 요약을 출력합니다.
  - ✅ 성공: 통과 테스트 수
  - ❌ 실패: 실패 테스트 수
  - ⏭️ 스킵: 스킵 테스트 수(있다면)
  - 🧪 스킴: 실행 스킴 이름
  - 📱 대상: 기기/OS 요약
  - ⏱️ 소요시간: 테스트 총 소요시간(가능하면)
- 실패가 있는 경우, 읽기 좋은 목록으로 실패 테스트를 명시합니다.
  - 🔴 실패 테스트: `<Target>/<TestClass>/<testMethod>`
  - 필요 시 해당 테스트의 assertion 메시지/스택 일부만 간결히 첨부합니다.

### 느린 테스트 대응(실행 시간 최적화)
- 선택 실행: 변경 관련 테스트만 우선 실행합니다.
  - `-only-testing:<Target>/<TestClass>/<testMethod>` 우선 사용
  - 또는 `-skip-testing:`으로 무거운/외부연동 테스트를 건너뜀
- 커버리지 기본 비활성화: 속도가 중요할 때 `-enableCodeCoverage NO` (요청 시/CI에서만 활성화)
- 병렬화: 필요 시에만 활성화합니다. 시작값은 2를 권장하며, 환경에 따라 3까지 고려합니다(4 이상은 이득이 제한적일 수 있음).
- 플래그: `-parallel-testing-enabled YES`, `-maximum-concurrent-test-simulator-destinations <N>`로 동시수 제어.
- 안정성 주의: 동시수가 높아질수록 메모리/디스크 경쟁과 플래키 리스크가 증가합니다. 스위트 특성에 맞춰 실측 후 결정하세요.
- 직렬 모드 참고: 일부 환경에서 `-parallel-testing-enabled NO`가 simctl 진단 수집 오류를 유발할 수 있습니다. 이 경우 `YES`와 함께 `-maximum-concurrent-test-simulator-destinations 1`을 사용해 동일 효과를 얻습니다.
- 시뮬레이터 워밍업: 테스트 전 대상 시뮬레이터를 부팅해 콜드 스타트를 회피합니다.
  - `xcrun simctl boot <UDID>` + `xcrun simctl bootstatus <UDID> -b`
- 아키텍처 명시: 중복 대상 경고를 피하려면 `arch=arm64`를 `-destination`에 포함합니다.
  - 예: `-destination "id=<UDID>,arch=arm64"` 또는 `-destination "platform=iOS Simulator,OS=18.5,name=iPhone 16,arch=arm64"`
- 단일 대상 최소화: 하나의 기기/OS 조합으로만 실행(필요 시에만 매트릭스 확장)
- 외부 I/O 차단: 네트워크/파일시스템 의존 테스트는 Mock으로 대체하여 지연 요인 제거
- 패키지 재해석 최소화: SPM 의존성은 기본 캐시를 재사용하고, 불필요한 `clean` 금지

## Git 브랜치/릴리즈 전략

팀 일관성과 안전한 배포를 위해 다음 전략을 기본으로 합니다.

- 권장 운영 모델: Merge‑Only 3‑레인(`development → stage → main`) + `release/x.y`, `hotfix/x.y.z`.
- 브랜치 모델: `development`(기본 개발), `stage`(릴리즈 후보 검증), `main`(프로덕션)
- 병합 정책: PR 머지 전용(merge commit 유지). 세부 설정과 메시지 규칙은 아래 "병합 커밋 정책(머지 커밋 유지) 세부 가이드"를 참조하세요.

### 브랜치 병합 허용(원천 제한)
- 용어: base=PR 대상 브랜치, head=PR 소스 브랜치(아래는 base별 허용 head 목록).
- base `main`: 허용 head = `stage`, `release/x.y`, `hotfix/x.y.z`
- base `stage`: 허용 head = `release/x.y`, `development`(동기화 PR만)
- base `development`: 허용 head = `feature/*`, `fix/*`, `refactor/*`, `chore/*`, `release/x.y`(역병합 동기화), `hotfix/x.y.z`(역병합 동기화)
- 역병합 동기화 PR: merge commit 유지(rebase/squash 금지). PR 제목 예시: `🔧 chore: [Release] x.y sync-back to development`, `🔧 chore: [Hotfix] x.y.z sync-back to development`. 라벨 권장: `sync-back`(+ `release` 또는 `hotfix`).
- 이유: 추적성·감사 용이성과 롤백 단순화, 실수성 직접 커밋/임의 병합 방지.

### 브랜치 네이밍 규칙
- `feature/<scope>/<short>` 예: `feature/Auth/FaceID-login`
- `fix/<scope>/<issue>` 예: `fix/Camera/#123-focus-lock`
- `refactor/<scope>` 예: `refactor/Store/Cancellation`
- `chore/<scope>` 예: `chore/CI/parallel-tests`
- `release/x.y` 예: `release/1.4`
- `hotfix/x.y.z` 예: `hotfix/1.4.1`
- Linear 티켓 기반 작업 시 브랜치명에 티켓 식별자를 포함합니다(예: `feature/Main/539-33-status-banner-connection`).

### 브랜치 업데이트 정책
- feature·fix 등 작업 브랜치는 정기적으로 `origin/development` 위로 rebase합니다.
  - 권장: `git fetch origin && git rebase -i --autosquash origin/development`
- `development → feature` 방향의 merge는 금지합니다(불필요한 머지 커밋 방지). rebase를 사용하세요.
- 공유 브랜치에 강제 push는 금지합니다. 개인 작업 브랜치 강제 push가 필요하면 `--force-with-lease`만 사용합니다.

### 보호 브랜치(Repository 보호 설정 권장)
- 대상: `main`, `development`, `stage`
- 규칙: 직접 push 금지, PR 필수, 필수 체크(빌드·테스트) 통과 후 병합
- 선택: 서명 커밋(Verified) 또는 DCO 서명(`Signed-off-by`) 권장

### 릴리즈 플로우
1) `development`에서 `release/x.y` 브랜치 생성(기능 동결·버그픽스만)
2) `release/x.y` → `stage`로 PR 생성, 승인 후 병합하여 후보 검증
3) 배포 승인 시 `release/x.y`를 `main`에 merge(merge commit 유지) 및 릴리즈 태그 생성(아래 "태그/릴리즈 관리 권고" 준수)
4) `CHANGELOG`/릴리즈 노트 갱신 후 `release/x.y`를 `development`로 역병합(동기화)하고 브랜치 정리

### 태그/릴리즈 관리 권고
- 태그 형식: `vX.Y.Z` annotated tag(서명 권장). 릴리즈 노트와 함께 생성합니다.
- 태그 시점: 릴리즈 병합(`release/x.y` → `main`) 및 핫픽스 병합(`hotfix/x.y.z` → `main`) 시 태깅합니다. 단순 동기화 PR은 태깅하지 않습니다.
- 권한: 태그/릴리즈 생성 권한을 제한하고, 릴리즈 노트 템플릿을 사용합니다.
- 템플릿 경로: GitHub 릴리즈 노트=`.github/release_template.md`, Annotated 태그 메시지=`.github/tag_message_template.txt`
- 사용 예시:
  - 릴리즈 노트 템플릿으로 GitHub 릴리즈 생성: `gh release create vX.Y.Z -F .github/release_template.md`
  - Annotated 태그 메시지 적용: `git tag -a vX.Y.Z -F .github/tag_message_template.txt && git push origin vX.Y.Z`

### 핫픽스 플로우
1) `main`에서 `hotfix/x.y.z` 분기 후 수정
2) `hotfix/x.y.z` → `main` PR 병합(merge commit 유지) 및 태그 `vX.Y.Z`
3) 동일 변경을 `development`(필요 시 `stage`)로 역병합하여 선행 라인과 동기화

### 스택드 PR 운용
- 라벨: `stacked` 부여, PR 설명 상단에 상·하위 링크 명시
- base: 하위 PR의 base를 반드시 상위 PR 브랜치로 지정합니다.
- 병합: 상위 PR 병합 후 하위 PR은 `origin/development` 기준으로 rebase하여 충돌을 정리한 뒤 진행합니다.
- 삭제 예외: 상·하위 의존 관계가 있으면 병합 후 head 브랜치를 삭제하지 않습니다(본 문서의 삭제 예외 규칙과 일치).

### 이슈 연동 규칙
- PR 본문에 다음 키워드를 사용해 이슈 연계를 명시합니다.
  - 완료(자동 닫힘): `Closes #123`, `Fixes #123`
  - 참고(연결만): `Refs #123`

## Commit 규칙

리뷰어가 변경 의도를 빠르게 이해하고 파일 단위로 탐색할 수 있도록, 커밋을 "의미 있는 작업 단위"로 구성합니다.

- 범위: 한 커밋은 하나의 목적만 담습니다(예: 기능 추가, 버그 수정, 리팩터, 스타일, 문서, 빌드 설정).
- 크기 가이드: ~150–300줄/≤5파일 권장. 넘어가면 자연 분할이 가능한지 우선 검토합니다.
- 독립성: 커밋 단위로도 빌드/미리보기/테스트 통과가 가능하도록 최대한 유지합니다(문서만 변경되는 경우 제외).
- 메시지 규칙: Gitmoji + type + [scope] + 요약 + 본문(왜/무엇/어떻게/테스트)
  - 예) `✨ feat: [Home] SkincareSection 미리보기 추가`
  - 본문(선택): 변경 이유(WHY), 핵심 변경(WHAT), 접근/대안(HOW), 리스크/롤백 전략, 테스트(수행/추가) 요약.
- 혼합 금지: 리팩터와 기능 변경을 같은 커밋에 섞지 않습니다. 대규모 리네이밍/포맷팅은 별도 PR로 분리합니다.
- 테스트: 로직 변경이 있는 커밋에는 최소 happy/edge 테스트를 포함합니다(TestSupport 활용).
- 스택/리베이스: PR 전 `git commit --fixup` + `git rebase -i --autosquash`로 WIP을 정리하고 순서를 내러티브로 재구성합니다.

권장 Gitmoji + type 매핑
- ✨ feat: 기능 추가  | 🐛 fix: 버그 수정 | ♻️ refactor: 리팩터
- 📝 docs: 문서/가이드 | 🎨 style: 포맷/스타일(동작 무변) | 🔧 chore: 잡무
- 📦 build: 빌드/의존성 | 👷 ci: CI | 🔒 security: 보안 | 🔥 remove: 삭제 | 🚑 hotfix: 긴급 수정

커밋 본문 예시
```
왜: Preview 없이 화면 검증 시간이 길고 리뷰 난이도가 높음
무엇: #Preview 추가, 상태/샘플데이터 구성, 폰트 프리뷰 확장 적용
어떻게: 모듈별 독립 미리보기 작성, 런타임 코드 변경 없음
테스트: Xcode Canvas 미리보기 수동 확인, 런타임 영향 없음
리스크: 없음(개발자 전용 미리보기)
```

## Pull Request 규칙

읽는 사람이 한눈에 변경점을 이해할 수 있도록 다음 규칙을 적용합니다.

- PR 생성 시 `.github/pull_request_template.md` 템플릿을 반드시 사용합니다.

### 1) PR 제목: Gitmoji 필수
- 형식: `<gitmoji> <type>: [<scope>] <요약>` (영문 소문자 type, scope 선택)
- 예시:
  - ✨ feat: [Auth] Face ID 로그인 지원
  - 🐛 fix: [Feed] 스크롤 튕김 현상 수정
  - ♻️ refactor: [Store] CancellationBag 사용으로 취소 처리 개선
  - 📝 docs: AGENTS.md에 PR 규칙 추가
  - ✅ test: [Service] PostLoginRequest happy/edge 테스트 추가
  - 🎨 style: 코드 포맷 정리(기능 변경 없음)
  - 🔧 chore: Xcode 설정 업데이트
  - 📦 build: Swift Package 의존성 업데이트
  - 👷 ci: CI 워크플로 병렬화
  - 🔒 security: 토큰 저장소 암호화 강화
  - 🔥 remove: 사용하지 않는 뷰/에셋 삭제
- tip: 긴급 수정은 `🚑 hotfix:` 를 사용합니다.

### 2) PR 본문: 5분 요약 템플릿
아래 템플릿을 사용해 핵심을 먼저 보여주세요. UI 변경이 있다면 **Before/After**를 반드시 첨부합니다.

```md
### TL;DR
- (한 줄 요약)

### 변경 요약
- (핵심 변경 3~6줄—모듈/기능 단위로)

### 배경/문제
- (왜 필요한가)

### 변경 상세
- (주요 타입/엔드포인트/스토어 상태 변화)

### UI 변경 (스크린샷/영상 필수)
- Before:
- After:
```

### 3) 변경 범위 위생(Hygiene)
- PR 목적은 한 가지로 유지합니다(기능/버그/리팩터/문서 등).
- 대규모 리포맷/리네이밍은 기능 변경 PR과 분리합니다.
- 자동 생성 파일/불필요한 스냅샷은 PR에서 제외합니다.
- PR 크기 가이드: **~300줄/≤10파일** 권장. 초과 시 논리 단위로 분할하거나 "스택드 PR"로 올립니다.
- 커밋은 의미 단위로 쪼개고, WIP 커밋은 squash·fixup로 정리합니다.
- 리뷰 친화: 커밋 순서를 내러티브로 배치(사전 정리 → 구현 → 테스트 → 문서)하고, 각 커밋 메시지 본문에 WHY/TEST를 요약합니다.

### 4) 작업 흐름 체크리스트
- [ ] 커밋이 목적·범위·테스트 포함 등 리뷰에 충분한 정보 제공
- [ ] 리팩터·포맷팅은 기능 변경과 분리됨
- [ ] PR 본문 템플릿(TL;DR/변경 요약/배경/변경 상세/UI 변경) 충실히 작성
- [ ] 큰 PR은 분할 또는 스택드 PR로 구성, Reviewer 수용 가능 크기 확인
- [ ] 스크린샷/영상/Canvas 캡처(필요 시) 포함

### 5) 병합 요청 시 자동 실행 프로토콜
- 트리거: 사용자가 "병합 진행", "PR 병합" 등 병합을 명시적으로 요청한 경우에만 수행합니다.
- 기본 동작: 아래 순서를 자동으로 실행합니다.
  1) PR 병합: 기존 PR이 있으면 병합, 없으면 생성 후 병합합니다.
     - 우선순위: merge(머지 커밋 유지) 단일 정책. rebase/squash 병합은 사용하지 않습니다.
     - Merge queue/필수 체크로 즉시 병합 불가하면 사유를 보고하고 대기/자동 병합을 설정하지 않습니다.
  2) 작업 브랜치 삭제: 병합된 head 브랜치를 원격/로컬 모두 삭제합니다.
     - 예외: 보호/영속 브랜치(main/master/development/dev/release), 릴리즈/핫픽스 등 장기 유지 브랜치, 포크 PR(head.repo ≠ base.repo), 스택드 PR(상위 PR 의존) 표식이 있는 경우.
  3) 원래 브랜치로 복귀: 병합 요청 직전의 로컬 브랜치로 체크아웃합니다.
  4) 최신 동기화: 원래 브랜치에서 `git pull --ff-only`로 원격 최신 상태를 반영합니다.
- 사전 점검(Preflight):
  - 워킹 트리 변경이 있으면 병합/체크아웃을 중단하고 사용자 승인 없이 스태시/폐기를 하지 않습니다.
- PR 병합 대상을 합의된 기본 브랜치로 제한합니다(상단 "브랜치 병합 허용(원천 제한)" 표를 준수하고, 예외가 필요하면 PR 본문에 명시).
  - 포크 PR은 브랜치 삭제를 시도하지 않습니다(권한 제약).
- 명령 예시(원문):
  - `gh pr create --base development --head <branch>`
  - `gh pr merge <url-or-number> --merge --delete-branch`
  - `git push origin --delete <branch> && git branch -d <branch>`
  - `git switch <prev-branch> && git pull --ff-only --no-rebase`
- 주의: GitHub Actions/자동 병합 설정은 사용하지 않습니다. 해당 작업은 에이전트가 명시 요청 시 수동으로 수행합니다.

#### 병합 커밋 정책(머지 커밋 유지) 세부 가이드
- 저장소 설정 권장: Allow merge commits=ON, Allow squash merge=OFF, Allow rebase merge=OFF, Require linear history=OFF.
- 병합 커밋 메시지: 기본값(“Merge pull request #…”)을 사용하되, PR 제목의 Gitmoji/type/scope가 본문 1행으로 포함되므로 제목 규칙을 엄격히 준수합니다.
- 대규모 기능 브랜치: 브랜치 내부 커밋은 자유롭게 rebase/fixup로 정리해도 되지만, base로의 병합은 반드시 `--merge`를 사용합니다.
- 롤백: PR 단위 전체 롤백은 `git revert -m 1 <merge-commit>` 사용. 부분 롤백은 개별 커밋 대상으로 `git revert <commit>`를 사용하며, 관련 회귀 테스트(추가/수정)를 동반합니다.
