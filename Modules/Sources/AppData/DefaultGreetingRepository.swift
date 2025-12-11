import Foundation
import AppDomain
import APIInfra

public typealias GreetingAPIConfiguration = APIConfiguration
public typealias GreetingAPITransport = APITransport
public typealias GreetingAPIMockStub = MockServerTransport.Stub

/// API 설정과 기본 스텁 값을 한 곳에서 관리합니다.
public enum GreetingRepositoryDefaults {
    public static func configuration() -> GreetingAPIConfiguration {
        .default()
    }

    public static func stubs() -> [GreetingAPIMockStub] {
        [.greetingResponse()]
    }
}

/// 생성된 OpenAPI 클라이언트의 Greeting 엔드포인트를 호출해 도메인 엔티티로 변환합니다.
public final class DefaultGreetingRepository: GreetingRepository {
    private let greetingAPI: any (GreetingAPI & Sendable)

    public init(greetingAPI: any (GreetingAPI & Sendable)) {
        self.greetingAPI = greetingAPI
    }

    /// 네트워크 DTO를 받아 도메인 엔티티로 매핑합니다.
    public func greeting(name: String?) async throws -> GreetingEntity {
        let dto = try await greetingAPI.fetchGreeting(name: name)
        return GreetingEntity(message: dto.message)
    }
}

/// 저장소 구현을 구성하는 헬퍼로, AppUI가 API 세부 구현을 몰라도 되도록 감춥니다.
public enum GreetingRepositoryFactory {
    public static func live(
        configuration: GreetingAPIConfiguration = .default(),
        transport: GreetingAPITransport? = nil
    ) throws -> GreetingRepository {
        let environment = try APIEnvironments.live(configuration: configuration, transport: transport)
        return DefaultGreetingRepository(greetingAPI: environment.greeting)
    }

    public static func preview(
        configuration: GreetingAPIConfiguration = .default(),
        stubs: [GreetingAPIMockStub] = [.greetingResponse()]
    ) throws -> GreetingRepository {
        let environment = try APIEnvironments.preview(configuration: configuration, stubs: stubs)
        return DefaultGreetingRepository(greetingAPI: environment.greeting)
    }
}
