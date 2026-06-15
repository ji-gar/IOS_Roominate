import Combine
import Foundation
import MapKit
import SwiftUI

// MARK: - Amenity Model

struct AmenityItem: Identifiable, Hashable {
    let id: String
    let label: String
    let icon: String

    static let all: [AmenityItem] = [
        AmenityItem(id: "wifi",     label: "Wifi",     icon: "wifi"),
        AmenityItem(id: "tv",       label: "TV",        icon: "tv"),
        AmenityItem(id: "washing",  label: "Washing",   icon: "washer"),
        AmenityItem(id: "fridge",   label: "Fridge",    icon: "refrigerator"),
        AmenityItem(id: "ro_water", label: "RO Water",  icon: "drop.fill"),
        AmenityItem(id: "parking",  label: "Parking",   icon: "p.circle.fill"),
        AmenityItem(id: "maid",     label: "Maid",      icon: "hands.sparkles.fill"),
        AmenityItem(id: "ac",       label: "AC",        icon: "snowflake"),
    ]
}

enum AmenityRoom: String, CaseIterable, Identifiable {
    case livingRoom = "Living Room"
    case bedRoom    = "Bed Room"
    case bathRoom   = "Bath Room"

    var id: String { rawValue }
}

// MARK: - ViewModel

@MainActor
final class CreatePostViewModel: ObservableObject {

    @Published var draft: PostDraft
    @Published var selectedAmenities: [String: Set<String>] = [:]
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    // Map state (default: Ahmedabad)
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 23.022505, longitude: 72.571365),
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    )

    init(postType: Bool = true) {
        var d = PostDraft()
        d.postType = postType
        self.draft = d
    }

    // MARK: Validation

    var isPropertyDetailsValid: Bool {
        !draft.city.isEmpty &&
        !draft.propertyType.isEmpty &&
        !draft.typeOfSpace.isEmpty &&
        !draft.homeFurnishing.isEmpty
    }

    var isLocationValid: Bool {
        !draft.area.isEmpty && !draft.city.isEmpty
    }

    // MARK: Amenity helpers

    func isAmenitySelected(room: AmenityRoom, amenity: AmenityItem) -> Bool {
        selectedAmenities[room.rawValue]?.contains(amenity.id) ?? false
    }

    func toggleAmenity(room: AmenityRoom, amenity: AmenityItem) {
        if selectedAmenities[room.rawValue] == nil {
            selectedAmenities[room.rawValue] = []
        }
        if selectedAmenities[room.rawValue]!.contains(amenity.id) {
            selectedAmenities[room.rawValue]!.remove(amenity.id)
        } else {
            selectedAmenities[room.rawValue]!.insert(amenity.id)
        }
        syncAmenities()
    }

    private func syncAmenities() {
        var flat: [String] = []
        for items in selectedAmenities.values {
            flat.append(contentsOf: items)
        }
        draft.amenities = Array(Set(flat))
    }

    // MARK: Submit

    func submit(postService: PostServiceProtocol) async -> Bool {
        buildAutoTitle()
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            _ = try await postService.createPost(draft)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func buildAutoTitle() {
        guard draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let parts = [draft.propertyType, draft.typeOfSpace, draft.city.isEmpty ? nil : "in \(draft.city)"]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        draft.title = parts.isEmpty ? "My Listing" : parts.joined(separator: " ")
    }
}
