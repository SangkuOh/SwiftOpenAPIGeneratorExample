import Foundation
import HTTPTypes
import OpenAPIRuntime

/// 네트워크 호출을 하지 않고 미리 정의된 응답을 돌려주는 가벼운 Transport 구현입니다.
public final actor MockServerTransport: ClientTransport {

    /// 요청을 식별하고 응답을 만들어 내는 클로저 세트를 묶은 단일 스텁입니다.
    public struct Stub: Sendable {
        /// 시나리오에서 스텁을 덮어쓸 때 사용하는 안정적인 식별자입니다.
        /// 값이 같으면 기본 스텁을 해당 스텁으로 교체합니다.
        public let key: String?
        public let matcher: @Sendable (HTTPRequest) -> Bool
        public let handler: @Sendable (HTTPRequest, HTTPBody?) async throws -> (HTTPResponse, HTTPBody?)

        public init(
            key: String? = nil,
            matcher: @escaping @Sendable (HTTPRequest) -> Bool,
            handler: @escaping @Sendable (HTTPRequest, HTTPBody?) async throws -> (HTTPResponse, HTTPBody?)
        ) {
            self.key = key
            self.matcher = matcher
            self.handler = handler
        }
    }

    public enum Error: Swift.Error, LocalizedError {
        case missingStub(method: HTTPRequest.Method, path: String?)

        public var errorDescription: String? {
            switch self {
                case .missingStub(let method, let path):
                    return "No mock stub for \(method.rawValue) \(path ?? "<nil>")"
            }
        }
    }

    public private(set) var recordedRequests: [HTTPRequest] = []
    private var stubs: [Stub]

    public init(stubs: [Stub] = []) {
        self.stubs = stubs
    }

    /// 지정한 스텁을 추가 등록합니다.
    public func register(_ stub: Stub) {
        stubs.append(stub)
    }

    /// 등록된 스텁과 기록된 요청을 모두 초기화합니다.
    public func reset() {
        stubs.removeAll()
        recordedRequests.removeAll()
    }

    /// 첫 번째로 매칭되는 스텁을 찾아 응답을 돌려주고, 없으면 오류를 던집니다.
    public func send(
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

public extension MockServerTransport.Stub {
    /// JSON 응답을 반환하는 공용 스텁 헬퍼입니다.
    /// - Parameters:
    ///   - key: 시나리오에서 덮어쓸 때 사용할 식별자입니다.
    ///   - method: 매칭할 HTTP 메서드입니다.
    ///   - pathContains: 요청 경로에 포함되어야 하는 문자열입니다.
    ///   - status: 반환할 HTTP 상태 코드입니다.
    ///   - body: 요청을 받아 JSON Data를 생성하는 클로저입니다.
    static func jsonResponse(
        key: String? = nil,
        method: HTTPRequest.Method,
        pathContains: String,
        status: HTTPResponse.Status = .ok,
        body: @escaping @Sendable (HTTPRequest, HTTPBody?) async throws -> Data
    ) -> Self {
        .init(
            key: key,
            matcher: { request in
                request.method == method && (request.path ?? "").contains(pathContains)
            },
            handler: { request, requestBody in
                let data = try await body(request, requestBody)
                var response = HTTPResponse(status: status)
                response.headerFields[.contentType] = "application/json; charset=utf-8"
                response.headerFields[.contentLength] = "\(data.count)"
                return (response, HTTPBody(data))
            }
        )
    }
}

public extension HTTPRequest {
    /// 쿼리 파라미터 값을 읽어옵니다.
    func queryItem(named name: String) -> String? {
        guard let path else { return nil }
        if let url = URL(string: "https://example.com\(path)"),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            return components.queryItems?.first(where: { $0.name == name })?.value
        }
        return nil
    }
}
