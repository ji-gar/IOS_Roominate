import Combine
import Foundation

@MainActor
final class SetPasswordViewModel: ObservableObject {
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var confirmPasswordError: String?

    let email: String
    let otp: String?
    private let authService: AuthServiceProtocol

    var signupPassword: String? {
        otp == nil ? password : nil
    }

    init(
        email: String,
        otp: String? = nil,
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.email = email
        self.otp = otp
        self.authService = authService
    }

    var isFormValid: Bool {
        PasswordValidator.isValid(password) && password == confirmPassword
    }

    func validateConfirmPassword() {
        if !confirmPassword.isEmpty && password != confirmPassword {
            confirmPasswordError = Strings.SetPassword.passwordMismatch
        } else {
            confirmPasswordError = nil
        }
    }

    func setPassword() async -> Bool {
        validateConfirmPassword()
        guard isFormValid else { return false }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // For signup flow, we need the OTP to complete registration
            // This ensures email is only marked as registered after OTP is verified
            guard let otp else {
                errorMessage = "Invalid session. Please start the signup process again."
                return false
            }
            
            // Use combined endpoint to verify OTP and set password atomically
            _ = try await authService.verifyOTPAndSetPassword(
                email: email,
                otp: otp,
                password: password,
                confirmation: confirmPassword
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
