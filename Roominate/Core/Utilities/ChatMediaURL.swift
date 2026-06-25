import Foundation

enum ChatMediaURL {
    static func resolve(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return trimmed
        }

        if trimmed.hasPrefix("storage/") {
            let siteBase = APIConstants.baseURL.replacingOccurrences(of: "/api", with: "")
            return siteBase + "/" + trimmed
        }

        if trimmed.hasPrefix("/storage/") {
            let siteBase = APIConstants.baseURL.replacingOccurrences(of: "/api", with: "")
            return siteBase + trimmed
        }

        let normalized = trimmed.hasPrefix("/") ? String(trimmed.dropFirst()) : trimmed
        return APIConstants.storageBaseURL + normalized
    }
}
