import Foundation

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
