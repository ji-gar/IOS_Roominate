import Foundation

protocol PostServiceProtocol {
    func fetchPosts(mode: PostFetchMode, query: PostQuery) async throws -> PaginatedPosts
    func fetchPost(id: Int) async throws -> Post
    func createPost(_ draft: PostDraft) async throws -> Post
    func updatePost(id: Int, draft: PostDraft) async throws -> Post
    func deletePost(id: Int) async throws
    func reportPost(postId: Int, reason: String, description: String) async throws
}

final class PostService: PostServiceProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchPosts(mode: PostFetchMode, query: PostQuery) async throws -> PaginatedPosts {
        let path: String
        let queryItems: [URLQueryItem]

        switch mode {
        case .all:
            path = APIConstants.Posts.myAll
            queryItems = query.allPostsQueryItems
        case .filtered:
            path = APIConstants.Posts.posts
            queryItems = query.queryItems
        case .search:
            path = APIConstants.Posts.search
            queryItems = query.searchQueryItems
        }

        let data = try await client.requestData(
            path: path,
            method: .get,
            queryItems: queryItems,
            requiresAuth: true
        )
        // #region agent log
        #if DEBUG
        Self.logRawFirstPost(from: data)
        #endif
        // #endregion
        let response = try PostsListResponse.decode(from: data, using: client.decoder)
        // #region agent log
        #if DEBUG
        if let first = response.data.data.first {
            let mapped = PostMapper.flatListing(from: first)
            DebugSessionLog.log(
                location: "PostService.swift:fetchPosts",
                message: "decoded first post mapping",
                data: [
                    "postId": "\(first.id)",
                    "userId": "\(first.userId ?? 0)",
                    "userResolvedName": first.user?.resolvedName ?? "nil",
                    "imageUrlsCount": "\(first.imageUrls?.count ?? 0)",
                    "firstImageUrl": first.imageUrls?.first ?? "none",
                    "imagesCount": "\(first.images?.count ?? 0)",
                    "firstImagePath": first.images?.first ?? "none",
                    "firstMappedImageURL": mapped.imageURLs.first ?? "none"
                ],
                hypothesisId: "H",
                runId: "post-fix-v3"
            )
        }
        #endif
        // #endregion
        return response.data
    }

    func fetchPost(id: Int) async throws -> Post {
        let data = try await client.requestData(
            path: APIConstants.Posts.post(id: id),
            method: .get,
            requiresAuth: true
        )
        let response = try CreatePostResponse.decode(from: data, using: client.decoder)
        return response.data
    }

    func createPost(_ draft: PostDraft) async throws -> Post {
        let payload = multipartPayload(for: draft)
        let data = try await client.requestData(
            path: APIConstants.Posts.posts,
            method: .post,
            multipart: payload,
            requiresAuth: true
        )
        let response = try CreatePostResponse.decode(from: data, using: client.decoder)
        return response.data
    }

    func updatePost(id: Int, draft: PostDraft) async throws -> Post {
        let payload = multipartPayload(for: draft)
        let data = try await client.requestData(
            path: APIConstants.Posts.post(id: id),
            method: .post,
            multipart: payload,
            requiresAuth: true
        )
        let response = try CreatePostResponse.decode(from: data, using: client.decoder)
        return response.data
    }

    func deletePost(id: Int) async throws {
        _ = try await client.requestData(
            path: APIConstants.Posts.post(id: id),
            method: .delete,
            requiresAuth: true
        )
    }

    func reportPost(postId: Int, reason: String, description: String) async throws {
        let body = ReportRequest(reason: reason, description: description)
        let _: ReportResponse = try await client.request(
            path: APIConstants.Posts.report(postId: postId),
            method: .post,
            body: body,
            requiresAuth: true
        )
    }

    private func multipartPayload(for draft: PostDraft) -> MultipartFormData {
        var fields: [MultipartFormData.Field] = [
            .init(name: "post_type", value: draft.postType ? "1" : "0"),
            .init(name: "title", value: draft.title)
        ]

        appendIfNotEmpty(&fields, name: "description", value: draft.description)
        appendIfNotEmpty(&fields, name: "property_type", value: PostDraftAPI.propertyType(draft.propertyType))
        appendIfNotEmpty(&fields, name: "type_of_space", value: PostDraftAPI.typeOfSpace(draft.typeOfSpace))
        appendIfNotEmpty(&fields, name: "home_furnishing", value: PostDraftAPI.homeFurnishing(draft.homeFurnishing))
        appendIfNotEmpty(&fields, name: "landmark", value: draft.landmark)
        appendIfNotEmpty(&fields, name: "area", value: draft.area)
        appendIfNotEmpty(&fields, name: "city", value: PostDraftAPI.city(draft.city))
        appendIfNotEmpty(&fields, name: "state", value: draft.state)
        appendIfNotEmpty(&fields, name: "pincode", value: draft.pincode)
        appendArrayFields(
            &fields,
            name: "prefered_location",
            values: PostDraftAPI.preferedLocations(draft.preferedLocation)
        )
        appendIfNotEmpty(&fields, name: "monthly_rent", value: draft.monthlyRent)
        appendIfNotEmpty(&fields, name: "deposit", value: draft.deposit)
        appendIfNotEmpty(&fields, name: "extra_cost", value: draft.extraCost)
        appendIfNotEmpty(&fields, name: "available_from", value: draft.availableFrom)
        appendIfNotEmpty(&fields, name: "available_to", value: draft.availableTo)
        appendIfNotEmpty(
            &fields,
            name: "flatmate_preference",
            value: PostDraftAPI.flatmatePreference(draft.flatmatePreference)
        )
        appendIfNotEmpty(
            &fields,
            name: "food_preference",
            value: PostDraftAPI.foodPreference(draft.foodPreference)
        )
        appendIfNotEmpty(&fields, name: "smoking", value: PostDraftAPI.smoking(draft.smoking))
        appendIfNotEmpty(&fields, name: "profession", value: PostDraftAPI.profession(draft.profession))

        fields.append(.init(name: "looking_for_long_term", value: draft.lookingForLongTerm ? "1" : "0"))

        for amenity in draft.amenities {
            fields.append(.init(name: "amenities[]", value: amenity))
        }

        var files: [MultipartFormData.FileField] = []
        for (index, imageData) in draft.imageData.enumerated() {
            files.append(
                .init(
                    name: "images[]",
                    filename: "image\(index).jpg",
                    mimeType: "image/jpeg",
                    data: imageData
                )
            )
        }

        return MultipartFormData(fields: fields, files: files)
    }

    private func appendIfNotEmpty(
        _ fields: inout [MultipartFormData.Field],
        name: String,
        value: String
    ) {
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        fields.append(.init(name: name, value: value))
    }

    private func appendArrayFields(
        _ fields: inout [MultipartFormData.Field],
        name: String,
        values: [String]
    ) {
        for value in values {
            fields.append(.init(name: "\(name)[]", value: value))
        }
    }

    #if DEBUG
    private static func logRawFirstPost(from data: Data) {
        guard let firstPost = extractFirstPostDictionary(from: data) else { return }
        let keys = firstPost.keys.sorted().joined(separator: ",")
        let userJSON: String = {
            guard let user = firstPost["user"] ?? firstPost["profile"] ?? firstPost["author"] else { return "none" }
            guard let json = try? JSONSerialization.data(withJSONObject: user),
                  let text = String(data: json, encoding: .utf8) else { return String(describing: user) }
            return text
        }()
        DebugSessionLog.log(
            location: "PostService.swift:logRawFirstPost",
            message: "raw first post JSON fields",
            data: [
                "postKeys": keys,
                "userJSON": userJSON,
                "images": String(describing: firstPost["images"] ?? "none"),
                "image_urls": String(describing: firstPost["image_urls"] ?? "none")
            ],
            hypothesisId: "G",
            runId: "post-fix-v2"
        )
    }

    private static func extractFirstPostDictionary(from data: Data) -> [String: Any]? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let dataNode = root["data"] ?? root
        if let page = dataNode as? [String: Any], let posts = page["data"] as? [[String: Any]] {
            return posts.first
        }
        if let posts = dataNode as? [[String: Any]] {
            return posts.first
        }
        return nil
    }
    #endif
}
