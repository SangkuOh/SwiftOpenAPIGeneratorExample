import Foundation

public extension AppDependencies {
    /// 주입된 저장소로 실제 의존성을 조립합니다.
    static func live(repository: GreetingRepository) -> Self {
        let service = DefaultGreetingService(repository: repository)
        return .init(greetingService: service)
    }
}
