import Foundation

/// 앱에서 사용하는 의존성을 한 곳에서 조립해 Live/Preview/Test가 동일한 경로를 공유하도록 만듭니다.
struct AppDependencies {
    let greetingService: GreetingService

    /// 실제 네트워크를 사용하는 라이브 의존성을 구성합니다.
    static func live(configuration: APIConfiguration = .default()) -> Self {
        let api: RemoteAPI<Client>
        do {
            api = try RemoteAPI<Client>(configuration: configuration)
        } catch {
            preconditionFailure("Failed to configure RemoteAPI: \(error.localizedDescription)")
        }
        let repository = DefaultGreetingRepository(api: api)
        let service = DefaultGreetingService(repository: repository)
        return .init(greetingService: service)
    }

    /// Mock transport를 사용해 네트워크 없이도 동일한 흐름을 실행하는 프리뷰/테스트용 구성을 만듭니다.
    static func preview(
        configuration: APIConfiguration = .default(),
        stubs: [MockServerTransport.Stub] = [.greetingResponse()]
    ) -> Self {
        let transport = MockServerTransport(stubs: stubs)
        let api: RemoteAPI<Client>
        do {
            api = try RemoteAPI<Client>(mockTransport: transport, configuration: configuration)
        } catch {
            preconditionFailure("Failed to configure mock RemoteAPI: \(error.localizedDescription)")
        }
        let repository = DefaultGreetingRepository(api: api)
        let service = DefaultGreetingService(repository: repository)
        return .init(greetingService: service)
    }
}
