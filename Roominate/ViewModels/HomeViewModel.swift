import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var segment: ListingSegment = .flat
    @Published var searchText: String = ""
    @Published var filters = ListingFilters()
    @Published private(set) var flatListings: [FlatListing] = []
    @Published private(set) var flatmateListings: [FlatmateListing] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var isCreatingPost = false
    @Published var errorMessage: String?
    @Published var createPostTitle = ""
    @Published var createPostErrorMessage: String?
    @Published private var favoriteIDs: Set<Int> = []

    private let postService: PostServiceProtocol
    private let userService: UserServiceProtocol
    private var cachedCurrentUser: PostUser?
    private var flatCurrentPage = 1
    private var flatmateCurrentPage = 1
    private var flatLastPage = 1
    private var flatmateLastPage = 1
    private var searchTask: Task<Void, Never>?
    private var loadPostsCounter = 0

    init(postService: PostServiceProtocol = PostService(), userService: UserServiceProtocol = UserService()) {
        self.postService = postService
        self.userService = userService
    }

    var filteredFlats: [FlatListing] {
        flatListings
    }

    var filteredFlatmates: [FlatmateListing] {
        flatmateListings
    }

    var hasMoreFlats: Bool {
        flatCurrentPage < flatLastPage
    }

    var hasMoreFlatmates: Bool {
        flatmateCurrentPage < flatmateLastPage
    }

    func loadPosts(source: String = "unknown", showLoadingIndicator: Bool? = nil) async {
        loadPostsCounter += 1
        let loadId = loadPostsCounter
        let shouldShowLoading = showLoadingIndicator ?? (flatListings.isEmpty && flatmateListings.isEmpty)
        // #region agent log
        #if DEBUG
        DebugSessionLog.log(
            location: "HomeViewModel.swift:loadPosts",
            message: "loadPosts started",
            data: [
                "source": source,
                "loadId": "\(loadId)",
                "taskCancelled": "\(Task.isCancelled)",
                "shouldShowLoading": "\(shouldShowLoading)"
            ],
            hypothesisId: "B"
        )
        #endif
        // #endregion
        if shouldShowLoading {
            isLoading = true
        }
        errorMessage = nil
        defer {
            if shouldShowLoading {
                isLoading = false
            }
            // #region agent log
            #if DEBUG
            DebugSessionLog.log(
                location: "HomeViewModel.swift:loadPosts",
                message: "loadPosts finished",
                data: [
                    "source": source,
                    "loadId": "\(loadId)",
                    "taskCancelled": "\(Task.isCancelled)",
                    "flatCount": "\(flatListings.count)",
                    "flatmateCount": "\(flatmateListings.count)",
                    "errorMessage": errorMessage ?? "nil"
                ],
                hypothesisId: "B"
            )
            #endif
            // #endregion
        }

        flatCurrentPage = 1
        flatmateCurrentPage = 1

        let currentUser = await loadCurrentPostUser()
        var errors: [String] = []

        do {
            let flatPage = try await fetchPosts(postType: true, page: 1)
            flatListings = flatPage.posts.map { PostMapper.flatListing(from: $0, currentUser: currentUser) }
            flatCurrentPage = flatPage.currentPage
            flatLastPage = flatPage.lastPage
        } catch {
            // #region agent log
            #if DEBUG
            DebugSessionLog.log(
                location: "HomeViewModel.swift:loadPosts",
                message: "flat fetch failed",
                data: [
                    "source": source,
                    "loadId": "\(loadId)",
                    "errorType": String(describing: type(of: error)),
                    "errorDesc": error.localizedDescription,
                    "isCancellation": "\(error is CancellationError || (error as? URLError)?.code == .cancelled)"
                ],
                hypothesisId: "D"
            )
            #endif
            // #endregion
            if Self.isCancellationError(error) { return }
            flatListings = []
            errors.append(error.localizedDescription)
        }

        do {
            let flatmatePage = try await fetchPosts(postType: false, page: 1)
            flatmateListings = flatmatePage.posts.map { PostMapper.flatmateListing(from: $0, currentUser: currentUser) }
            flatmateCurrentPage = flatmatePage.currentPage
            flatmateLastPage = flatmatePage.lastPage
        } catch {
            // #region agent log
            #if DEBUG
            DebugSessionLog.log(
                location: "HomeViewModel.swift:loadPosts",
                message: "flatmate fetch failed",
                data: [
                    "source": source,
                    "loadId": "\(loadId)",
                    "errorType": String(describing: type(of: error)),
                    "errorDesc": error.localizedDescription,
                    "isCancellation": "\(error is CancellationError || (error as? URLError)?.code == .cancelled)"
                ],
                hypothesisId: "D"
            )
            #endif
            // #endregion
            if Self.isCancellationError(error) { return }
            flatmateListings = []
            errors.append(error.localizedDescription)
        }

        if !errors.isEmpty {
            let hasAnyListings = !flatListings.isEmpty || !flatmateListings.isEmpty
            errorMessage = hasAnyListings ? nil : errors.first
            // #region agent log
            #if DEBUG
            DebugSessionLog.log(
                location: "HomeViewModel.swift:loadPosts",
                message: "loadPosts set errorMessage",
                data: [
                    "source": source,
                    "loadId": "\(loadId)",
                    "errorMessage": errorMessage ?? "nil",
                    "errors": errors.joined(separator: "|")
                ],
                hypothesisId: "D"
            )
            #endif
            // #endregion
        }
    }

    func refreshPosts() async {
        // SwiftUI `.refreshable` cancels its task quickly; detached work keeps the fetch alive.
        await Task.detached { @MainActor in
            await self.loadPosts(source: "refreshPosts", showLoadingIndicator: false)
        }.value
    }

    func loadMoreIfNeeded(currentItem: FlatListing) async {
        guard segment == .flat,
              hasMoreFlats,
              !isLoadingMore,
              currentItem.id == flatListings.last?.id else { return }
        await loadMoreFlats()
    }

    func loadMoreIfNeeded(currentItem: FlatmateListing) async {
        guard segment == .flatmate,
              hasMoreFlatmates,
              !isLoadingMore,
              currentItem.id == flatmateListings.last?.id else { return }
        await loadMoreFlatmates()
    }

    func onSearchTextChanged() {
        // #region agent log
        #if DEBUG
        DebugSessionLog.log(
            location: "HomeViewModel.swift:onSearchTextChanged",
            message: "search debounce triggered, cancelling prior searchTask",
            data: ["searchText": searchText],
            hypothesisId: "C"
        )
        #endif
        // #endregion
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            await loadPosts(source: "searchDebounce")
        }
    }

    func applyFilters(_ newFilters: ListingFilters) {
        filters = newFilters
        Task { await loadPosts(source: "applyFilters") }
    }

    /// Total number of posts matching the given filters for the current segment, used by the filter sheet's live count.
    func matchCount(for candidateFilters: ListingFilters) async -> Int? {
        let query = makeQuery(
            postType: segment == .flat,
            page: 1,
            perPage: 1,
            filters: candidateFilters,
            mode: .filtered
        )
        do {
            let response = try await postService.fetchPosts(mode: .filtered, query: query)
            return response.total
        } catch {
            return nil
        }
    }

    func isFavorite(_ id: Int) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggleFavorite(_ id: Int) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
    }

    func createPost() async -> Bool {
        let trimmedTitle = createPostTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            createPostErrorMessage = "Please enter a title."
            return false
        }

        isCreatingPost = true
        createPostErrorMessage = nil
        defer { isCreatingPost = false }

        let draft = PostDraft(
            postType: segment == .flat,
            title: trimmedTitle
        )

        do {
            _ = try await postService.createPost(draft)
            createPostTitle = ""
            await loadPosts(source: "createPost")
            return true
        } catch {
            createPostErrorMessage = error.localizedDescription
            return false
        }
    }

    func resetCreatePostForm() {
        createPostTitle = ""
        createPostErrorMessage = nil
    }

    private func loadMoreFlats() async {
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = flatCurrentPage + 1
            let page = try await fetchPosts(postType: true, page: nextPage)
            flatListings.append(contentsOf: page.posts.map { PostMapper.flatListing(from: $0, currentUser: cachedCurrentUser) })
            flatCurrentPage = page.currentPage
            flatLastPage = page.lastPage
        } catch {
            guard !Self.isCancellationError(error) else { return }
            errorMessage = error.localizedDescription
        }
    }

    private func loadMoreFlatmates() async {
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = flatmateCurrentPage + 1
            let page = try await fetchPosts(postType: false, page: nextPage)
            flatmateListings.append(contentsOf: page.posts.map { PostMapper.flatmateListing(from: $0, currentUser: cachedCurrentUser) })
            flatmateCurrentPage = page.currentPage
            flatmateLastPage = page.lastPage
        } catch {
            guard !Self.isCancellationError(error) else { return }
            errorMessage = error.localizedDescription
        }
    }

    private static func isCancellationError(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        if let urlError = error as? URLError, urlError.code == .cancelled { return true }
        return false
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

    private func fetchPosts(postType: Bool, page: Int) async throws -> FetchedPostsPage {
        let mode = fetchMode()
        let query = makeQuery(
            postType: postType,
            page: page,
            perPage: 15,
            filters: filters,
            mode: mode
        )
        let response = try await postService.fetchPosts(mode: mode, query: query)
        return FetchedPostsPage(
            posts: response.data,
            currentPage: response.currentPage,
            lastPage: response.lastPage
        )
    }

    /// Routes to the correct posts endpoint based on active search text and filters.
    private func fetchMode() -> PostFetchMode {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            return .search
        }
        if !filters.isDefault {
            return .filtered
        }
        return .all
    }

    /// Builds a `PostQuery` combining the free-text search bar and the structured filters.
    private func makeQuery(
        postType: Bool,
        page: Int,
        perPage: Int,
        filters: ListingFilters,
        mode: PostFetchMode
    ) -> PostQuery {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        var query = PostQuery(
            city: mode == .search && !trimmedSearch.isEmpty ? trimmedSearch : nil,
            postType: postType,
            sortBy: "monthly_rent",
            sortOrder: "asc",
            perPage: perPage,
            page: page
        )

        if mode == .filtered {
            filters.apply(to: &query)
        }

        return query
    }
}

private struct FetchedPostsPage {
    let posts: [Post]
    let currentPage: Int
    let lastPage: Int
}
