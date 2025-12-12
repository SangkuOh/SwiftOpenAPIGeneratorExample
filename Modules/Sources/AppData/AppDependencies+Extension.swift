import Foundation
import AppService
import APIInfra

public extension AppDependencies {
    /// 실제 API를 사용하는 라이브 의존성을 조립합니다.
    static func live(
        configuration: GreetingAPIConfiguration = .default(),
        transport: GreetingAPITransport? = nil
    ) -> Self {
        do {
            let repository = try GreetingRepositoryFactory.live(configuration: configuration, transport: transport)
            return .live(repository: repository)
        } catch {
            preconditionFailure("Live 의존성 생성에 실패했습니다: \(error.localizedDescription)")
        }
    }

    /// `GreetingRepositoryFactory.preview`를 통해 OpenAPI 기반 목 저장소를 조립합니다.
    /// - Parameters:
    ///   - configuration: 프리뷰에서 사용할 API 설정입니다.
    ///   - stubs: `APIMockScenarios`에서 만든 스텁 세트입니다. 기본값은 공용 기본 스텁입니다.
    static func preview(
        configuration: GreetingAPIConfiguration = .default(),
        stubs: [GreetingAPIMockStub] = GreetingRepositoryDefaults.stubs()
    ) -> Self {
        do {
            let repository = try GreetingRepositoryFactory.preview(configuration: configuration, stubs: stubs)
            return .live(repository: repository)
        } catch {
            preconditionFailure("Preview 의존성 생성에 실패했습니다: \(error.localizedDescription)")
        }
    }

    /// 간단히 메시지만 바꿔 보고 싶을 때 사용하는 편의 프리뷰입니다.
    /// 내부적으로 기본 `Greeting` 스텁을 교체해 `preview(stubs:)`로 전달합니다.
    static func preview(message: String) -> Self {
        let greetingStub = APIMockScenarios.Greeting.response { name in
            if let name, !name.isEmpty {
                return "\(message) \(name)"
            } else {
                return message
            }
        }
        let stubs = APIMockScenarios.defaults(overriding: [greetingStub])
        return preview(stubs: stubs)
    }
}
