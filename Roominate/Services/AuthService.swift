import Foundation

protocol AuthServiceProtocol {
    func sendOTP(email: String) async throws -> AuthResponse
    func resendOTP(email: String) async throws -> AuthResponse
    func requestOTPForSignUp(email: String) async throws -> AuthResponse
    func requestOTPForSignIn(email: String) async throws -> AuthResponse
    func verifyOTP(email: String, otp: String) async throws -> AuthResponse
    func login(email: String, password: String) async throws -> AuthResponse
    func loginWithOTP(email: String, otp: String) async throws -> AuthResponse
    func register(name: String, email: String, password: String, confirmation: String) async throws -> AuthResponse
    func setPassword(email: String, otp: String?, password: String, confirmation: String) async throws -> AuthResponse
    func fetchCurrentUser() async throws -> UserResponse
    func fetchProfile() async throws -> ProfileResponse
    func resolveProfileCompletion() async throws -> Bool
}

final class AuthService: AuthServiceProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func sendOTP(email: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        return try await client.request(
            path: APIConstants.Auth.sendOTP,
            method: .post,
            body: SendOTPRequest(email: normalizedEmail)
        )
    }

    func resendOTP(email: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        return try await client.request(
            path: APIConstants.Auth.resendOTP,
            method: .post,
            body: SendOTPRequest(email: normalizedEmail)
        )
    }

    func requestOTPForSignUp(email: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        do {
            return try await sendOTP(email: normalizedEmail)
        } catch let error as NetworkError {
            if case .httpError(422, _) = error {
                return try await resendOTP(email: normalizedEmail)
            }
            throw error
        }
    }

    func requestOTPForSignIn(email: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        do {
            return try await requestLoginOTP(email: normalizedEmail)
        } catch let error as NetworkError {
            if case .httpError(404, _) = error {
                return try await resendOTP(email: normalizedEmail)
            }
            throw error
        }
    }

    private func requestLoginOTP(email: String) async throws -> AuthResponse {
        try await client.request(
            path: APIConstants.Auth.loginWithOTP,
            method: .post,
            body: SendOTPRequest(email: email)
        )
    }

    func verifyOTP(email: String, otp: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.verifyOTP,
            method: .post,
            body: VerifyOTPRequest(email: normalizedEmail, otp: otp)
        )
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        if let userId = response.data?.userId, userId > 0 {
            TokenStorage.shared.userId = userId
        }
        return response
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.login,
            method: .post,
            body: LoginRequest(email: normalizedEmail, password: password)
        )
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        if let userId = response.data?.userId, userId > 0 {
            TokenStorage.shared.userId = userId
        }
        return response
    }

    func loginWithOTP(email: String, otp: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.loginWithOTP,
            method: .post,
            body: LoginWithOTPRequest(email: normalizedEmail, otp: otp)
        )
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        if let userId = response.data?.userId, userId > 0 {
            TokenStorage.shared.userId = userId
        }
        return response
    }

    func setPassword(
        email: String,
        otp: String?,
        password: String,
        confirmation: String
    ) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)

        if let otp, !otp.isEmpty {
            _ = try await resetPasswordWithOTP(
                email: normalizedEmail,
                otp: otp,
                password: password,
                confirmation: confirmation
            )
            return try await login(email: normalizedEmail, password: password)
        }

        return try await register(
            name: "User",
            email: normalizedEmail,
            password: password,
            confirmation: confirmation
        )
    }

    func register(
        name: String,
        email: String,
        password: String,
        confirmation: String
    ) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        return try await client.request(
            path: APIConstants.Auth.register,
            method: .post,
            body: RegisterRequest(
                name: name,
                email: normalizedEmail,
                password: password,
                passwordConfirmation: confirmation
            )
        )
    }

    private func resetPasswordWithOTP(
        email: String,
        otp: String,
        password: String,
        confirmation: String
    ) async throws -> AuthResponse {
        try await client.request(
            path: APIConstants.Auth.resetPassword,
            method: .post,
            body: ResetPasswordRequest(
                email: email,
                token: otp,
                password: password,
                passwordConfirmation: confirmation
            )
        )
    }

    func fetchCurrentUser() async throws -> UserResponse {
        let data = try await client.requestData(
            path: APIConstants.User.me,
            method: .get,
            requiresAuth: true
        )
        return try UserResponse.decode(from: data, using: client.decoder)
    }

    func fetchProfile() async throws -> ProfileResponse {
        let data = try await client.requestData(
            path: APIConstants.User.profile,
            method: .get,
            requiresAuth: true
        )
        return try ProfileResponse.decode(from: data, using: client.decoder)
    }

    func resolveProfileCompletion() async throws -> Bool {
        if let profile = try? await fetchProfile(), profile.isComplete {
            return true
        }

        let user = try await fetchCurrentUser()
        return user.isProfileComplete
    }

    private func normalizeEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
