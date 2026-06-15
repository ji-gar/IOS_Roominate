import SwiftUI

private let reportReasons: [String] = [
    "Inappropriate or abusive content",
    "Spam or misleading information",
    "Fake listing or scam",
    "Offensive photos or language",
    "Personal attack or harassment",
    "Promoting illegal activity",
    "Not relevant to Roominate",
    "Other"
]

private enum ReportStep: Equatable {
    case reasonPicker
    case descriptionInput(reason: String)
    case success
}

struct ReportPostSheet: View {
    let postId: Int

    @Environment(\.dismiss) private var dismiss
    @State private var step: ReportStep = .reasonPicker
    @State private var descriptionText = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private let service = PostService()

    var body: some View {
        Group {
            switch step {
            case .reasonPicker:
                reasonPickerView
            case .descriptionInput(let reason):
                descriptionInputView(reason: reason)
            case .success:
                successView
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(20)
    }

    // MARK: - Screen 1: Reason Picker

    private var reasonPickerView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("Why are you reporting Post?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.chipBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 14)

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(reportReasons, id: \.self) { reason in
                        Button {
                            descriptionText = ""
                            errorMessage = nil
                            withAnimation(.easeInOut(duration: 0.22)) {
                                step = .descriptionInput(reason: reason)
                            }
                        } label: {
                            HStack {
                                Text(reason)
                                    .font(.system(size: 15))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 17)
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .padding(.leading, 20)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Screen 2: Description Input

    private func descriptionInputView(reason: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    step = .reasonPicker
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(AppTheme.textPrimary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 22)

            VStack(alignment: .leading, spacing: 8) {
                Text("Please specify the reason for reporting.")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Your cooperation helps us maintain a safe and respectful community.")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 24)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.infoCardBorder, lineWidth: 1)
                    .frame(height: 120)

                TextEditor(text: $descriptionText)
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .frame(height: 120)

                if descriptionText.isEmpty {
                    Text("Describe the issue (optional)")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.7))
                        .padding(.top, 18)
                        .padding(.leading, 14)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 20)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.errorRed)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }

            Spacer()

            Button {
                Task { await submitReport(reason: reason) }
            } label: {
                ZStack {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Report")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isSubmitting ? AppTheme.primaryBlue.opacity(0.6) : AppTheme.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(isSubmitting)
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
    }

    // MARK: - Screen 3: Success

    private var successView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .strokeBorder(AppTheme.primaryBlue, lineWidth: 2.5)
                        .frame(width: 84, height: 84)
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryBlue)
                }

                VStack(spacing: 10) {
                    Text("We've received your report!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Your feedback helps us keep Roominate safe, respectful, and trustworthy for everyone.")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Back to Home")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.primaryBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
    }

    // MARK: - API

    private func submitReport(reason: String) async {
        isSubmitting = true
        errorMessage = nil
        // #region agent log
        DebugLog.write(
            location: "ReportPostSheet.swift:submitReport",
            message: "Submitting report",
            data: [
                "postId": String(postId),
                "reason": reason,
                "descriptionLength": String(descriptionText.count),
                "reasonIsEmpty": reason.isEmpty ? "true" : "false"
            ],
            hypothesisId: "H1"
        )
        // #endregion
        do {
            try await service.reportPost(postId: postId, reason: reason, description: descriptionText)
            // #region agent log
            DebugLog.write(
                location: "ReportPostSheet.swift:submitReport",
                message: "Report submitted successfully",
                data: ["postId": String(postId)],
                hypothesisId: "H5"
            )
            // #endregion
            withAnimation(.easeInOut(duration: 0.28)) {
                step = .success
            }
        } catch {
            // #region agent log
            DebugLog.write(
                location: "ReportPostSheet.swift:submitReport",
                message: "Report submission failed",
                data: [
                    "postId": String(postId),
                    "reason": reason,
                    "error": error.localizedDescription
                ],
                hypothesisId: "H1"
            )
            // #endregion
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}
