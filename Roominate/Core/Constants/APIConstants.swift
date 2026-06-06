import Foundation

enum APIConstants {
    static let baseURL = "https://roominate.laravel.cloud/api"

    enum Auth {
        static let login = "/login"
        static let loginWithOTP = "/login-with-otp"
        static let sendOTP = "/send-otp"
        static let verifyOTP = "/verify-otp"
        static let register = "/register"
    }

    enum User {
        static let me = "/user"
        static let profile = "/profile"
    }
}
