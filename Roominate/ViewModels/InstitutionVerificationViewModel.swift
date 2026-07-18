import Combine
import Foundation
import UIKit

enum VerificationDocumentType: String, CaseIterable, Identifiable {
    case studentID        = "student_id"
    case alumniID         = "alumni_id"
    case degreeCertificate = "degree_certificate"
    case admissionLetter  = "admission_letter"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .studentID:         return Strings.InstitutionVerification.studentID
        case .alumniID:          return Strings.InstitutionVerification.alumniID
        case .degreeCertificate: return Strings.InstitutionVerification.degreeCertificate
        case .admissionLetter:   return Strings.InstitutionVerification.admissionLetter
        }
    }

    var systemImage: String {
        switch self {
        case .studentID:         return "person.text.rectangle"
        case .alumniID:          return "graduationcap.fill"
        case .degreeCertificate: return "scroll.fill"
        case .admissionLetter:   return "envelope.fill"
        }
    }
}

@MainActor
final class InstitutionVerificationViewModel: ObservableObject {

    // MARK: - Inputs
    @Published var selectedDocumentType: VerificationDocumentType? = nil
    @Published var selectedImageData: Data? = nil

    // MARK: - State
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSubmitted = false

    let email: String

    // MARK: - Validation

    var isFormValid: Bool {
        selectedDocumentType != nil && selectedImageData != nil
    }

    // MARK: - Init

    init(email: String) {
        self.email = email
    }

    // MARK: - Actions

    func setImage(_ image: UIImage?) {
        guard let image else {
            selectedImageData = nil
            return
        }
        // Compress to ≤ 2 MB for upload
        selectedImageData = image.jpegData(compressionQuality: 0.8)
    }

    func submit() async -> Bool {
        guard isFormValid,
              let docType = selectedDocumentType,
              let imageData = selectedImageData else { return false }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await uploadVerificationDocument(
                email: email,
                documentType: docType.rawValue,
                imageData: imageData
            )
            isSubmitted = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Private

    /// Uploads the verification document via a multipart form-data request.
    private func uploadVerificationDocument(
        email: String,
        documentType: String,
        imageData: Data
    ) async throws {
        let path = APIConstants.Auth.verifyInstitution
        try await APIClient.shared.uploadVerificationDocument(
            path: path,
            email: email,
            documentType: documentType,
            imageData: imageData
        )
    }
}
