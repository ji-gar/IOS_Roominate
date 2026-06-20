import Foundation

enum PostDraftAPI {
    static func city(_ value: String) -> String {
        IndianLocationsService.normalizedCityName(value)
    }

    static func propertyType(_ value: String) -> String {
        mapCommaSeparated(value) { part in
            switch part.uppercased().replacingOccurrences(of: " ", with: "") {
            case "3BHK": return "3 BHK"
            case "2BHK": return "2 BHK"
            case "1BHK": return "1 BHK"
            case "4BHK+", "4BHK": return "4 BHK+"
            case "ANY": return "any"
            case "OTHER": return "other"
            default: return part
            }
        }
    }

    static func typeOfSpace(_ value: String) -> String {
        switch value {
        case "Shared Room": return "sharing"
        case "Private Room": return "private"
        default: return value.lowercased()
        }
    }

    static func homeFurnishing(_ value: String) -> String {
        mapCommaSeparated(value) { part in
            switch part.lowercased() {
            case "ful furn.", "fully furnished", "full furn.": return "fully_furnished"
            case "half", "semi furnished", "semi": return "semi_furnished"
            case "non furn.", "unfurnished", "non furnished": return "unfurnished"
            default:
                return part.lowercased().replacingOccurrences(of: " ", with: "_")
            }
        }
    }

    static func flatmatePreference(_ value: String) -> String {
        mapCommaSeparated(value) { part in
            switch part.lowercased() {
            case "male": return "male"
            case "female": return "female"
            case "any": return "any"
            default: return part.lowercased()
            }
        }
    }

    static func foodPreference(_ value: String) -> String {
        mapCommaSeparated(value) { part in
            switch part.lowercased() {
            case "veg": return "veg"
            case "non veg", "non_veg", "non-veg": return "non_veg"
            default: return part.lowercased().replacingOccurrences(of: " ", with: "_")
            }
        }
    }

    static func smoking(_ value: String) -> String {
        mapCommaSeparated(value) { part in
            switch part.lowercased() {
            case "yes", "smoker": return "yes"
            case "no", "non smoker", "non_smoker": return "no"
            default: return part.lowercased()
            }
        }
    }

    static func profession(_ value: String) -> String {
        mapCommaSeparated(value) { part in
            switch part.lowercased() {
            case "student": return "student"
            case "working", "working professional": return "working"
            default: return part.lowercased()
            }
        }
    }

    private static func mapCommaSeparated(_ value: String, transform: (String) -> String) -> String {
        value
            .split(separator: ",")
            .map { transform(String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
            .filter { !$0.isEmpty }
            .joined(separator: ",")
    }
}
