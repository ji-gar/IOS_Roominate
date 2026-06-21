import SwiftUI

enum ProfileRoute: Hashable {
    case detail
    case editPersonalInfo
    case editContact
    case editAboutMe
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
                onOpenProfile: { path.append(.detail) }
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

    @State private var showDeleteConfirmation = false
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
                    VStack(spacing: 16) {
                        profileHeader
                        settingsMenu
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert(Strings.Profile.deleteAccountTitle, isPresented: $showDeleteConfirmation) {
            Button(Strings.Profile.deleteAccountConfirm, role: .destructive) {
                Task {
                    if await viewModel.deleteAccount() {
                        onAccountDeleted()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(Strings.Profile.deleteAccountMessage)
        }
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
        .overlay {
            if viewModel.isDeletingAccount {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
            }
        }
    }

    private var header: some View {
        HStack {
            Text(Strings.App.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.primaryBlue)
            Spacer()
            Image(systemName: "ellipsis.message")
                .font(.system(size: 19))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var profileHeader: some View {
        Button(action: onOpenProfile) {
            HStack(spacing: 14) {
                ProfileAvatarView(profile: viewModel.profile, size: 48, style: .settings)

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.profile.name.isEmpty ? Strings.Profile.guestUser : viewModel.profile.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    if !viewModel.profile.email.isEmpty {
                        Text(viewModel.profile.email)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var settingsMenu: some View {
        VStack(spacing: 0) {
            ProfileMenuSection(rows: [
                ProfileMenuItem(title: Strings.Profile.notification, systemImage: "bell", showsChevron: true),
                ProfileMenuItem(title: Strings.Profile.blockedUsers, systemImage: "nosign", showsChevron: true)
            ])

            ProfileMenuSectionDivider()

            ProfileMenuSection(rows: [
                ProfileMenuItem(title: Strings.Profile.aboutUs, systemImage: "info.circle"),
                ProfileMenuItem(title: Strings.Profile.contactUs, systemImage: "envelope"),
                ProfileMenuItem(title: Strings.Profile.reportProblem, systemImage: "exclamationmark.bubble")
            ])

            ProfileMenuSectionDivider()

            ProfileMenuSection(rows: [
                ProfileMenuItem(title: Strings.Profile.help, systemImage: "questionmark.circle", showsChevron: true),
                ProfileMenuItem(title: Strings.Profile.shareApp, systemImage: "square.and.arrow.up", action: { showShareSheet = true })
            ])

            ProfileMenuSectionDivider()

            ProfileMenuSection(rows: [
                ProfileMenuItem(title: Strings.Profile.logOut, systemImage: "rectangle.portrait.and.arrow.right", action: onSignOut),
                ProfileMenuItem(title: Strings.Profile.deleteAccount, systemImage: "trash", isDestructive: true, action: { showDeleteConfirmation = true })
            ])
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil && !viewModel.isDeletingAccount },
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
