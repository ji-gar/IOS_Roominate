import CoreLocation
import Foundation

enum IndianLocationsService {
    static let cities: [String] = [
        "Ahmedabad", "Agra", "Ajmer", "Aligarh", "Amritsar", "Aurangabad",
        "Bangalore", "Bengaluru", "Bhopal", "Bhubaneswar", "Chandigarh",
        "Chennai", "Coimbatore", "Dehradun", "Delhi", "New Delhi",
        "Faridabad", "Ghaziabad", "Goa", "Gurugram", "Guwahati",
        "Gwalior", "Hyderabad", "Indore", "Jaipur", "Jalandhar",
        "Jammu", "Jamshedpur", "Jodhpur", "Kanpur", "Kochi",
        "Kolkata", "Kota", "Lucknow", "Ludhiana", "Madurai",
        "Mangalore", "Meerut", "Mumbai", "Mysuru", "Nagpur",
        "Nashik", "Noida", "Patna", "Pune", "Raipur",
        "Rajkot", "Ranchi", "Srinagar", "Surat", "Thane",
        "Thiruvananthapuram", "Trivandrum", "Udaipur", "Vadodara", "Varanasi",
        "Visakhapatnam", "Vijayawada", "Warangal"
    ]

    private static let landmarksByCity: [String: [String]] = [
        "Ahmedabad": [
            "Thaltej", "CG Road", "C.G. Road", "Satellite", "Bopal",
            "Maninagar", "Vastrapur", "Navrangpura", "Paldi", "Ashram Road",
            "Bodakdev", "SG Highway", "S.G. Highway", "Science City",
            "Gota", "Naranpura", "Ellisbridge", "Law Garden", "Memnagar",
            "Ambawadi", "Jodhpur Village", "Shilaj", "Shela", "Gift City"
        ],
        "Mumbai": [
            "Andheri", "Bandra", "Borivali", "Colaba", "Dadar",
            "Goregaon", "Juhu", "Kandivali", "Lower Parel", "Malad",
            "Powai", "Thane", "Vashi", "Worli"
        ],
        "Thane": [
            "Ghodbunder Road", "Hiranandani Estate", "Kolshet", "Majiwada", "Naupada"
        ],
        "Bengaluru": [
            "Koramangala", "Indiranagar", "Whitefield", "HSR Layout",
            "Electronic City", "Marathahalli", "Jayanagar", "MG Road"
        ],
        "Bangalore": [
            "Koramangala", "Indiranagar", "Whitefield", "HSR Layout",
            "Electronic City", "Marathahalli", "Jayanagar", "MG Road"
        ],
        "Delhi": [
            "Connaught Place", "Dwarka", "Karol Bagh", "Lajpat Nagar",
            "Rohini", "Saket", "Vasant Kunj", "Hauz Khas"
        ],
        "New Delhi": [
            "Connaught Place", "Dwarka", "Karol Bagh", "Lajpat Nagar",
            "Rohini", "Saket", "Vasant Kunj", "Hauz Khas"
        ],
        "Pune": [
            "Hinjewadi", "Kothrud", "Baner", "Wakad", "Koregaon Park",
            "Viman Nagar", "Aundh", "Hadapsar"
        ],
        "Hyderabad": [
            "Banjara Hills", "Gachibowli", "Hitech City", "Jubilee Hills",
            "Kondapur", "Madhapur", "Secunderabad"
        ],
        "Chennai": [
            "Adyar", "Anna Nagar", "OMR", "T Nagar", "Velachery", "Porur"
        ],
        "Gurugram": [
            "Cyber City", "DLF Phase 1", "DLF Phase 3", "Golf Course Road",
            "MG Road", "Sohna Road", "Sector 29"
        ],
        "Kolkata": [
            "Park Street", "Salt Lake", "New Town", "Ballygunge", "Howrah"
        ]
    ]

    static func matchingCities(for query: String, limit: Int = 8) -> [PlaceSuggestion] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.count >= 2 else { return [] }

        let lowercasedQuery = normalized.lowercased()
        let matches = cities.filter { city in
            city.lowercased().contains(lowercasedQuery)
        }

        return Array(matches.prefix(limit)).map { city in
            PlaceSuggestion(
                id: "local-city-\(city)",
                mainText: city,
                secondaryText: "India"
            )
        }
    }

    static func matchingLandmarks(for query: String, city: String, limit: Int = 8) -> [PlaceSuggestion] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedQuery.count >= 2 else { return [] }

        let cityKey = normalizedCityName(city)
        let lowercasedQuery = normalizedQuery.lowercased()

        if cityKey.isEmpty {
            return matchingLandmarksAcrossCities(for: normalizedQuery, limit: limit)
        }

        let landmarks = landmarksByCity[cityKey] ?? []
        let matches = landmarks.filter { landmark in
            landmark.lowercased().contains(lowercasedQuery)
        }

        return Array(matches.prefix(limit)).map { landmark in
            PlaceSuggestion(
                id: "local-landmark-\(cityKey)-\(landmark)",
                mainText: landmark,
                secondaryText: "\(cityKey), India"
            )
        }
    }

    static func matchingAddresses(for query: String, limit: Int = 8) -> [PlaceSuggestion] {
        var results: [PlaceSuggestion] = []
        var seen = Set<String>()

        for suggestion in matchingCities(for: query, limit: limit) {
            let key = suggestion.mainText.lowercased()
            guard seen.insert(key).inserted else { continue }
            results.append(suggestion)
        }

        for suggestion in matchingLandmarksAcrossCities(for: query, limit: limit) {
            let key = "\(suggestion.mainText.lowercased())-\(suggestion.secondaryText.lowercased())"
            guard seen.insert(key).inserted else { continue }
            results.append(suggestion)
            if results.count >= limit { break }
        }

        return Array(results.prefix(limit))
    }

    static func matchingLandmarksAcrossCities(for query: String, limit: Int = 8) -> [PlaceSuggestion] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedQuery.count >= 2 else { return [] }

        let lowercasedQuery = normalizedQuery.lowercased()
        var results: [PlaceSuggestion] = []

        for (city, landmarks) in landmarksByCity.sorted(by: { $0.key < $1.key }) {
            for landmark in landmarks where landmark.lowercased().contains(lowercasedQuery) {
                results.append(
                    PlaceSuggestion(
                        id: "local-landmark-\(city)-\(landmark)",
                        mainText: landmark,
                        secondaryText: "\(city), India"
                    )
                )
                if results.count >= limit { return results }
            }
        }

        return results
    }

    static func city(fromLandmarkSecondary secondary: String) -> String {
        let parts = secondary
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.lowercased() != "india" }
        return parts.first ?? normalizedCityName(secondary)
    }

    static func normalizedCityName(_ city: String) -> String {
        let trimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains(",") {
            return trimmed.components(separatedBy: ",").first?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? trimmed
        }
        return trimmed
    }

    static func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        coordinate.latitude != 0 || coordinate.longitude != 0
    }
}
