import Foundation

enum APIConstants {
    static let baseURL = "https://roominate.laravel.cloud/api"
    // Replace with your actual Google Places API key
    static let googlePlacesAPIKey = ""

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
    }
}
