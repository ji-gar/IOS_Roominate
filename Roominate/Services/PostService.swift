import Foundation

protocol PostServiceProtocol {
    func fetchPosts(query: PostQuery) async throws -> PaginatedPosts
    func createPost(_ draft: PostDraft) async throws -> Post
    func reportPost(postId: Int, reason: String, description: String) async throws
}

final class PostService: PostServiceProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchPosts(query: PostQuery) async throws -> PaginatedPosts {
        let data = try await client.requestData(
            path: APIConstants.Posts.posts,
            method: .get,
            queryItems: query.queryItems,
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
        appendIfNotEmpty(&fields, name: "property_type", value: draft.propertyType)
        appendIfNotEmpty(&fields, name: "type_of_space", value: draft.typeOfSpace)
        appendIfNotEmpty(&fields, name: "home_furnishing", value: draft.homeFurnishing)
        appendIfNotEmpty(&fields, name: "landmark", value: draft.landmark)
        appendIfNotEmpty(&fields, name: "area", value: draft.area)
        appendIfNotEmpty(&fields, name: "city", value: draft.city)
        appendIfNotEmpty(&fields, name: "state", value: draft.state)
        appendIfNotEmpty(&fields, name: "pincode", value: draft.pincode)
        appendIfNotEmpty(&fields, name: "monthly_rent", value: draft.monthlyRent)
        appendIfNotEmpty(&fields, name: "deposit", value: draft.deposit)
        appendIfNotEmpty(&fields, name: "extra_cost", value: draft.extraCost)
        appendIfNotEmpty(&fields, name: "available_from", value: draft.availableFrom)
        appendIfNotEmpty(&fields, name: "available_to", value: draft.availableTo)
        appendIfNotEmpty(&fields, name: "flatmate_preference", value: draft.flatmatePreference)
        appendIfNotEmpty(&fields, name: "food_preference", value: draft.foodPreference)
        appendIfNotEmpty(&fields, name: "smoking", value: draft.smoking)
        appendIfNotEmpty(&fields, name: "profession", value: draft.profession)

        fields.append(.init(name: "looking_for_long_term", value: draft.lookingForLongTerm ? "1" : "0"))

        if !draft.amenities.isEmpty {
            fields.append(.init(name: "amenities", value: draft.amenities.joined(separator: ",")))
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

        let data = try await client.requestData(
            path: APIConstants.Posts.posts,
            method: .post,
            multipart: MultipartFormData(fields: fields, files: files),
            requiresAuth: true
        )
        let response = try CreatePostResponse.decode(from: data, using: client.decoder)
        return response.data
    }

    func reportPost(postId: Int, reason: String, description: String) async throws {
        let body = ReportRequest(reason: reason, description: description)
        // #region agent log
        let encodedBody = (try? JSONEncoder().encode(body)).flatMap { String(data: $0, encoding: .utf8) } ?? "encode-failed"
        DebugLog.write(
            location: "PostService.swift:reportPost",
            message: "Report request payload",
            data: [
                "postId": String(postId),
                "path": APIConstants.Posts.report(postId: postId),
                "encodedBody": encodedBody
            ],
            hypothesisId: "H3"
        )
        // #endregion
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
}
