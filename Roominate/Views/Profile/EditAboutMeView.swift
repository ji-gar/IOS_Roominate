import SwiftUI

struct EditAboutMeView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onBack: () -> Void
    let onSaved: () -> Void

    @State private var about: String = ""

    private var isValid: Bool {
        !about.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        profileEditContainer(title: Strings.Profile.aboutYou, onBack: onBack) {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    RequiredLabel(title: Strings.Profile.aboutYou)

                    TextField(
                        Strings.Profile.aboutPlaceholder,
                        text: $about,
                        axis: .vertical
                    )
                    .lineLimit(5...10)
                    .font(.system(size: AppTheme.Profile.fieldInputSize))
                    .appTextInputStyle()
                    .padding(16)
                    .frame(minHeight: 140, alignment: .topLeading)
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
                    title: Strings.Profile.update,
                    isEnabled: isValid,
                    isLoading: viewModel.isSaving
                ) {
                    Task {
                        let saved = await viewModel.updateAbout(
                            about.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        if saved { onSaved() }
                    }
                }
            }
        }
        .onAppear {
            about = viewModel.profile.about
        }
    }
}
