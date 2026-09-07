import Foundation

protocol AuthServiceProtocol {
    /// Checks whether an email address already exists in the system.
    func checkEmail(email: String) async throws -> CheckEmailResponse
    /// Checks if email is from accepted institute and returns next step for signup.
    func checkInstituteEmail(email: String) async throws -> CheckInstituteEmailResponse
    func sendOTP(email: String) async throws -> AuthResponse
    func resendOTP(email: String) async throws -> AuthResponse
    func requestOTPForSignUp(email: String) async throws -> AuthResponse
    func requestOTPForSignIn(email: String) async throws -> AuthResponse
    func verifyOTP(email: String, otp: String) async throws -> AuthResponse
    func verifyOTPAndSetPassword(email: String, otp: String, password: String, confirmation: String) async throws -> AuthResponse
    func login(email: String, password: String) async throws -> AuthResponse
    func requestLoginOTP(email: String) async throws -> AuthResponse
    func verifyLoginOTP(email: String, otp: String) async throws -> AuthResponse
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

    // MARK: - Check Email

    /// POST /check-email — returns `success: true` if the email exists.
    func checkEmail(email: String) async throws -> CheckEmailResponse {
        let normalizedEmail = normalizeEmail(email)
        return try await client.request(
            path: APIConstants.Auth.checkEmail,
            method: .post,
            body: CheckEmailRequest(email: normalizedEmail)
        )
    }
    
    /// POST /check-institute-email — validates institute email and returns next step for signup.
    func checkInstituteEmail(email: String) async throws -> CheckInstituteEmailResponse {
        let normalizedEmail = normalizeEmail(email)
        return try await client.request(
            path: APIConstants.Auth.checkInstituteEmail,
            method: .post,
            body: CheckInstituteEmailRequest(email: normalizedEmail)
        )
    }

    // MARK: - OTP

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

    func requestLoginOTP(email: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        return try await client.request(
            path: APIConstants.Auth.loginWithOTP,
            method: .post,
            body: SendOTPRequest(email: normalizedEmail)
        )
    }

    // MARK: - Verify / Login

    func verifyOTP(email: String, otp: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.verifyOTP,
            method: .post,
            body: VerifyOTPRequest(email: normalizedEmail, otp: otp)
        )
        await persistAuthCredentials(from: response)
        return response
    }
    
    /// Verifies OTP and sets password in a single call (recommended for signup flow)
    func verifyOTPAndSetPassword(
        email: String,
        otp: String,
        password: String,
        confirmation: String
    ) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.verifyOTPSetPassword,
            method: .post,
            body: VerifyOTPSetPasswordRequest(
                email: normalizedEmail,
                otp: otp,
                password: password,
                passwordConfirmation: confirmation
            )
        )
        await persistAuthCredentials(from: response)
        return response
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.login,
            method: .post,
            body: LoginRequest(email: normalizedEmail, password: password)
        )
        await persistAuthCredentials(from: response)
        return response
    }

    func verifyLoginOTP(email: String, otp: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.verifyLoginOTP,
            method: .post,
            body: LoginWithOTPRequest(email: normalizedEmail, otp: otp)
        )
        await persistAuthCredentials(from: response)
        return response
    }

    // MARK: - Auth Credentials

    /// Stores token + user id from an auth response. Falls back to `/me` when
    /// the response doesn't embed a user id (needed for chat bubble alignment).
    private func persistAuthCredentials(from response: AuthResponse) async {
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        if let userId = response.data?.userId, userId > 0 {
            TokenStorage.shared.userId = userId
            return
        }
        if let user = try? await fetchCurrentUser(),
           let resolved = user.resolvedUserId, resolved > 0 {
            TokenStorage.shared.userId = resolved
        }
    }

    // MARK: - Password

    func setPassword(
        email: String,
        otp: String?,
        password: String,
        confirmation: String
    ) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)

        // If OTP is provided, this is a signup flow - use the combined endpoint
        if let otp, !otp.isEmpty {
            return try await verifyOTPAndSetPassword(
                email: normalizedEmail,
                otp: otp,
                password: password,
                confirmation: confirmation
            )
        }

        // Fallback to legacy register endpoint
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

    // MARK: - User / Profile

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

    // MARK: - Helpers

    private func normalizeEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
