import Foundation

protocol ChatServiceProtocol {
    func startChat(postId: Int, message: String) async throws -> ChatConversation
    func listConversations() async throws -> [ChatConversation]
    func findConversation(id: Int) async throws -> ChatConversation?
    func loadMessages(conversationId: Int, perPage: Int) async throws -> [MessageItem]
    func sendMessage(conversationId: Int, body: String) async throws -> [MessageItem]
    func sendImageMessage(conversationId: Int, imageData: Data) async throws -> [MessageItem]
    func blockUser(userId: Int) async throws
    func grabDeal(conversationId: Int) async throws
    func enrichWithLatestMessages(_ conversations: [ChatConversation]) async -> [ChatConversation]
}

extension ChatServiceProtocol {
    func loadMessages(conversationId: Int) async throws -> [MessageItem] {
        try await loadMessages(conversationId: conversationId, perPage: 50)
    }
}

final class ChatService: ChatServiceProtocol {

    private let api: APIClient

    init(api: APIClient = .shared) {
        self.api = api
    }

    func startChat(postId: Int, message: String) async throws -> ChatConversation {
        let body = StartChatRequest(postId: postId, message: message)
        let response: StartChatResponse = try await api.request(
            path: APIConstants.Chat.startChat,
            method: .post,
            body: body,
            requiresAuth: true
        )
        guard let conversation = response.data else {
            throw NetworkError.decodingError
        }
        return conversation
    }

    func listConversations() async throws -> [ChatConversation] {
        let query = [URLQueryItem(name: "per_page", value: "30")]
        let response: ChatConversationsResponse = try await api.request(
            path: APIConstants.Chat.conversations,
            method: .get,
            queryItems: query,
            requiresAuth: true
        )
        let items = response.data?.data ?? []
        return deduplicateConversations(items.compactMap { $0 })
    }

    func findConversation(id: Int) async throws -> ChatConversation? {
        let conversations = try await listConversations()
        return conversations.first { $0.id == id }
    }

    func loadMessages(conversationId: Int, perPage: Int) async throws -> [MessageItem] {
        let query = [URLQueryItem(name: "per_page", value: String(perPage))]
        let response: MessagesResponse = try await api.request(
            path: APIConstants.Chat.messages(conversationId: conversationId),
            method: .get,
            queryItems: query,
            requiresAuth: true
        )
        let items = response.data?.data ?? []
        return items.compactMap { $0 }
    }

    func sendMessage(conversationId: Int, body: String) async throws -> [MessageItem] {
        let req = SendMessageRequest(type: "text", body: body)
        let response: MessagesResponse = try await api.request(
            path: APIConstants.Chat.messages(conversationId: conversationId),
            method: .post,
            body: req,
            requiresAuth: true
        )
        let items = response.data?.data ?? []
        return items.compactMap { $0 }
    }

    func sendImageMessage(conversationId: Int, imageData: Data) async throws -> [MessageItem] {
        let fieldNames = ["image", "media", "file"]
        var lastError: Error = NetworkError.decodingError

        for fieldName in fieldNames {
            do {
                let multipart = MultipartFormData(
                    fields: [.init(name: "type", value: "image")],
                    files: [
                        .init(
                            name: fieldName,
                            filename: "photo.jpg",
                            mimeType: "image/jpeg",
                            data: imageData
                        )
                    ]
                )
                let response: MessagesResponse = try await api.request(
                    path: APIConstants.Chat.messages(conversationId: conversationId),
                    method: .post,
                    multipart: multipart,
                    requiresAuth: true
                )
                let items = response.data?.data ?? []
                return items.compactMap { $0 }
            } catch {
                lastError = error
                if case NetworkError.httpError(let code, _) = error, code == 422 {
                    continue
                }
                throw error
            }
        }

        throw lastError
    }

    func blockUser(userId: Int) async throws {
        let _: ChatActionResponse = try await api.request(
            path: APIConstants.User.block(userId: userId),
            method: .post,
            requiresAuth: true
        )
    }

    func grabDeal(conversationId: Int) async throws {
        let _: ChatActionResponse = try await api.request(
            path: APIConstants.Chat.grabDeal(conversationId: conversationId),
            method: .post,
            requiresAuth: true
        )
    }

    func enrichWithLatestMessages(_ conversations: [ChatConversation]) async -> [ChatConversation] {
        await withTaskGroup(of: (Int, ChatConversation).self) { group in
            for conversation in conversations {
                guard let conversationId = conversation.id else { continue }
                guard conversation.needsLatestMessageEnrichment else { continue }

                group.addTask { [self] in
                    guard let latest = try? await self.loadMessages(conversationId: conversationId, perPage: 1).first else {
                        return (conversationId, conversation)
                    }
                    return (conversationId, conversation.withLatestMessage(LatestChatMessage(from: latest)))
                }
            }

            var enriched = conversations
            for await (conversationId, updated) in group {
                if let index = enriched.firstIndex(where: { $0.id == conversationId }) {
                    enriched[index] = updated
                }
            }
            return enriched
        }
    }

    private func deduplicateConversations(_ conversations: [ChatConversation]) -> [ChatConversation] {
        var bestByID: [Int: ChatConversation] = [:]

        for conversation in conversations {
            guard let id = conversation.id else { continue }
            guard let existing = bestByID[id] else {
                bestByID[id] = conversation
                continue
            }

            let existingDate = existing.latestMessage?.updatedAt
                ?? existing.latestMessage?.createdAt
                ?? existing.updatedAt
                ?? ""
            let candidateDate = conversation.latestMessage?.updatedAt
                ?? conversation.latestMessage?.createdAt
                ?? conversation.updatedAt
                ?? ""

            if candidateDate > existingDate {
                bestByID[id] = conversation
            }
        }

        return bestByID.values.sorted {
            let lhs = $0.latestMessage?.updatedAt
                ?? $0.latestMessage?.createdAt
                ?? $0.updatedAt
                ?? ""
            let rhs = $1.latestMessage?.updatedAt
                ?? $1.latestMessage?.createdAt
                ?? $1.updatedAt
                ?? ""
            return lhs > rhs
        }
    }
}
