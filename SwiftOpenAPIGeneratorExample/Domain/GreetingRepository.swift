import Foundation

protocol GreetingRepository: Sendable {
    func greeting(name: String?) async throws -> GreetingEntity
}
