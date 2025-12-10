import Foundation

/// 화면에서 사용하는 유스케이스 계층으로, 입력값을 그대로 위임해 인사말을 조회합니다.
protocol GreetingService: Sendable {
    /// 표시할 이름을 받아 인사말을 반환합니다.
    func greeting(name: String?) async throws -> GreetingEntity
}

/// 구체 서비스 구현으로, 저장소를 주입받아 네트워크/데이터 접근을 캡슐화합니다.
final class DefaultGreetingService: GreetingService {
    private let repository: GreetingRepository

    init(repository: GreetingRepository) {
        self.repository = repository
    }

    /// 현재는 추가 비즈니스 규칙 없이 저장소 호출을 위임합니다.
    func greeting(name: String?) async throws -> GreetingEntity {
        try await repository.greeting(name: name)
    }
}
