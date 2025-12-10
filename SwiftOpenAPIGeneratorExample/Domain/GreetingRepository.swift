import Foundation

/// 데이터 소스(네트워크/스토리지 등)에서 인사말을 가져오는 추상화입니다.
protocol GreetingRepository: Sendable {
    /// 이름을 옵션으로 받아 인사말 엔티티를 반환합니다.
    func greeting(name: String?) async throws -> GreetingEntity
}
