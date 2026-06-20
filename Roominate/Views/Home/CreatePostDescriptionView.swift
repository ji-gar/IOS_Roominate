import SwiftUI

struct CreatePostDescriptionView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    @FocusState private var isDescriptionFocused: Bool

    private let descriptionLimit = 500

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Text("Write a Short Description\nfor Roomy")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    // Title
                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Title")
                        TextField("Looking for a flexible roommate", text: $viewModel.draft.title)
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(.horizontal, 14)
                            .frame(height: 52)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        viewModel.draft.title.isEmpty
                                        ? AppTheme.fieldBorder
                                        : AppTheme.primaryBlue.opacity(0.5),
                                        lineWidth: 1
                                    )
                            )
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "How would you describe it?", isRequired: false)

                        ZStack(alignment: .topLeading) {
                            if viewModel.draft.description.isEmpty {
                                Text("Tell roommates about the place, the vibe, who you're looking for…")
                                    .font(.system(size: 15))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)
                            }

                            TextEditor(text: $viewModel.draft.description)
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textPrimary)
                                .focused($isDescriptionFocused)
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(minHeight: 160, alignment: .topLeading)
                                .onChange(of: viewModel.draft.description) { _, newValue in
                                    if newValue.count > descriptionLimit {
                                        viewModel.draft.description = String(newValue.prefix(descriptionLimit))
                                    }
                                }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isDescriptionFocused
                                    ? AppTheme.primaryBlue.opacity(0.5)
                                    : AppTheme.fieldBorder,
                                    lineWidth: 1
                                )
                        )

                        HStack {
                            Spacer()
                            Text("\(viewModel.draft.description.count)/\(descriptionLimit)")
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            CreatePostBottomBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                isNextEnabled: viewModel.isDescriptionValid,
                onBack: onBack,
                onNext: onNext
            )
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Create Post")
                            .font(.system(size: 16))
                    }
                    .foregroundStyle(AppTheme.primaryBlue)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if isDescriptionFocused {
                    Button("Done") { isDescriptionFocused = false }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryBlue)
                }
            }
        }
    }
}
