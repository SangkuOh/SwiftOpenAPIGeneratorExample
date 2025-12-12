import Foundation
import HTTPTypes
import OpenAPIRuntime
import APITypes

/// 테스트/프리뷰에서 재사용할 목 시나리오 모음입니다.
public enum APIMockScenarios {
    /// 모든 엔드포인트에 대한 기본 스텁 세트를 제공합니다.
    /// 새 API를 추가하면 여기에서 엔드포인트별 기본 스텁을 한 번에 모아 관리합니다.
    public static func defaults() -> [MockServerTransport.Stub] {
        Greeting.defaults()
    }

    /// 기본 스텁 위에 특정 엔드포인트 스텁만 교체/추가한 시나리오를 만듭니다.
    public static func defaults(
        overriding overrides: [MockServerTransport.Stub]
    ) -> [MockServerTransport.Stub] {
        defaults().overriding(overrides)
    }

    /// 지정한 스텁으로 초기화된 mock transport를 반환합니다.
    public static func transport(stubs: [MockServerTransport.Stub]) -> MockServerTransport {
        MockServerTransport(stubs: stubs)
    }
}

public extension APIMockScenarios {
    /// `GET /greet` 계열 모킹을 모은 네임스페이스입니다.
    enum Greeting {
        public static let stubKey = "greeting.fetchGreeting"

        /// 기본 인사말 응답을 반환하는 스텁 세트를 제공합니다.
        public static func defaults() -> [MockServerTransport.Stub] {
            [response()]
        }

        /// 인사말 응답 스텁을 만듭니다.
        public static func response(
            status: HTTPResponse.Status = .ok,
            message: @escaping @Sendable (String?) -> String = defaultMessage
        ) -> MockServerTransport.Stub {
            MockServerTransport.Stub.jsonResponse(
                key: stubKey,
                method: .get,
                pathContains: "/greet",
                status: status
            ) { request, _ in
                let name = request.queryItem(named: "name")
                return try await MainActor.run {
                    let greeting = Components.Schemas.Greeting(message: message(name))
                    return try JSONEncoder().encode(greeting)
                }
            }
        }

        /// 기본 메시지 생성기입니다.
        public static let defaultMessage: @Sendable (String?) -> String = { name in
            let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let trimmed, !trimmed.isEmpty {
                return "Hello \(trimmed)"
            } else {
                return "Hello from mock"
            }
        }
    }
}

public extension Array where Element == MockServerTransport.Stub {
    /// `key`가 같은 스텁은 교체하고, 없으면 추가합니다.
    func overriding(_ overrides: [Element]) -> [Element] {
        var result = self
        for override in overrides {
            if let key = override.key,
               let index = result.firstIndex(where: { $0.key == key }) {
                result[index] = override
            } else {
                result.append(override)
            }
        }
        return result
    }
}
