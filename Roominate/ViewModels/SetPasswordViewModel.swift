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
            _ = try await authService.setPassword(
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
