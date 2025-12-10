import Foundation
import OpenAPIRuntime

/// Greeting 관련 엔드포인트를 모아두는 모듈입니다.
protocol GreetingAPI {
    func fetchGreeting(name: String?) async throws -> Components.Schemas.Greeting
}

/// OpenAPI로 생성된 `Client.getGreeting` 호출을 담당합니다.
struct GreetingEndpoint<C: APIProtocol>: GreetingAPI {
    private let client: C

    init(client: C) {
        self.client = client
    }

    /// 서버 상태 코드나 바디 누락을 안전하게 검사하고, 오류를 `RemoteAPIError`로 통일합니다.
    func fetchGreeting(name: String? = nil) async throws -> Components.Schemas.Greeting {
        do {
            let response = try await client.getGreeting(query: .init(name: name))
            switch response {
            case .ok(let okResponse):
                switch okResponse.body {
                case .json(let greeting):
                    return greeting
                @unknown default:
                    throw RemoteAPIError.missingBody
                }
            case .undocumented(let status, _):
                throw RemoteAPIError.unexpectedStatus(Int(status))
            }
        } catch let apiError as RemoteAPIError {
            throw apiError
        } catch {
            throw RemoteAPIError.transport(error)
        }
    }
}
