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

    /// Validates the email format locally, then calls `POST /check-email` to
    /// confirm the address does NOT already exist in the system before
    /// proceeding to the Set Password step.
    func signUp() async -> String? {
        validateEmail()
        guard isFormValid else { return nil }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await authService.checkEmail(email: normalizedEmail)

            if response.success {
                // Email already registered — tell the user to sign in instead
                emailError = "This email is already registered. Please sign in."
                return nil
            } else {
                // Email does not exist — safe to proceed with sign up
                return normalizedEmail
            }
        } catch {
            // Network / server error — surface the message but still allow
            // the user to continue so a transient failure doesn't block sign up
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
