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
                AuthScreenHeader(onBack: onBack)

                VStack(spacing: 8) {
                    Text(Strings.SignUp.title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryBlue)

                    Text(Strings.SignUp.subtitle)
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.top, 32)

                Spacer()

                VStack(spacing: 16) {
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
                        prefix: Strings.SignUp.alreadyHaveAccount,
                        linkText: Strings.SignUp.signInLink,
                        action: onSignIn
                    )

                    PrimaryButton(
                        title: Strings.SignUp.button,
                        isEnabled: viewModel.isFormValid,
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            if let normalizedEmail = await viewModel.signUp() {
                                onSuccess(normalizedEmail)
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
