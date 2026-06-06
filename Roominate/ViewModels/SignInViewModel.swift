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
            _ = try await authService.sendOTP(email: email)
            return true
        } catch {
            errorMessage = error.localizedDescription
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
            let user = try await authService.fetchCurrentUser()
            return user.isProfileComplete ? .authenticatedComplete : .authenticatedNeedsProfile
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
        case failure
    }
}
