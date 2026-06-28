import Foundation
import Combine
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var messages: [MessageItem] = []
    @Published var isLoading = false
    @Published var isSending = false
    @Published var isBlocking = false
    @Published var isShortlisting = false
    @Published var errorMessage: String?
    @Published var inputText: String = ""
    @Published var postDetails: ChatPostDetails?
    @Published var isPostDetailsLoading = false
    @Published var isDealGrabbed = false
    @Published private(set) var currentUserId: Int = TokenStorage.shared.userId

    let conversationId: Int
    let otherName: String

    private(set) var postId: Int?
    private(set) var otherUserId: Int?

    var myUserId: Int { currentUserId }

    private let chatService: ChatServiceProtocol
    private let postService: PostServiceProtocol
    private let userService: UserServiceProtocol
    private var currentConversationId: Int

    init(
        conversationId: Int,
        otherName: String,
        postId: Int? = nil,
        otherUserId: Int? = nil,
        chatService: ChatServiceProtocol? = nil,
        postService: PostServiceProtocol? = nil,
        userService: UserServiceProtocol? = nil
    ) {
        self.conversationId = conversationId
        self.otherName = otherName
        self.postId = postId
        self.otherUserId = otherUserId
        self.currentConversationId = conversationId
        self.chatService = chatService ?? ChatService()
        self.postService = postService ?? PostService()
        self.userService = userService ?? UserService()
    }

    // MARK: - Load history

    func loadMessages() async {
        isLoading = true
        errorMessage = nil
        await backfillUserIdIfNeeded()
        await loadConversationContext()
        let requestedId = conversationId
        do {
            let fetched = try await chatService.loadMessages(conversationId: requestedId)
            guard currentConversationId == requestedId else { return }
            messages = fetched
        } catch {
            guard currentConversationId == requestedId else { return }
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadPostDetails() async {
        guard let postId else { return }
        isPostDetailsLoading = true
        do {
            let post = try await postService.fetchPost(id: postId)
            postDetails = ChatPostDetails(from: post)
        } catch {
            if postDetails == nil, let conversation = try? await chatService.findConversation(id: conversationId),
               let embedded = conversation.post {
                postDetails = ChatPostDetails(from: embedded)
            }
        }
        isPostDetailsLoading = false
    }

    // MARK: - Send

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        isSending = true
        inputText = ""

        do {
            _ = try await chatService.sendMessage(conversationId: conversationId, body: text)
            let refreshed = try await chatService.loadMessages(conversationId: conversationId)
            messages = refreshed
        } catch {
            errorMessage = error.localizedDescription
            inputText = text
        }
        isSending = false
    }

    func sendImage(_ imageData: Data) async {
        guard !imageData.isEmpty, !isSending else { return }

        isSending = true
        do {
            _ = try await chatService.sendImageMessage(conversationId: conversationId, imageData: imageData)
            let refreshed = try await chatService.loadMessages(conversationId: conversationId)
            messages = refreshed
        } catch {
            errorMessage = error.localizedDescription
        }
        isSending = false
    }

    // MARK: - Block & shortlist

    func blockUser() async -> Bool {
        guard let otherUserId, otherUserId > 0, !isBlocking else { return false }

        isBlocking = true
        errorMessage = nil
        defer { isBlocking = false }

        do {
            try await chatService.blockUser(userId: otherUserId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func shortlist() async {
        guard !isShortlisting, !isDealGrabbed else { return }

        isShortlisting = true
        errorMessage = nil
        defer { isShortlisting = false }

        do {
            try await chatService.grabDeal(conversationId: conversationId)
            isDealGrabbed = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - WebSocket events

    func onRealtimeMessage(_ msg: MessageItem) {
        guard msg.conversationId == nil || msg.conversationId == conversationId else { return }
        insert(msg)
    }

    // MARK: - Subscribe / unsubscribe

    func subscribeReverb() {
        ReverbManager.shared.subscribe(conversationId: conversationId) { [weak self] msg in
            Task { @MainActor [weak self] in
                self?.onRealtimeMessage(msg)
            }
        }
    }

    func unsubscribeReverb() {
        ReverbManager.shared.unsubscribe()
    }

    // MARK: - Bubble alignment

    /// Determines whether a given message was sent by the signed-in user.
    ///
    /// Resolving "me" purely from `TokenStorage.userId` is fragile — older
    /// installs may have a stale or missing value. To keep bubble alignment
    /// correct in every case we cross-check against the other party's id (from
    /// the conversation context). If the message's sender is unambiguously the
    /// OTHER user, we treat the message as inbound; everything else falls back
    /// to the stored "my id" comparison.
    func isSentByMe(_ message: MessageItem) -> Bool {
        guard let senderId = message.resolvedSenderId else {
            // No sender id available: assume optimistic outbound (e.g. the
            // locally appended echo of a just-sent message).
            return true
        }

        if let otherId = otherUserId, otherId > 0 {
            return senderId != otherId
        }

        let myId = myUserId
        if myId > 0 {
            return senderId == myId
        }

        // We know neither side — best we can do is keep messages on the left
        // (receiver style) until context loads.
        return false
    }

    // MARK: - Private helpers

    private func insert(_ msg: MessageItem) {
        if let msgId = msg.id {
            if messages.contains(where: { $0.id != nil && $0.id == msgId }) { return }
        }
        messages.insert(msg, at: 0)
    }

    private func backfillUserIdIfNeeded() async {
        // Always re-verify the signed-in user's id when opening a chat. Older
        // builds may have persisted the wrong value (e.g. a profile row id
        // instead of the user id), which would otherwise cause every outbound
        // message to render on the receiver side.
        let stored = TokenStorage.shared.userId
        let refreshed = await UserIdBackfill.ensureStored(
            userService: userService,
            forceRefresh: true
        )
        currentUserId = refreshed > 0 ? refreshed : stored
    }

    private func loadConversationContext() async {
        guard let conversation = try? await chatService.findConversation(id: conversationId) else {
            if postId != nil, postDetails == nil {
                await loadPostDetails()
            }
            return
        }

        if postId == nil {
            postId = conversation.postId ?? conversation.post?.id
        }
        if otherUserId == nil {
            otherUserId = Self.otherUserId(from: conversation, myId: currentUserId)
        }
        if let dealGrabbed = conversation.dealGrabbed {
            isDealGrabbed = dealGrabbed
        }
        if postDetails == nil, let embedded = conversation.post {
            postDetails = ChatPostDetails(from: embedded)
        }
        await loadPostDetails()
    }

    static func otherUserId(from conversation: ChatConversation, myId: Int) -> Int? {
        if let initiatorId = conversation.initiatorId, initiatorId == myId {
            return conversation.receiverId ?? conversation.receiver?.id
        }
        return conversation.initiatorId ?? conversation.initiator?.id
    }
}
