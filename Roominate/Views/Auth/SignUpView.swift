import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @FocusState private var isEmailFocused: Bool

    let onBack: () -> Void
    let onSignIn: () -> Void
    let onSuccess: (String) -> Void

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
                            Text(Strings.SignUp.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(AppTheme.primaryBlue)

                            Text(Strings.SignUp.subtitle)
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        AuthTextField(
                            placeholder: Strings.SignUp.emailPlaceholder,
                            text: $viewModel.email,
                            state: mapFieldState(viewModel.emailFieldState)
                        )
                        .focused($isEmailFocused)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.email) { _, _ in
                            viewModel.validateEmail()
                        }

                        TextLinkButton(
                            prefix: Strings.SignUp.alreadyHaveAccount,
                            linkText: Strings.SignUp.signInLink,
                            action: {
                                // #region agent log
                                DebugLog.write(
                                    location: "SignUpView.swift:onSignIn",
                                    message: "Sign In link tapped",
                                    hypothesisId: "E"
                                )
                                // #endregion
                                onSignIn()
                            }
                        )

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.errorRed)
                                .multilineTextAlignment(.center)
                        }

                        PrimaryButton(
                            title: Strings.SignUp.button,
                            isEnabled: viewModel.isFormValid,
                            isLoading: viewModel.isLoading
                        ) {
                            // #region agent log
                            DebugLog.write(
                                location: "SignUpView.swift:signUpButton",
                                message: "Sign Up button tapped",
                                data: [
                                    "isFormValid": String(viewModel.isFormValid),
                                    "isLoading": String(viewModel.isLoading)
                                ],
                                hypothesisId: "C"
                            )
                            // #endregion
                            Task {
                                if await viewModel.signUp() {
                                    onSuccess(viewModel.email)
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

    private func mapFieldState(_ state: SignUpViewModel.EmailFieldState) -> AuthTextField.FieldState {
        switch state {
        case .normal: return .normal
        case .focused: return .focused
        case .error(let message): return .error(message)
        }
    }
}

#Preview {
    SignUpView(onBack: {}, onSignIn: {}, onSuccess: { _ in })
}
