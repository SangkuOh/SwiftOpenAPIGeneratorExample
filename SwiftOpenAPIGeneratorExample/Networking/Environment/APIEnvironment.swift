import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// 공통 클라이언트 조립과 엔드포인트 모듈을 묶어 전달하는 환경입니다.
struct APIEnvironment<C: APIProtocol> {
    let client: C
    let greeting: GreetingEndpoint<C>

    init(client: C) {
        self.client = client
        self.greeting = GreetingEndpoint(client: client)
    }
}

extension APIEnvironment where C == Client {
    /// 실제 네트워크를 사용하는 라이브 환경을 생성합니다.
    static func live(
        configuration: APIConfiguration = .default(),
        transport: (any ClientTransport)? = nil
    ) throws -> Self {
        let baseURL = try configuration.validatedBaseURL()
        let resolvedTransport = transport ?? URLSessionTransport()
        let client = Client(serverURL: baseURL, transport: resolvedTransport)
        return .init(client: client)
    }

    /// Mock transport를 사용해 네트워크 없이도 동일한 흐름을 실행하는 프리뷰/테스트 환경을 생성합니다.
    static func preview(
        configuration: APIConfiguration = .default(),
        stubs: [MockServerTransport.Stub] = [.greetingResponse()]
    ) throws -> Self {
        let transport = MockServerTransport(stubs: stubs)
        return try mock(configuration: configuration, mockTransport: transport)
    }

    /// 지정한 mock transport를 사용해 환경을 생성합니다.
    static func mock(
        configuration: APIConfiguration = .default(),
        mockTransport: MockServerTransport
    ) throws -> Self {
        let baseURL = try configuration.validatedBaseURL()
        let client = Client(serverURL: baseURL, transport: mockTransport)
        return .init(client: client)
    }
}
