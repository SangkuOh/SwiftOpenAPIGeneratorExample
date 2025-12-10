import Foundation
import HTTPTypes
import OpenAPIRuntime

/// 네트워크 호출을 하지 않고 미리 정의된 응답을 돌려주는 가벼운 Transport 구현입니다.
final actor MockServerTransport: ClientTransport {

    /// 요청을 식별하고 응답을 만들어 내는 클로저 세트를 묶은 단일 스텁입니다.
    struct Stub {
        let matcher: (HTTPRequest) -> Bool
        let handler: @Sendable (HTTPRequest, HTTPBody?) async throws -> (HTTPResponse, HTTPBody?)

        init(
            matcher: @escaping (HTTPRequest) -> Bool,
            handler: @escaping @Sendable (HTTPRequest, HTTPBody?) async throws -> (HTTPResponse, HTTPBody?)
        ) {
            self.matcher = matcher
            self.handler = handler
        }
    }

    enum Error: Swift.Error, LocalizedError {
        case missingStub(method: HTTPRequest.Method, path: String?)

        var errorDescription: String? {
            switch self {
                case .missingStub(let method, let path):
                    return "No mock stub for \(method.rawValue) \(path ?? "<nil>")"
            }
        }
    }

    private(set) var recordedRequests: [HTTPRequest] = []
    private var stubs: [Stub]

    init(stubs: [Stub] = []) {
        self.stubs = stubs
    }

    /// 지정한 스텁을 추가 등록합니다.
    func register(_ stub: Stub) {
        stubs.append(stub)
    }

    /// 등록된 스텁과 기록된 요청을 모두 초기화합니다.
    func reset() {
        stubs.removeAll()
        recordedRequests.removeAll()
    }

    /// 첫 번째로 매칭되는 스텁을 찾아 응답을 돌려주고, 없으면 오류를 던집니다.
    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        recordedRequests.append(request)
        guard let stub = stubs.first(where: { $0.matcher(request) }) else {
            throw Error.missingStub(method: request.method, path: request.path)
        }
        return try await stub.handler(request, body)
    }
}

extension MockServerTransport.Stub {
    /// 샘플에서 사용하는 `GET /greet` 엔드포인트에 대한 스텁을 만듭니다.
    static func greetingResponse(
        status: HTTPResponse.Status = .ok,
        message: @escaping (String?) -> String = { name in
            let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let trimmed, !trimmed.isEmpty {
                return "Hello \(trimmed)"
            } else {
                return "Hello from mock"
            }
        }
    ) -> Self {
        .init(
            matcher: { request in
                request.method == .get && (request.path ?? "").contains("/greet")
            },
            handler: { request, _ in
                let name = await request.queryItem(named: "name")
                let data: Data = try await MainActor.run {
                    let greeting = Components.Schemas.Greeting(
                        message: message(name)
                    )
                    return try JSONEncoder().encode(greeting)
                }
                var response = HTTPResponse(status: status)
                response.headerFields[.contentType] = "application/json; charset=utf-8"
                response.headerFields[.contentLength] = "\(data.count)"
                return (response, HTTPBody(data))
            }
        )
    }
}

private extension HTTPRequest {
    func queryItem(named name: String) -> String? {
        guard let path else { return nil }
        if let url = URL(string: "https://example.com\(path)"),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            return components.queryItems?.first(where: { $0.name == name })?.value
        }
        return nil
    }
}
