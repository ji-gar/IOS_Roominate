import Combine
import Foundation

@MainActor
final class InstitutionDetailsViewModel: ObservableObject {

    // MARK: - Inputs

    @Published var fullName: String = ""
    @Published var selectedInstitution: String = ""
    @Published var course: String = ""
    @Published var graduationYear: Int? = nil

    // MARK: - Derived state

    /// Whether the user's email domain auto-matched a known B-school domain.
    let isAutoVerified: Bool

    /// Pre-filled institution name (from email domain), if auto-verified.
    let autoInstitutionName: String?

    let email: String

    // MARK: - Validation

    var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedInstitution.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !course.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        graduationYear != nil
    }

    // MARK: - Available years

    var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        // Allow a range: 10 years back to 5 years forward (current/future students)
        return Array(stride(from: currentYear + 5, through: currentYear - 10, by: -1))
    }

    // MARK: - Init

    init(email: String) {
        self.email = email
        let autoName = EmailValidator.institutionName(for: email)
        self.isAutoVerified = autoName != nil
        self.autoInstitutionName = autoName
        // Pre-select institution when auto-verified
        self.selectedInstitution = autoName ?? ""
    }
}
