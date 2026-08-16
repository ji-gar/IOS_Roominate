import SwiftUI

/// Shown after the user submits a verification document — the admin review
/// step. Users can tap "I'll come back later" to proceed to profile setup.
struct VerificationPendingView: View {

    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                // Animated pending badge
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryBlue.opacity(0.08))
                        .frame(width: 120, height: 120)

                    Image(systemName: "clock.badge.checkmark.fill")
                        .font(.system(size: 54))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(AppTheme.primaryBlue)
                }

                VStack(spacing: 12) {
                    Text(Strings.VerificationPending.title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(Strings.VerificationPending.subtitle)
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                }

                // Info card
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.primaryBlue)
                        .padding(.top, 2)

                    Text(Strings.VerificationPending.note)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(AppTheme.primaryBlue.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Progress steps
                pendingStepsView
            }
            .padding(.horizontal, AppTheme.horizontalPadding)

            Spacer()

            PrimaryButton(
                title: Strings.VerificationPending.continueButton,
                isEnabled: true
            ) {
                onContinue()
            }
            .padding(.horizontal, AppTheme.horizontalPadding)
            .padding(.bottom, 44)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Steps visual

    private var pendingStepsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            pendingStep(icon: "envelope.open.fill",
                        title: "Email Verified",
                        state: .done)
            pendingStep(icon: "doc.badge.arrow.up.fill",
                        title: "Document Submitted",
                        state: .done)
            pendingStep(icon: "person.badge.clock.fill",
                        title: "Admin Review",
                        state: .inProgress)
            pendingStep(icon: "checkmark.seal.fill",
                        title: "Institution Verified",
                        state: .pending)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private enum StepState { case done, inProgress, pending }

    @ViewBuilder
    private func pendingStep(icon: String, title: String, state: StepState) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(stepColor(state).opacity(0.15))
                    .frame(width: 34, height: 34)

                Image(systemName: state == .done ? "checkmark" : icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(stepColor(state))
            }

            Text(title)
                .font(.system(size: 14, weight: state == .inProgress ? .semibold : .regular))
                .foregroundStyle(state == .pending ? AppTheme.textSecondary : AppTheme.textPrimary)

            Spacer()

            if state == .inProgress {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(AppTheme.primaryBlue)
            } else if state == .done {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }

    private func stepColor(_ state: StepState) -> Color {
        switch state {
        case .done:       return .green
        case .inProgress: return AppTheme.primaryBlue
        case .pending:    return AppTheme.textSecondary
        }
    }
}

#Preview {
    VerificationPendingView(onContinue: {})
}
