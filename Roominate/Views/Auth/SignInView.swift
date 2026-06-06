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
                HStack {
                    BackButton(action: onBack)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text(Strings.SignIn.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(AppTheme.primaryBlue)

                            Text(Strings.SignIn.subtitle)
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

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
                        }

                        Text(Strings.SignIn.or)
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)

                        OutlineButton(title: Strings.SignIn.otpButton) {
                            guard EmailValidator.isValidIIMEmail(viewModel.email) else { return }
                            let normalizedEmail = viewModel.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                            Task {
                                if await viewModel.sendOTPForLogin(email: normalizedEmail) {
                                    onOTP(normalizedEmail)
                                }
                            }
                        }

                        TextLinkButton(
                            prefix: Strings.SignIn.newUser,
                            linkText: Strings.SignIn.signUpLink,
                            action: {
                                // #region agent log
                                DebugLog.write(
                                    location: "SignInView.swift:onSignUp",
                                    message: "Sign Up link tapped",
                                    hypothesisId: "E"
                                )
                                // #endregion
                                onSignUp()
                            }
                        )

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.errorRed)
                                .multilineTextAlignment(.center)
                        }

                        PrimaryButton(
                            title: Strings.SignIn.button,
                            isEnabled: viewModel.isFormValid,
                            isLoading: viewModel.isLoading
                        ) {
                            // #region agent log
                            DebugLog.write(
                                location: "SignInView.swift:signInButton",
                                message: "Sign In button tapped",
                                data: [
                                    "isFormValid": String(viewModel.isFormValid),
                                    "isLoading": String(viewModel.isLoading)
                                ],
                                hypothesisId: "C"
                            )
                            // #endregion
                            Task {
                                switch await viewModel.signIn() {
                                case .authenticatedComplete:
                                    onAuthenticated(true)
                                case .authenticatedNeedsProfile:
                                    onAuthenticated(false)
                                case .failure:
                                    break
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.horizontalPadding)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    SignInView(onBack: {}, onSignUp: {}, onOTP: { _ in }, onAuthenticated: { _ in })
}
