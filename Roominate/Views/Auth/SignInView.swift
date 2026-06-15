import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @FocusState private var focusedField: Field?

    let onBack: () -> Void
    let onSignUp: () -> Void
    let onOTP: (String) -> Void
    let onAuthenticated: (Bool) -> Void

    private enum Field {
        case email
        case password
    }

    var body: some View {
        ZStack {
            AuthBackgroundView()

            VStack(spacing: 0) {
                AuthScreenHeader(onBack: onBack)

                VStack(spacing: 8) {
                    Text(Strings.SignIn.title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryBlue)

                    Text(Strings.SignIn.subtitle)
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.top, 32)

                Spacer()

                VStack(spacing: 16) {
                    AuthTextField(
                        placeholder: Strings.SignIn.emailPlaceholder,
                        text: $viewModel.email,
                        state: focusedField == .email ? .focused : .normal
                    )
                    .focused($focusedField, equals: .email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    AuthTextField(
                        placeholder: Strings.SignIn.passwordPlaceholder,
                        text: $viewModel.password,
                        isSecure: true,
                        state: focusedField == .password ? .focused : .normal
                    )
                    .focused($focusedField, equals: .password)

                    HStack {
                        Rectangle()
                            .fill(AppTheme.fieldBorder)
                            .frame(height: 1)
                        Text(Strings.SignIn.or)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(AppTheme.fieldBorder)
                            .frame(height: 1)
                    }

                    OutlineButton(title: Strings.SignIn.otpButton) {
                        guard EmailValidator.isValidIIMEmail(viewModel.email) else { return }
                        let normalizedEmail = viewModel.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        Task {
                            if await viewModel.sendOTPForLogin(email: normalizedEmail) {
                                onOTP(normalizedEmail)
                            }
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.errorRed)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, AppTheme.horizontalPadding)

                Spacer()

                VStack(spacing: 16) {
                    TextLinkButton(
                        prefix: Strings.SignIn.newUser,
                        linkText: Strings.SignIn.signUpLink,
                        action: onSignUp
                    )

                    PrimaryButton(
                        title: Strings.SignIn.button,
                        isEnabled: viewModel.isFormValid,
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            switch await viewModel.signIn() {
                            case .authenticatedComplete:
                                onAuthenticated(true)
                            case .authenticatedNeedsProfile:
                                onAuthenticated(false)
                            case .needsEmailVerification(let email):
                                if await viewModel.sendOTPForLogin(email: email) {
                                    onOTP(email)
                                }
                            case .failure:
                                break
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.bottom, 36)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    SignInView(onBack: {}, onSignUp: {}, onOTP: { _ in }, onAuthenticated: { _ in })
}
