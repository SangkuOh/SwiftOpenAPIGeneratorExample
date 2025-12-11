import SwiftUI

extension ContentFeature: View {
    /// 입력 필드, 로딩 상태, 결과/에러 라벨을 단순한 VStack으로 배치한 예제 UI입니다.
    /// 실제 로딩 동작은 `loadGreeting()`의 Task 호출에 위임합니다.
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            TextField("Name (optional)", text: $name)
                .textFieldStyle(.roundedBorder)
#if os(iOS)
                .textInputAutocapitalization(.words)
#endif
            Button("Fetch greeting") {
                Task { await loadGreeting() }
            }
            .disabled(isLoading)
            if isLoading {
                ProgressView("Fetching greeting...")
            } else {
                Text(greeting)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("greeting-label")
            }
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("greeting-error-label")
            }
        }
        .padding()
    }
}

#Preview {
    ContentFeature()
        .environment(\.appDependencies, .preview())
}
