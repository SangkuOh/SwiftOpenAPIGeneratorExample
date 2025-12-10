import Foundation
import HTTPTypes
import OpenAPIRuntime

/// Lightweight transport that returns stubbed responses instead of performing network calls.
final actor MockServerTransport: ClientTransport {

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

    func register(_ stub: Stub) {
        stubs.append(stub)
    }

    func reset() {
        stubs.removeAll()
        recordedRequests.removeAll()
    }

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
    /// Returns a stub for the `GET /greet` endpoint used in this sample.
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
