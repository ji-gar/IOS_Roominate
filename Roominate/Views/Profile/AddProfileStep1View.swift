import PhotosUI
import SwiftUI

struct AddProfileStep1View: View {
    @ObservedObject var viewModel: AddProfileViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        profileContainer(onBack: onBack) {
            VStack(spacing: 28) {
                profilePhotoPicker

                VStack(alignment: .leading, spacing: 8) {
                    RequiredLabel(title: Strings.Profile.fullName)
                    TextField(Strings.Profile.fullNamePlaceholder, text: $viewModel.draft.fullName)
                        .font(.system(size: 16))
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(AppTheme.fieldBorder, lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 12) {
                    RequiredLabel(title: Strings.Profile.gender)
                    HStack(spacing: 12) {
                        SelectionCard(
                            title: Strings.Profile.genderMale,
                            systemImage: "person.fill",
                            isSelected: viewModel.draft.gender == .male
                        ) {
                            viewModel.draft.gender = .male
                        }
                        SelectionCard(
                            title: Strings.Profile.genderFemale,
                            systemImage: "person.fill",
                            isSelected: viewModel.draft.gender == .female
                        ) {
                            viewModel.draft.gender = .female
                        }
                        SelectionCard(
                            title: Strings.Profile.genderOther,
                            systemImage: "person.2.fill",
                            isSelected: viewModel.draft.gender == .other
                        ) {
                            viewModel.draft.gender = .other
                        }
                    }
                }

                PrimaryButton(
                    title: Strings.Profile.next,
                    isEnabled: viewModel.isStep1Valid
                ) {
                    onNext()
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.setProfileImage(image)
                }
            }
        }
    }

    private var profilePhotoPicker: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(red: 0.88, green: 0.93, blue: 0.98))
                    .frame(width: 120, height: 120)
                    .overlay {
                        if let data = viewModel.draft.profileImageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }

                Circle()
                    .fill(AppTheme.primaryBlue)
                    .frame(width: 32, height: 32)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
