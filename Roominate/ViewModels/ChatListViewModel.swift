import Foundation
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {

    @Published var conversations: [ChatConversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var currentUserId: Int = TokenStorage.shared.userId
    
    // Store deleted conversation IDs locally
    @Published private var deletedConversationIds: Set<Int> = []

    private let chatService: ChatServiceProtocol
    private let userService: UserServiceProtocol
    
    private let deletedConversationsKey = "deletedConversationIds"

    var myUserId: Int { currentUserId }
    
    // Filtered conversations excluding locally deleted ones
    var displayedConversations: [ChatConversation] {
        conversations.filter { conv in
            guard let id = conv.id else { return true }
            return !deletedConversationIds.contains(id)
        }
    }

    init(chatService: ChatServiceProtocol? = nil, userService: UserServiceProtocol? = nil) {
        self.chatService = chatService ?? ChatService()
        self.userService = userService ?? UserService()
        loadDeletedConversationIds()
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

    func deleteConversation(_ conversation: ChatConversation) async {
        guard let conversationId = conversationId(for: conversation) else { 
            print("❌ Cannot delete: conversation ID is nil")
            return 
        }
        
        // Remove from local list immediately
        deletedConversationIds.insert(conversationId)
        saveDeletedConversationIds()
        
        // Trigger UI update
        objectWillChange.send()
        
        // Try to delete on backend (but don't restore if it fails since backend doesn't support it)
        do {
            try await chatService.deleteConversation(conversationId: conversationId)
            print("✅ Successfully deleted conversation \(conversationId) on backend")
        } catch {
            print("⚠️ Backend deletion failed (expected): \(error.localizedDescription)")
            // Keep it deleted locally even if backend fails
        }
    }
    
    private func loadDeletedConversationIds() {
        if let data = UserDefaults.standard.data(forKey: deletedConversationsKey),
           let decoded = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            deletedConversationIds = decoded
        }
    }
    
    private func saveDeletedConversationIds() {
        if let encoded = try? JSONEncoder().encode(deletedConversationIds) {
            UserDefaults.standard.set(encoded, forKey: deletedConversationsKey)
        }
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
