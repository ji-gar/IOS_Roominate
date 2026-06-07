import SwiftUI

struct OTPView: View {
    @StateObject private var viewModel: OTPViewModel

    let onBack: () -> Void
    let onSuccess: (OTPViewModel.OTPResult) -> Void

    init(
        flowType: OTPFlowType,
        email: String,
        onBack: @escaping () -> Void,
        onSuccess: @escaping (OTPViewModel.OTPResult) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: OTPViewModel(flowType: flowType, email: email)
        )
        self.onBack = onBack
        self.onSuccess = onSuccess
    }

    var body: some View {
        VStack(spacing: 0) {
            AuthScreenHeader(onBack: onBack)

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text(viewModel.flowType.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(viewModel.flowType.subtitle)
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 32)

                OTPInputView(code: viewModel.code, length: 4)
                    .padding(.top, 8)

                Group {
                    if viewModel.canResend {
                        Button(Strings.OTP.resendAction) {
                            Task { await viewModel.resendCode() }
                        }
                        .foregroundStyle(AppTheme.primaryBlue)
                        .fontWeight(.semibold)
                    } else {
                        Text("\(Strings.OTP.resendPrefix) \(viewModel.formattedTimer)")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .font(.system(size: 14))

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.errorRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.horizontalPadding)
                }

                PrimaryButton(
                    title: viewModel.flowType.actionTitle,
                    isEnabled: viewModel.isComplete,
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        let result = await viewModel.verify()
                        if result != .failure {
                            onSuccess(result)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.top, 8)

                Spacer()
            }

            NumericKeypad(
                onDigit: viewModel.appendDigit,
                onDelete: viewModel.deleteDigit
            )
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

#Preview {
    OTPView(
        flowType: .signUpVerification,
        email: "test@iim.com",
        onBack: {},
        onSuccess: { _ in }
    )
}
