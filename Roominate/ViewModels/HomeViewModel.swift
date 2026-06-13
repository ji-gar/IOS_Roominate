import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var segment: ListingSegment = .flat
    @Published var searchText: String = ""
    @Published private(set) var flatListings: [FlatListing] = MockListings.flats
    @Published private(set) var flatmateListings: [FlatmateListing] = MockListings.flatmates
    @Published private var favoriteIDs: Set<UUID> = []

    var filteredFlats: [FlatListing] {
        guard !searchText.isEmpty else { return flatListings }
        return flatListings.filter {
            $0.location.localizedCaseInsensitiveContains(searchText)
                || $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var filteredFlatmates: [FlatmateListing] {
        guard !searchText.isEmpty else { return flatmateListings }
        return flatmateListings.filter {
            $0.location.localizedCaseInsensitiveContains(searchText)
                || $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    func isFavorite(_ id: UUID) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggleFavorite(_ id: UUID) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
    }
}
