import Foundation

protocol UserServiceProtocol {
    func updateProfile(_ draft: ProfileDraft) async throws -> UserResponse
}

final class UserService: UserServiceProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func updateProfile(_ draft: ProfileDraft) async throws -> UserResponse {
        var fields: [MultipartFormData.Field] = [
            .init(name: "name", value: draft.fullName),
            .init(name: "fullname", value: draft.fullName),
            .init(name: "current_city", value: draft.area),
            .init(name: "area", value: draft.area),
            .init(name: "about", value: draft.about)
        ]

        if !draft.organization.isEmpty {
            fields.append(.init(name: "organization_name", value: draft.organization))
            fields.append(.init(name: "organization", value: draft.organization))
        }

        if let gender = draft.gender {
            fields.append(.init(name: "gender", value: gender.rawValue))
        }

        if let profession = draft.profession {
            fields.append(.init(name: "profession", value: profession.rawValue))
        }

        var files: [MultipartFormData.FileField] = []
        if let imageData = draft.profileImageData {
            files.append(
                .init(
                    name: "profilePic",
                    filename: "profile.jpg",
                    mimeType: "image/jpeg",
                    data: imageData
                )
            )
        }

        return try await client.request(
            path: APIConstants.User.profile,
            method: .post,
            multipart: MultipartFormData(fields: fields, files: files),
            requiresAuth: true
        )
    }
}
