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
    let fullname: String?
    let area: String?
    let birthyear: String?
    let profession: String?
    let gender: String?
    let about: String?
    let profilePic: String?
    let isVerified: Bool?

    var isProfileComplete: Bool {
        guard let fullname, !fullname.isEmpty else { return false }
        guard let area, !area.isEmpty else { return false }
        guard let about, !about.isEmpty else { return false }
        return true
    }
}

private struct UserEnvelope: Decodable {
    let data: UserResponse?
}

extension UserResponse {
    static func decode(from data: Data, using decoder: JSONDecoder) throws -> UserResponse {
        if let wrapped = try? decoder.decode(UserEnvelope.self, from: data), let user = wrapped.data {
            return user
        }
        return try decoder.decode(UserResponse.self, from: data)
    }
}

enum Gender: String, CaseIterable, Identifiable {
    case male = "MALE"
    case female = "FEMALE"
    case other = "OTHER"

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
    var birthYear: String = "2003"
    var profession: Profession?
    var about: String = ""
    var profileImageData: Data?
}
