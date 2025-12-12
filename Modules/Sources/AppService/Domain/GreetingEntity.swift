import Foundation

/// API에서 내려오는 인사말을 도메인에서 사용하는 형태로 감싼 값 객체입니다.
public struct GreetingEntity: Sendable, Hashable {
    public let message: String

    public init(message: String) {
        self.message = message
    }
}
