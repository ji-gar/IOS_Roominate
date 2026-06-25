import Foundation
import Combine

@MainActor
final class StartChatViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let chatService: ChatServiceProtocol

    init(chatService: ChatServiceProtocol? = nil) {
        self.chatService = chatService ?? ChatService()
    }

    func startChat(
        postId: Int,
        receiverName: String,
        onSuccess: @escaping (Int, String, Int?, Int?) -> Void
    ) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let conversation = try await chatService.startChat(
                postId: postId,
                message: "Hi, I'm interested in your listing!"
            )
            guard let convId = conversation.id else {
                errorMessage = "Could not start conversation."
                isLoading = false
                return
            }
            let myId = TokenStorage.shared.userId
            var otherName = receiverName
            if let initiatorId = conversation.initiatorId, initiatorId == myId {
                otherName = conversation.receiver?.name ?? receiverName
            } else {
                otherName = conversation.initiator?.name ?? receiverName
            }
            let resolvedPostId = conversation.postId ?? conversation.post?.id ?? postId
            let otherUserId = ChatViewModel.otherUserId(from: conversation, myId: myId)
            onSuccess(convId, otherName, resolvedPostId, otherUserId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
