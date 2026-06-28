import Foundation

struct BlockedUser: Identifiable, Hashable {
    let id: Int
    let name: String
    let profileImageURL: String?

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first.map(String.init) }
        return letters.joined().uppercased()
    }
}

struct BlockedUserResponse: Decodable {
    let id: Int?
    let userId: Int?
    let name: String?
    let fullname: String?
    let profileImageUrl: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case fullname
        case profileImageUrl = "profile_image_url"
        case profileImage = "profile_image"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeFlexibleIntIfPresent(forKey: .id)
        userId = try container.decodeFlexibleIntIfPresent(forKey: .userId)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        fullname = try container.decodeIfPresent(String.self, forKey: .fullname)
        profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
            ?? profileImage
    }

    var resolvedID: Int? {
        if let userId, userId > 0 { return userId }
        if let id, id > 0 { return id }
        return nil
    }

    var resolvedName: String {
        let trimmedName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmedName.isEmpty { return trimmedName }
        return fullname?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "User"
    }

    var resolvedProfileImageURL: String? {
        if let path = profileImageUrl, !path.isEmpty {
            return APIConstants.resolveMediaURL(path)
        }
        if let path = profileImage, !path.isEmpty {
            return APIConstants.resolveMediaURL(path)
        }
        return nil
    }

    func toBlockedUser() -> BlockedUser? {
        guard let resolvedID else { return nil }
        return BlockedUser(
            id: resolvedID,
            name: resolvedName,
            profileImageURL: resolvedProfileImageURL
        )
    }
}

private struct BlockedUsersEnvelope: Decodable {
    let data: [BlockedUserResponse]?
}

extension BlockedUser {
    static func decodeList(from data: Data, using decoder: JSONDecoder) throws -> [BlockedUser] {
        if let wrapped = try? decoder.decode(BlockedUsersEnvelope.self, from: data),
           let users = wrapped.data {
            return users.compactMap { $0.toBlockedUser() }
        }
        if let users = try? decoder.decode([BlockedUserResponse].self, from: data) {
            return users.compactMap { $0.toBlockedUser() }
        }
        if let user = try? decoder.decode(BlockedUserResponse.self, from: data),
           let blocked = user.toBlockedUser() {
            return [blocked]
        }
        return []
    }
}

struct DeleteAccountRequest: Encodable {
    let reason: String
}

struct DeleteAccountVerifyRequest: Encodable {
    let otp: String
}
