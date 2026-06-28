import Combine
import SwiftUI

@MainActor
final class SavedPostsStore: ObservableObject {
    @Published private(set) var savedIDs: Set<Int> = []
    @Published private(set) var togglingIDs: Set<Int> = []

    private let service: SavedPostsServiceProtocol

    init(service: SavedPostsServiceProtocol = SavedPostsService()) {
        self.service = service
    }

    func load() async {
        guard let ids = try? await service.fetchSavedPostIDs() else { return }
        savedIDs = ids
    }

    func isSaved(_ id: Int) -> Bool {
        savedIDs.contains(id)
    }

    func isToggling(_ id: Int) -> Bool {
        togglingIDs.contains(id)
    }

    func toggleSave(postId: Int) async {
        guard !togglingIDs.contains(postId) else { return }

        togglingIDs.insert(postId)
        defer { togglingIDs.remove(postId) }

        let wasSaved = savedIDs.contains(postId)
        if wasSaved {
            savedIDs.remove(postId)
        } else {
            savedIDs.insert(postId)
        }

        do {
            if wasSaved {
                try await service.unsavePost(postId: postId)
            } else {
                try await service.savePost(postId: postId)
            }
        } catch {
            if wasSaved {
                savedIDs.insert(postId)
            } else {
                savedIDs.remove(postId)
            }
        }
    }
}
