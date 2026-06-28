import Combine
import SwiftUI

@MainActor
final class SavedPostsViewModel: ObservableObject {
    @Published var segment: ListingSegment = .flat
    @Published private(set) var flatListings: [FlatListing] = []
    @Published private(set) var flatmateListings: [FlatmateListing] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published var errorMessage: String?

    private let savedPostsService: SavedPostsServiceProtocol
    private let userService: UserServiceProtocol
    private var cachedCurrentUser: PostUser?
    private var currentPage = 1
    private var lastPage = 1

    init(
        savedPostsService: SavedPostsServiceProtocol = SavedPostsService(),
        userService: UserServiceProtocol = UserService()
    ) {
        self.savedPostsService = savedPostsService
        self.userService = userService
    }

    var hasMore: Bool {
        currentPage < lastPage
    }

    func load(showLoadingIndicator: Bool? = nil) async {
        let shouldShowLoading = showLoadingIndicator ?? (flatListings.isEmpty && flatmateListings.isEmpty)
        if shouldShowLoading {
            isLoading = true
        }
        errorMessage = nil
        defer {
            if shouldShowLoading {
                isLoading = false
            }
        }

        currentPage = 1

        do {
            let currentUser = await loadCurrentPostUser()
            let page = try await savedPostsService.fetchWishlist(page: 1, perPage: 15)
            applyWishlistPage(page, currentUser: currentUser, reset: true)
        } catch {
            flatListings = []
            flatmateListings = []
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await load(showLoadingIndicator: false)
    }

    func loadMoreIfNeeded(currentItem: FlatListing) async {
        guard segment == .flat,
              hasMore,
              !isLoadingMore,
              currentItem.id == flatListings.last?.id else { return }
        await loadMore()
    }

    func loadMoreIfNeeded(currentItem: FlatmateListing) async {
        guard segment == .flatmate,
              hasMore,
              !isLoadingMore,
              currentItem.id == flatmateListings.last?.id else { return }
        await loadMore()
    }

    private func loadMore() async {
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = currentPage + 1
            let page = try await savedPostsService.fetchWishlist(page: nextPage, perPage: 15)
            applyWishlistPage(page, currentUser: cachedCurrentUser, reset: false)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func applyWishlistPage(_ page: PaginatedWishlist, currentUser: PostUser?, reset: Bool) {
        let flats = page.posts
            .filter { $0.postType ?? true }
            .map { PostMapper.flatListing(from: $0, currentUser: currentUser) }
        let flatmates = page.posts
            .filter { !($0.postType ?? true) }
            .map { PostMapper.flatmateListing(from: $0, currentUser: currentUser) }

        if reset {
            flatListings = flats
            flatmateListings = flatmates
        } else {
            flatListings.append(contentsOf: flats)
            flatmateListings.append(contentsOf: flatmates)
        }

        currentPage = page.currentPage
        lastPage = page.lastPage
    }

    private func loadCurrentPostUser() async -> PostUser? {
        if let cachedCurrentUser { return cachedCurrentUser }
        guard let profile = try? await userService.fetchProfile() else { return nil }
        let userId = profile.resolvedUserId ?? TokenStorage.shared.userId
        guard userId > 0 else { return nil }
        let user = PostUser(
            id: userId,
            name: profile.name ?? "",
            fullName: profile.name,
            email: profile.email,
            profileImageUrl: profile.profileImageUrl,
            profession: profile.profession
        )
        cachedCurrentUser = user
        return user
    }
}
