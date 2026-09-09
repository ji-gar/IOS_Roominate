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

    /// Validates the email format locally, then calls `POST /check-institute-email` to
    /// confirm the email is from an accepted institute and determine the next step
    /// in the signup flow (send-otp, login, or resend-otp).
    func signUp() async -> String? {
        validateEmail()
        guard isFormValid else { return nil }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await authService.checkInstituteEmail(email: normalizedEmail)

            guard response.success, let data = response.data else {
                emailError = response.message
                return nil
            }
            
            // Check if email domain is allowed
            guard data.allowed else {
                emailError = response.message
                return nil
            }
            
            // Handle based on next_step
            switch data.nextStep {
            case "send-otp":
                // New user - proceed with sign up
                return normalizedEmail
                
            case "login":
                // Account exists and is verified - redirect to sign in
                emailError = "This email is already registered. Please sign in."
                return nil
                
            case "resend-otp":
                // Abandoned signup - proceed but OTP screen should call resend
                return normalizedEmail
                
            default:
                emailError = "Unexpected response from server. Please try again."
                return nil
            }
        } catch let error as NetworkError {
            // Handle 422 validation errors
            if case .httpError(422, let message) = error {
                emailError = message ?? "Invalid email address."
            } else {
                errorMessage = error.localizedDescription
            }
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
