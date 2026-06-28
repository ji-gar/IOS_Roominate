import SwiftUI

struct EditContactView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onBack: () -> Void
    let onSaved: () -> Void

    @State private var email: String = ""
    @State private var socialLinks: [SocialLinkDraft] = []

    private var isValid: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedEmail.contains("@") && trimmedEmail.contains(".")
    }

    var body: some View {
        profileEditContainer(title: Strings.Profile.contactAndPrivacy, onBack: onBack) {
            VStack(spacing: 24) {
                ProfileFormTextField(
                    title: Strings.Profile.email,
                    text: $email,
                    placeholder: Strings.SignIn.emailPlaceholder,
                    keyboardType: .emailAddress,
                    isRequired: true
                )

                if viewModel.profile.isEmailVerified {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.availableGreen)
                        Text(Strings.Profile.emailVerified)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.availableGreen)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(Strings.Profile.socialLinks)
                        .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)

                    ForEach($socialLinks) { $link in
                        socialLinkRow(link: $link)
                    }

                    Button {
                        socialLinks.append(SocialLinkDraft())
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text(Strings.Profile.addSocialLink)
                        }
                        .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .medium))
                        .foregroundStyle(AppTheme.primaryBlue)
                    }
                    .buttonStyle(.plain)
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
                        let saved = await viewModel.updateContact(
                            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                            socialLinks: socialLinks
                        )
                        if saved { onSaved() }
                    }
                }
            }
        }
        .onAppear {
            email = viewModel.profile.email
            socialLinks = viewModel.profile.socialLinks.isEmpty
                ? [SocialLinkDraft()]
                : viewModel.profile.socialLinks
        }
    }

    private func socialLinkRow(link: Binding<SocialLinkDraft>) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Menu {
                    ForEach(SocialLinkType.allCases) { type in
                        Button(type.displayName) {
                            link.wrappedValue.type = type
                        }
                    }
                } label: {
                    HStack {
                        Text(link.wrappedValue.type.displayName)
                            .font(.system(size: AppTheme.Profile.fieldInputSize))
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: AppTheme.Profile.fieldHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(AppTheme.fieldBorder, lineWidth: 1)
                    )
                }

                Button {
                    removeSocialLink(link.wrappedValue)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }

            TextField(Strings.Profile.socialLinkPlaceholder, text: link.link)
                .font(.system(size: AppTheme.Profile.fieldInputSize))
                .keyboardType(.URL)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .appTextInputStyle()
                .padding(.horizontal, 16)
                .frame(height: AppTheme.Profile.fieldHeight)
                .background(AppTheme.fieldBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppTheme.fieldBorder, lineWidth: 1)
                )
        }
    }

    private func removeSocialLink(_ link: SocialLinkDraft) {
        if let serverID = link.serverID {
            Task {
                if await viewModel.deleteSocialLink(id: serverID) {
                    socialLinks.removeAll { $0.serverID == serverID }
                }
            }
        } else {
            socialLinks.removeAll { $0.localID == link.localID }
        }
    }
}
