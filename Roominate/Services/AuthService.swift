import Foundation

protocol AuthServiceProtocol {
    func sendOTP(email: String) async throws -> AuthResponse
    func verifyOTP(email: String, otp: String) async throws -> AuthResponse
    func login(email: String, password: String) async throws -> AuthResponse
    func loginWithOTP(email: String, otp: String) async throws -> AuthResponse
    func setPassword(password: String, confirmation: String) async throws -> AuthResponse
    func fetchCurrentUser() async throws -> UserResponse
}

final class AuthService: AuthServiceProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func sendOTP(email: String) async throws -> AuthResponse {
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:sendOTP",
            message: "Sending OTP",
            data: ["emailDomain": String(email.split(separator: "@").last ?? "")],
            hypothesisId: "D"
        )
        // #endregion
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.sendOTP,
            method: .post,
            body: SendOTPRequest(email: email)
        )
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:sendOTP",
            message: "OTP send completed",
            data: ["success": String(response.success ?? false), "hasToken": String(response.resolvedToken != nil)],
            hypothesisId: "D"
        )
        // #endregion
        return response
    }

    func verifyOTP(email: String, otp: String) async throws -> AuthResponse {
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.verifyOTP,
            method: .post,
            body: VerifyOTPRequest(email: email, otp: otp)
        )
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        return response
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:login",
            message: "Login attempt",
            data: ["emailDomain": String(email.split(separator: "@").last ?? "")],
            hypothesisId: "D"
        )
        // #endregion
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.login,
            method: .post,
            body: LoginRequest(email: email, password: password)
        )
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:login",
            message: "Login completed",
            data: ["hasToken": String(response.resolvedToken != nil)],
            hypothesisId: "D"
        )
        // #endregion
        return response
    }

    func loginWithOTP(email: String, otp: String) async throws -> AuthResponse {
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.loginWithOTP,
            method: .post,
            body: LoginWithOTPRequest(email: email, otp: otp)
        )
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        return response
    }

    func setPassword(password: String, confirmation: String) async throws -> AuthResponse {
        let response: AuthResponse = try await client.request(
            path: APIConstants.User.profile,
            method: .post,
            body: SetPasswordRequest(password: password, passwordConfirmation: confirmation),
            requiresAuth: true
        )
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        return response
    }

    func fetchCurrentUser() async throws -> UserResponse {
        let data = try await client.requestData(
            path: APIConstants.User.me,
            method: .get,
            requiresAuth: true
        )
        return try UserResponse.decode(from: data, using: client.decoder)
    }
}
