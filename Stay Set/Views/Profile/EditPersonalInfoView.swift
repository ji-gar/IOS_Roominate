import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

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
    @State private var programCourse: String = ""
    @State private var graduationYear: Int?
    @State private var organizationName: String = ""
    @State private var position: String = ""
    @State private var documentType: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedDocumentItem: PhotosPickerItem?
    @State private var showRemovePhotoConfirm = false
    @State private var showRemoveDocumentConfirm = false
    @State private var showDocumentPicker = false

    private var birthYearOptions: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((1900...currentYear).reversed())
    }
    
    private var graduationYearOptions: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((1950...(currentYear + 10)).reversed())
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
                    
                    ProfileFormTextField(
                        title: "Program/Course",
                        text: $programCourse,
                        placeholder: "e.g. B.Tech Computer Engineering",
                        icon: "book"
                    )
                    
                    graduationYearField
                    
                    documentUploadSection
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
                        mode: .address,
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
                            programCourse: programCourse.trimmingCharacters(in: .whitespacesAndNewlines),
                            graduationYear: graduationYear,
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
        .onChange(of: selectedDocumentItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.setDocument(data, type: documentType)
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
        .confirmationDialog(
            "Remove Document",
            isPresented: $showRemoveDocumentConfirm,
            titleVisibility: .visible
        ) {
            Button("Remove Document", role: .destructive) {
                viewModel.removeDocument()
            }
        }
        .dismissKeyboardOnTap()
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
    
    private var graduationYearField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Graduation Year")
                .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)

            Menu {
                ForEach(graduationYearOptions, id: \.self) { year in
                    Button(String(year)) {
                        graduationYear = year
                    }
                }
            } label: {
                HStack {
                    Text(graduationYear.map(String.init) ?? "Select year")
                        .font(.system(size: AppTheme.Profile.fieldInputSize))
                        .foregroundStyle(
                            graduationYear == nil ? AppTheme.textSecondary : AppTheme.textPrimary
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
    
    private var documentUploadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Identity Document")
                .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("Upload Student ID or other proof (JPG, PNG, PDF - max 5MB)")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.textSecondary)
            
            ProfileFormTextField(
                title: "Document Type",
                text: $documentType,
                placeholder: "e.g. Student ID, ID Card",
                icon: "doc.text"
            )
            
            if viewModel.profile.documentURL != nil || viewModel.profile.documentData != nil {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundStyle(AppTheme.primaryBlue)
                    Text("Document uploaded")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Button("Remove") {
                        showRemoveDocumentConfirm = true
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.errorRed)
                }
                .padding(12)
                .background(Color(red: 0.95, green: 0.97, blue: 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            PhotosPicker(
                selection: $selectedDocumentItem,
                matching: .any(of: [.images, .item(conformingTo: .pdf)])
            ) {
                HStack {
                    Image(systemName: "doc.badge.plus")
                    Text(viewModel.profile.documentURL != nil || viewModel.profile.documentData != nil
                         ? "Replace Document" : "Upload Document")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.primaryBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(red: 0.95, green: 0.97, blue: 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 8))
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
        programCourse = profile.programCourse
        graduationYear = profile.graduationYear
        organizationName = profile.organizationName
        position = profile.position
        documentType = profile.documentType
    }
}
