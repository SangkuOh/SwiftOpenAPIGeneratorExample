import Foundation

protocol GreetingService: Sendable {
    func greeting(name: String?) async throws -> GreetingEntity
}

final class DefaultGreetingService: GreetingService {
    private let repository: GreetingRepository

    init(repository: GreetingRepository) {
        self.repository = repository
    }

    func greeting(name: String?) async throws -> GreetingEntity {
        try await repository.greeting(name: name)
    }
}
