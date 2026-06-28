import Combine
import Foundation
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile = UserProfile()
    @Published var listings: [UserListing] = []
    @Published var blockedUsers: [BlockedUser] = []
    @Published var isLoading = false
    @Published var isLoadingListings = false
    @Published var isLoadingBlockedUsers = false
    @Published var isSaving = false
    @Published var isDeletingListing = false
    @Published var isDeletingAccount = false
    @Published var errorMessage: String?

    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    private let postService: PostServiceProtocol

    init(
        userService: UserServiceProtocol = UserService(),
        authService: AuthServiceProtocol = AuthService(),
        postService: PostServiceProtocol = PostService()
    ) {
        self.userService = userService
        self.authService = authService
        self.postService = postService
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let profileResponse = userService.fetchProfile()
            async let userResponse = authService.fetchCurrentUser()
            async let listingsLoaded = loadListings()
            let (fetchedProfile, fetchedUser, _) = try await (profileResponse, userResponse, listingsLoaded)
            profile = UserProfile.from(profile: fetchedProfile, user: fetchedUser)
        } catch {
            do {
                let fetchedProfile = try await userService.fetchProfile()
                profile = UserProfile.from(profile: fetchedProfile, user: nil)
                await loadListings()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func refreshProfile() async {
        do {
            async let profileResponse = userService.fetchProfile()
            async let userResponse = authService.fetchCurrentUser()
            let (fetchedProfile, fetchedUser) = try await (profileResponse, userResponse)
            let preservedImageData = profile.profileImageData
            profile = UserProfile.from(profile: fetchedProfile, user: fetchedUser)
            if preservedImageData != nil, profile.profileImageURL == nil {
                profile.profileImageData = preservedImageData
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func loadListings() async -> Bool {
        isLoadingListings = true
        defer { isLoadingListings = false }

        do {
            let response = try await postService.fetchPosts(
                mode: .mine,
                query: PostQuery(perPage: 50, page: 1)
            )
            listings = response.data.map(UserListing.init)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func loadBlockedUsers() async -> Bool {
        isLoadingBlockedUsers = true
        defer { isLoadingBlockedUsers = false }

        do {
            blockedUsers = try await userService.fetchBlockedUsers()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func setProfileImage(_ image: UIImage?) {
        profile.profileImageData = image?.jpegData(compressionQuality: 0.85)
    }

    func removeProfileImage() {
        profile.profileImageData = nil
        profile.profileImageURL = nil
    }

    func updatePersonalInfo(
        name: String,
        gender: Gender?,
        birthYear: Int?,
        currentCity: String,
        profession: Profession?,
        instituteName: String,
        organizationName: String,
        position: String,
        removeImage: Bool
    ) async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            _ = try await userService.updateProfile(
                name: name,
                gender: gender,
                birthYear: birthYear,
                currentCity: currentCity,
                profession: profession,
                instituteName: profession == .student ? instituteName : nil,
                organizationName: profession == .working ? organizationName : nil,
                position: position.isEmpty ? nil : position,
                about: profile.about.isEmpty ? nil : profile.about,
                email: profile.email.isEmpty ? nil : profile.email,
                socialLinks: profile.socialLinks.isEmpty ? nil : profile.socialLinks,
                profileImageData: profile.profileImageData,
                removeProfileImage: removeImage
            )
            await refreshProfile()
            profile.profileImageData = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateContact(email: String, socialLinks: [SocialLinkDraft]) async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            _ = try await userService.updateProfile(
                name: profile.name.isEmpty ? nil : profile.name,
                gender: profile.gender,
                birthYear: profile.birthYear,
                currentCity: profile.currentCity.isEmpty ? nil : profile.currentCity,
                profession: profile.profession,
                instituteName: profile.profession == .student && !profile.instituteName.isEmpty
                    ? profile.instituteName : nil,
                organizationName: profile.profession == .working && !profile.organizationName.isEmpty
                    ? profile.organizationName : nil,
                position: profile.position.isEmpty ? nil : profile.position,
                about: profile.about.isEmpty ? nil : profile.about,
                email: email,
                socialLinks: socialLinks,
                profileImageData: nil,
                removeProfileImage: false
            )
            await refreshProfile()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateAbout(_ about: String) async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            _ = try await userService.updateProfile(
                name: profile.name.isEmpty ? nil : profile.name,
                gender: profile.gender,
                birthYear: profile.birthYear,
                currentCity: profile.currentCity.isEmpty ? nil : profile.currentCity,
                profession: profile.profession,
                instituteName: profile.profession == .student && !profile.instituteName.isEmpty
                    ? profile.instituteName : nil,
                organizationName: profile.profession == .working && !profile.organizationName.isEmpty
                    ? profile.organizationName : nil,
                position: profile.position.isEmpty ? nil : profile.position,
                about: about,
                email: profile.email.isEmpty ? nil : profile.email,
                socialLinks: profile.socialLinks.isEmpty ? nil : profile.socialLinks,
                profileImageData: nil,
                removeProfileImage: false
            )
            await refreshProfile()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteListing(id: Int) async -> Bool {
        isDeletingListing = true
        errorMessage = nil
        defer { isDeletingListing = false }

        do {
            try await postService.deletePost(id: id)
            listings.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteSocialLink(id: Int) async -> Bool {
        do {
            try await userService.deleteSocialLink(id: id)
            profile.socialLinks.removeAll { $0.serverID == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteProfileImage() async -> Bool {
        do {
            try await userService.deleteProfileImage()
            profile.profileImageURL = nil
            profile.profileImageData = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func unblockUser(id: Int) async -> Bool {
        do {
            try await userService.unblockUser(userId: id)
            blockedUsers.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func requestAccountDeletion(reason: String) async -> Bool {
        isDeletingAccount = true
        errorMessage = nil
        defer { isDeletingAccount = false }

        do {
            try await userService.requestAccountDeletion(reason: reason)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func verifyAccountDeletion(otp: String) async -> Bool {
        isDeletingAccount = true
        errorMessage = nil
        defer { isDeletingAccount = false }

        do {
            try await userService.verifyAccountDeletion(otp: otp)
            TokenStorage.shared.clear()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
