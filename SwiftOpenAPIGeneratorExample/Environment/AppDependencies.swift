import Foundation

/// Single place to assemble the app's dependencies.
/// Keeps the production wiring and preview wiring consistent.
struct AppDependencies {
    let greetingService: GreetingService

    /// Production/live dependencies.
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

    /// Preview/demo dependencies backed by the mock transport.
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
