import Foundation

final class TokenStorage {
    static let shared = TokenStorage()

    private let tokenKey = "roominate.auth.token"

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

    func clear() {
        token = nil
    }
}
