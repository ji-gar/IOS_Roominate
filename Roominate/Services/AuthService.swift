import Foundation

protocol AuthServiceProtocol {
    func sendOTP(email: String) async throws -> AuthResponse
    func resendOTP(email: String) async throws -> AuthResponse
    func requestOTPForSignUp(email: String) async throws -> AuthResponse
    func requestOTPForSignIn(email: String) async throws -> AuthResponse
    func verifyOTP(email: String, otp: String) async throws -> AuthResponse
    func login(email: String, password: String) async throws -> AuthResponse
    func loginWithOTP(email: String, otp: String) async throws -> AuthResponse
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
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:sendOTP",
            message: "Sending OTP (new user registration)",
            data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
            hypothesisId: "B"
        )
        print("[RoominateAuth] sendOTP -> \(normalizedEmail)")
        // #endregion
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.sendOTP,
            method: .post,
            body: SendOTPRequest(email: normalizedEmail)
        )
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:sendOTP",
            message: "OTP send completed",
            data: [
                "success": String(response.success ?? false),
                "message": response.message ?? "",
                "hasToken": String(response.resolvedToken != nil)
            ],
            hypothesisId: "B"
        )
        // #endregion
        return response
    }

    func resendOTP(email: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:resendOTP",
            message: "Resending OTP (existing user)",
            data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
            hypothesisId: "B"
        )
        print("[RoominateAuth] resendOTP -> \(normalizedEmail)")
        // #endregion
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.resendOTP,
            method: .post,
            body: SendOTPRequest(email: normalizedEmail)
        )
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:resendOTP",
            message: "OTP resend completed",
            data: [
                "success": String(response.success ?? false),
                "message": response.message ?? ""
            ],
            hypothesisId: "B"
        )
        // #endregion
        return response
    }

    func requestOTPForSignUp(email: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        do {
            return try await sendOTP(email: normalizedEmail)
        } catch let error as NetworkError {
            if case .httpError(422, _) = error {
                // #region agent log
                DebugLog.write(
                    location: "AuthService.swift:requestOTPForSignUp",
                    message: "send-otp returned 422, falling back to resend-otp",
                    data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
                    hypothesisId: "B"
                )
                print("[RoominateAuth] signUp: send-otp 422, trying resend-otp")
                // #endregion
                return try await resendOTP(email: normalizedEmail)
            }
            throw error
        }
    }

    func requestOTPForSignIn(email: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:requestOTPForSignIn",
            message: "Requesting OTP for sign-in",
            data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
            hypothesisId: "B"
        )
        print("[RoominateAuth] requestOTPForSignIn -> \(normalizedEmail)")
        // #endregion
        do {
            return try await requestLoginOTP(email: normalizedEmail)
        } catch let error as NetworkError {
            if case .httpError(404, _) = error {
                // #region agent log
                DebugLog.write(
                    location: "AuthService.swift:requestOTPForSignIn",
                    message: "login-with-otp returned 404, falling back to resend-otp",
                    data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
                    hypothesisId: "B"
                )
                print("[RoominateAuth] signIn: login-with-otp 404, trying resend-otp")
                // #endregion
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
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:verifyOTP",
            message: "Verifying OTP",
            data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
            hypothesisId: "E"
        )
        print("[RoominateAuth] verifyOTP -> \(normalizedEmail)")
        // #endregion
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.verifyOTP,
            method: .post,
            body: VerifyOTPRequest(email: normalizedEmail, otp: otp)
        )
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:verifyOTP",
            message: "OTP verify completed",
            data: [
                "success": String(response.success ?? false),
                "hasToken": String(response.resolvedToken != nil)
            ],
            hypothesisId: "E"
        )
        // #endregion
        return response
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let normalizedEmail = normalizeEmail(email)
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:login",
            message: "Login attempt",
            data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
            hypothesisId: "D"
        )
        // #endregion
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.login,
            method: .post,
            body: LoginRequest(email: normalizedEmail, password: password)
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
        let normalizedEmail = normalizeEmail(email)
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:loginWithOTP",
            message: "Attempting OTP login",
            data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
            hypothesisId: "E"
        )
        // #endregion
        let response: AuthResponse = try await client.request(
            path: APIConstants.Auth.loginWithOTP,
            method: .post,
            body: LoginWithOTPRequest(email: normalizedEmail, otp: otp)
        )
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:loginWithOTP",
            message: "OTP login completed",
            data: ["hasToken": String(response.resolvedToken != nil)],
            hypothesisId: "E"
        )
        // #endregion
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
            // #region agent log
            DebugLog.write(
                location: "AuthService.swift:setPassword",
                message: "reset-password succeeded, logging in with new password",
                data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
                hypothesisId: "A"
            )
            // #endregion
            let response = try await login(email: normalizedEmail, password: password)
            // #region agent log
            DebugLog.write(
                location: "AuthService.swift:setPassword",
                message: "Login after set-password completed",
                data: ["hasToken": String(response.resolvedToken != nil)],
                hypothesisId: "A"
            )
            // #endregion
            return response
        }

        let response: AuthResponse = try await client.request(
            path: APIConstants.User.profile,
            method: .post,
            multipart: MultipartFormData(fields: [
                .init(name: "password", value: password),
                .init(name: "password_confirmation", value: confirmation)
            ]),
            requiresAuth: true
        )
        if let token = response.resolvedToken {
            TokenStorage.shared.token = token
        }
        return response
    }

    private func resetPasswordWithOTP(
        email: String,
        otp: String,
        password: String,
        confirmation: String
    ) async throws -> AuthResponse {
        // #region agent log
        DebugLog.write(
            location: "AuthService.swift:resetPasswordWithOTP",
            message: "Setting account password via reset-password",
            data: ["emailDomain": String(email.split(separator: "@").last ?? "")],
            hypothesisId: "D"
        )
        // #endregion
        return try await client.request(
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
