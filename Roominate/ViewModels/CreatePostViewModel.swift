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

// MARK: - Draft Image

struct DraftImage: Identifiable, Hashable {
    let id = UUID()
    let data: Data
    let image: UIImage
}

// MARK: - Preference Options

enum FlatmatePreferenceOption: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case any = "Any"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .male: return "person.fill"
        case .female: return "person.fill"
        case .any: return "person.2.fill"
        }
    }
}

enum FoodPreferenceOption: String, CaseIterable, Identifiable {
    case veg = "Veg"
    case nonVeg = "Non Veg"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .veg: return "leaf.fill"
        case .nonVeg: return "fork.knife"
        }
    }
}

enum SmokingOption: String, CaseIterable, Identifiable {
    case smoker = "Smoker"
    case nonSmoker = "Non Smoker"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .smoker: return "smoke.fill"
        case .nonSmoker: return "nosign"
        }
    }
    /// Value sent to the API `smoking` field.
    var apiValue: String {
        switch self {
        case .smoker: return "Yes"
        case .nonSmoker: return "No"
        }
    }
}

enum ProfessionOption: String, CaseIterable, Identifiable {
    case student = "Student"
    case working = "Working"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .student: return "graduationcap.fill"
        case .working: return "briefcase.fill"
        }
    }
}

// MARK: - ViewModel

@MainActor
final class CreatePostViewModel: ObservableObject {

    @Published var draft: PostDraft
    @Published var selectedAmenities: [String: Set<String>] = [:]
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    @Published var availableFromDate: Date? {
        didSet { draft.availableFrom = Self.apiDateString(availableFromDate) }
    }
    @Published var availableToDate: Date? {
        didSet { draft.availableTo = Self.apiDateString(availableToDate) }
    }
    @Published var images: [DraftImage] = [] {
        didSet { draft.imageData = images.map(\.data) }
    }

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

    var isAvailabilityValid: Bool {
        !draft.monthlyRent.isEmpty &&
        !draft.deposit.isEmpty &&
        !draft.availableFrom.isEmpty &&
        (draft.lookingForLongTerm || !draft.availableTo.isEmpty)
    }

    var isPreferencesValid: Bool {
        !draft.flatmatePreference.isEmpty &&
        !draft.foodPreference.isEmpty &&
        !draft.smoking.isEmpty &&
        !draft.profession.isEmpty
    }

    var isDescriptionValid: Bool {
        !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: Image helpers

    func addImages(_ datas: [Data]) {
        for data in datas {
            guard let image = UIImage(data: data) else { continue }
            images.append(DraftImage(data: data, image: image))
        }
    }

    func removeImage(_ id: UUID) {
        images.removeAll { $0.id == id }
    }

    // MARK: Date helpers

    func displayDate(for value: String) -> String {
        guard !value.isEmpty, let date = Self.apiDateFormatter.date(from: value) else { return "" }
        return Self.displayDateFormatter.string(from: date)
    }

    static func apiDateString(_ date: Date?) -> String {
        guard let date else { return "" }
        return apiDateFormatter.string(from: date)
    }

    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

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
        draft.amenities = Array(Set(flat)).compactMap { id in
            AmenityItem.all.first(where: { $0.id == id })?.label
        }
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
