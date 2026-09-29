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

        // TODO: Backend endpoint /api/verify-institution not yet implemented
        // Once the backend route is added, uncomment the API call below
        
        /*
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
        */
        
        // TEMPORARY: Simulate successful submission until backend is ready
        #if DEBUG
        print("📄 [Institution Verification] Simulating document upload (backend not implemented)")
        print("   Email: \(email)")
        print("   Document Type: \(docType.rawValue)")
        print("   Image Size: \(imageData.count) bytes")
        #endif
        
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        isSubmitted = true
        return true
    }

    // MARK: - Private

    /// Uploads the verification document via a multipart form-data request.
    private func uploadVerificationDocument(
        email: String,
        documentType: String,
        imageData: Data
    ) async throws {
        // Compress and resize image aggressively to prevent timeout issues
        // Target max size: 500KB for reliable upload on slower connections
        let compressedData: Data
        if let image = UIImage(data: imageData) {
            // First, resize image if it's too large (max 1600px on longest side)
            let resized: UIImage
            let maxDimension: CGFloat = 1600
            if image.size.width > maxDimension || image.size.height > maxDimension {
                let scale = min(maxDimension / image.size.width, maxDimension / image.size.height)
                let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                let renderer = UIGraphicsImageRenderer(size: newSize)
                resized = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: newSize))
                }
            } else {
                resized = image
            }
            
            // Then compress with adaptive quality to hit target file size
            var quality: CGFloat = 0.7
            var tempData = resized.jpegData(compressionQuality: quality) ?? imageData
            
            // Reduce quality further if image is larger than 500KB
            while tempData.count > 500_000 && quality > 0.3 {
                quality -= 0.1
                tempData = resized.jpegData(compressionQuality: quality) ?? tempData
            }
            compressedData = tempData
        } else {
            compressedData = imageData
        }
        
        let path = APIConstants.Auth.verifyInstitution
        try await APIClient.shared.uploadVerificationDocument(
            path: path,
            email: email,
            documentType: documentType,
            imageData: compressedData
        )
    }
}
