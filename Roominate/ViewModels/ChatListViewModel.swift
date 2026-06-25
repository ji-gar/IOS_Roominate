import Foundation
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {

    @Published var conversations: [ChatConversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var currentUserId: Int = TokenStorage.shared.userId

    private let chatService: ChatServiceProtocol
    private let userService: UserServiceProtocol

    var myUserId: Int { currentUserId }

    init(chatService: ChatServiceProtocol? = nil, userService: UserServiceProtocol? = nil) {
        self.chatService = chatService ?? ChatService()
        self.userService = userService ?? UserService()
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        await backfillUserIdIfNeeded()
        do {
            let loaded = try await chatService.listConversations()
            conversations = await chatService.enrichWithLatestMessages(loaded)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async {
        await load()
    }

    func otherName(for conversation: ChatConversation) -> String {
        let myId = myUserId
        if let initiatorId = conversation.initiatorId, initiatorId == myId {
            return conversation.receiver?.name ?? "Unknown"
        }
        return conversation.initiator?.name ?? "Unknown"
    }

    func conversationId(for conversation: ChatConversation) -> Int? {
        conversation.id ?? conversation.latestMessage?.conversationId
    }

    private func backfillUserIdIfNeeded() async {
        currentUserId = await UserIdBackfill.ensureStored(userService: userService)
    }
}
