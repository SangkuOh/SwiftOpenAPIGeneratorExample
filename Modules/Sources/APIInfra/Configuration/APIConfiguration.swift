import Foundation
import OpenAPIRuntime
import APITypes

/// Info.plist와 OpenAPI 서버 정보를 조합해 클라이언트 설정을 만드는 구성 객체입니다.
public struct APIConfiguration {
    public let baseURL: URL
    public let allowInsecureHosts: Set<String>

    public init(baseURL: URL, allowInsecureHosts: Set<String> = ["localhost", "127.0.0.1"]) {
        self.baseURL = baseURL
        self.allowInsecureHosts = allowInsecureHosts
    }

    public static func `default`(bundle: Bundle = .main) -> Self {
        fromInfoPlist(bundle: bundle)
    }

    /// .xcconfig가 채운 Info.plist 값을 바탕으로 구성을 만듭니다.
    public static func fromInfoPlist(bundle: Bundle = .main) -> Self {
        let baseURL = resolveBaseURL(from: bundle.infoDictionary?["API_BASE_URL"] as? String)
        let insecureHosts = resolveAllowInsecureHosts(
            from: bundle.infoDictionary?["API_ALLOW_INSECURE_HOSTS"] as? String
        )
        return .init(baseURL: baseURL, allowInsecureHosts: insecureHosts)
    }

    /// HTTPS가 아닌 경우 허용 목록에 포함되어 있는지 검사해 안전하게 베이스 URL을 결정합니다.
    public func validatedBaseURL() throws -> URL {
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
