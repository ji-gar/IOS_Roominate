import PhotosUI
import SwiftUI

/// Step 5 of onboarding – upload one of four accepted documents for admin
/// review. The user may skip this step and complete it later.
struct InstitutionVerificationView: View {

    @StateObject private var viewModel: InstitutionVerificationViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showSkipAlert = false

    let onBack: () -> Void
    let onSubmitted: () -> Void
    let onSkip: () -> Void

    init(
        email: String,
        onBack: @escaping () -> Void,
        onSubmitted: @escaping () -> Void,
        onSkip: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: InstitutionVerificationViewModel(email: email))
        self.onBack = onBack
        self.onSubmitted = onSubmitted
        self.onSkip = onSkip
    }

    var body: some View {
        ZStack {
            AuthBackgroundView()

            VStack(spacing: 0) {
                // Header row — back on left, skip on right
                HStack {
                    BackButton(action: onBack)
                    Spacer()
                    Button("Skip") {
                        showSkipAlert = true
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .frame(minHeight: 44)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        // Title
                        VStack(spacing: 8) {
                            Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                                .font(.system(size: 48))
                                .foregroundStyle(AppTheme.primaryBlue)
                                .padding(.top, 8)

                            Text(Strings.InstitutionVerification.title)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.primaryBlue)

                            Text(Strings.InstitutionVerification.subtitle)
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 4)

                        // Document type selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text(Strings.InstitutionVerification.selectDocType)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)

                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 12
                            ) {
                                ForEach(VerificationDocumentType.allCases) { docType in
                                    DocumentTypeCard(
                                        docType: docType,
                                        isSelected: viewModel.selectedDocumentType == docType
                                    ) {
                                        viewModel.selectedDocumentType = docType
                                    }
                                }
                            }
                        }

                        // Upload area
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            uploadArea
                        }
                        .onChange(of: selectedPhotoItem) { _, item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    viewModel.setImage(image)
                                }
                            }
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.errorRed)
                                .multilineTextAlignment(.center)
                        }

                        // Submit button
                        PrimaryButton(
                            title: viewModel.isLoading
                                ? Strings.InstitutionVerification.uploading
                                : Strings.InstitutionVerification.submit,
                            isEnabled: viewModel.isFormValid,
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                if await viewModel.submit() {
                                    onSubmitted()
                                }
                            }
                        }

                        // Inline skip link below submit
                        Button {
                            showSkipAlert = true
                        } label: {
                            Text("Skip for now")
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.textSecondary)
                                .underline()
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, AppTheme.horizontalPadding)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Skip Verification?", isPresented: $showSkipAlert) {
            Button("Skip", role: .destructive) { onSkip() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can upload your document later from your profile. Your account will have limited access until verified.")
        }
    }

    // MARK: - Upload area

    @ViewBuilder
    private var uploadArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    viewModel.selectedImageData != nil
                        ? AppTheme.primaryBlue
                        : AppTheme.fieldBorder,
                    style: StrokeStyle(
                        lineWidth: viewModel.selectedImageData != nil ? 1.5 : 1,
                        dash: [6]
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.fieldBackground)
                )
                .frame(height: 160)

            if let imageData = viewModel.selectedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white, AppTheme.primaryBlue)
                            .font(.system(size: 22))
                            .padding(8)
                    }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up.doc.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(AppTheme.primaryBlue)
                    Text(Strings.InstitutionVerification.tapToUpload)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.primaryBlue)
                    Text(Strings.InstitutionVerification.uploadPrompt)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

// MARK: - DocumentTypeCard

private struct DocumentTypeCard: View {
    let docType: VerificationDocumentType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: docType.systemImage)
                    .font(.system(size: 16))
                    .foregroundStyle(isSelected ? .white : AppTheme.primaryBlue)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(isSelected ? AppTheme.primaryBlue : AppTheme.primaryBlue.opacity(0.1))
                    )

                Text(docType.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? .white : AppTheme.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppTheme.primaryBlue : AppTheme.fieldBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? AppTheme.primaryBlue : AppTheme.fieldBorder,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    InstitutionVerificationView(
        email: "test@iima.ac.in",
        onBack: {},
        onSubmitted: {},
        onSkip: {}
    )
}
