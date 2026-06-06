import SwiftUI

struct OnboardingView: View {
    let onSignUp: () -> Void
    let onSignIn: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("OnboardingIllustration")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 32)

            Spacer().frame(height: 32)

            Text(Strings.Onboarding.title)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.horizontalPadding)

            Spacer().frame(height: 16)

            Text(Strings.Onboarding.subtitle)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, AppTheme.horizontalPadding)

            Spacer()

            HStack(spacing: 16) {
                PrimaryButton(title: Strings.Onboarding.signUp) {
                    // #region agent log
                    DebugLog.write(
                        location: "OnboardingView.swift:signUp",
                        message: "Onboarding Sign Up tapped",
                        hypothesisId: "A"
                    )
                    // #endregion
                    onSignUp()
                }
                Button(action: {
                    // #region agent log
                    DebugLog.write(
                        location: "OnboardingView.swift:signIn",
                        message: "Onboarding Sign In tapped",
                        hypothesisId: "A"
                    )
                    // #endregion
                    onSignIn()
                }) {
                    Text(Strings.Onboarding.signIn)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.buttonHeight)
                }
            }
            .padding(.horizontal, AppTheme.horizontalPadding)
            .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingView(onSignUp: {}, onSignIn: {})
}
