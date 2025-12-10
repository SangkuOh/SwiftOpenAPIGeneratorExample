import Foundation
import Testing
@testable import SwiftOpenAPIGeneratorExample

@MainActor
struct ContentFeatureLogicTests {

    @Test
    func sanitizedName_trimsAndReturnsNilOnEmpty() {
        let feature = ContentFeature()

        #expect(feature.sanitizedName("  Alice ") == "Alice")
        #expect(feature.sanitizedName("   \n  ") == nil)
    }

    @Test
    func userMessage_prefersAPIErrorDescription() {
        let feature = ContentFeature()
        let message = feature.userMessage(from: RemoteAPIError.unexpectedStatus(500))

        #expect(message.contains("Unexpected status code 500"))
    }

    @Test
    func userMessage_fallsBackToLocalizedError() {
        struct DummyError: LocalizedError {
            var errorDescription: String? { "Localized description" }
        }

        let feature = ContentFeature()
        let message = feature.userMessage(from: DummyError())

        #expect(message == "Localized description")
    }

    @Test
    func userMessage_usesDefaultMessageAsLastResort() {
        let feature = ContentFeature()
        let message = feature.userMessage(from: NSError(domain: "Test", code: 1))

        #expect(message == "Failed to load greeting. Check your connection and try again.")
    }
}
