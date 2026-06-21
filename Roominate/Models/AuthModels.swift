import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct SendOTPRequest: Encodable {
    let email: String
}

struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let passwordConfirmation: String

    enum CodingKeys: String, CodingKey {
        case name
        case email
        case password
        case passwordConfirmation = "password_confirmation"
    }
}

struct VerifyOTPRequest: Encodable {
    let email: String
    let otp: String
}

struct LoginWithOTPRequest: Encodable {
    let email: String
    let otp: String
}

struct SetPasswordRequest: Encodable {
    let password: String
    let passwordConfirmation: String

    enum CodingKeys: String, CodingKey {
        case password
        case passwordConfirmation = "password_confirmation"
    }
}

struct ResetPasswordRequest: Encodable {
    let email: String
    let token: String
    let password: String
    let passwordConfirmation: String

    enum CodingKeys: String, CodingKey {
        case email
        case token
        case password
        case passwordConfirmation = "password_confirmation"
    }
}

struct AuthResponse: Decodable {
    let success: Bool?
    let token: String?
    let accessToken: String?
    let message: String?
    let data: AuthData?

    struct AuthData: Decodable {
        let token: String?
        let accessToken: String?
        let userId: Int?
        let email: String?
    }

    var resolvedToken: String? {
        token ?? accessToken ?? data?.token ?? data?.accessToken
    }
}

struct UserResponse: Decodable {
    let id: String?
    let email: String?
    let name: String?
    let fullname: String?
    let area: String?
    let currentCity: String?
    let birthyear: String?
    let profession: String?
    let gender: String?
    let about: String?
    let profilePic: String?
    let isVerified: Bool?

    var isProfileComplete: Bool {
        ProfileResponse(
            id: nil,
            name: name ?? fullname,
            email: email,
            currentCity: currentCity ?? area,
            about: about,
            gender: gender,
            profession: profession,
            instituteName: nil,
            organizationName: nil,
            position: nil,
            birthYear: birthyear.flatMap(Int.init),
            profileImageUrl: profilePic,
            isVerified: isVerified,
            socialLinks: nil,
            lifestyleNotes: nil
        ).isComplete
    }
}

struct SocialLink: Decodable, Identifiable, Hashable {
    let id: Int?
    let type: String?
    let link: String?

    var resolvedType: SocialLinkType {
        SocialLinkType(rawValue: type?.lowercased() ?? "") ?? .other
    }
}

struct SocialLinkDraft: Identifiable, Hashable {
    let localID = UUID()
    var serverID: Int?
    var type: SocialLinkType
    var link: String

    var id: String {
        serverID.map(String.init) ?? localID.uuidString
    }

    init(serverID: Int? = nil, type: SocialLinkType = .linkedin, link: String = "") {
        self.serverID = serverID
        self.type = type
        self.link = link
    }
}

enum SocialLinkType: String, CaseIterable, Identifiable {
    case facebook
    case twitter
    case instagram
    case linkedin
    case github
    case youtube
    case tiktok
    case website
    case other

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var systemImage: String {
        switch self {
        case .facebook: return "f.square.fill"
        case .twitter: return "bird.fill"
        case .instagram: return "camera.fill"
        case .linkedin: return "link"
        case .github: return "chevron.left.forwardslash.chevron.right"
        case .youtube: return "play.rectangle.fill"
        case .tiktok: return "music.note"
        case .website: return "globe"
        case .other: return "link"
        }
    }
}

struct ProfileResponse: Decodable {
    let id: Int?
    let name: String?
    let email: String?
    let currentCity: String?
    let about: String?
    let gender: String?
    let profession: String?
    let instituteName: String?
    let organizationName: String?
    let position: String?
    let birthYear: Int?
    let profileImageUrl: String?
    let isVerified: Bool?
    let socialLinks: [SocialLink]?
    let lifestyleNotes: [String]?

    var resolvedProfileImageURL: String? {
        guard let profileImageUrl, !profileImageUrl.isEmpty else { return nil }
        if profileImageUrl.hasPrefix("http://") || profileImageUrl.hasPrefix("https://") {
            return profileImageUrl
        }
        return APIConstants.storageBaseURL + profileImageUrl
    }

    var resolvedGender: Gender? {
        guard let gender else { return nil }
        return Gender(rawValue: gender.lowercased())
    }

    var resolvedProfession: Profession? {
        guard let profession else { return nil }
        let normalized = profession.uppercased()
        if normalized.contains("STUDENT") { return .student }
        if normalized.contains("WORK") { return .working }
        return Profession(rawValue: normalized)
    }

    var age: Int? {
        guard let birthYear else { return nil }
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - birthYear
    }

    var isComplete: Bool {
        if let about, !about.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }

        let resolvedName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let resolvedCity = currentCity?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !resolvedName.isEmpty, !resolvedCity.isEmpty {
            return true
        }

        if id != nil, gender != nil || profession != nil {
            return true
        }

        return false
    }
}

private struct UserEnvelope: Decodable {
    let data: UserResponse?
}

private struct ProfileEnvelope: Decodable {
    let data: ProfileResponse?
}

extension UserResponse {
    static func decode(from data: Data, using decoder: JSONDecoder) throws -> UserResponse {
        if let wrapped = try? decoder.decode(UserEnvelope.self, from: data), let user = wrapped.data {
            return user
        }
        return try decoder.decode(UserResponse.self, from: data)
    }
}

extension ProfileResponse {
    static func decode(from data: Data, using decoder: JSONDecoder) throws -> ProfileResponse {
        if let wrapped = try? decoder.decode(ProfileEnvelope.self, from: data), let profile = wrapped.data {
            return profile
        }
        return try decoder.decode(ProfileResponse.self, from: data)
    }
}

enum Gender: String, CaseIterable, Identifiable {
    case male = "male"
    case female = "female"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .male: return Strings.Profile.genderMale
        case .female: return Strings.Profile.genderFemale
        case .other: return Strings.Profile.genderOther
        }
    }
}

enum Profession: String, CaseIterable, Identifiable {
    case student = "STUDENT"
    case working = "WORKER"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .student: return Strings.Profile.professionStudent
        case .working: return Strings.Profile.professionWorking
        }
    }
}

struct ProfileDraft {
    var fullName: String = ""
    var gender: Gender?
    var area: String = ""
    var profession: Profession?
    var organization: String = ""
    var about: String = ""
    var profileImageData: Data?
}

struct UserProfile {
    var name: String = ""
    var email: String = ""
    var gender: Gender?
    var birthYear: Int?
    var currentCity: String = ""
    var profession: Profession?
    var instituteName: String = ""
    var organizationName: String = ""
    var position: String = ""
    var about: String = ""
    var lifestyleNotes: [String] = []
    var profileImageURL: String?
    var profileImageData: Data?
    var isEmailVerified: Bool = false
    var socialLinks: [SocialLinkDraft] = []

    var age: Int? {
        guard let birthYear else { return nil }
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - birthYear
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first.map(String.init) }
        return letters.joined().uppercased()
    }

    var subtitle: String {
        var parts: [String] = []
        if let gender {
            parts.append(gender.displayName)
        }
        if let age {
            parts.append("\(age)")
        }
        return parts.joined(separator: ", ")
    }

    var profileHeaderSubtitle: String {
        let rolePart: String = {
            if !position.isEmpty { return position }
            if profession == .student, !instituteName.isEmpty { return instituteName }
            if profession == .working, !organizationName.isEmpty { return organizationName }
            return profession?.displayName ?? ""
        }()

        if let age, !rolePart.isEmpty {
            return "\(rolePart) \(age)"
        }
        if let age {
            return "\(age)"
        }
        return rolePart
    }

    var professionDisplay: String {
        if !position.isEmpty { return position }
        if profession == .student, !instituteName.isEmpty { return instituteName }
        if profession == .working, !organizationName.isEmpty { return organizationName }
        return profession?.displayName ?? ""
    }

    var linkedInLink: SocialLinkDraft? {
        socialLinks.first { $0.type == .linkedin && !$0.link.isEmpty }
    }

    var educationLabel: String {
        if profession == .student {
            return instituteName
        }
        return organizationName
    }

    static func from(profile: ProfileResponse, user: UserResponse?) -> UserProfile {
        let resolvedBirthYear: Int? = {
            if let birthYear = profile.birthYear { return birthYear }
            if let birthyear = user?.birthyear, let year = Int(birthyear) { return year }
            return nil
        }()

        let resolvedImageURL: String? = {
            if let url = profile.resolvedProfileImageURL { return url }
            guard let pic = user?.profilePic, !pic.isEmpty else { return nil }
            if pic.hasPrefix("http://") || pic.hasPrefix("https://") { return pic }
            return APIConstants.storageBaseURL + pic
        }()

        let socialLinks = (profile.socialLinks ?? []).map {
            SocialLinkDraft(
                serverID: $0.id,
                type: $0.resolvedType,
                link: $0.link ?? ""
            )
        }

        return UserProfile(
            name: profile.name ?? user?.name ?? user?.fullname ?? "",
            email: profile.email ?? user?.email ?? "",
            gender: profile.resolvedGender ?? user?.gender.flatMap { Gender(rawValue: $0.lowercased()) },
            birthYear: resolvedBirthYear,
            currentCity: profile.currentCity ?? user?.currentCity ?? user?.area ?? "",
            profession: profile.resolvedProfession ?? user?.profession.flatMap { profession in
                let normalized = profession.uppercased()
                if normalized.contains("STUDENT") { return .student }
                if normalized.contains("WORK") { return .working }
                return Profession(rawValue: normalized)
            },
            instituteName: profile.instituteName ?? "",
            organizationName: profile.organizationName ?? "",
            position: profile.position ?? "",
            about: profile.about ?? user?.about ?? "",
            lifestyleNotes: profile.lifestyleNotes ?? [],
            profileImageURL: resolvedImageURL,
            isEmailVerified: profile.isVerified ?? user?.isVerified ?? false,
            socialLinks: socialLinks
        )
    }
}
