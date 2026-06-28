import SwiftUI

struct AddProfileStep2View: View {
    @ObservedObject var viewModel: AddProfileViewModel

    let onBack: () -> Void
    let onNext: () -> Void

    private var organizationPlaceholder: String {
        viewModel.draft.profession == .student
            ? Strings.Profile.institutePlaceholder
            : Strings.Profile.organizationPlaceholder
    }

    var body: some View {
        profileContainer(onBack: onBack) {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    RequiredLabel(title: Strings.Profile.areaCity)
                    PlacesSearchTextField(
                        selectedText: $viewModel.draft.area,
                        placeholder: Strings.Profile.areaPlaceholder
                    )
                }
                .zIndex(1)

                VStack(alignment: .leading, spacing: 12) {
                    RequiredLabel(title: Strings.Profile.profession)
                    HStack(spacing: 12) {
                        SelectionCard(
                            title: Strings.Profile.professionStudent,
                            systemImage: "graduationcap.fill",
                            isSelected: viewModel.draft.profession == .student
                        ) {
                            viewModel.draft.profession = .student
                            viewModel.draft.organization = ""
                        }
                        SelectionCard(
                            title: Strings.Profile.professionWorking,
                            systemImage: "briefcase.fill",
                            isSelected: viewModel.draft.profession == .working
                        ) {
                            viewModel.draft.profession = .working
                            viewModel.draft.organization = ""
                        }
                    }
                }

                if viewModel.draft.profession != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        RequiredLabel(
                            title: viewModel.draft.profession == .student
                                ? Strings.Profile.instituteLabel
                                : Strings.Profile.organizationLabel
                        )
                        HStack(spacing: 10) {
                            Image(systemName: viewModel.draft.profession == .student ? "building.columns" : "building.2")
                                .font(.system(size: 16))
                                .foregroundStyle(AppTheme.textSecondary)
                            TextField(organizationPlaceholder, text: $viewModel.draft.organization)
                                .font(.system(size: 16))
                                .autocorrectionDisabled()
                                .appTextInputStyle()
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(AppTheme.fieldBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(AppTheme.fieldBorder, lineWidth: 1)
                        )
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                PrimaryButton(
                    title: Strings.Profile.next,
                    isEnabled: viewModel.isStep2Valid
                ) {
                    onNext()
                }
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.draft.profession)
        }
    }
}
