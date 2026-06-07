import Combine
import Foundation

enum AppRoute: Hashable {
    case onboarding
    case signUp
    case signIn
    case signUpVerification(email: String)
    case signInOTP(email: String)
    case setPassword(email: String, otp: String?)
    case addProfileStep1
    case addProfileStep2
    case addProfileStep3
    case home
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var rootRoute: AppRoute = .onboarding
    @Published var profileDraft = ProfileDraft()
    @Published var isAuthenticated = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    func navigate(to route: AppRoute) {
        // #region agent log
        DebugLog.write(
            location: "AppRouter.swift:navigate",
            message: "Navigating to route",
            data: [
                "route": String(describing: route),
                "pathCountBefore": String(path.count)
            ],
            hypothesisId: "B"
        )
        // #endregion
        path.append(route)
        // #region agent log
        DebugLog.write(
            location: "AppRouter.swift:navigate",
            message: "Navigation path updated",
            data: ["pathCountAfter": String(path.count)],
            hypothesisId: "B"
        )
        // #endregion
    }

    func replaceLast(with route: AppRoute) {
        // #region agent log
        DebugLog.write(
            location: "AppRouter.swift:replaceLast",
            message: "Replacing last route",
            data: [
                "route": String(describing: route),
                "pathCountBefore": String(path.count)
            ],
            hypothesisId: "E"
        )
        // #endregion
        if path.isEmpty {
            path.append(route)
        } else {
            path[path.count - 1] = route
        }
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func resetToOnboarding() {
        TokenStorage.shared.clear()
        isAuthenticated = false
        profileDraft = ProfileDraft()
        path.removeAll()
        rootRoute = .onboarding
    }

    func checkSessionOnLaunch() async -> AppRoute {
        guard TokenStorage.shared.token != nil else {
            return .onboarding
        }

        do {
            isAuthenticated = true
            if try await authService.resolveProfileCompletion() {
                return .home
            }
            return .addProfileStep1
        } catch {
            TokenStorage.shared.clear()
            return .onboarding
        }
    }

    func completeAuthFlow() {
        isAuthenticated = true
        path.removeAll()
        rootRoute = .addProfileStep1
    }

    func completeProfileSetup() {
        path.removeAll()
        rootRoute = .home
    }
}
