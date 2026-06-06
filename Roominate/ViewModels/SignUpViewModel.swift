import Combine
import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailError: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didValidateEmail = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    var isFormValid: Bool {
        EmailValidator.isValidIIMEmail(email)
    }

    enum EmailFieldState {
        case normal
        case focused
        case error(String)
    }

    var emailFieldState: EmailFieldState {
        if let emailError {
            return .error(emailError)
        }
        if didValidateEmail && email.isEmpty {
            return .error(Strings.SignUp.emailError)
        }
        return email.isEmpty ? .normal : .focused
    }

    func validateEmail() {
        didValidateEmail = true
        if !email.isEmpty && !EmailValidator.isValidIIMEmail(email) {
            emailError = Strings.SignUp.emailError
        } else {
            emailError = nil
        }
    }

    func signUp() async -> Bool {
        validateEmail()
        guard isFormValid else {
            // #region agent log
            DebugLog.write(
                location: "SignUpViewModel.swift:signUp",
                message: "Sign up blocked by validation",
                data: ["isFormValid": "false", "emailEmpty": String(email.isEmpty)],
                hypothesisId: "C"
            )
            // #endregion
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        do {
            _ = try await authService.sendOTP(email: normalizedEmail)
            // #region agent log
            DebugLog.write(
                location: "SignUpViewModel.swift:signUp",
                message: "OTP sent successfully",
                data: ["emailDomain": String(normalizedEmail.split(separator: "@").last ?? "")],
                hypothesisId: "D"
            )
            // #endregion
            return true
        } catch {
            errorMessage = error.localizedDescription
            // #region agent log
            DebugLog.write(
                location: "SignUpViewModel.swift:signUp",
                message: "OTP send failed",
                data: ["error": error.localizedDescription],
                hypothesisId: "D"
            )
            // #endregion
            return false
        }
    }
}
