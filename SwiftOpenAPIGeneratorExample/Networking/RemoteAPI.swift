import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// Info.plist와 OpenAPI 서버 정보를 조합해 클라이언트 설정을 만드는 구성 객체입니다.
struct APIConfiguration {
    let baseURL: URL
    let allowInsecureHosts: Set<String>

    init(baseURL: URL, allowInsecureHosts: Set<String> = ["localhost", "127.0.0.1"]) {
        self.baseURL = baseURL
        self.allowInsecureHosts = allowInsecureHosts
    }

    static func `default`(bundle: Bundle = .main) -> Self {
        fromInfoPlist(bundle: bundle)
    }

    /// .xcconfig가 채운 Info.plist 값을 바탕으로 구성을 만듭니다.
    static func fromInfoPlist(bundle: Bundle = .main) -> Self {
        let baseURL = resolveBaseURL(from: bundle.infoDictionary?["API_BASE_URL"] as? String)
        let insecureHosts = resolveAllowInsecureHosts(
            from: bundle.infoDictionary?["API_ALLOW_INSECURE_HOSTS"] as? String
        )
        return .init(baseURL: baseURL, allowInsecureHosts: insecureHosts)
    }

    /// HTTPS가 아닌 경우 허용 목록에 포함되어 있는지 검사해 안전하게 베이스 URL을 결정합니다.
    func validatedBaseURL() throws -> URL {
        if baseURL.scheme == "https" { return baseURL }
        if let host = baseURL.host, allowInsecureHosts.contains(host) { return baseURL }
        throw RemoteAPIError.insecureBaseURL(baseURL)
    }

    private static func resolveBaseURL(from infoValue: String?) -> URL {
        if let infoValue {
            let trimmed = infoValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty, let url = URL(string: trimmed) {
                return url
            }
        }
        // Info.plist 값이 없으면 OpenAPI 서버 정의 또는 로컬 기본값으로 대체합니다.
        return (try? Servers.Server1.url()) ?? URL(string: "http://localhost:8080/api")!
    }

    private static func resolveAllowInsecureHosts(from infoValue: String?) -> Set<String> {
        guard let infoValue else {
            return ["localhost", "127.0.0.1"]
        }
        let hosts = infoValue
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        // 빈 문자열이면 모든 HTTP 호스트를 거부합니다.
        return hosts.isEmpty ? [] : Set(hosts)
    }
}

/// OpenAPI 호출 과정에서 발생할 수 있는 오류를 정의합니다.
enum RemoteAPIError: LocalizedError {
    case insecureBaseURL(URL)
    case unexpectedStatus(Int)
    case missingBody
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .insecureBaseURL(let url):
            return "Refusing to use insecure base URL: \(url.absoluteString). Use HTTPS or allow localhost explicitly."
        case .unexpectedStatus(let code):
            return "Unexpected status code \(code)"
        case .missingBody:
            return "Response body is missing or in an unsupported format."
        case .transport(let error):
            return error.localizedDescription
        }
    }
}

/// 생성된 OpenAPI 클라이언트를 감싸 도메인에서 단순하게 사용할 수 있도록 하는 래퍼입니다.
final class RemoteAPI<C: APIProtocol> {
    private let client: C

    init(client: C) {
        self.client = client
    }

    convenience init(
        configuration: APIConfiguration = .default(),
        transport: (any ClientTransport)? = nil
    ) throws where C == Client {
        let baseURL = try configuration.validatedBaseURL()
        let resolvedTransport = transport ?? URLSessionTransport()
        let client = Client(serverURL: baseURL, transport: resolvedTransport)
        self.init(client: client)
    }

    convenience init(
        mockTransport: MockServerTransport,
        configuration: APIConfiguration = .default()
    ) throws where C == Client {
        let baseURL = try configuration.validatedBaseURL()
        let client = Client(serverURL: baseURL, transport: mockTransport)
        self.init(client: client)
    }

    /// OpenAPI로 생성된 `Client`의 `getGreeting`을 호출해 DTO를 반환합니다.
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
