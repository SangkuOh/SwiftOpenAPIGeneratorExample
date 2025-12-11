import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import APIClient
import APITypes

/// OpenAPI 클라이언트가 기대하는 전송 계층 타입 별칭입니다.
public typealias APITransport = any ClientTransport

/// 생성된 기본 클라이언트 타입을 노출합니다.
public typealias DefaultAPIClient = Client

/// 앱에서 사용하는 기본 API 환경 타입 별칭입니다.
public typealias DefaultAPIEnvironment = APIEnvironment<Client>

/// 공통 클라이언트 조립과 API 래퍼를 묶어 전달하는 환경입니다.
public struct APIEnvironment<C: APIProtocol> {
    public let client: C
    public let greeting: GreetingAPIClient<C>

    public init(client: C) {
        self.client = client
        self.greeting = GreetingAPIClient(client: client)
    }
}

extension APIEnvironment where C == Client {
    /// 실제 네트워크를 사용하는 라이브 환경을 생성합니다.
    public static func live(
        configuration: APIConfiguration = .default(),
        transport: APITransport? = nil
    ) throws -> Self {
        let baseURL = try configuration.validatedBaseURL()
        let resolvedTransport = transport ?? URLSessionTransport()
        let client = Client(serverURL: baseURL, transport: resolvedTransport)
        return .init(client: client)
    }

    /// Mock transport를 사용해 네트워크 없이도 동일한 흐름을 실행하는 프리뷰/테스트 환경을 생성합니다.
    public static func preview(
        configuration: APIConfiguration = .default(),
        stubs: [MockServerTransport.Stub] = [.greetingResponse()]
    ) throws -> Self {
        let transport = MockServerTransport(stubs: stubs)
        return try mock(configuration: configuration, mockTransport: transport)
    }

    /// 지정한 mock transport를 사용해 환경을 생성합니다.
    public static func mock(
        configuration: APIConfiguration = .default(),
        mockTransport: MockServerTransport
    ) throws -> Self {
        let baseURL = try configuration.validatedBaseURL()
        let client = Client(serverURL: baseURL, transport: mockTransport)
        return .init(client: client)
    }
}

/// 기본 클라이언트를 사용하는 환경 생성 헬퍼입니다.
public enum APIEnvironments {
    public static func live(
        configuration: APIConfiguration = .default(),
        transport: APITransport? = nil
    ) throws -> DefaultAPIEnvironment {
        try APIEnvironment<Client>.live(configuration: configuration, transport: transport)
    }

    public static func preview(
        configuration: APIConfiguration = .default(),
        stubs: [MockServerTransport.Stub] = [.greetingResponse()]
    ) throws -> DefaultAPIEnvironment {
        try APIEnvironment<Client>.preview(configuration: configuration, stubs: stubs)
    }

    public static func mock(
        configuration: APIConfiguration = .default(),
        mockTransport: MockServerTransport
    ) throws -> DefaultAPIEnvironment {
        try APIEnvironment<Client>.mock(configuration: configuration, mockTransport: mockTransport)
    }
}
