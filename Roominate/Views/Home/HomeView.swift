import SwiftUI

enum HomeRoute: Hashable {
    case flatDetail(FlatListing)
    case flatmateDetail(FlatmateListing)
    case chat(
        conversationId: Int,
        otherName: String,
        postId: Int? = nil,
        otherUserId: Int? = nil
    )
    case chatList
}

private struct ReportTarget: Identifiable {
    let id: Int
}

struct HomeView: View {
    @EnvironmentObject private var tabState: MainTabState
    @EnvironmentObject private var savedStore: SavedPostsStore
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var startChatVM = StartChatViewModel()
    @State private var path: [HomeRoute] = []
    @State private var showFilters = false
    @State private var reportTarget: ReportTarget?

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                feed
            }
            .background(AppTheme.screenBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: HomeRoute.self) { route in
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
                case .chatList:
                    ChatListView(
                        showsBackButton: true,
                        onBack: { if !path.isEmpty { path.removeLast() } },
                        onSelectConversation: { id, name, postId, otherUserId in
                            path.append(.chat(
                                conversationId: id,
                                otherName: name,
                                postId: postId,
                                otherUserId: otherUserId
                            ))
                        }
                    )
                }
            }
            .task {
                await viewModel.loadPosts()
            }
            .onChange(of: tabState.homeRefreshID) { _, _ in
                Task { await viewModel.refreshPosts() }
            }
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.onSearchTextChanged()
            }
            .sheet(isPresented: $showFilters) {
                FilterView(
                    filters: viewModel.filters,
                    matchCountProvider: { await viewModel.matchCount(for: $0) },
                    onApply: { viewModel.applyFilters($0) }
                )
            }
            .sheet(item: $reportTarget) { target in
                ReportPostSheet(postId: target.id)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(Strings.App.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.primaryBlue)
            Spacer()
            Button {
                path.append(.chatList)
            } label: {
                Image(systemName: "ellipsis.message")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textSecondary)
                TextField("Search City / area", text: $viewModel.searchText)
                    .font(.system(size: 15))
                    .appTextInputStyle()
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.infoCardBorder, lineWidth: 1)
            )

            Button {
                showFilters = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(width: 46, height: 46)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.infoCardBorder, lineWidth: 1)
                        )

                    if viewModel.filters.activeCount > 0 {
                        Text("\(viewModel.filters.activeCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 18, minHeight: 18)
                            .background(AppTheme.primaryBlue)
                            .clipShape(Circle())
                            .offset(x: 6, y: -6)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var feed: some View {
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
            await viewModel.refreshPosts()
        }
    }

    private var currentListingsEmpty: Bool {
        switch viewModel.segment {
        case .flat:
            return viewModel.filteredFlats.isEmpty
        case .flatmate:
            return viewModel.filteredFlatmates.isEmpty
        }
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading listings...")
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
            if viewModel.filteredFlats.isEmpty && !viewModel.isLoading {
                emptyStateContent
            }

            ForEach(viewModel.filteredFlats) { listing in
                NavigationLink(value: HomeRoute.flatDetail(listing)) {
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
            if viewModel.filteredFlatmates.isEmpty && !viewModel.isLoading {
                emptyStateContent
            }

            ForEach(viewModel.filteredFlatmates) { listing in
                NavigationLink(value: HomeRoute.flatmateDetail(listing)) {
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

    private var hasActiveSearchOrFilters: Bool {
        !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || viewModel.filters.activeCount > 0
    }

    @ViewBuilder
    private var emptyStateContent: some View {
        if hasActiveSearchOrFilters {
            filteredEmptyState
        } else {
            HomeEmptyStateView(
                segment: viewModel.segment,
                onAddPost: { tabState.openAddTab() }
            )
        }
    }

    private var filteredEmptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28))
                .foregroundStyle(AppTheme.textSecondary)
            Text("No listings found")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Try adjusting your city search or filters.")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

#Preview {
    HomeView()
        .environmentObject(MainTabState())
        .environmentObject(SavedPostsStore())
}
