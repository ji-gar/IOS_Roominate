import Foundation

// MARK: - Message

struct MessageItem: Decodable, Identifiable, Equatable {
    let id: Int?
    let conversationId: Int?
    let senderId: Int?
    let type: String?
    let body: String?
    let mediaPath: String?
    let mediaUrl: String?
    let createdAt: String?
    let sender: ChatSender?

    enum CodingKeys: String, CodingKey {
        case id, type, body, sender, user
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case userId = "user_id"
        case mediaPath = "media_path"
        case mediaUrl = "media_url"
        case imageUrl = "image_url"
        case image
        case file
        case url
        case createdAt = "created_at"
    }

    var resolvedSenderId: Int? {
        senderId ?? sender?.resolvedId
    }

    init(
        id: Int? = nil,
        conversationId: Int? = nil,
        senderId: Int? = nil,
        type: String? = nil,
        body: String? = nil,
        mediaPath: String? = nil,
        mediaUrl: String? = nil,
        createdAt: String? = nil,
        sender: ChatSender? = nil
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.type = type
        self.body = body
        self.mediaPath = mediaPath
        self.mediaUrl = mediaUrl
        self.createdAt = createdAt
        self.sender = sender
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeFlexibleIntIfPresent(forKey: .id)
        conversationId = try container.decodeFlexibleIntIfPresent(forKey: .conversationId)
        let decodedSender = try container.decodeIfPresent(ChatSender.self, forKey: .sender)
            ?? (try container.decodeIfPresent(ChatSender.self, forKey: .user))
        senderId = try container.decodeFlexibleIntIfPresent(forKey: .senderId)
            ?? (try container.decodeFlexibleIntIfPresent(forKey: .userId))
            ?? decodedSender?.resolvedId
        type = try container.decodeIfPresent(String.self, forKey: .type)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        mediaPath = try container.decodeIfPresent(String.self, forKey: .mediaPath)
            ?? (try container.decodeIfPresent(String.self, forKey: .image))
            ?? (try container.decodeIfPresent(String.self, forKey: .file))
        mediaUrl = try container.decodeIfPresent(String.self, forKey: .mediaUrl)
            ?? (try container.decodeIfPresent(String.self, forKey: .imageUrl))
            ?? (try container.decodeIfPresent(String.self, forKey: .url))
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        sender = decodedSender
    }

    var resolvedMediaURL: String? {
        if let url = ChatMediaURL.resolve(mediaUrl) { return url }
        if let url = ChatMediaURL.resolve(mediaPath) { return url }
        if isImageType, let body, body.contains("/") || body.hasPrefix("http") {
            return ChatMediaURL.resolve(body)
        }
        return nil
    }

    private var isImageType: Bool {
        let normalized = type?.lowercased() ?? ""
        return normalized == "image" || normalized == "photo" || normalized == "media"
    }

    var isImageMessage: Bool {
        isImageType || resolvedMediaURL != nil
    }

    static func == (lhs: MessageItem, rhs: MessageItem) -> Bool {
        guard let lid = lhs.id, let rid = rhs.id else { return false }
        return lid == rid
    }
}

struct ChatSender: Decodable {
    let id: Int?
    let userId: Int?
    let name: String?
    let email: String?

    var resolvedId: Int? {
        id ?? userId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeFlexibleIntIfPresent(forKey: .id)
        userId = try container.decodeFlexibleIntIfPresent(forKey: .userId)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, email
        case userId = "user_id"
    }
}

// MARK: - Conversation

struct ChatConversation: Decodable, Identifiable, Hashable {
    let id: Int?
    let status: String?
    let postId: Int?
    let initiatorId: Int?
    let receiverId: Int?
    let initiator: ChatParty?
    let receiver: ChatParty?
    let post: ConversationPost?
    let latestMessage: LatestChatMessage?
    let dealGrabbed: Bool?
    let dealGrabbedAt: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, status, initiator, receiver, post
        case postId = "post_id"
        case initiatorId = "initiator_id"
        case receiverId = "receiver_id"
        case latestMessage = "latest_message"
        case lastMessage = "last_message"
        case dealGrabbed = "deal_grabbed"
        case dealGrabbedAt = "deal_grabbed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(
        id: Int? = nil,
        status: String? = nil,
        postId: Int? = nil,
        initiatorId: Int? = nil,
        receiverId: Int? = nil,
        initiator: ChatParty? = nil,
        receiver: ChatParty? = nil,
        post: ConversationPost? = nil,
        latestMessage: LatestChatMessage? = nil,
        dealGrabbed: Bool? = nil,
        dealGrabbedAt: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.status = status
        self.postId = postId
        self.initiatorId = initiatorId
        self.receiverId = receiverId
        self.initiator = initiator
        self.receiver = receiver
        self.post = post
        self.latestMessage = latestMessage
        self.dealGrabbed = dealGrabbed
        self.dealGrabbedAt = dealGrabbedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeFlexibleIntIfPresent(forKey: .id)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        postId = try container.decodeFlexibleIntIfPresent(forKey: .postId)
        initiatorId = try container.decodeFlexibleIntIfPresent(forKey: .initiatorId)
        receiverId = try container.decodeFlexibleIntIfPresent(forKey: .receiverId)
        initiator = try container.decodeIfPresent(ChatParty.self, forKey: .initiator)
        receiver = try container.decodeIfPresent(ChatParty.self, forKey: .receiver)
        post = try container.decodeIfPresent(ConversationPost.self, forKey: .post)
        latestMessage = try container.decodeIfPresent(LatestChatMessage.self, forKey: .latestMessage)
            ?? (try container.decodeIfPresent(LatestChatMessage.self, forKey: .lastMessage))
        dealGrabbed = try container.decodeIfPresent(Bool.self, forKey: .dealGrabbed)
        dealGrabbedAt = try container.decodeIfPresent(String.self, forKey: .dealGrabbedAt)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }

    func withLatestMessage(_ message: LatestChatMessage) -> ChatConversation {
        ChatConversation(
            id: id,
            status: status,
            postId: postId,
            initiatorId: initiatorId,
            receiverId: receiverId,
            initiator: initiator,
            receiver: receiver,
            post: post,
            latestMessage: message,
            dealGrabbed: dealGrabbed,
            dealGrabbedAt: dealGrabbedAt,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var needsLatestMessageEnrichment: Bool {
        latestMessage?.previewText == nil
    }

    static func == (lhs: ChatConversation, rhs: ChatConversation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ChatParty: Decodable {
    let id: Int?
    let name: String?
    let email: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeFlexibleIntIfPresent(forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, email
    }
}

struct ConversationPost: Decodable {
    let id: Int?
    let title: String?
    let city: String?
    let monthlyRent: String?
    let imageUrls: [String]?

    enum CodingKeys: String, CodingKey {
        case id, title, city
        case monthlyRent = "monthly_rent"
        case imageUrls = "image_urls"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeFlexibleIntIfPresent(forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        monthlyRent = try container.decodeIfPresent(String.self, forKey: .monthlyRent)
        imageUrls = try container.decodeIfPresent([String].self, forKey: .imageUrls)
    }
}

struct LatestChatMessage: Decodable {
    let id: Int?
    let conversationId: Int?
    let senderId: Int?
    let type: String?
    let body: String?
    let mediaPath: String?
    let mediaUrl: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, type, body
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case userId = "user_id"
        case mediaPath = "media_path"
        case mediaUrl = "media_url"
        case imageUrl = "image_url"
        case image
        case file
        case url
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var resolvedSenderId: Int? {
        senderId
    }

    init(from message: MessageItem) {
        id = message.id
        conversationId = message.conversationId
        senderId = message.resolvedSenderId
        type = message.type
        body = message.body
        mediaPath = message.mediaPath
        mediaUrl = message.mediaUrl
        createdAt = message.createdAt
        updatedAt = message.createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeFlexibleIntIfPresent(forKey: .id)
        conversationId = try container.decodeFlexibleIntIfPresent(forKey: .conversationId)
        senderId = try container.decodeFlexibleIntIfPresent(forKey: .senderId)
            ?? (try container.decodeFlexibleIntIfPresent(forKey: .userId))
        type = try container.decodeIfPresent(String.self, forKey: .type)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        mediaPath = try container.decodeIfPresent(String.self, forKey: .mediaPath)
            ?? (try container.decodeIfPresent(String.self, forKey: .image))
            ?? (try container.decodeIfPresent(String.self, forKey: .file))
        mediaUrl = try container.decodeIfPresent(String.self, forKey: .mediaUrl)
            ?? (try container.decodeIfPresent(String.self, forKey: .imageUrl))
            ?? (try container.decodeIfPresent(String.self, forKey: .url))
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }

    var resolvedMediaURL: String? {
        if let url = ChatMediaURL.resolve(mediaUrl) { return url }
        if let url = ChatMediaURL.resolve(mediaPath) { return url }
        if isImageType, let body, body.contains("/") || body.hasPrefix("http") {
            return ChatMediaURL.resolve(body)
        }
        return nil
    }

    private var isImageType: Bool {
        let normalized = type?.lowercased() ?? ""
        return normalized == "image" || normalized == "photo" || normalized == "media"
    }

    var isImageMessage: Bool {
        isImageType || resolvedMediaURL != nil
    }

    var previewText: String? {
        if isImageMessage { return "Photo" }
        if let body, !body.isEmpty { return body }
        return nil
    }
}

// MARK: - Requests

struct StartChatRequest: Encodable {
    let postId: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case message
    }
}

struct SendMessageRequest: Encodable {
    let type: String
    let body: String
}

// MARK: - API Response Wrappers

struct StartChatResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: ChatConversation?
}

struct ChatConversationsResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: ConversationPage?
}

struct ConversationPage: Decodable {
    let currentPage: Int?
    let perPage: Int?
    let total: Int?
    let lastPage: Int?
    let data: [ChatConversation?]?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case perPage = "per_page"
        case total
        case lastPage = "last_page"
        case data
    }
}

struct MessagesResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: MessagePage?
}

struct MessagePage: Decodable {
    let currentPage: Int?
    let data: [MessageItem?]?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
    }
}

struct ChatActionResponse: Decodable {
    let success: Bool?
    let message: String?
}

// MARK: - Chat post details (details sheet + property card)

struct ChatPostDetails: Equatable {
    let id: Int
    let title: String
    let location: String
    let imageURL: String?
    let lookingFor: String
    let deposit: String
    let rent: String
    let moveInDate: String
    let extras: String

    init(from post: Post) {
        id = post.id
        title = post.title
        location = PostMapper.chatLocation(from: post)
        imageURL = PostMapper.chatHeroImageURL(from: post)
        lookingFor = PostMapper.chatLookingFor(from: post)
        deposit = PostMapper.chatCurrency(from: post.deposit)
        rent = PostMapper.chatCurrency(from: post.monthlyRent)
        moveInDate = PostMapper.chatMoveInDate(from: post)
        extras = PostMapper.chatExtras(from: post)
    }

    init(from post: ConversationPost) {
        id = post.id ?? 0
        title = post.title ?? "Listing"
        location = post.city ?? ""
        imageURL = post.imageUrls?.first.map { APIConstants.resolveMediaURL($0) }
        lookingFor = ""
        deposit = ""
        rent = post.monthlyRent ?? ""
        moveInDate = ""
        extras = ""
    }
}
