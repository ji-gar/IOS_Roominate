import Foundation

final class TokenStorage {
    static let shared = TokenStorage()

    private let tokenKey = "roominate.auth.token"
    private let userIdKey = "roominate.auth.userId"

    private init() {}

    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    var userId: Int {
        get { UserDefaults.standard.integer(forKey: userIdKey) }
        set { UserDefaults.standard.set(newValue, forKey: userIdKey) }
    }

    func clear() {
        token = nil
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}
