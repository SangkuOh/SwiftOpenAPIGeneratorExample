import Foundation
import Testing
@testable import SwiftOpenAPIGeneratorExample

@MainActor
struct ContentViewLogicTests {

    @Test
    func sanitizedName_trimsAndReturnsNilOnEmpty() {
        let view = ContentView()

        #expect(view.sanitizedName("  Alice ") == "Alice")
        #expect(view.sanitizedName("   \n  ") == nil)
    }

    @Test
    func userMessage_prefersAPIErrorDescription() {
        let view = ContentView()
        let message = view.userMessage(from: RemoteAPIError.unexpectedStatus(500))

        #expect(message.contains("Unexpected status code 500"))
    }

    @Test
    func userMessage_fallsBackToLocalizedError() {
        struct DummyError: LocalizedError {
            var errorDescription: String? { "Localized description" }
        }

        let view = ContentView()
        let message = view.userMessage(from: DummyError())

        #expect(message == "Localized description")
    }

    @Test
    func userMessage_usesDefaultMessageAsLastResort() {
        let view = ContentView()
        let message = view.userMessage(from: NSError(domain: "Test", code: 1))

        #expect(message == "Failed to load greeting. Check your connection and try again.")
    }
}
