import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct MultipartFormData {
    struct Field {
        let name: String
        let value: String
    }

    struct FileField {
        let name: String
        let filename: String
        let mimeType: String
        let data: Data
    }

    let fields: [Field]
    let files: [FileField]

    init(fields: [Field] = [], files: [FileField] = []) {
        self.fields = fields
        self.files = files
    }

    func encoded(boundary: String) -> Data {
        var body = Data()

        for field in fields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(field.name)\"\r\n\r\n")
            body.append("\(field.value)\r\n")
        }

        for file in files {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.filename)\"\r\n")
            body.append("Content-Type: \(file.mimeType)\r\n\r\n")
            body.append(file.data)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        return body
    }
}

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        body: Encodable? = nil,
        multipart: MultipartFormData? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        let data = try await requestData(
            path: path,
            method: method,
            body: body,
            multipart: multipart,
            requiresAuth: requiresAuth
        )
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func requestData(
        path: String,
        method: HTTPMethod,
        body: Encodable? = nil,
        multipart: MultipartFormData? = nil,
        requiresAuth: Bool = false
    ) async throws -> Data {
        guard let url = URL(string: APIConstants.baseURL + path) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth, let token = TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let multipart {
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = multipart.encoded(boundary: boundary)
        } else if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // #region agent log
        let responsePreview = String(data: data.prefix(300), encoding: .utf8) ?? ""
        DebugLog.write(
            location: "APIClient.swift:requestData",
            message: "HTTP response received",
            data: [
                "path": path,
                "method": method.rawValue,
                "statusCode": String(httpResponse.statusCode),
                "responsePreview": responsePreview
            ],
            hypothesisId: "A"
        )
        print("[RoominateAuth][API] \(method.rawValue) \(path) -> \(httpResponse.statusCode)")
        // #endregion

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = parseErrorMessage(from: data)
            // #region agent log
            DebugLog.write(
                location: "APIClient.swift:requestData",
                message: "HTTP error",
                data: [
                    "path": path,
                    "statusCode": String(httpResponse.statusCode),
                    "errorMessage": message ?? "nil"
                ],
                hypothesisId: "A"
            )
            print("[RoominateAuth][API][ERROR] \(path) \(httpResponse.statusCode): \(message ?? "unknown")")
            // #endregion
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: message)
        }

        return data
    }

    private func parseErrorMessage(from data: Data) -> String? {
        struct ErrorResponse: Decodable {
            let success: Bool?
            let message: String?
            let error: String?
        }
        guard let decoded = try? decoder.decode(ErrorResponse.self, from: data) else { return nil }
        if decoded.success == false {
            return decoded.message ?? decoded.error
        }
        return decoded.message ?? decoded.error
    }
}

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        encodeClosure = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
