import Foundation
import SwiftUI
import AppService

/// 입력/로딩/결과/에러 상태를 한 곳에서 관리하는 화면 기능 모음입니다.
/// UI는 `ContentFeature+View.swift`에 분리되어 있으며, 여기서는 비즈니스 로직과 상태만 다룹니다.
@MainActor
public struct ContentFeature {
    @Environment(\.appDependencies) var dependencies

    @State var greeting: String = "Enter a name to fetch a greeting."
    @State var name: String = ""
    @State var isLoading: Bool = false
    @State var errorMessage: String?

    public init() {}

    /// 입력값을 정리한 뒤 `GreetingService`를 호출해 인사말을 로드합니다.
    /// 동시에 중복 호출을 막고, 오류를 사용자 메시지로 변환합니다.
    public func loadGreeting() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let entity = try await dependencies.greetingService.greeting(name: sanitizedName(name))
            greeting = entity.message
        } catch {
            errorMessage = userMessage(from: error)
        }
    }

    /// 공백을 제거하고 비어 있으면 `nil`로 치환해 API에 안전하게 전달합니다.
    public func sanitizedName(_ rawName: String) -> String? {
        let trimmed = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    /// API 오류/LocalizedError를 우선으로 노출하고, 마지막 수단으로 기본 메시지를 돌려줍니다.
    public func userMessage(from error: Error) -> String {
        if let localizedError = error as? LocalizedError, let description = localizedError.errorDescription {
            return description
        }
        return "Failed to load greeting. Check your connection and try again."
    }
}
