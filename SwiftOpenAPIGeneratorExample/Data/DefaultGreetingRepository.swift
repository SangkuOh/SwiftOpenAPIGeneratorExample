import Foundation

/// 생성된 OpenAPI 클라이언트를 감싼 `RemoteAPI`를 호출해 도메인 엔티티로 변환합니다.
final class DefaultGreetingRepository: GreetingRepository {
    private let api: RemoteAPI<Client>

    init(api: RemoteAPI<Client>) {
        self.api = api
    }

    /// 네트워크 DTO를 받아 도메인 엔티티로 매핑합니다.
    func greeting(name: String?) async throws -> GreetingEntity {
        let dto = try await api.fetchGreeting(name: name)
        return GreetingEntity(message: dto.message)
    }
}
