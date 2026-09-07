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
                    .lineLimit(4...8)
                    .font(.system(size: 16))
                    .appTextInputStyle()
                    .padding(16)
                    .frame(minHeight: 120, alignment: .topLeading)
                    .background(AppTheme.fieldBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(AppTheme.fieldBorder, lineWidth: 1)
                    )
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
        .dismissKeyboardOnTap()
    }
}
