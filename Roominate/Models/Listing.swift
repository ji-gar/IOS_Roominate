import Foundation

enum ListingSegment: String, CaseIterable, Identifiable {
    case flat = "Flat"
    case flatmate = "Flat-mate"

    var id: String { rawValue }
}

struct ListingAuthor: Hashable {
    let name: String
    let role: String
    let avatarURL: String?
}

/// A "Flat" listing: someone offering a flat / room and looking for a flatmate.
struct FlatListing: Identifiable, Hashable {
    let id = UUID()
    let author: ListingAuthor
    let imageURLs: [String]
    let title: String
    let location: String
    let lookingFor: String
    let deposit: String
    let rent: String
    let moveIn: String
    let amenities: String
    let isShortStay: Bool
    let isFeatured: Bool

    // Detail
    let monthlyRent: String
    let isAvailable: Bool
    let propertyType: String
    let roomType: String
    let furnishing: String
    let moveInDate: String
    let securityDeposit: String
    let brokerage: String
    let utilities: String
    let genderPreference: String
    let foodPreference: String
    let smokingPreference: String
    let occupation: String
}

/// A "Flat-mate" listing: someone looking for a flat / room to join.
struct FlatmateListing: Identifiable, Hashable {
    let id = UUID()
    let author: ListingAuthor
    let title: String
    let location: String
    let lookingFor: String
    let maxBudget: String
    let fromDate: String
    let toDate: String?
    let isShortStay: Bool
    let isFeatured: Bool
    let tags: [String]

    // Detail
    let maxBudgetMonthly: String
    let isAvailable: Bool
    let preferredAreas: [String]
    let propertyType: String
    let roomType: String
    let furnishing: String
    let duration: String
    let moveInDate: String
    let moveOutDate: String
    let genderPreference: String
    let foodPreference: String
    let smokingPreference: String
    let occupation: String
    let lifestyleNotes: [String]
    let aboutMe: String
}
