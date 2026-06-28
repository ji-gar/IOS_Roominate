import SwiftUI

struct BlockedUsersView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onBack: () -> Void

    @State private var searchText = ""

    private var filteredUsers: [BlockedUser] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return viewModel.blockedUsers }
        return viewModel.blockedUsers.filter { $0.name.lowercased().contains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            DetailNavBar(title: Strings.Profile.blockedUsers, onBack: onBack) {
                Color.clear.frame(width: 44, height: 44)
            }

            searchBar
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)

            if viewModel.isLoadingBlockedUsers && viewModel.blockedUsers.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if filteredUsers.isEmpty {
                Spacer()
                Text(
                    searchText.isEmpty
                        ? Strings.Profile.noBlockedUsers
                        : Strings.Profile.noSearchResults
                )
                .font(.system(size: AppTheme.Profile.cardSubtitleSize))
                .foregroundStyle(AppTheme.textSecondary)
                Spacer()
            } else {
                List {
                    ForEach(filteredUsers) { user in
                        blockedUserRow(user)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.visible)
                            .listRowBackground(Color.white)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await viewModel.loadBlockedUsers()
        }
        .alert("Error", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? Strings.Error.generic)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: AppTheme.Profile.fieldInputSize))
                .foregroundStyle(AppTheme.textSecondary)

            TextField(Strings.Profile.searchPerson, text: $searchText)
                .font(.system(size: AppTheme.Profile.fieldInputSize))
                .autocorrectionDisabled()
                .appTextInputStyle()
        }
        .padding(.horizontal, 14)
        .frame(height: AppTheme.Profile.fieldHeight)
        .background(Color.white)
        .overlay(
            Capsule()
                .stroke(AppTheme.fieldBorder, lineWidth: 1)
        )
        .clipShape(Capsule())
    }

    private func blockedUserRow(_ user: BlockedUser) -> some View {
        HStack(spacing: 14) {
            blockedUserAvatar(user)

            Text(user.name)
                .font(.system(size: AppTheme.Profile.cardTitleSize, weight: .regular))
                .foregroundStyle(AppTheme.textPrimary)

            Spacer(minLength: 8)

            Button(Strings.Profile.unblock) {
                Task { _ = await viewModel.unblockUser(id: user.id) }
            }
            .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .regular))
            .foregroundStyle(AppTheme.textPrimary)
            .buttonStyle(.plain)
        }
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func blockedUserAvatar(_ user: BlockedUser) -> some View {
        if let url = user.profileImageURL {
            AvatarView(urlString: url, size: 44, fallbackInitials: user.initials, style: .standard)
        } else {
            Circle()
                .fill(Color(red: 0.88, green: 0.93, blue: 0.98))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(user.initials.prefix(1))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppTheme.primaryBlue)
                }
        }
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
