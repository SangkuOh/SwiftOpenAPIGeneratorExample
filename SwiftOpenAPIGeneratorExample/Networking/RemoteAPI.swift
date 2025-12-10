import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

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

    /// Builds a configuration from Info.plist entries populated via .xcconfig.
    static func fromInfoPlist(bundle: Bundle = .main) -> Self {
        let baseURL = resolveBaseURL(from: bundle.infoDictionary?["API_BASE_URL"] as? String)
        let insecureHosts = resolveAllowInsecureHosts(
            from: bundle.infoDictionary?["API_ALLOW_INSECURE_HOSTS"] as? String
        )
        return .init(baseURL: baseURL, allowInsecureHosts: insecureHosts)
    }

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
        // Fall back to the first server entry in the OpenAPI document or a local default.
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
        // Empty string means "disallow HTTP everywhere".
        return hosts.isEmpty ? [] : Set(hosts)
    }
}

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

/// Thin wrapper around the generated OpenAPI client.
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
