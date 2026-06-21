import Foundation

protocol PostServiceProtocol {
    func fetchPosts(mode: PostFetchMode, query: PostQuery) async throws -> PaginatedPosts
    func createPost(_ draft: PostDraft) async throws -> Post
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
        let response = try PostsListResponse.decode(from: data, using: client.decoder)
        return response.data
    }

    func createPost(_ draft: PostDraft) async throws -> Post {
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

        // #region agent log
        let fieldSummary = fields.map { "\($0.name)=\($0.value)" }.joined(separator: "|")
        let totalImageBytes = draft.imageData.reduce(0) { $0 + $1.count }
        DebugSessionLog.write(
            location: "PostService.swift:createPost",
            message: "request payload",
            data: [
                "fieldCount": String(fields.count),
                "fields": fieldSummary,
                "imageCount": String(files.count),
                "totalImageBytes": String(totalImageBytes)
            ],
            hypothesisId: "B-C-D-F"
        )
        // #endregion

        let data = try await client.requestData(
            path: APIConstants.Posts.posts,
            method: .post,
            multipart: MultipartFormData(fields: fields, files: files),
            requiresAuth: true
        )
        // #region agent log
        DebugSessionLog.write(
            location: "PostService.swift:createPost",
            message: "response received before decode",
            data: [
                "byteCount": String(data.count),
                "preview": String(data: data.prefix(300), encoding: .utf8) ?? "(binary)"
            ],
            hypothesisId: "E"
        )
        // #endregion
        let response = try CreatePostResponse.decode(from: data, using: client.decoder)
        return response.data
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
}
