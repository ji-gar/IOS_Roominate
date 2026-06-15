import Combine
import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailError: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didValidateEmail = false

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

    func signUp() async -> String? {
        validateEmail()
        guard isFormValid else { return nil }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        return email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
