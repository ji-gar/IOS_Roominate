import SwiftUI

enum DeleteAccountReason: String, CaseIterable, Identifiable {
    case dataPrivacy = "I'm worried about my data privacy."
    case tooManyNotifications = "I receive too many notifications."
    case negativeExperience = "I haven't had positive experience."
    case switchingPlatform = "I'm switching to another platform."
    case securityConcern = "I'm concerned about the security of my account"
    case contentExpectations = "The content doesn't meet my expectations."
    case hardToNavigate = "The platform is hard to navigate."
    case missingFeatures = "The platform doesn't have the feature I need."
    case tooMuchTime = "Using the platform takes up too much time."
    case other = "Other"

    var id: String { rawValue }
}

struct DeleteAccountReasonView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onBack: () -> Void
    let onContinue: (String) -> Void

    @State private var selectedReason: DeleteAccountReason?

    var body: some View {
        VStack(spacing: 0) {
            DetailNavBar(title: Strings.Profile.deleteAccount, onBack: onBack) {
                Color.clear.frame(width: 44, height: 44)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(Strings.Profile.deleteAccountReasonPrompt)
                        .font(.system(size: AppTheme.Profile.fieldInputSize))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 0) {
                        ForEach(Array(DeleteAccountReason.allCases.enumerated()), id: \.element.id) { index, reason in
                            if index > 0 {
                                Divider()
                            }
                            reasonRow(reason)
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)

            footerButtons
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .overlay {
            if viewModel.isDeletingAccount {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
            }
        }
        .alert("Error", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? Strings.Error.generic)
        }
    }

    private func reasonRow(_ reason: DeleteAccountReason) -> some View {
        Button {
            selectedReason = reason
        } label: {
            HStack(spacing: 12) {
                Image(systemName: selectedReason == reason ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundStyle(selectedReason == reason ? AppTheme.primaryBlue : AppTheme.textSecondary)

                Text(reason.rawValue)
                    .font(.system(size: AppTheme.Profile.fieldInputSize))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var footerButtons: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Text(Strings.Profile.cancel)
                    .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppTheme.buttonHeight)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(AppTheme.fieldBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Button {
                guard let selectedReason else { return }
                Task {
                    if await viewModel.requestAccountDeletion(reason: selectedReason.rawValue) {
                        onContinue(selectedReason.rawValue)
                    }
                }
            } label: {
                Text(Strings.Profile.deleteAccountConfirm)
                    .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppTheme.buttonHeight)
                    .background(selectedReason == nil ? AppTheme.disabledButton : AppTheme.errorRed)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            }
            .buttonStyle(.plain)
            .disabled(selectedReason == nil || viewModel.isDeletingAccount)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil && !viewModel.isDeletingAccount },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}

struct DeleteAccountOTPView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let reason: String
    let onBack: () -> Void
    let onAccountDeleted: () -> Void

    @State private var code = ""
    @State private var remainingSeconds = 34
    @State private var timerTask: Task<Void, Never>?

    private let codeLength = 4

    private var canResend: Bool { remainingSeconds <= 0 }
    private var isComplete: Bool { code.count == codeLength }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton(action: onBack)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text(Strings.OTP.enterCodeTitle)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(Strings.Profile.deleteAccountOTPSent)
                        .font(.system(size: AppTheme.Profile.cardSubtitleSize))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 32)

                OTPInputView(code: code, length: codeLength)
                    .padding(.top, 8)

                Group {
                    if canResend {
                        Button(Strings.OTP.resendAction) {
                            Task {
                                _ = await viewModel.requestAccountDeletion(reason: reason)
                                restartTimer()
                            }
                        }
                        .foregroundStyle(AppTheme.primaryBlue)
                        .fontWeight(.semibold)
                    } else {
                        Text("\(Strings.OTP.resendPrefix) \(formattedTimer)")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .font(.system(size: AppTheme.Profile.cardSubtitleSize))

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: AppTheme.Profile.detailLabelSize))
                        .foregroundStyle(AppTheme.errorRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.horizontalPadding)
                }

                Button {
                    Task {
                        if await viewModel.verifyAccountDeletion(otp: code) {
                            onAccountDeleted()
                        }
                    }
                } label: {
                    ZStack {
                        if viewModel.isDeletingAccount {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(Strings.Profile.verifyAndDelete)
                                .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppTheme.buttonHeight)
                    .background(isComplete ? AppTheme.errorRed : AppTheme.disabledButton)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                }
                .buttonStyle(.plain)
                .disabled(!isComplete || viewModel.isDeletingAccount)
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.top, 8)

                Spacer()
            }

            NumericKeypad(
                onDigit: appendDigit,
                onDelete: deleteDigit
            )
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timerTask?.cancel()
        }
    }

    private var formattedTimer: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func appendDigit(_ digit: String) {
        guard code.count < codeLength else { return }
        code.append(digit)
    }

    private func deleteDigit() {
        guard !code.isEmpty else { return }
        code.removeLast()
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while remainingSeconds > 0, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                remainingSeconds -= 1
            }
        }
    }

    private func restartTimer() {
        remainingSeconds = 34
        startTimer()
    }
}
