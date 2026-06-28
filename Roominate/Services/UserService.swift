import Foundation

protocol UserServiceProtocol {
    func fetchProfile() async throws -> ProfileResponse
    func updateProfile(_ draft: ProfileDraft) async throws -> UserResponse
    func updateProfile(
        name: String?,
        gender: Gender?,
        birthYear: Int?,
        currentCity: String?,
        profession: Profession?,
        instituteName: String?,
        organizationName: String?,
        position: String?,
        about: String?,
        email: String?,
        socialLinks: [SocialLinkDraft]?,
        profileImageData: Data?,
        removeProfileImage: Bool
    ) async throws -> ProfileResponse
    func deleteProfileImage() async throws
    func deleteSocialLink(id: Int) async throws
    func fetchBlockedUsers() async throws -> [BlockedUser]
    func blockUser(userId: Int) async throws
    func unblockUser(userId: Int) async throws
    func requestAccountDeletion(reason: String) async throws
    func verifyAccountDeletion(otp: String) async throws
}

final class UserService: UserServiceProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchProfile() async throws -> ProfileResponse {
        let data = try await client.requestData(
            path: APIConstants.User.profile,
            method: .get,
            requiresAuth: true
        )
        return try ProfileResponse.decode(from: data, using: client.decoder)
    }

    func updateProfile(_ draft: ProfileDraft) async throws -> UserResponse {
        let profile = try await updateProfile(
            name: draft.fullName,
            gender: draft.gender,
            birthYear: nil,
            currentCity: draft.area,
            profession: draft.profession,
            instituteName: draft.profession == .student ? draft.organization : nil,
            organizationName: draft.profession == .working ? draft.organization : nil,
            position: nil,
            about: draft.about,
            email: nil,
            socialLinks: nil,
            profileImageData: draft.profileImageData,
            removeProfileImage: false
        )
        return UserResponse(
            id: profile.id.map(String.init),
            email: profile.email,
            name: profile.name,
            fullname: profile.name,
            area: profile.currentCity,
            currentCity: profile.currentCity,
            birthyear: profile.birthYear.map(String.init),
            profession: profile.profession,
            gender: profile.gender,
            about: profile.about,
            profilePic: profile.profileImageUrl,
            isVerified: profile.isVerified
        )
    }

    func updateProfile(
        name: String?,
        gender: Gender?,
        birthYear: Int?,
        currentCity: String?,
        profession: Profession?,
        instituteName: String?,
        organizationName: String?,
        position: String?,
        about: String?,
        email: String?,
        socialLinks: [SocialLinkDraft]?,
        profileImageData: Data?,
        removeProfileImage: Bool
    ) async throws -> ProfileResponse {
        var fields: [MultipartFormData.Field] = []

        if let name {
            fields.append(.init(name: "name", value: name))
        }
        if let gender {
            fields.append(.init(name: "gender", value: gender.rawValue))
        }
        if let birthYear {
            fields.append(.init(name: "birth_year", value: String(birthYear)))
        }
        if let currentCity {
            fields.append(.init(name: "current_city", value: currentCity))
        }
        if let profession {
            fields.append(.init(name: "profession", value: profession.rawValue))
        }
        if let instituteName {
            fields.append(.init(name: "institute_name", value: instituteName))
        }
        if let organizationName {
            fields.append(.init(name: "organization_name", value: organizationName))
        }
        if let position {
            fields.append(.init(name: "position", value: position))
        }
        if let about {
            fields.append(.init(name: "about", value: about))
        }
        if let email {
            fields.append(.init(name: "email", value: email))
        }

        if let socialLinks {
            for (index, link) in socialLinks.enumerated() {
                let trimmedLink = link.link.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedLink.isEmpty else { continue }
                fields.append(.init(name: "social_links[\(index)][type]", value: link.type.rawValue))
                fields.append(.init(name: "social_links[\(index)][link]", value: trimmedLink))
            }
        }

        var files: [MultipartFormData.FileField] = []
        if let imageData = profileImageData {
            files.append(
                .init(
                    name: "profile_image",
                    filename: "profile.jpg",
                    mimeType: "image/jpeg",
                    data: imageData
                )
            )
        }

        let data = try await client.requestData(
            path: APIConstants.User.profile,
            method: .post,
            multipart: MultipartFormData(fields: fields, files: files),
            requiresAuth: true
        )

        if removeProfileImage {
            try await deleteProfileImage()
        }

        return try ProfileResponse.decode(from: data, using: client.decoder)
    }

    func deleteProfileImage() async throws {
        _ = try await client.requestData(
            path: APIConstants.User.profileImage,
            method: .delete,
            requiresAuth: true
        )
    }

    func deleteSocialLink(id: Int) async throws {
        _ = try await client.requestData(
            path: APIConstants.User.socialLink(id: id),
            method: .delete,
            requiresAuth: true
        )
    }

    func fetchBlockedUsers() async throws -> [BlockedUser] {
        let data = try await client.requestData(
            path: APIConstants.User.blockedUsers,
            method: .get,
            requiresAuth: true
        )
        return try BlockedUser.decodeList(from: data, using: client.decoder)
    }

    func blockUser(userId: Int) async throws {
        _ = try await client.requestData(
            path: APIConstants.User.block(userId: userId),
            method: .post,
            requiresAuth: true
        )
    }

    func unblockUser(userId: Int) async throws {
        _ = try await client.requestData(
            path: APIConstants.User.block(userId: userId),
            method: .delete,
            requiresAuth: true
        )
    }

    func requestAccountDeletion(reason: String) async throws {
        _ = try await client.requestData(
            path: APIConstants.Account.deleteRequest,
            method: .post,
            body: DeleteAccountRequest(reason: reason),
            requiresAuth: true
        )
    }

    func verifyAccountDeletion(otp: String) async throws {
        _ = try await client.requestData(
            path: APIConstants.Account.deleteVerify,
            method: .post,
            body: DeleteAccountVerifyRequest(otp: otp),
            requiresAuth: true
        )
    }
}
