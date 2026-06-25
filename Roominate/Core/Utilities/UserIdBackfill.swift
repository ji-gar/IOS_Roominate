import Foundation

enum UserIdBackfill {
    @MainActor
    static func ensureStored(
        userService: UserServiceProtocol = UserService(),
        authService: AuthServiceProtocol = AuthService()
    ) async -> Int {
        let stored = TokenStorage.shared.userId
        if stored > 0 { return stored }

        if let profile = try? await userService.fetchProfile(),
           let id = profile.resolvedUserId, id > 0 {
            TokenStorage.shared.userId = id
            return id
        }

        if let user = try? await authService.fetchCurrentUser(),
           let idString = user.id,
           let id = Int(idString), id > 0 {
            TokenStorage.shared.userId = id
            return id
        }

        return 0
    }
}
