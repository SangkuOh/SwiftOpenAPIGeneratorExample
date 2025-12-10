import Foundation

/// 앱에서 사용하는 의존성을 한 곳에서 조립해 Live/Preview/Test가 동일한 경로를 공유하도록 만듭니다.
struct AppDependencies {
    let greetingService: GreetingService

    /// 실제 네트워크를 사용하는 라이브 의존성을 구성합니다.
    static func live(configuration: APIConfiguration = .default()) -> Self {
        let apiEnvironment: APIEnvironment<Client>
        do {
            apiEnvironment = try APIEnvironment<Client>.live(configuration: configuration)
        } catch {
            preconditionFailure("Failed to configure APIEnvironment: \(error.localizedDescription)")
        }
        let repository = DefaultGreetingRepository(greetingAPI: apiEnvironment.greeting)
        let service = DefaultGreetingService(repository: repository)
        return .init(greetingService: service)
    }

    /// Mock transport를 사용해 네트워크 없이도 동일한 흐름을 실행하는 프리뷰/테스트용 구성을 만듭니다.
    static func preview(
        configuration: APIConfiguration = .default(),
        stubs: [MockServerTransport.Stub] = [.greetingResponse()]
    ) -> Self {
        let apiEnvironment: APIEnvironment<Client>
        do {
            apiEnvironment = try APIEnvironment<Client>.preview(configuration: configuration, stubs: stubs)
        } catch {
            preconditionFailure("Failed to configure mock APIEnvironment: \(error.localizedDescription)")
        }
        let repository = DefaultGreetingRepository(greetingAPI: apiEnvironment.greeting)
        let service = DefaultGreetingService(repository: repository)
        return .init(greetingService: service)
    }
}
