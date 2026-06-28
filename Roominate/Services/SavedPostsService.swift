import Foundation

protocol SavedPostsServiceProtocol {
    func fetchWishlist(page: Int, perPage: Int) async throws -> PaginatedWishlist
    func fetchSavedPostIDs() async throws -> Set<Int>
    func savePost(postId: Int) async throws
    func unsavePost(postId: Int) async throws
}

final class SavedPostsService: SavedPostsServiceProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchSavedPostIDs() async throws -> Set<Int> {
        var ids = Set<Int>()
        var page = 1
        var lastPage = 1

        repeat {
            let wishlistPage = try await fetchWishlist(page: page, perPage: 100)
            wishlistPage.data.forEach { ids.insert($0.postId) }
            lastPage = wishlistPage.lastPage
            page += 1
        } while page <= lastPage

        return ids
    }

    func savePost(postId: Int) async throws {
        do {
            _ = try await client.requestData(
                path: APIConstants.Wishlist.post(postId: postId),
                method: .post,
                requiresAuth: true
            )
        } catch NetworkError.httpError(let statusCode, _) where statusCode == 422 {
            // Post is already in the wishlist — treat as success.
            return
        }
    }

    func unsavePost(postId: Int) async throws {
        do {
            _ = try await client.requestData(
                path: APIConstants.Wishlist.post(postId: postId),
                method: .delete,
                requiresAuth: true
            )
        } catch NetworkError.httpError(let statusCode, _) where statusCode == 404 {
            // Post is not in the wishlist — treat as success.
            return
        }
    }

    func fetchWishlist(page: Int, perPage: Int) async throws -> PaginatedWishlist {
        let data = try await client.requestData(
            path: APIConstants.Wishlist.list,
            method: .get,
            queryItems: [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(min(perPage, 100))),
            ],
            requiresAuth: true
        )
        let response = try WishlistListResponse.decode(from: data, using: client.decoder)
        return response.data
    }
}
