import PhotosUI
import SwiftUI

struct EditPersonalInfoView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onBack: () -> Void
    let onSaved: () -> Void

    @State private var name: String = ""
    @State private var selectedGender: Gender?
    @State private var birthYear: Int?
    @State private var currentCity: String = ""
    @State private var profession: Profession?
    @State private var instituteName: String = ""
    @State private var organizationName: String = ""
    @State private var position: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showRemovePhotoConfirm = false

    private var birthYearOptions: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((1900...currentYear).reversed())
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedGender != nil
            && !currentCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && profession != nil
    }

    var body: some View {
        profileEditContainer(title: Strings.Profile.basicInformation, onBack: onBack) {
            VStack(spacing: 24) {
                profilePhotoSection

                ProfileFormTextField(
                    title: Strings.Profile.fullName,
                    text: $name,
                    placeholder: Strings.Profile.fullNamePlaceholder,
                    isRequired: true
                )

                birthYearField

                VStack(alignment: .leading, spacing: 12) {
                    RequiredLabel(title: Strings.Profile.gender)
                    HStack(spacing: 12) {
                        ForEach(Gender.allCases) { gender in
                            SelectionCard(
                                title: gender.displayName,
                                systemImage: gender == .male ? "figure.stand" : gender == .female ? "figure.stand.dress" : "person.2.fill",
                                isSelected: selectedGender == gender
                            ) {
                                selectedGender = gender
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    RequiredLabel(title: Strings.Profile.profession)
                    HStack(spacing: 12) {
                        SelectionCard(
                            title: Strings.Profile.professionStudent,
                            systemImage: "graduationcap.fill",
                            isSelected: profession == .student
                        ) {
                            profession = .student
                        }
                        SelectionCard(
                            title: Strings.Profile.professionWorking,
                            systemImage: "briefcase.fill",
                            isSelected: profession == .working
                        ) {
                            profession = .working
                        }
                    }
                }

                if profession == .student {
                    ProfileFormTextField(
                        title: Strings.Profile.instituteLabel,
                        text: $instituteName,
                        placeholder: Strings.Profile.institutePlaceholder,
                        icon: "building.columns",
                        isRequired: true
                    )
                } else if profession == .working {
                    ProfileFormTextField(
                        title: Strings.Profile.organizationLabel,
                        text: $organizationName,
                        placeholder: Strings.Profile.organizationPlaceholder,
                        icon: "building.2",
                        isRequired: true
                    )
                    ProfileFormTextField(
                        title: Strings.Profile.position,
                        text: $position,
                        placeholder: Strings.Profile.positionPlaceholder,
                        icon: "briefcase"
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    RequiredLabel(title: Strings.Profile.areaCity)
                    PlacesSearchTextField(
                        selectedText: $currentCity,
                        placeholder: Strings.Profile.areaPlaceholder
                    )
                }
                .zIndex(1)

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
                        let saved = await viewModel.updatePersonalInfo(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            gender: selectedGender,
                            birthYear: birthYear,
                            currentCity: currentCity.trimmingCharacters(in: .whitespacesAndNewlines),
                            profession: profession,
                            instituteName: instituteName.trimmingCharacters(in: .whitespacesAndNewlines),
                            organizationName: organizationName.trimmingCharacters(in: .whitespacesAndNewlines),
                            position: position.trimmingCharacters(in: .whitespacesAndNewlines),
                            removeImage: false
                        )
                        if saved { onSaved() }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.25), value: profession)
        }
        .onAppear(perform: populateFields)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.setProfileImage(image)
                }
            }
        }
        .confirmationDialog(
            Strings.Profile.removePhotoTitle,
            isPresented: $showRemovePhotoConfirm,
            titleVisibility: .visible
        ) {
            Button(Strings.Profile.removePhoto, role: .destructive) {
                Task {
                    _ = await viewModel.deleteProfileImage()
                    viewModel.removeProfileImage()
                }
            }
        }
    }

    private var profilePhotoSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    ProfileAvatarView(profile: viewModel.profile, size: 100)
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

            if viewModel.profile.profileImageURL != nil || viewModel.profile.profileImageData != nil {
                Button(Strings.Profile.removePhoto) {
                    showRemovePhotoConfirm = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.errorRed)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var birthYearField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.Profile.birthYear)
                .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)

            Menu {
                ForEach(birthYearOptions, id: \.self) { year in
                    Button(String(year)) {
                        birthYear = year
                    }
                }
            } label: {
                HStack {
                    Text(birthYear.map(String.init) ?? Strings.Profile.birthYearPlaceholder)
                        .font(.system(size: AppTheme.Profile.fieldInputSize))
                        .foregroundStyle(
                            birthYear == nil ? AppTheme.textSecondary : AppTheme.textPrimary
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.horizontal, 16)
                .frame(height: AppTheme.Profile.fieldHeight)
                .background(AppTheme.fieldBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppTheme.fieldBorder, lineWidth: 1)
                )
            }
        }
    }

    private func populateFields() {
        let profile = viewModel.profile
        name = profile.name
        selectedGender = profile.gender
        birthYear = profile.birthYear
        currentCity = profile.currentCity
        profession = profile.profession
        instituteName = profile.instituteName
        organizationName = profile.organizationName
        position = profile.position
    }
}
