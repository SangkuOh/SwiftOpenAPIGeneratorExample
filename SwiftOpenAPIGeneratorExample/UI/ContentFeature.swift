import Foundation
import SwiftUI

@MainActor
struct ContentFeature {
    @Environment(\.appDependencies) var dependencies

    @State var greeting: String = "Enter a name to fetch a greeting."
    @State var name: String = ""
    @State var isLoading: Bool = false
    @State var errorMessage: String?

    func loadGreeting() async {
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

    func sanitizedName(_ rawName: String) -> String? {
        let trimmed = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    func userMessage(from error: Error) -> String {
        if let apiError = error as? RemoteAPIError, let description = apiError.errorDescription {
            return description
        }
        if let localizedError = error as? LocalizedError, let description = localizedError.errorDescription {
            return description
        }
        return "Failed to load greeting. Check your connection and try again."
    }
}
