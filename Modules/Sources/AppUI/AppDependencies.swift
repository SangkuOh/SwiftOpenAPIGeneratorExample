import Foundation
import AppData
import AppService

/// 앱에서 사용하는 의존성을 한 곳에서 조립해 Live/Preview/Test가 동일한 경로를 공유하도록 만듭니다.
public struct AppDependencies {
    public let greetingService: GreetingService

    public init(greetingService: GreetingService) {
        self.greetingService = greetingService
    }

    /// 실제 네트워크를 사용하는 라이브 의존성을 구성합니다.
    public static func live(
        configuration: GreetingAPIConfiguration = GreetingRepositoryDefaults.configuration(),
        transport: GreetingAPITransport? = nil
    ) -> Self {
        do {
            let repository = try GreetingRepositoryFactory.live(configuration: configuration, transport: transport)
            let service = DefaultGreetingService(repository: repository)
            return .init(greetingService: service)
        } catch {
            preconditionFailure("Failed to configure API environment: \(error.localizedDescription)")
        }
    }

    /// Mock transport를 사용해 네트워크 없이도 동일한 흐름을 실행하는 프리뷰/테스트용 구성을 만듭니다.
    public static func preview(
        configuration: GreetingAPIConfiguration = GreetingRepositoryDefaults.configuration(),
        stubs: [GreetingAPIMockStub] = GreetingRepositoryDefaults.stubs()
    ) -> Self {
        do {
            let repository = try GreetingRepositoryFactory.preview(configuration: configuration, stubs: stubs)
            let service = DefaultGreetingService(repository: repository)
            return .init(greetingService: service)
        } catch {
            preconditionFailure("Failed to configure mock API environment: \(error.localizedDescription)")
        }
    }
}
