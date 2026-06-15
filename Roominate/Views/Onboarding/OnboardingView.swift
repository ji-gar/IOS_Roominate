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
                .padding(.horizontal, 24)

            Spacer().frame(height: 36)

            Text(Strings.Onboarding.title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.horizontalPadding)

            Spacer().frame(height: 14)

            Text(Strings.Onboarding.subtitle)
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, AppTheme.horizontalPadding)

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton(title: Strings.Onboarding.signUp, action: onSignUp)

                OutlineButton(title: Strings.Onboarding.signIn, action: onSignIn)
            }
            .padding(.horizontal, AppTheme.horizontalPadding)
            .padding(.bottom, 44)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingView(onSignUp: {}, onSignIn: {})
}
