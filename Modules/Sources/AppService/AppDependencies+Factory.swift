import Foundation

public extension AppDependencies {
    /// 주입된 저장소로 실제 의존성을 조립합니다.
    static func live(repository: GreetingRepository) -> Self {
        let service = DefaultGreetingService(repository: repository)
        return .init(greetingService: service)
    }

    /// 네트워크 없이 빠르게 확인할 수 있는 프리뷰 의존성을 조립합니다.
    static func preview(message: String = "Hello preview!") -> Self {
        let repository = MockGreetingRepository(message: message)
        let service = DefaultGreetingService(repository: repository)
        return .init(greetingService: service)
    }
}
