import Foundation
/// Service가 비즈니스 규칙과 도메인 변환을 담당하며, Repository는 원격 호출을 캡슐화합니다.

public protocol GreetingService: Sendable {
    /// 표시할 이름을 받아 도메인 엔티티로 변환한 인사말을 반환합니다.
    func greeting(name: String?) async throws -> GreetingEntity
}

/// 구체 서비스 구현으로, 저장소를 주입받아 네트워크/데이터 접근을 캡슐화합니다.
public final class DefaultGreetingService: GreetingService {
    private let repository: GreetingRepository

    public init(repository: GreetingRepository) {
        self.repository = repository
    }

    /// 저장소에서 받아온 도메인 엔티티에 추가 규칙을 적용합니다.
    public func greeting(name: String?) async throws -> GreetingEntity {
        let entity = try await repository.greeting(name: name)
        // 추가 비즈니스 규칙이 생기면 여기서 조정합니다.
        return entity
    }
}
