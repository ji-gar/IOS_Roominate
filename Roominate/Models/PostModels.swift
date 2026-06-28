import Foundation

// MARK: - API Response Models

struct PostUser: Decodable, Hashable {
    let id: Int
    let name: String
    let fullName: String?
    let email: String?
    let profileImageUrl: String?
    let profession: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeFlexibleInt(forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
            ?? container.decodeIfPresent(String.self, forKey: .fullname)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
            ?? container.decodeIfPresent(String.self, forKey: .profileImage)
            ?? container.decodeIfPresent(String.self, forKey: .profilePic)
        profession = try container.decodeFlexibleJoinedString(forKey: .profession)
    }

    init(
        id: Int,
        name: String,
        fullName: String? = nil,
        email: String?,
        profileImageUrl: String? = nil,
        profession: String? = nil
    ) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.profession = profession
    }

    var resolvedName: String {
        let candidates = [name, fullName ?? ""].map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return candidates.first(where: { !$0.isEmpty }) ?? "Unknown"
    }

    var resolvedProfileImageURL: String? {
        guard let profileImageUrl, !profileImageUrl.isEmpty else { return nil }
        return APIConstants.resolveMediaURL(profileImageUrl)
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, email, profession
        case fullName
        case fullname
        case profileImageUrl
        case profileImage
        case profilePic
    }
}

private struct PostProfileSummary: Decodable {
    let id: Int?
    let userId: Int?
    let name: String?
    let profileImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case userId
        case profileImageUrl
        case profileImage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeFlexibleIntIfPresent(forKey: .id)
        userId = try container.decodeFlexibleIntIfPresent(forKey: .userId)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
            ?? container.decodeIfPresent(String.self, forKey: .profileImage)
    }

    func asPostUser() -> PostUser {
        PostUser(
            id: userId ?? id ?? 0,
            name: name ?? "",
            fullName: name,
            email: nil,
            profileImageUrl: profileImageUrl,
            profession: nil
        )
    }
}

struct Post: Decodable, Hashable {
    let id: Int
    let userId: Int?
    let title: String
    let description: String?
    let propertyType: String?
    let typeOfSpace: String?
    let homeFurnishing: String?
    let amenities: [String]?
    let landmark: String?
    let area: String?
    let city: String?
    let state: String?
    let pincode: String?
    let monthlyRent: String?
    let deposit: String?
    let extraCost: String?
    let availableFrom: String?
    let availableTo: String?
    let lookingForLongTerm: Bool?
    let flatmatePreference: String?
    let foodPreference: String?
    let smoking: String?
    let profession: String?
    let imageUrls: [String]?
    let images: [String]?
    let preferedLocation: String?
    let postType: Bool?
    let isHidden: Bool?
    let createdAt: String?
    let updatedAt: String?
    let user: PostUser?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeFlexibleInt(forKey: .id)
        userId = try container.decodeFlexibleIntIfPresent(forKey: .userId)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Untitled"
        description = try container.decodeIfPresent(String.self, forKey: .description)
        propertyType = try container.decodeFlexibleJoinedString(forKey: .propertyType)
        typeOfSpace = try container.decodeIfPresent(String.self, forKey: .typeOfSpace)
        homeFurnishing = try container.decodeFlexibleJoinedString(forKey: .homeFurnishing)
        amenities = try container.decodeFlexibleStringArray(forKey: .amenities)
        landmark = try container.decodeIfPresent(String.self, forKey: .landmark)
        area = try container.decodeIfPresent(String.self, forKey: .area)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        pincode = try container.decodeIfPresent(String.self, forKey: .pincode)
        monthlyRent = try container.decodeFlexibleString(forKey: .monthlyRent)
        deposit = try container.decodeFlexibleString(forKey: .deposit)
        extraCost = try container.decodeFlexibleString(forKey: .extraCost)
        availableFrom = try container.decodeIfPresent(String.self, forKey: .availableFrom)
        availableTo = try container.decodeIfPresent(String.self, forKey: .availableTo)
        lookingForLongTerm = try container.decodeFlexibleBool(forKey: .lookingForLongTerm)
        flatmatePreference = try container.decodeFlexibleJoinedString(forKey: .flatmatePreference)
        foodPreference = try container.decodeFlexibleJoinedString(forKey: .foodPreference)
        smoking = try container.decodeFlexibleJoinedString(forKey: .smoking)
        profession = try container.decodeFlexibleJoinedString(forKey: .profession)
        imageUrls = try container.decodeIfPresent([String].self, forKey: .imageUrls)
        images = try container.decodeFlexibleImageURLs(forKey: .images)
        preferedLocation = try container.decodeFlexibleJoinedString(forKey: .preferedLocation)
        postType = try container.decodeFlexibleBool(forKey: .postType)
        isHidden = try container.decodeFlexibleBool(forKey: .isHidden)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        user = try Self.decodePostUser(from: container)
    }

    private static func decodePostUser(from container: KeyedDecodingContainer<CodingKeys>) throws -> PostUser? {
        if let nestedUser = try container.decodeIfPresent(PostUser.self, forKey: .user),
           nestedUser.resolvedName != "Unknown" {
            return nestedUser
        }
        if let author = try container.decodeIfPresent(PostUser.self, forKey: .author),
           author.resolvedName != "Unknown" {
            return author
        }
        if let profile = try container.decodeIfPresent(PostProfileSummary.self, forKey: .profile) {
            return profile.asPostUser()
        }

        let userId = try container.decodeFlexibleIntIfPresent(forKey: .userId)
        let flatName = try container.decodeIfPresent(String.self, forKey: .userName)
            ?? container.decodeIfPresent(String.self, forKey: .fullName)
            ?? container.decodeIfPresent(String.self, forKey: .fullname)
        let profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
            ?? container.decodeIfPresent(String.self, forKey: .profileImage)
            ?? container.decodeIfPresent(String.self, forKey: .profilePic)
        let profession = try container.decodeFlexibleJoinedString(forKey: .profession)

        guard userId != nil || flatName != nil || profileImageUrl != nil else { return nil }

        return PostUser(
            id: userId ?? 0,
            name: flatName ?? "",
            fullName: flatName,
            email: nil,
            profileImageUrl: profileImageUrl,
            profession: profession
        )
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title, description
        case propertyType
        case typeOfSpace
        case homeFurnishing
        case amenities, landmark, area, city, state, pincode
        case monthlyRent
        case deposit
        case extraCost
        case availableFrom
        case availableTo
        case lookingForLongTerm
        case flatmatePreference
        case foodPreference
        case smoking, profession
        case imageUrls
        case images
        case preferedLocation
        case postType
        case isHidden
        case createdAt
        case updatedAt
        case user, author, profile
        case userName
        case fullName
        case fullname
        case profileImageUrl
        case profileImage
        case profilePic
    }
}

extension Post {
    /// Prefer CDN `image_urls` from the API; fall back to relative `images` paths.
    var resolvedImageSources: [String] {
        if let imageUrls, !imageUrls.isEmpty { return imageUrls }
        return images ?? []
    }
}

struct PaginatedPosts: Decodable {
    let currentPage: Int
    let data: [Post]
    let lastPage: Int
    let perPage: Int
    let total: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentPage = try container.decodeFlexibleInt(forKey: .currentPage, default: 1)
        data = try container.decodeIfPresent([Post].self, forKey: .data) ?? []
        perPage = try container.decodeFlexibleInt(forKey: .perPage, default: 15)
        total = try container.decodeFlexibleInt(forKey: .total, default: data.count)

        let decodedLastPage = try container.decodeFlexibleIntIfPresent(forKey: .lastPage)
        if let decodedLastPage {
            lastPage = decodedLastPage
        } else {
            let pageSize = max(perPage, 1)
            lastPage = max(1, Int(ceil(Double(total) / Double(pageSize))))
        }
    }

    init(currentPage: Int, data: [Post], lastPage: Int, perPage: Int, total: Int) {
        self.currentPage = currentPage
        self.data = data
        self.lastPage = lastPage
        self.perPage = perPage
        self.total = total
    }

    static let empty = PaginatedPosts(currentPage: 1, data: [], lastPage: 1, perPage: 15, total: 0)

    private enum CodingKeys: String, CodingKey {
        case currentPage
        case data
        case lastPage
        case perPage
        case total
    }
}

struct PostsListResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: PaginatedPosts

    static func decode(from data: Data, using decoder: JSONDecoder) throws -> PostsListResponse {
        if let wrapped = try? decoder.decode(PostsListEnvelope.self, from: data) {
            return PostsListResponse(
                success: wrapped.success,
                message: wrapped.message,
                data: wrapped.resolvedData
            )
        }
        return try decoder.decode(PostsListResponse.self, from: data)
    }
}

private struct PostsListEnvelope: Decodable {
    let success: Bool?
    let message: String?
    let data: PaginatedPostsContainer?

    var resolvedData: PaginatedPosts {
        data?.resolved ?? .empty
    }
}

private enum PaginatedPostsContainer: Decodable {
    case page(PaginatedPosts)
    case posts([Post])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let page = try? container.decode(PaginatedPosts.self) {
            self = .page(page)
            return
        }
        if let posts = try? container.decode([Post].self) {
            self = .posts(posts)
            return
        }
        self = .posts([])
    }

    var resolved: PaginatedPosts {
        switch self {
        case .page(let page):
            return page
        case .posts(let posts):
            return PaginatedPosts(
                currentPage: 1,
                data: posts,
                lastPage: 1,
                perPage: posts.count,
                total: posts.count
            )
        }
    }
}

struct CreatePostResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: Post

    static func decode(from data: Data, using decoder: JSONDecoder) throws -> CreatePostResponse {
        if let wrapped = try? decoder.decode(CreatePostEnvelope.self, from: data), let post = wrapped.data {
            return CreatePostResponse(success: wrapped.success, message: wrapped.message, data: post)
        }
        return try decoder.decode(CreatePostResponse.self, from: data)
    }
}

private struct CreatePostEnvelope: Decodable {
    let success: Bool?
    let message: String?
    let data: Post?
}

enum PostReportReason: String, CaseIterable, Identifiable {
    case inappropriate = "Inappropriate or abusive content"
    case spam = "Spam or misleading information"
    case fake = "Fake listing or scam"
    case offensive = "Offensive photos or language"
    case harassment = "Personal attack or harassment"
    case illegal = "Promoting illegal activity"
    case irrelevant = "Not relevant to Roominate"
    case other = "Other"

    var id: String { rawValue }

    var displayTitle: String { rawValue }

    /// Values accepted by `POST /posts/:id/report`.
    /// Confirmed valid via API probing. The backend enum only exposes 5 distinct values;
    /// offensive, illegal, and irrelevant fall back to "Others".
    var apiValue: String {
        switch self {
        case .inappropriate: return "Inappropriate content"
        case .spam:          return "Spam"
        case .fake:          return "Fake Info"
        case .offensive:     return "Others"
        case .harassment:    return "Harassment"
        case .illegal:       return "Others"
        case .irrelevant:    return "Others"
        case .other:         return "Others"
        }
    }
}

struct ReportRequest: Encodable {
    let reason: String
    let description: String
}

struct ReportResponse: Decodable {
    let success: Bool?
    let message: String?
}

// MARK: - Flexible JSON helpers

private extension KeyedDecodingContainer {
    func decodeFlexibleString(forKey key: Key) throws -> String? {
        guard contains(key), !(try decodeNil(forKey: key)) else { return nil }
        if let value = try? decode(String.self, forKey: key) { return value }
        if let value = try? decode(Int.self, forKey: key) { return String(value) }
        if let value = try? decode(Double.self, forKey: key) {
            return String(format: "%.2f", value)
        }
        return nil
    }

    func decodeFlexibleBool(forKey key: Key) throws -> Bool? {
        guard contains(key), !(try decodeNil(forKey: key)) else { return nil }
        if let value = try? decode(Bool.self, forKey: key) { return value }
        if let value = try? decode(Int.self, forKey: key) { return value != 0 }
        if let value = try? decode(String.self, forKey: key) {
            switch value.lowercased() {
            case "1", "true", "yes": return true
            case "0", "false", "no": return false
            default: return nil
            }
        }
        return nil
    }

    func decodeFlexibleStringArray(forKey key: Key) throws -> [String]? {
        guard contains(key), !(try decodeNil(forKey: key)) else { return nil }
        if let values = try? decode([String].self, forKey: key) { return values }
        if let value = try? decode(String.self, forKey: key) {
            let parts = value
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            return parts.isEmpty ? nil : parts
        }
        return nil
    }

    func decodeFlexibleJoinedString(forKey key: Key) throws -> String? {
        if let values = try decodeFlexibleStringArray(forKey: key) {
            return values.joined(separator: ", ")
        }
        return nil
    }

    func decodeFlexibleImageURLs(forKey key: Key) throws -> [String]? {
        guard contains(key), !(try decodeNil(forKey: key)) else { return nil }
        if let values = try? decode([String].self, forKey: key) {
            let filtered = values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            return filtered.isEmpty ? nil : filtered
        }
        if let value = try? decode(String.self, forKey: key) {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("["),
               let data = trimmed.data(using: .utf8),
               let decoded = try? JSONDecoder().decode([String].self, from: data) {
                let filtered = decoded.filter { !$0.isEmpty }
                return filtered.isEmpty ? nil : filtered
            }
            let parts = trimmed
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            return parts.isEmpty ? nil : parts
        }
        if let objects = try? decode([PostImageReference].self, forKey: key) {
            let urls = objects.compactMap(\.resolvedPath)
            return urls.isEmpty ? nil : urls
        }
        return nil
    }
}

private struct PostImageReference: Decodable {
    let url: String?
    let path: String?
    let image: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case url, path, image
        case imageUrl = "image_url"
    }

    var resolvedPath: String? {
        [url, imageUrl, path, image]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first(where: { !$0.isEmpty })
    }
}

// MARK: - Query & Draft

struct PostQuery {
    var city: String?
    var propertyType: String?
    var lookingFor: String?
    var roomType: String?
    var furnishing: String?
    var minRent: Int?
    var maxRent: Int?
    var movedInFrom: String?
    var movedInTo: String?
    var amenities: String?
    var availableOnly: Bool?
    var postType: Bool?
    var lookingForLongTerm: Bool?
    var sortBy: String = "monthly_rent"
    var sortOrder: String = "asc"
    var perPage: Int = 15
    var page: Int = 1

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let city, !city.isEmpty {
            items.append(.init(name: "city", value: city))
        }
        if let propertyType, !propertyType.isEmpty {
            items.append(.init(name: "property_type", value: propertyType))
        }
        if let lookingFor, !lookingFor.isEmpty {
            items.append(.init(name: "looking_for", value: lookingFor))
        }
        if let roomType, !roomType.isEmpty {
            items.append(.init(name: "room_type", value: roomType))
        }
        if let furnishing, !furnishing.isEmpty {
            items.append(.init(name: "furnishing", value: furnishing))
        }
        if let minRent {
            items.append(.init(name: "min_rent", value: String(minRent)))
        }
        if let maxRent {
            items.append(.init(name: "max_rent", value: String(maxRent)))
        }
        if let movedInFrom, !movedInFrom.isEmpty {
            items.append(.init(name: "moved_in_from", value: movedInFrom))
        }
        if let movedInTo, !movedInTo.isEmpty {
            items.append(.init(name: "moved_in_to", value: movedInTo))
        }
        if let amenities, !amenities.isEmpty {
            items.append(.init(name: "amenities", value: amenities))
        }
        if let availableOnly {
            items.append(.init(name: "available_only", value: availableOnly ? "true" : "false"))
        }
        if let postType {
            items.append(.init(name: "post_type", value: postType ? "true" : "false"))
        }
        if let lookingForLongTerm {
            items.append(.init(name: "looking_for_long_term", value: lookingForLongTerm ? "true" : "false"))
        }

        items.append(.init(name: "sort_by", value: sortBy))
        items.append(.init(name: "sort_order", value: sortOrder))
        items.append(.init(name: "per_page", value: String(perPage)))
        items.append(.init(name: "page", value: String(page)))

        return items
    }

    /// Query items for `GET /posts/search` (city/area text search).
    var searchQueryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let city, !city.isEmpty {
            items.append(.init(name: "city", value: city))
        }
        if let postType {
            items.append(.init(name: "post_type", value: postType ? "true" : "false"))
        }

        items.append(.init(name: "per_page", value: String(perPage)))
        items.append(.init(name: "page", value: String(page)))

        return items
    }

    /// Query items for `GET /posts/my/all` (the current user's own listings).
    var allPostsQueryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let postType {
            items.append(.init(name: "post_type", value: postType ? "true" : "false"))
        }

        items.append(.init(name: "per_page", value: String(perPage)))
        items.append(.init(name: "page", value: String(page)))

        return items
    }
}

enum PostFetchMode: Equatable {
    /// Public catalog of every listing on the server (`GET /posts`).
    case all
    /// The current user's own listings (`GET /posts/my/all`).
    case mine
    case filtered
    case search
}

struct PostDraft {
    var postType: Bool = true
    var title: String = ""
    var description: String = ""
    var propertyType: String = ""
    var typeOfSpace: String = ""
    var homeFurnishing: String = ""
    var amenities: [String] = []
    var landmark: String = ""
    var area: String = ""
    var city: String = ""
    var state: String = ""
    var pincode: String = ""
    var monthlyRent: String = ""
    var deposit: String = ""
    var extraCost: String = ""
    var availableFrom: String = ""
    var availableTo: String = ""
    var lookingForLongTerm: Bool = true
    var flatmatePreference: String = ""
    var foodPreference: String = ""
    var smoking: String = ""
    var profession: String = ""
    var preferedLocation: String = ""
    var imageData: [Data] = []
}

extension PostDraft {
    static func from(_ post: Post) -> PostDraft {
        var draft = PostDraft()
        draft.postType = post.postType ?? true
        draft.title = post.title
        draft.description = post.description ?? ""
        draft.propertyType = post.propertyType ?? ""
        draft.typeOfSpace = uiTypeOfSpace(from: post.typeOfSpace)
        draft.homeFurnishing = post.homeFurnishing ?? ""
        draft.amenities = post.amenities ?? []
        draft.landmark = post.landmark ?? ""
        draft.area = post.area ?? ""
        draft.city = post.city ?? ""
        draft.state = post.state ?? ""
        draft.pincode = post.pincode ?? ""
        draft.monthlyRent = post.monthlyRent ?? ""
        draft.deposit = post.deposit ?? ""
        draft.extraCost = post.extraCost ?? ""
        draft.availableFrom = post.availableFrom ?? ""
        draft.availableTo = post.availableTo ?? ""
        draft.lookingForLongTerm = post.lookingForLongTerm ?? true
        draft.flatmatePreference = post.flatmatePreference ?? ""
        draft.foodPreference = post.foodPreference ?? ""
        draft.smoking = post.smoking ?? ""
        draft.profession = post.profession ?? ""
        draft.preferedLocation = post.preferedLocation ?? ""
        return draft
    }

    private static func uiTypeOfSpace(from value: String?) -> String {
        switch value?.lowercased() {
        case "sharing", "shared room":
            return "Shared Room"
        case "private", "private room":
            return "Private Room"
        default:
            return value ?? "Shared Room"
        }
    }
}

struct UserListing: Identifiable, Hashable {
    let id: Int
    let post: Post
    let flatListing: FlatListing?
    let flatmateListing: FlatmateListing?

    init(post: Post) {
        id = post.id
        self.post = post
        if post.postType ?? true {
            flatListing = PostMapper.flatListing(from: post)
            flatmateListing = nil
        } else {
            flatListing = nil
            flatmateListing = PostMapper.flatmateListing(from: post)
        }
    }
}

// MARK: - Mapping to UI Models

enum PostMapper {
    static func flatListing(from post: Post, currentUser: PostUser? = nil) -> FlatListing {
        let author = listingAuthor(from: post, currentUser: currentUser)

        let location = formattedLocation(area: post.area, city: post.city, landmark: post.landmark)
        let isShortStay = !(post.lookingForLongTerm ?? true) || post.availableTo != nil

        return FlatListing(
            id: post.id,
            author: author,
            imageURLs: resolvedImageURLs(for: post),
            title: post.title,
            location: location,
            lookingFor: formattedPreference(post.flatmatePreference),
            deposit: formattedCurrency(post.deposit),
            rent: formattedCurrency(post.monthlyRent),
            moveIn: DateFormatterHelper.displayDateRange(from: post.availableFrom, to: post.availableTo),
            amenities: post.amenities?.joined(separator: ", ") ?? "",
            isShortStay: isShortStay,
            isFeatured: false,
            monthlyRent: formattedCurrency(post.monthlyRent, suffix: " / month"),
            isAvailable: post.isHidden != true,
            propertyType: post.propertyType ?? "",
            roomType: post.typeOfSpace ?? "",
            furnishing: post.homeFurnishing ?? "",
            moveInDate: DateFormatterHelper.displayDate(from: post.availableFrom),
            securityDeposit: formattedCurrency(post.deposit),
            brokerage: "None",
            utilities: formattedCurrency(post.extraCost, fallback: "Included"),
            genderPreference: formattedPreference(post.flatmatePreference),
            foodPreference: post.foodPreference ?? "",
            smokingPreference: post.smoking ?? "",
            occupation: formattedProfession(post.profession)
        )
    }

    static func flatmateListing(from post: Post, currentUser: PostUser? = nil) -> FlatmateListing {
        let author = listingAuthor(from: post, currentUser: currentUser)

        let location = formattedLocation(area: post.area, city: post.city, landmark: post.landmark)
        let isShortStay = !(post.lookingForLongTerm ?? true) || post.availableTo != nil
        var tags: [String] = []
        if let preference = post.flatmatePreference, !preference.isEmpty {
            tags.append(formattedPreference(preference))
        }
        if let food = post.foodPreference, !food.isEmpty {
            tags.append(food)
        }
        if let smoking = post.smoking, !smoking.isEmpty {
            tags.append(smoking == "No" ? "No Smoking" : smoking)
        }

        let preferredAreas = preferredAreas(from: post)

        return FlatmateListing(
            id: post.id,
            author: author,
            title: post.title,
            location: location,
            lookingFor: formattedPreference(post.flatmatePreference),
            maxBudget: formattedCurrency(post.monthlyRent),
            fromDate: DateFormatterHelper.displayDate(from: post.availableFrom),
            toDate: post.availableTo.map { DateFormatterHelper.displayDate(from: $0) },
            isShortStay: isShortStay,
            isFeatured: false,
            tags: tags,
            maxBudgetMonthly: formattedCurrency(post.monthlyRent, suffix: " / month"),
            isAvailable: post.isHidden != true,
            preferredAreas: preferredAreas,
            propertyType: post.propertyType ?? "",
            roomType: post.typeOfSpace ?? "",
            furnishing: post.homeFurnishing ?? "",
            duration: isShortStay ? "Temporary Stay" : "Long Term",
            moveInDate: DateFormatterHelper.displayDate(from: post.availableFrom),
            moveOutDate: DateFormatterHelper.displayDate(from: post.availableTo),
            genderPreference: formattedPreference(post.flatmatePreference),
            foodPreference: post.foodPreference ?? "",
            smokingPreference: post.smoking ?? "",
            occupation: formattedProfession(post.profession),
            lifestyleNotes: post.amenities ?? [],
            aboutMe: post.description ?? ""
        )
    }

    private static func listingAuthor(from post: Post, currentUser: PostUser? = nil) -> ListingAuthor {
        let resolvedUser = resolvedPostUser(for: post, currentUser: currentUser)
        let role = formattedProfession(resolvedUser?.profession ?? post.profession)
        return ListingAuthor(
            name: resolvedUser?.resolvedName ?? "Unknown",
            role: role,
            avatarURL: resolvedUser?.resolvedProfileImageURL
        )
    }

    private static func resolvedPostUser(for post: Post, currentUser: PostUser?) -> PostUser? {
        if let user = post.user, user.resolvedName != "Unknown" { return user }
        if let currentUser,
           let userId = post.userId,
           userId > 0,
           userId == currentUser.id,
           currentUser.resolvedName != "Unknown" {
            return currentUser
        }
        return post.user
    }

    private static func resolvedImageURLs(for post: Post) -> [String] {
        post.resolvedImageSources.map { APIConstants.resolveMediaURL($0) }
    }

    private static func formattedLocation(area: String?, city: String?, landmark: String?) -> String {
        if let area, let city, !area.isEmpty, !city.isEmpty {
            return "\(area), \(city)"
        }
        if let area, !area.isEmpty { return area }
        if let city, !city.isEmpty { return city }
        if let landmark, !landmark.isEmpty { return landmark }
        return ""
    }

    private static func preferredAreas(from post: Post) -> [String] {
        if let preferred = post.preferedLocation, !preferred.isEmpty {
            return preferred
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        if let area = post.area, !area.isEmpty {
            return [area]
        }
        if let city = post.city, !city.isEmpty {
            return [city]
        }
        return []
    }

    private static func formattedPreference(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "Any" }
        return value.capitalized
    }

    private static func formattedProfession(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "" }
        switch value.lowercased() {
        case "working", "worker":
            return "Working Professional"
        case "student":
            return "Student"
        default:
            return value.capitalized
        }
    }

    private static func formattedCurrency(_ value: String?, suffix: String = "", fallback: String = "—") -> String {
        guard let value, !value.isEmpty else { return fallback }
        let cleaned = value.replacingOccurrences(of: ",", with: "")
        guard let amount = Double(cleaned) else { return "₹\(value)\(suffix)" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? String(Int(amount))
        return "₹\(formatted)\(suffix)"
    }

    // MARK: - Chat details helpers

    static func chatLocation(from post: Post) -> String {
        formattedLocation(area: post.area, city: post.city, landmark: post.landmark)
    }

    static func chatHeroImageURL(from post: Post) -> String? {
        resolvedImageURLs(for: post).first
    }

    static func chatLookingFor(from post: Post) -> String {
        formattedPreference(post.flatmatePreference)
    }

    static func chatCurrency(from value: String?) -> String {
        formattedCurrency(value, fallback: "—")
    }

    static func chatMoveInDate(from post: Post) -> String {
        let date = DateFormatterHelper.displayDate(from: post.availableFrom)
        return date.isEmpty ? "ASAP" : date
    }

    static func chatExtras(from post: Post) -> String {
        var parts: [String] = []
        if let furnishing = post.homeFurnishing, !furnishing.isEmpty {
            parts.append(furnishing.capitalized)
        }
        if let amenities = post.amenities, !amenities.isEmpty {
            parts.append(amenities.joined(separator: ", "))
        }
        return parts.isEmpty ? "—" : parts.joined(separator: ", ")
    }

}
