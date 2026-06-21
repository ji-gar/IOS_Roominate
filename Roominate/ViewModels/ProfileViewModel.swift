import Combine
import Foundation
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile = UserProfile()
    @Published var listings: [UserListing] = []
    @Published var isLoading = false
    @Published var isLoadingListings = false
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

    @discardableResult
    func loadListings() async -> Bool {
        isLoadingListings = true
        defer { isLoadingListings = false }

        do {
            let response = try await postService.fetchPosts(
                mode: .all,
                query: PostQuery(perPage: 50, page: 1)
            )
            listings = response.data.map(UserListing.init)
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
            let response = try await userService.updateProfile(
                name: name,
                gender: gender,
                birthYear: birthYear,
                currentCity: currentCity,
                profession: profession,
                instituteName: profession == .student ? instituteName : nil,
                organizationName: profession == .working ? organizationName : nil,
                position: position.isEmpty ? nil : position,
                about: nil,
                email: nil,
                socialLinks: nil,
                profileImageData: profile.profileImageData,
                removeProfileImage: removeImage
            )
            profile = UserProfile.from(profile: response, user: nil)
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
            let response = try await userService.updateProfile(
                name: nil,
                gender: nil,
                birthYear: nil,
                currentCity: nil,
                profession: nil,
                instituteName: nil,
                organizationName: nil,
                position: nil,
                about: nil,
                email: email,
                socialLinks: socialLinks,
                profileImageData: nil,
                removeProfileImage: false
            )
            profile = UserProfile.from(profile: response, user: nil)
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
            let response = try await userService.updateProfile(
                name: nil,
                gender: nil,
                birthYear: nil,
                currentCity: nil,
                profession: nil,
                instituteName: nil,
                organizationName: nil,
                position: nil,
                about: about,
                email: nil,
                socialLinks: nil,
                profileImageData: nil,
                removeProfileImage: false
            )
            profile = UserProfile.from(profile: response, user: nil)
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

    func deleteAccount() async -> Bool {
        isDeletingAccount = true
        errorMessage = nil
        defer { isDeletingAccount = false }

        do {
            try await userService.deleteAccount()
            TokenStorage.shared.clear()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
