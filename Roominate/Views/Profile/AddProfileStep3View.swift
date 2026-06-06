import SwiftUI

struct AddProfileStep3View: View {
    @ObservedObject var viewModel: AddProfileViewModel

    let onBack: () -> Void
    let onFinish: () -> Void

    var body: some View {
        profileContainer(onBack: onBack) {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    RequiredLabel(title: Strings.Profile.aboutYou)

                    TextField(
                        Strings.Profile.aboutPlaceholder,
                        text: $viewModel.draft.about,
                        axis: .vertical
                    )
                    .lineLimit(4...6)
                    .font(.system(size: 16))
                    .padding(16)
                    .frame(minHeight: 120, alignment: .topLeading)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(AppTheme.fieldBorder, lineWidth: 1)
                    )

                    HStack {
                        Spacer()
                        Text("\(viewModel.aboutCharacterCount)/100")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.errorRed)
                        .multilineTextAlignment(.center)
                }

                PrimaryButton(
                    title: Strings.Profile.finish,
                    isEnabled: viewModel.isStep3Valid,
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        if await viewModel.submitProfile() {
                            onFinish()
                        }
                    }
                }
            }
        }
        .onChange(of: viewModel.draft.about) { _, newValue in
            if newValue.count > 100 {
                viewModel.draft.about = String(newValue.prefix(100))
            }
        }
    }
}
