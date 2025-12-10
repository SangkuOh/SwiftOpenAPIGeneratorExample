import Foundation

final class DefaultGreetingRepository: GreetingRepository {
    private let api: RemoteAPI<Client>

    init(api: RemoteAPI<Client>) {
        self.api = api
    }

    func greeting(name: String?) async throws -> GreetingEntity {
        let dto = try await api.fetchGreeting(name: name)
        return GreetingEntity(message: dto.message)
    }
}
