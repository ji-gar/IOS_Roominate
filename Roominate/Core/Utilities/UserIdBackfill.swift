import Foundation

enum UserIdBackfill {
    /// Returns the signed-in user's numeric id, fetching it from the backend
    /// when needed.
    ///
    /// `forceRefresh` should be used by surfaces where having a CORRECT user id
    /// is critical (e.g. chat — needed for sender-side bubble alignment), to
    /// avoid trusting a possibly stale/wrong value persisted by an older
    /// version of the app.
    @MainActor
    static func ensureStored(
        userService: UserServiceProtocol = UserService(),
        authService: AuthServiceProtocol = AuthService(),
        forceRefresh: Bool = false
    ) async -> Int {
        let stored = TokenStorage.shared.userId
        if !forceRefresh, stored > 0 { return stored }

        if let user = try? await authService.fetchCurrentUser(),
           let id = user.resolvedUserId, id > 0 {
            TokenStorage.shared.userId = id
            return id
        }

        if let profile = try? await userService.fetchProfile(),
           let id = profile.resolvedUserId, id > 0 {
            TokenStorage.shared.userId = id
            return id
        }

        return stored
    }
}
