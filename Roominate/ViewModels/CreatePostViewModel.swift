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
        AmenityItem(id: "tv",       label: "Tv",        icon: "tv"),
        AmenityItem(id: "washing",  label: "Washing",   icon: "washer"),
        AmenityItem(id: "fridge",   label: "Fridge",    icon: "refrigerator"),
        AmenityItem(id: "ro_water", label: "RO Water",  icon: "drop.fill"),
        AmenityItem(id: "parking",  label: "Parking",   icon: "p.circle.fill"),
        AmenityItem(id: "maid",     label: "Maid",      icon: "hands.sparkles.fill"),
        AmenityItem(id: "ac",       label: "Ac",        icon: "snowflake"),
    ]
}

enum AmenityRoom: String, CaseIterable, Identifiable {
    case livingRoom = "Living Room"
    case bedRoom    = "Bed Room"
    case bathRoom   = "Bath Room"

    var id: String { rawValue }

    var sectionTitle: String {
        switch self {
        case .livingRoom: return "Living room Amenities"
        case .bedRoom: return "Bed room Amenities"
        case .bathRoom: return "Bath room Amenities"
        }
    }
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
    @Published var customAmenities: [String: [String]] = [:]
    @Published var customAmenityInputs: [String: String] = [:]
    @Published var showCustomAmenityField = false
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    static let minimumPhotoCount = 5

    @Published var availableFromDate: Date? {
        didSet { draft.availableFrom = Self.apiDateString(availableFromDate) }
    }
    @Published var availableToDate: Date? {
        didSet { draft.availableTo = Self.apiDateString(availableToDate) }
    }
    @Published var moveInImmediately = true {
        didSet {
            if moveInImmediately {
                availableFromDate = Date()
            }
        }
    }
    @Published var preferredAreaQuery = ""
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
        d.typeOfSpace = "Shared Room"
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
        !draft.extraCost.isEmpty &&
        !draft.availableFrom.isEmpty &&
        (draft.lookingForLongTerm || !draft.availableTo.isEmpty)
    }

    var isPhotosValid: Bool {
        images.count >= Self.minimumPhotoCount
    }

    var isPreferencesValid: Bool {
        !draft.flatmatePreference.isEmpty &&
        !draft.foodPreference.isEmpty &&
        !draft.smoking.isEmpty &&
        !draft.profession.isEmpty
    }

    var isSeekerLocationValid: Bool {
        !draft.city.isEmpty && !draft.preferedLocation.isEmpty
    }

    var isSeekerBudgetValid: Bool {
        !draft.monthlyRent.isEmpty &&
        (moveInImmediately || !draft.availableFrom.isEmpty)
    }

    var isSeekerPropertyValid: Bool {
        !draft.propertyType.isEmpty &&
        !draft.typeOfSpace.isEmpty &&
        !draft.homeFurnishing.isEmpty
    }

    var isDescriptionValid: Bool {
        !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: Image helpers

    static let maxImageBytes = 4_800_000

    func addImages(_ datas: [Data]) {
        for data in datas {
            guard let image = UIImage(data: data),
                  let jpegData = Self.compressedJPEGData(from: image) else { continue }
            let preview = UIImage(data: jpegData) ?? image
            images.append(DraftImage(data: jpegData, image: preview))
        }
    }

    private static func compressedJPEGData(from image: UIImage) -> Data? {
        let normalized = normalizedImage(image)
        var maxDimension: CGFloat = 1600

        while maxDimension >= 640 {
            let resized = resizedImage(normalized, maxDimension: maxDimension)
            var quality: CGFloat = 0.82

            while quality >= 0.35 {
                if let data = resized.jpegData(compressionQuality: quality),
                   data.count <= maxImageBytes {
                    return data
                }
                quality -= 0.08
            }

            maxDimension *= 0.8
        }

        return resizedImage(normalized, maxDimension: 640).jpegData(compressionQuality: 0.35)
    }

    private static func normalizedImage(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    private static func resizedImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        let largestSide = max(pixelWidth, pixelHeight)
        guard largestSide > maxDimension else { return image }

        let scale = maxDimension / largestSide
        let newSize = CGSize(width: pixelWidth * scale, height: pixelHeight * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    func recompressImagesForUpload() {
        images = images.compactMap { item in
            guard let jpegData = Self.compressedJPEGData(from: item.image) else { return nil }
            let preview = UIImage(data: jpegData) ?? item.image
            return DraftImage(data: jpegData, image: preview)
        }
    }

    func removeImage(_ id: UUID) {
        images.removeAll { $0.id == id }
    }

    // MARK: Date helpers

    func displayDate(for value: String) -> String {
        DateFormatterHelper.displayDate(from: value)
    }

    static func apiDateString(_ date: Date?) -> String {
        guard let date else { return "" }
        return DateFormatterHelper.apiDateString(from: date)
    }

    // MARK: Location helpers

    func applyPlaceDetails(_ details: PlaceDetails) {
        if !details.landmark.isEmpty { draft.landmark = details.landmark }
        if !details.area.isEmpty { draft.area = details.area }
        if !details.city.isEmpty {
            draft.city = IndianLocationsService.normalizedCityName(details.city)
        }
        if !details.state.isEmpty, details.state.lowercased() != "india" {
            draft.state = details.state
        }
        if !details.pincode.isEmpty { draft.pincode = details.pincode }
        if IndianLocationsService.isValidCoordinate(details.coordinate) {
            updateMapCenter(details.coordinate)
        }
    }

    func updateMapCenter(_ coordinate: CLLocationCoordinate2D) {
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
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

    func selectedTags(for room: AmenityRoom) -> [String] {
        var tags: [String] = []
        for amenity in AmenityItem.all where isAmenitySelected(room: room, amenity: amenity) {
            tags.append(amenity.label)
        }
        tags.append(contentsOf: customAmenities[room.rawValue] ?? [])
        return tags
    }

    func customAmenityBinding(for room: AmenityRoom) -> Binding<String> {
        Binding(
            get: { self.customAmenityInputs[room.rawValue] ?? "" },
            set: { self.customAmenityInputs[room.rawValue] = $0 }
        )
    }

    func submitCustomAmenity(for room: AmenityRoom) {
        let trimmed = (customAmenityInputs[room.rawValue] ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if customAmenities[room.rawValue] == nil {
            customAmenities[room.rawValue] = []
        }
        if !(customAmenities[room.rawValue]?.contains(trimmed) ?? false) {
            customAmenities[room.rawValue]?.append(trimmed)
        }
        customAmenityInputs[room.rawValue] = ""
        showCustomAmenityField = false
        syncAmenities()
    }

    // MARK: Preference helpers

    func isPreferenceSelected(_ value: String, in field: String) -> Bool {
        preferenceValues(in: field).contains(value)
    }

    func isMultiValueSelected(_ value: String, in field: String) -> Bool {
        isPreferenceSelected(value, in: field)
    }

    func toggleMultiValue(_ value: String, in keyPath: WritableKeyPath<PostDraft, String>) {
        togglePreference(value, in: keyPath)
    }

    var preferredAreas: [String] {
        preferenceValues(in: draft.preferedLocation)
    }

    func addPreferredArea(_ area: String) {
        let trimmed = area.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var selected = Set(preferenceValues(in: draft.preferedLocation))
        guard selected.insert(trimmed).inserted else { return }
        draft.preferedLocation = selected.sorted().joined(separator: ", ")
        preferredAreaQuery = ""
    }

    func removePreferredArea(_ area: String) {
        var selected = Set(preferenceValues(in: draft.preferedLocation))
        selected.remove(area)
        draft.preferedLocation = selected.sorted().joined(separator: ", ")
    }

    func togglePreference(_ value: String, in keyPath: WritableKeyPath<PostDraft, String>) {
        var selected = Set(preferenceValues(in: draft[keyPath: keyPath]))
        if selected.contains(value) {
            selected.remove(value)
        } else {
            selected.insert(value)
        }
        draft[keyPath: keyPath] = selected.sorted().joined(separator: ", ")
    }

    private func preferenceValues(in field: String) -> [String] {
        field
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func prepareDraftForSubmit() {
        buildAutoTitle()
        if !draft.postType {
            if draft.deposit.isEmpty { draft.deposit = "0" }
            if draft.extraCost.isEmpty { draft.extraCost = "0" }
            if moveInImmediately, draft.availableFrom.isEmpty {
                availableFromDate = Date()
            }
            let preferredAreas = PostDraftAPI.preferedLocations(draft.preferedLocation)
            if draft.area.isEmpty, let firstArea = preferredAreas.first {
                draft.area = firstArea
            }
            if draft.landmark.isEmpty, let firstArea = preferredAreas.first {
                draft.landmark = firstArea
            }
        } else {
            recompressImagesForUpload()
        }
        draft.city = IndianLocationsService.normalizedCityName(draft.city)
    }

    private func resolvePincodeIfNeeded() async {
        guard draft.pincode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let addressParts = [draft.area, draft.landmark, draft.city, draft.state]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !addressParts.isEmpty else { return }

        if let pincode = await GeocodingService.pincode(forAddress: addressParts.joined(separator: ", ")),
           !pincode.isEmpty {
            draft.pincode = pincode
        }
    }

    private func syncAmenities() {
        var flat: [String] = []
        for items in selectedAmenities.values {
            flat.append(contentsOf: items.compactMap { id in
                AmenityItem.all.first(where: { $0.id == id })?.label
            })
        }
        for custom in customAmenities.values {
            flat.append(contentsOf: custom)
        }
        draft.amenities = Array(Set(flat))
    }

    // MARK: Submit

    func submit(postService: PostServiceProtocol) async -> Bool {
        await resolvePincodeIfNeeded()
        prepareDraftForSubmit()
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
        if !draft.postType {
            let cityPart = draft.city.isEmpty ? nil : "in \(draft.city)"
            let parts = ["Looking for", draft.typeOfSpace, cityPart]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
            draft.title = parts.isEmpty ? "Looking for a Stay" : parts.joined(separator: " ")
            return
        }
        let parts = [draft.propertyType, draft.typeOfSpace, draft.city.isEmpty ? nil : "in \(draft.city)"]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        draft.title = parts.isEmpty ? "My Listing" : parts.joined(separator: " ")
    }
}
