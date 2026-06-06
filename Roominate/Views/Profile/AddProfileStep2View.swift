import SwiftUI

struct AddProfileStep2View: View {
    @ObservedObject var viewModel: AddProfileViewModel

    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        profileContainer(onBack: onBack) {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    RequiredLabel(title: Strings.Profile.areaCity)
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(AppTheme.textSecondary)
                        TextField(Strings.Profile.areaPlaceholder, text: $viewModel.draft.area)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(AppTheme.fieldBorder, lineWidth: 1)
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    RequiredLabel(title: Strings.Profile.birthYear)
                    Menu {
                        ForEach(viewModel.birthYears, id: \.self) { year in
                            Button(year) {
                                viewModel.draft.birthYear = year
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.draft.birthYear)
                                .font(.system(size: 16))
                                .foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(AppTheme.fieldBorder, lineWidth: 1)
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    RequiredLabel(title: Strings.Profile.profession)
                    HStack(spacing: 12) {
                        SelectionCard(
                            title: Strings.Profile.professionStudent,
                            systemImage: "graduationcap.fill",
                            isSelected: viewModel.draft.profession == .student
                        ) {
                            viewModel.draft.profession = .student
                        }
                        SelectionCard(
                            title: Strings.Profile.professionWorking,
                            systemImage: "briefcase.fill",
                            isSelected: viewModel.draft.profession == .working
                        ) {
                            viewModel.draft.profession = .working
                        }
                    }
                }

                PrimaryButton(
                    title: Strings.Profile.next,
                    isEnabled: viewModel.isStep2Valid
                ) {
                    onNext()
                }
            }
        }
    }
}
