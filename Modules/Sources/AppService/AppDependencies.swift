import Foundation

/// 앱에서 사용하는 의존성을 한 곳에서 묶어 Environment로 전달합니다.
public struct AppDependencies {
    public let greetingService: GreetingService

    public init(greetingService: GreetingService) {
        self.greetingService = greetingService
    }
}
