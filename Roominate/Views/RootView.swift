import SwiftUI

struct RootView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var profileViewModel = AddProfileViewModel()
    @State private var showSplash = true
    @State private var isBootstrapping = true

    var body: some View {
        Group {
            if showSplash {
                SplashView {
                    showSplash = false
                }
            } else if isBootstrapping {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.ignoresSafeArea())
            } else {
                NavigationStack(path: $router.path) {
                    rootContent
                        .navigationDestination(for: AppRoute.self) { route in
                            destination(for: route)
                        }
                }
            }
        }
        .task {
            guard !showSplash else { return }
            await bootstrapSession()
        }
        .onChange(of: showSplash) { _, isShowing in
            if !isShowing {
                Task { await bootstrapSession() }
            }
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        switch router.rootRoute {
        case .onboarding:
            OnboardingView(
                onSignUp: { router.navigate(to: .signUp) },
                onSignIn: { router.navigate(to: .signIn) }
            )
        case .addProfileStep1:
            AddProfileStep1View(
                viewModel: profileViewModel,
                onBack: { router.resetToOnboarding() },
                onNext: { router.navigate(to: .addProfileStep2) }
            )
        case .home:
            HomeView(onSignOut: { router.resetToOnboarding() })
        default:
            OnboardingView(
                onSignUp: { router.navigate(to: .signUp) },
                onSignIn: { router.navigate(to: .signIn) }
            )
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .signUp:
            SignUpView(
                onBack: { router.pop() },
                onSignIn: { router.replaceLast(with: .signIn) },
                onSuccess: { email in
                    router.navigate(to: .signUpVerification(email: email))
                }
            )
        case .signIn:
            SignInView(
                onBack: { router.pop() },
                onSignUp: { router.replaceLast(with: .signUp) },
                onOTP: { email in
                    router.navigate(to: .signInOTP(email: email))
                },
                onAuthenticated: { isComplete in
                    router.popToRoot()
                    router.isAuthenticated = true
                    router.rootRoute = isComplete ? .home : .addProfileStep1
                }
            )
        case .signUpVerification(let email):
            OTPView(
                flowType: .signUpVerification,
                email: email,
                onBack: { router.pop() },
                onSuccess: { result in
                    switch result {
                    case .needsSetPassword:
                        router.navigate(to: .setPassword)
                    case .authenticatedComplete:
                        router.popToRoot()
                        router.isAuthenticated = true
                        router.rootRoute = .home
                    case .authenticatedNeedsProfile:
                        router.popToRoot()
                        router.isAuthenticated = true
                        router.rootRoute = .addProfileStep1
                    case .failure:
                        break
                    }
                }
            )
        case .signInOTP(let email):
            OTPView(
                flowType: .signIn,
                email: email,
                onBack: { router.pop() },
                onSuccess: { result in
                    switch result {
                    case .authenticatedComplete:
                        router.popToRoot()
                        router.isAuthenticated = true
                        router.rootRoute = .home
                    case .authenticatedNeedsProfile:
                        router.popToRoot()
                        router.isAuthenticated = true
                        router.rootRoute = .addProfileStep1
                    case .needsSetPassword, .failure:
                        break
                    }
                }
            )
        case .setPassword:
            SetPasswordView(
                onBack: { router.pop() },
                onSuccess: {
                    router.popToRoot()
                    router.isAuthenticated = true
                    router.rootRoute = .addProfileStep1
                }
            )
        case .addProfileStep2:
            AddProfileStep2View(
                viewModel: profileViewModel,
                onBack: { router.pop() },
                onNext: { router.navigate(to: .addProfileStep3) }
            )
        case .addProfileStep3:
            AddProfileStep3View(
                viewModel: profileViewModel,
                onBack: { router.pop() },
                onFinish: {
                    router.completeProfileSetup()
                }
            )
        default:
            EmptyView()
        }
    }

    private func bootstrapSession() async {
        isBootstrapping = true
        router.rootRoute = await router.checkSessionOnLaunch()
        isBootstrapping = false
    }
}

#Preview {
    RootView()
}
