import Combine
import Foundation
import UIKit

@MainActor
final class AddProfileViewModel: ObservableObject {
    @Published var draft = ProfileDraft()
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }

    var isStep1Valid: Bool {
        !draft.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        draft.gender != nil
    }

    var isStep2Valid: Bool {
        !draft.area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        draft.profession != nil &&
        !draft.organization.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isStep3Valid: Bool {
        !draft.about.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        draft.about.count <= 100
    }

    var aboutCharacterCount: Int {
        draft.about.count
    }

    func setProfileImage(_ image: UIImage?) {
        draft.profileImageData = image?.jpegData(compressionQuality: 0.85)
    }

    func submitProfile() async -> Bool {
        guard isStep3Valid else { return false }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await userService.updateProfile(draft)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
