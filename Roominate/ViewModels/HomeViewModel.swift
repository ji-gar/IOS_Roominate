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
    private var flatCurrentPage = 1
    private var flatmateCurrentPage = 1
    private var flatLastPage = 1
    private var flatmateLastPage = 1
    private var searchTask: Task<Void, Never>?

    init(postService: PostServiceProtocol = PostService()) {
        self.postService = postService
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

    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        flatCurrentPage = 1
        flatmateCurrentPage = 1

        var errors: [String] = []

        do {
            let flatPage = try await fetchPosts(postType: true, page: 1)
            flatListings = flatPage.posts.map(PostMapper.flatListing)
            flatCurrentPage = flatPage.currentPage
            flatLastPage = flatPage.lastPage
        } catch {
            flatListings = []
            errors.append(error.localizedDescription)
        }

        do {
            let flatmatePage = try await fetchPosts(postType: false, page: 1)
            flatmateListings = flatmatePage.posts.map(PostMapper.flatmateListing)
            flatmateCurrentPage = flatmatePage.currentPage
            flatmateLastPage = flatmatePage.lastPage
        } catch {
            flatmateListings = []
            errors.append(error.localizedDescription)
        }

        if !errors.isEmpty {
            let hasAnyListings = !flatListings.isEmpty || !flatmateListings.isEmpty
            errorMessage = hasAnyListings ? nil : errors.first
        }
    }

    func refreshPosts() async {
        await loadPosts()
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
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            await loadPosts()
        }
    }

    func applyFilters(_ newFilters: ListingFilters) {
        filters = newFilters
        Task { await loadPosts() }
    }

    /// Total number of posts matching the given filters for the current segment, used by the filter sheet's live count.
    func matchCount(for candidateFilters: ListingFilters) async -> Int? {
        let query = makeQuery(
            postType: segment == .flat,
            page: 1,
            perPage: 1,
            filters: candidateFilters
        )
        do {
            let response = try await postService.fetchPosts(query: query)
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
            await loadPosts()
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
            flatListings.append(contentsOf: page.posts.map(PostMapper.flatListing))
            flatCurrentPage = page.currentPage
            flatLastPage = page.lastPage
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadMoreFlatmates() async {
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = flatmateCurrentPage + 1
            let page = try await fetchPosts(postType: false, page: nextPage)
            flatmateListings.append(contentsOf: page.posts.map(PostMapper.flatmateListing))
            flatmateCurrentPage = page.currentPage
            flatmateLastPage = page.lastPage
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func fetchPosts(postType: Bool, page: Int) async throws -> FetchedPostsPage {
        let query = makeQuery(postType: postType, page: page, perPage: 15, filters: filters)
        let response = try await postService.fetchPosts(query: query)
        return FetchedPostsPage(
            posts: response.data,
            currentPage: response.currentPage,
            lastPage: response.lastPage
        )
    }

    /// Builds a `PostQuery` combining the free-text search bar and the structured filters.
    private func makeQuery(
        postType: Bool,
        page: Int,
        perPage: Int,
        filters: ListingFilters
    ) -> PostQuery {
        let trimmedCity = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        var query = PostQuery(
            city: trimmedCity.isEmpty ? nil : trimmedCity,
            postType: postType,
            sortBy: "monthly_rent",
            sortOrder: "asc",
            perPage: perPage,
            page: page
        )

        // Structured filters take precedence (e.g. a selected city chip overrides the search text).
        filters.apply(to: &query)
        return query
    }
}

private struct FetchedPostsPage {
    let posts: [Post]
    let currentPage: Int
    let lastPage: Int
}
