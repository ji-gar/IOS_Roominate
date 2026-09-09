import SwiftUI

/// Step 4 of onboarding – collects name, institution, course and graduation year.
/// When the user's email domain auto-matches a known B-school the institution
/// field is pre-filled and locked; otherwise it's an editable picker.
struct InstitutionDetailsView: View {

    @StateObject private var viewModel: InstitutionDetailsViewModel
    @FocusState private var focusedField: Field?

    let onBack: () -> Void
    /// Called with `isAutoVerified` so the router can skip the upload step.
    let onContinue: (Bool) -> Void

    private enum Field: Hashable {
        case name, course
    }

    init(
        email: String,
        onBack: @escaping () -> Void,
        onContinue: @escaping (Bool) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: InstitutionDetailsViewModel(email: email))
        self.onBack = onBack
        self.onContinue = onContinue
    }

    var body: some View {
        ZStack {
            AuthBackgroundView()

            VStack(spacing: 0) {
                AuthScreenHeader(onBack: onBack)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Title
                        VStack(spacing: 8) {
                            Text(Strings.InstitutionDetails.title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.primaryBlue)

                            Text(Strings.InstitutionDetails.subtitle)
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        // Auto-verified banner
                        if viewModel.isAutoVerified {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                                    .font(.system(size: 18))
                                Text(Strings.InstitutionDetails.autoVerified)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.green.opacity(0.85))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.green.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // Full Name
                        fieldSection(label: Strings.InstitutionDetails.name) {
                            AuthTextField(
                                placeholder: Strings.InstitutionDetails.namePlaceholder,
                                text: $viewModel.fullName,
                                state: focusedField == .name ? .focused : .normal
                            )
                            .focused($focusedField, equals: .name)
                            .textContentType(.name)
                            .autocorrectionDisabled()
                        }

                        // Institution
                        fieldSection(label: Strings.InstitutionDetails.institution) {
                            institutionPicker
                        }

                        // Course
                        fieldSection(label: Strings.InstitutionDetails.course) {
                            AuthTextField(
                                placeholder: Strings.InstitutionDetails.coursePlaceholder,
                                text: $viewModel.course,
                                state: focusedField == .course ? .focused : .normal
                            )
                            .focused($focusedField, equals: .course)
                            .autocorrectionDisabled()
                        }

                        // Graduation Year
                        fieldSection(label: Strings.InstitutionDetails.graduationYear) {
                            graduationYearPicker
                        }

                        PrimaryButton(
                            title: Strings.InstitutionDetails.next,
                            isEnabled: viewModel.isFormValid
                        ) {
                            onContinue(viewModel.isAutoVerified)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, AppTheme.horizontalPadding)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var institutionPicker: some View {
        if viewModel.isAutoVerified, let name = viewModel.autoInstitutionName {
            // Locked display — institution confirmed via email domain
            HStack(spacing: 12) {
                Image(systemName: "building.columns.fill")
                    .foregroundStyle(AppTheme.primaryBlue)
                Text(name)
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(AppTheme.fieldBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(Color.green.opacity(0.4), lineWidth: 1)
            )
        } else {
            Menu {
                ForEach(BSchoolDomain.allInstitutions, id: \.self) { name in
                    Button(name) {
                        viewModel.selectedInstitution = name
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "building.columns")
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(
                        viewModel.selectedInstitution.isEmpty
                            ? Strings.InstitutionDetails.institutionPlaceholder
                            : viewModel.selectedInstitution
                    )
                    .font(.system(size: 16))
                    .foregroundStyle(
                        viewModel.selectedInstitution.isEmpty
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary
                    )
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(AppTheme.fieldBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppTheme.fieldBorder, lineWidth: 1)
                )
            }
        }
    }

    @ViewBuilder
    private var graduationYearPicker: some View {
        Menu {
            ForEach(viewModel.availableYears, id: \.self) { year in
                Button("\(year)") {
                    viewModel.graduationYear = year
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundStyle(AppTheme.textSecondary)
                Text(
                    viewModel.graduationYear.map { String($0) }
                    ?? Strings.InstitutionDetails.graduationYearPlaceholder
                )
                .font(.system(size: 16))
                .foregroundStyle(
                    viewModel.graduationYear == nil
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary
                )
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(AppTheme.fieldBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.fieldBorder, lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private func fieldSection<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RequiredLabel(title: label)
            content()
        }
    }
}

#Preview {
    InstitutionDetailsView(
        email: "pgp2024@iima.ac.in",
        onBack: {},
        onContinue: { _ in }
    )
}
