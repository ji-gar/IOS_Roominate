import Combine
import Foundation

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    var isFormValid: Bool {
        EmailValidator.isValidIIMEmail(email) && PasswordValidator.isValid(password)
    }

    func sendOTPForLogin(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await authService.requestOTPForSignIn(email: email)
            // #region agent log
            DebugLog.write(
                location: "SignInViewModel.swift:sendOTPForLogin",
                message: "OTP requested for sign-in",
                data: ["emailDomain": String(email.split(separator: "@").last ?? "")],
                hypothesisId: "B"
            )
            // #endregion
            return true
        } catch {
            errorMessage = error.localizedDescription
            // #region agent log
            DebugLog.write(
                location: "SignInViewModel.swift:sendOTPForLogin",
                message: "OTP request for sign-in failed",
                data: ["error": error.localizedDescription],
                hypothesisId: "B"
            )
            // #endregion
            return false
        }
    }

    func signIn() async -> SignInResult {
        guard isFormValid else {
            // #region agent log
            DebugLog.write(
                location: "SignInViewModel.swift:signIn",
                message: "Sign in blocked by validation",
                data: ["isFormValid": "false"],
                hypothesisId: "C"
            )
            // #endregion
            return .failure
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await authService.login(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                password: password
            )
            let isComplete = try await authService.resolveProfileCompletion()
            return isComplete ? .authenticatedComplete : .authenticatedNeedsProfile
        } catch let error as NetworkError {
            if case .httpError(let statusCode, let message) = error,
               statusCode == 403,
               message?.lowercased().contains("verify your email") == true {
                let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                errorMessage = message
                // #region agent log
                DebugLog.write(
                    location: "SignInViewModel.swift:signIn",
                    message: "Sign in requires email verification",
                    data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
                    hypothesisId: "D"
                )
                // #endregion
                return .needsEmailVerification(email: normalizedEmail)
            }

            if case .httpError(401, let message) = error,
               message?.lowercased().contains("invalid credentials") == true {
                errorMessage = Strings.Error.invalidCredentials
            } else {
                errorMessage = error.localizedDescription
            }
            // #region agent log
            DebugLog.write(
                location: "SignInViewModel.swift:signIn",
                message: "Sign in failed",
                data: ["error": errorMessage ?? error.localizedDescription],
                hypothesisId: "D"
            )
            // #endregion
            return .failure
        } catch {
            errorMessage = error.localizedDescription
            // #region agent log
            DebugLog.write(
                location: "SignInViewModel.swift:signIn",
                message: "Sign in failed",
                data: ["error": error.localizedDescription],
                hypothesisId: "D"
            )
            // #endregion
            return .failure
        }
    }

    enum SignInResult {
        case authenticatedComplete
        case authenticatedNeedsProfile
        case needsEmailVerification(email: String)
        case failure
    }
}
