import SwiftUI

enum SavedRoute: Hashable {
    case flatDetail(FlatListing)
    case flatmateDetail(FlatmateListing)
    case chat(
        conversationId: Int,
        otherName: String,
        postId: Int? = nil,
        otherUserId: Int? = nil
    )
}

private struct ReportTarget: Identifiable {
    let id: Int
}

struct SavedTabView: View {
    @EnvironmentObject private var tabState: MainTabState
    @EnvironmentObject private var savedStore: SavedPostsStore
    @StateObject private var viewModel = SavedPostsViewModel()
    @StateObject private var startChatVM = StartChatViewModel()
    @State private var path: [SavedRoute] = []
    @State private var reportTarget: ReportTarget?

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 16) {
                        ListingSegmentedControl(selection: $viewModel.segment)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)

                        if let errorMessage = viewModel.errorMessage {
                            errorBanner(errorMessage)
                                .padding(.horizontal, 16)
                        }

                        if viewModel.isLoading && currentListingsEmpty {
                            loadingState
                        } else {
                            switch viewModel.segment {
                            case .flat:
                                flatList
                            case .flatmate:
                                flatmateList
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .background(AppTheme.screenBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: SavedRoute.self) { route in
                switch route {
                case .flatDetail(let listing):
                    FlatDetailView(listing: listing, onStartChat: { id, name, postId, otherUserId in
                        path.append(.chat(
                            conversationId: id,
                            otherName: name,
                            postId: postId,
                            otherUserId: otherUserId
                        ))
                    })
                case .flatmateDetail(let listing):
                    FlatmateDetailView(listing: listing, onStartChat: { id, name, postId, otherUserId in
                        path.append(.chat(
                            conversationId: id,
                            otherName: name,
                            postId: postId,
                            otherUserId: otherUserId
                        ))
                    })
                case .chat(let id, let name, let postId, let otherUserId):
                    ChatView(
                        conversationId: id,
                        otherName: name,
                        postId: postId,
                        otherUserId: otherUserId
                    )
                }
            }
            .task {
                await viewModel.load()
            }
            .onChange(of: tabState.savedRefreshID) { _, _ in
                Task { await viewModel.refresh() }
            }
            .onChange(of: savedStore.savedIDs) { _, _ in
                Task { await viewModel.refresh() }
            }
            .sheet(item: $reportTarget) { target in
                ReportPostSheet(postId: target.id)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Saved")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.primaryBlue)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var currentListingsEmpty: Bool {
        switch viewModel.segment {
        case .flat:
            return viewModel.flatListings.isEmpty
        case .flatmate:
            return viewModel.flatmateListings.isEmpty
        }
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading saved listings...")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 14))
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var flatList: some View {
        LazyVStack(spacing: 16) {
            if viewModel.flatListings.isEmpty && !viewModel.isLoading {
                emptyState
            }

            ForEach(viewModel.flatListings) { listing in
                Button {
                    path.append(.flatDetail(listing))
                } label: {
                    FlatCard(
                        listing: listing,
                        isFavorite: savedStore.isSaved(listing.id),
                        onToggleFavorite: { Task { await savedStore.toggleSave(postId: listing.id) } },
                        onReport: { reportTarget = ReportTarget(id: listing.id) }
                    )
                }
                .buttonStyle(.plain)
                .task {
                    await viewModel.loadMoreIfNeeded(currentItem: listing)
                }
            }

            if viewModel.isLoadingMore && viewModel.segment == .flat {
                ProgressView()
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 16)
    }

    private var flatmateList: some View {
        LazyVStack(spacing: 16) {
            if viewModel.flatmateListings.isEmpty && !viewModel.isLoading {
                emptyState
            }

            ForEach(viewModel.flatmateListings) { listing in
                Button {
                    path.append(.flatmateDetail(listing))
                } label: {
                    FlatmateCard(
                        listing: listing,
                        isFavorite: savedStore.isSaved(listing.id),
                        onSave: { Task { await savedStore.toggleSave(postId: listing.id) } },
                        onChat: {
                            Task {
                                await startChatVM.startChat(postId: listing.id, receiverName: listing.author.name) { id, name, postId, otherUserId in
                                    path.append(.chat(
                                        conversationId: id,
                                        otherName: name,
                                        postId: postId,
                                        otherUserId: otherUserId
                                    ))
                                }
                            }
                        },
                        onReport: { reportTarget = ReportTarget(id: listing.id) }
                    )
                }
                .buttonStyle(.plain)
                .task {
                    await viewModel.loadMoreIfNeeded(currentItem: listing)
                }
            }

            if viewModel.isLoadingMore && viewModel.segment == .flatmate {
                ProgressView()
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 16)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 28))
                .foregroundStyle(AppTheme.textSecondary)
            Text("No saved listings")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Tap the heart on any listing to save it here.")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .padding(.horizontal, 24)
    }
}

#Preview {
    SavedTabView()
        .environmentObject(MainTabState())
        .environmentObject(SavedPostsStore())
}
