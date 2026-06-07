import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct SendOTPRequest: Encodable {
    let email: String
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
            currentCity: currentCity ?? area,
            about: about,
            gender: gender,
            profession: profession,
            organizationName: nil,
            profileImageUrl: profilePic
        ).isComplete
    }
}

struct ProfileResponse: Decodable {
    let id: Int?
    let name: String?
    let currentCity: String?
    let about: String?
    let gender: String?
    let profession: String?
    let organizationName: String?
    let profileImageUrl: String?

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
