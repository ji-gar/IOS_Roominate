import Foundation

enum EmailValidator {
    static func isValidIIMEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
}

enum PasswordValidator {
    static func isValid(_ password: String) -> Bool {
        password.count >= 8
    }
}
