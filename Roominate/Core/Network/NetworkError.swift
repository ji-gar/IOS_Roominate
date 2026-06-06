import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError
    case noData
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return Strings.Error.network
        case .invalidResponse:
            return Strings.Error.network
        case .httpError(_, let message):
            return message ?? Strings.Error.generic
        case .decodingError:
            return Strings.Error.generic
        case .noData:
            return Strings.Error.generic
        case .unauthorized:
            return Strings.Error.generic
        }
    }
}
