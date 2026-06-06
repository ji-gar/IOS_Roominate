import SwiftUI

struct SetPasswordView: View {
    @StateObject private var viewModel = SetPasswordViewModel()
    @FocusState private var focusedField: Field?

    let onBack: () -> Void
    let onSuccess: () -> Void

    private enum Field {
        case password
        case confirmPassword
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
                            Text(Strings.SetPassword.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(AppTheme.primaryBlue)

                            Text(Strings.SetPassword.subtitle)
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 16) {
                            AuthTextField(
                                placeholder: Strings.SetPassword.passwordPlaceholder,
                                text: $viewModel.password,
                                isSecure: true,
                                state: focusedField == .password ? .focused : .normal
                            )
                            .focused($focusedField, equals: .password)

                            AuthTextField(
                                placeholder: Strings.SetPassword.confirmPasswordPlaceholder,
                                text: $viewModel.confirmPassword,
                                isSecure: true,
                                state: mapConfirmFieldState()
                            )
                            .focused($focusedField, equals: .confirmPassword)
                            .onChange(of: viewModel.confirmPassword) { _, _ in
                                viewModel.validateConfirmPassword()
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(Strings.SetPassword.requirementsTitle)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)

                            HStack(spacing: 6) {
                                Circle()
                                    .fill(viewModel.password.count >= 8 ? Color.green : AppTheme.textSecondary)
                                    .frame(width: 6, height: 6)
                                Text(Strings.SetPassword.requirementLength)
                                    .font(.system(size: 13))
                                    .foregroundStyle(viewModel.password.count >= 8 ? Color.green : AppTheme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.errorRed)
                                .multilineTextAlignment(.center)
                        }

                        PrimaryButton(
                            title: Strings.SetPassword.button,
                            isEnabled: viewModel.isFormValid,
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                if await viewModel.setPassword() {
                                    onSuccess()
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

    private func mapConfirmFieldState() -> AuthTextField.FieldState {
        if let error = viewModel.confirmPasswordError {
            return .error(error)
        }
        return focusedField == .confirmPassword ? .focused : .normal
    }
}

#Preview {
    SetPasswordView(onBack: {}, onSuccess: {})
}
