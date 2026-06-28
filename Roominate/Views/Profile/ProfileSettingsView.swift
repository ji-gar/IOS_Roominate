import SwiftUI

enum ProfileRoute: Hashable {
    case detail
    case editPersonalInfo
    case editContact
    case editAboutMe
    case myPosts
    case blockedUsers
    case aboutUs
    case deleteAccountReason
    case deleteAccountVerify(reason: String)
}

enum ProfilePostFlow: Identifiable {
    case add
    case edit(Post)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let post):
            return "edit-\(post.id)"
        }
    }

    var existingPost: Post? {
        switch self {
        case .add:
            return nil
        case .edit(let post):
            return post
        }
    }
}

struct ProfileTabView: View {
    let onSignOut: () -> Void

    @StateObject private var viewModel = ProfileViewModel()
    @State private var path: [ProfileRoute] = []
    @State private var postFlow: ProfilePostFlow?

    var body: some View {
        NavigationStack(path: $path) {
            ProfileSettingsView(
                viewModel: viewModel,
                onSignOut: onSignOut,
                onAccountDeleted: onSignOut,
                onOpenProfile: { path.append(.detail) },
                onOpenMyPosts: { path.append(.myPosts) },
                onOpenBlockedUsers: { path.append(.blockedUsers) },
                onOpenAboutUs: { path.append(.aboutUs) },
                onOpenDeleteAccount: { path.append(.deleteAccountReason) }
            )
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .detail:
                    ProfileDetailView(
                        viewModel: viewModel,
                        onBack: { path.removeLast() },
                        onEditPersonalInfo: { path.append(.editPersonalInfo) },
                        onEditContact: { path.append(.editContact) },
                        onEditAboutMe: { path.append(.editAboutMe) },
                        onAddPost: { postFlow = .add },
                        onEditListing: { post in postFlow = .edit(post) }
                    )
                case .myPosts:
                    MyPostsView(
                        viewModel: viewModel,
                        onBack: { path.removeLast() },
                        onAddPost: { postFlow = .add },
                        onEditListing: { post in postFlow = .edit(post) }
                    )
                case .blockedUsers:
                    BlockedUsersView(
                        viewModel: viewModel,
                        onBack: { path.removeLast() }
                    )
                case .aboutUs:
                    AboutUsView(onBack: { path.removeLast() })
                case .deleteAccountReason:
                    DeleteAccountReasonView(
                        viewModel: viewModel,
                        onBack: { path.removeLast() },
                        onContinue: { reason in path.append(.deleteAccountVerify(reason: reason)) }
                    )
                case .deleteAccountVerify(let reason):
                    DeleteAccountOTPView(
                        viewModel: viewModel,
                        reason: reason,
                        onBack: { path.removeLast() },
                        onAccountDeleted: onSignOut
                    )
                case .editPersonalInfo:
                    EditPersonalInfoView(
                        viewModel: viewModel,
                        onBack: { path.removeLast() },
                        onSaved: { path.removeLast() }
                    )
                case .editContact:
                    EditContactView(
                        viewModel: viewModel,
                        onBack: { path.removeLast() },
                        onSaved: { path.removeLast() }
                    )
                case .editAboutMe:
                    EditAboutMeView(
                        viewModel: viewModel,
                        onBack: { path.removeLast() },
                        onSaved: { path.removeLast() }
                    )
                }
            }
        }
        .task {
            await viewModel.loadProfile()
        }
        .fullScreenCover(item: $postFlow) { flow in
            CreatePostFlowView(
                existingPost: flow.existingPost,
                onDismiss: { postFlow = nil },
                onSuccess: {
                    postFlow = nil
                    Task { await viewModel.loadListings() }
                }
            )
        }
    }
}

struct ProfileSettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onSignOut: () -> Void
    let onAccountDeleted: () -> Void
    let onOpenProfile: () -> Void
    let onOpenMyPosts: () -> Void
    let onOpenBlockedUsers: () -> Void
    let onOpenAboutUs: () -> Void
    let onOpenDeleteAccount: () -> Void

    @State private var showShareSheet = false

    var body: some View {
        VStack(spacing: 0) {
            header

            if viewModel.isLoading && viewModel.profile.name.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        profileCard
                        if !viewModel.profile.about.isEmpty {
                            aboutCard
                        }
                        settingsMenu
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("Error", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? Strings.Error.generic)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [URL(string: "https://roominate.app") ?? Strings.App.name])
        }
    }

    private var header: some View {
        HStack {
            Text(Strings.App.name)
                .font(.system(size: AppTheme.Profile.sectionTitleSize + 5, weight: .bold))
                .foregroundStyle(AppTheme.primaryBlue)
            Spacer()
            Image(systemName: "ellipsis.message")
                .font(.system(size: 19))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var profileCard: some View {
        Button(action: onOpenProfile) {
            HStack(spacing: 14) {
                ProfileAvatarView(profile: viewModel.profile, size: 62, style: .standard)

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.profile.name.isEmpty ? Strings.Profile.guestUser : viewModel.profile.name)
                        .font(.system(size: AppTheme.Profile.cardTitleSize, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    if !viewModel.profile.professionDisplay.isEmpty {
                        Text(viewModel.profile.professionDisplay)
                            .font(.system(size: AppTheme.Profile.detailLabelSize))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }

                    let detailLine = profileDetailLine
                    if !detailLine.isEmpty {
                        Text(detailLine)
                            .font(.system(size: AppTheme.Profile.detailLabelSize))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var profileDetailLine: String {
        var parts: [String] = []
        if !viewModel.profile.currentCity.isEmpty {
            parts.append(viewModel.profile.currentCity)
        }
        if let age = viewModel.profile.age {
            parts.append("\(age) yrs")
        }
        if let gender = viewModel.profile.gender {
            parts.append(gender.displayName)
        }
        return parts.joined(separator: " · ")
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Strings.Profile.aboutCardTitle)
                .font(.system(size: AppTheme.Profile.detailLabelSize, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
            Text(viewModel.profile.about)
                .font(.system(size: AppTheme.Profile.detailValueSize))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var settingsMenu: some View {
        VStack(spacing: 0) {
            ProfileMenuSection(rows: [
                ProfileMenuItem(title: Strings.Profile.myPosts, systemImage: "house", showsChevron: true, action: onOpenMyPosts),
                ProfileMenuItem(title: Strings.Profile.notification, systemImage: "bell", showsChevron: true),
                ProfileMenuItem(title: Strings.Profile.blockedUsers, systemImage: "nosign", showsChevron: true, action: onOpenBlockedUsers)
            ])

            ProfileMenuSectionDivider()

            ProfileMenuSection(rows: [
                ProfileMenuItem(title: Strings.Profile.aboutUs, systemImage: "info.circle", showsChevron: true, action: onOpenAboutUs),
                ProfileMenuItem(title: Strings.Profile.contactUs, systemImage: "envelope", showsChevron: true),
                ProfileMenuItem(title: Strings.Profile.reportProblem, systemImage: "exclamationmark.bubble", showsChevron: true)
            ])

            ProfileMenuSectionDivider()

            ProfileMenuSection(rows: [
                ProfileMenuItem(title: Strings.Profile.help, systemImage: "questionmark.circle", showsChevron: true),
                ProfileMenuItem(title: Strings.Profile.shareApp, systemImage: "square.and.arrow.up", showsChevron: true, action: { showShareSheet = true })
            ])

            ProfileMenuSectionDivider()

            ProfileMenuSection(rows: [
                ProfileMenuItem(title: Strings.Profile.logOut, systemImage: "rectangle.portrait.and.arrow.right", showsChevron: true, action: onSignOut)
            ])

            ProfileMenuSectionDivider()

            ProfileMenuSection(rows: [
                ProfileMenuItem(title: Strings.Profile.deleteAccount, systemImage: "trash", isDestructive: true, action: onOpenDeleteAccount)
            ])
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
