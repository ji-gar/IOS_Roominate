import Foundation

enum APIConstants {
    static let baseURL = "https://roominate.laravel.cloud/api"
    static let siteBaseURL = "https://roominate.laravel.cloud"
    static let storageBaseURL = siteBaseURL + "/storage/"

    /// Normalizes API media paths to a loadable URL.
    static func resolveMediaURL(_ path: String) -> String {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") { return trimmed }
        if trimmed.hasPrefix("/storage/") { return siteBaseURL + trimmed }
        if trimmed.hasPrefix("storage/") { return siteBaseURL + "/" + trimmed }
        let normalized = trimmed.hasPrefix("/") ? String(trimmed.dropFirst()) : trimmed
        return storageBaseURL + normalized
    }
    /// Set `GOOGLE_PLACES_API_KEY` in the target Info.plist for live Google suggestions.
    static let googlePlacesAPIKey: String = {
        if let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_PLACES_API_KEY") as? String,
           !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return key
        }
        return ""
    }()

    enum Auth {
        static let login = "/login"
        static let loginWithOTP = "/login-with-otp"
        static let sendOTP = "/send-otp"
        static let resendOTP = "/resend-otp"
        static let verifyOTP = "/verify-otp"
        static let register = "/register"
        static let forgotPassword = "/forgot-password"
        static let resetPassword = "/reset-password"
    }

    enum User {
        static let me = "/user"
        static let profile = "/profile"
        static let profileImage = "/profile/image"
        static let deleteAccount = "/profile"
        static func socialLink(id: Int) -> String { "/profile/social-links/\(id)" }
        static func block(userId: Int) -> String { "/users/\(userId)/block" }
    }

    enum Posts {
        static let posts = "/posts"
        static let myAll = "/posts/my/all"
        static let search = "/posts/search"
        static func post(id: Int) -> String { "/posts/\(id)" }
        static func report(postId: Int) -> String { "/posts/\(postId)/report" }
    }

    enum Chat {
        static let startChat = "/chat/start"
        static let conversations = "/chat/conversations"
        static func messages(conversationId: Int) -> String {
            "/chat/conversations/\(conversationId)/messages"
        }
        static func grabDeal(conversationId: Int) -> String {
            "/chat/conversations/\(conversationId)/grab-deal"
        }
    }

    enum Reverb {
        static let appKey = "BwBxNVCnJUHRVs5D80qL"
        static let host = "ws-a1c22b5a-d13a-4044-98e6-669ed7a44a29-reverb.laravel.cloud"
        static let port = 443
        static let authEndpoint = "\(baseURL)/broadcasting/auth"
    }
}
