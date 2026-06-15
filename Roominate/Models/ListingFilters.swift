import Foundation

/// All user-selectable filters for the listing feed.
/// Mirrors the fields supported by `PostQuery` so it can be applied directly to a network request.
struct ListingFilters: Equatable {
    // Rent range (₹). Slider bounds are defined by `Self.rentBounds`.
    var minRent: Double = rentBounds.lowerBound
    var maxRent: Double = rentBounds.upperBound

    var city: String?
    var propertyType: PropertyType?
    var lookingFor: LookingFor = .any
    var roomType: RoomType?
    var furnishing: Set<Furnishing> = []
    var moveInFrom: Date?
    var moveInTo: Date?
    var amenities: Set<Amenity> = []

    static let rentBounds: ClosedRange<Double> = 0...50_000
    static let rentStep: Double = 1_000

    static let cities = [
        "Mumbai", "Bengaluru", "Hyderabad", "Delhi",
        "Gurugram", "Ahmedabad", "Chennai"
    ]

    enum PropertyType: String, CaseIterable, Identifiable {
        case one = "1 BHK"
        case two = "2 BHK"
        case three = "3 BHK"
        case fourPlus = "4+ BHK"

        var id: String { rawValue }
        var apiValue: String { rawValue }
    }

    enum LookingFor: String, CaseIterable, Identifiable {
        case female = "Female"
        case male = "Male"
        case any = "Any"

        var id: String { rawValue }
        var apiValue: String? {
            switch self {
            case .female: return "female"
            case .male: return "male"
            case .any: return nil
            }
        }
    }

    enum RoomType: String, CaseIterable, Identifiable {
        case `private` = "Private"
        case sharing = "Sharing"

        var id: String { rawValue }
        var title: String { rawValue }
        var subtitle: String {
            switch self {
            case .private: return "Room of your own"
            case .sharing: return "Shared with others"
            }
        }
        var systemImage: String {
            switch self {
            case .private: return "bed.double.fill"
            case .sharing: return "person.2.fill"
            }
        }
        var apiValue: String {
            switch self {
            case .private: return "private"
            case .sharing: return "sharing"
            }
        }
    }

    enum Furnishing: String, CaseIterable, Identifiable {
        case fully = "Fully furnished"
        case semi = "Semi furnished"
        case unfurnished = "Unfurnished"

        var id: String { rawValue }
        var apiValue: String {
            switch self {
            case .fully: return "fully_furnished"
            case .semi: return "semi_furnished"
            case .unfurnished: return "unfurnished"
            }
        }
    }

    enum Amenity: String, CaseIterable, Identifiable {
        case sofa = "Sofa"
        case tv = "TV"
        case kitchen = "Kitchen"
        case ac = "AC"
        case wifi = "WiFi"
        case parking = "Parking"
        case washer = "Washer"
        case gym = "Gym"
        case geyser = "Geyser"
        case lift = "Lift"
        case security = "Security"
        case power = "Power"

        var id: String { rawValue }
        var apiValue: String { rawValue.lowercased() }

        var systemImage: String {
            switch self {
            case .sofa: return "sofa.fill"
            case .tv: return "tv.fill"
            case .kitchen: return "fork.knife"
            case .ac: return "snowflake"
            case .wifi: return "wifi"
            case .parking: return "parkingsign"
            case .washer: return "washer.fill"
            case .gym: return "dumbbell.fill"
            case .geyser: return "flame.fill"
            case .lift: return "arrow.up.arrow.down"
            case .security: return "shield.fill"
            case .power: return "bolt.fill"
            }
        }
    }

    // MARK: - Helpers

    var isDefault: Bool {
        self == ListingFilters()
    }

    /// Number of distinct sections actively narrowing the results, used for a badge on the filter button.
    var activeCount: Int {
        var count = 0
        if minRent > Self.rentBounds.lowerBound || maxRent < Self.rentBounds.upperBound { count += 1 }
        if city != nil { count += 1 }
        if propertyType != nil { count += 1 }
        if lookingFor != .any { count += 1 }
        if roomType != nil { count += 1 }
        if !furnishing.isEmpty { count += 1 }
        if moveInFrom != nil || moveInTo != nil { count += 1 }
        if !amenities.isEmpty { count += 1 }
        return count
    }

    mutating func reset() {
        self = ListingFilters()
    }

    /// Applies the active filters onto a base query (which already carries `postType`, paging and search city).
    func apply(to query: inout PostQuery) {
        if minRent > Self.rentBounds.lowerBound {
            query.minRent = Int(minRent)
        }
        if maxRent < Self.rentBounds.upperBound {
            query.maxRent = Int(maxRent)
        }
        if let city, !city.isEmpty {
            query.city = city
        }
        query.propertyType = propertyType?.apiValue
        query.lookingFor = lookingFor.apiValue
        query.roomType = roomType?.apiValue

        if !furnishing.isEmpty {
            query.furnishing = furnishing
                .sorted { $0.rawValue < $1.rawValue }
                .map(\.apiValue)
                .joined(separator: ",")
        }

        if let moveInFrom {
            query.movedInFrom = Self.apiDateFormatter.string(from: moveInFrom)
        }
        if let moveInTo {
            query.movedInTo = Self.apiDateFormatter.string(from: moveInTo)
        }

        if !amenities.isEmpty {
            query.amenities = amenities
                .sorted { $0.rawValue < $1.rawValue }
                .map(\.apiValue)
                .joined(separator: ",")
        }
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
}
