import Combine
import CoreLocation
import Foundation

struct PlaceSuggestion: Identifiable, Equatable {
    let id: String
    let mainText: String
    let secondaryText: String
    
    var entityType: EntityType {
        // All results come from Google Places API
        // Infer type from the response structure
        if secondaryText.isEmpty {
            return .city
        }
        return .locality
    }

    var fullText: String {
        secondaryText.isEmpty ? mainText : "\(mainText), \(secondaryText)"
    }
    
    enum EntityType: String {
        case society
        case landmark
        case locality
        case city
        
        var iconName: String {
            switch self {
            case .society: return "building.2.fill"
            case .landmark: return "mappin.and.ellipse"
            case .locality: return "map"
            case .city: return "building.columns.fill"
            }
        }
        
        var displayName: String {
            rawValue.capitalized
        }
    }
}

struct PlaceDetails {
    let coordinate: CLLocationCoordinate2D
    let landmark: String
    let area: String
    let city: String
    let state: String
    let pincode: String
    let formattedAddress: String
}

enum PlacesSearchMode: Equatable {
    case cities
    case address
    case landmarks(city: String)
}

@MainActor
final class GooglePlacesService: ObservableObject {
    @Published var suggestions: [PlaceSuggestion] = []
    @Published var isLoading = false

    private var searchTask: Task<Void, Never>?
    private var sequenceNumber: UInt64 = 0
    
    func search(query: String, mode: PlacesSearchMode = .cities) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            suggestions = []
            return
        }

        sequenceNumber &+= 1
        let currentSeq = sequenceNumber

        searchTask = Task {
            // Debounce: 250ms as per spec
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }

            isLoading = true
            defer { isLoading = false }

            let key = APIConstants.googlePlacesAPIKey

            // ✅ DEBUG: Log API key status
            print("🔑 Google Places API Key present: \(!key.isEmpty)")
            print("🔍 Searching for: '\(trimmed)'")

            guard !key.isEmpty else {
                // No API key - can't search
                print("❌ No Google Places API key configured!")
                suggestions = []
                return
            }

            // ✅ Use ONLY Google Places API (no local data)
            let remoteResults = await fetchRemoteSuggestions(query: trimmed, mode: mode, apiKey: key)
            
            print("✅ Got \(remoteResults.count) results from Google")
            
            // Stale-response guard: only update if this is still the latest search
            guard !Task.isCancelled, currentSeq >= sequenceNumber else { return }

            suggestions = remoteResults
        }
    }

    func fetchPlaceDetails(placeId: String) async -> PlaceDetails? {
        let key = APIConstants.googlePlacesAPIKey
        guard !key.isEmpty else { return nil }

        // ✅ Request comprehensive fields from Google
        let fields = "geometry,address_components,formatted_address,name,types"
        let sessionToken = UUID().uuidString
        let urlString =
            "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=\(fields)&sessiontoken=\(sessionToken)&key=\(key)"

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
            guard response.status == "OK", let result = response.result else { return nil }

            let components = result.addressComponents
            let coordinate = CLLocationCoordinate2D(
                latitude: result.geometry.location.lat,
                longitude: result.geometry.location.lng
            )

            // Extract address components
            let streetNumber = firstComponent(in: components, types: ["street_number"])
            let route = firstComponent(in: components, types: ["route"])
            let premise = firstComponent(in: components, types: ["premise"])
            let establishment = firstComponent(in: components, types: ["establishment"])
            
            let area = firstComponent(in: components, types: [
                "sublocality_level_1", "sublocality_level_2", "neighborhood", "sublocality", "locality"
            ])
            
            let city = firstComponent(in: components, types: [
                "locality", "administrative_area_level_2"
            ])
            
            let state = firstComponent(in: components, types: ["administrative_area_level_1"])
            let pincode = firstComponent(in: components, types: ["postal_code"])
            
            // Build landmark with priority logic
            var landmark = ""
            if !establishment.isEmpty {
                landmark = establishment
            } else if !premise.isEmpty {
                landmark = premise
            } else if let name = result.name, !name.isEmpty {
                landmark = name
            } else if !streetNumber.isEmpty || !route.isEmpty {
                landmark = [streetNumber, route].filter { !$0.isEmpty }.joined(separator: " ")
            } else {
                landmark = result.formattedAddress
            }

            return PlaceDetails(
                coordinate: coordinate,
                landmark: landmark,
                area: area,
                city: city,
                state: state,
                pincode: pincode,
                formattedAddress: result.formattedAddress
            )
        } catch {
            print("❌ Place Details Error: \(error)")
            return nil
        }
    }

    func clear() {
        searchTask?.cancel()
        suggestions = []
    }

    func resolveSuggestion(_ suggestion: PlaceSuggestion, mode: PlacesSearchMode) async -> PlaceDetails {
        // ✅ Always use Google Places API for place details
        if let details = await fetchPlaceDetails(placeId: suggestion.id) {
            return details
        }

        // Fallback: Try geocoding the text if Google fails
        return await GeocodingService.placeDetails(from: suggestion, mode: mode)
    }

    private func fetchRemoteSuggestions(
        query: String,
        mode: PlacesSearchMode,
        apiKey: String
    ) async -> [PlaceSuggestion] {
        let searchQuery: String
        
        switch mode {
        case .cities:
            searchQuery = query
            
        case .landmarks(let city):
            // For landmarks, append city for better context
            searchQuery = city.isEmpty ? query : "\(query), \(city)"
            
        case .address:
            searchQuery = query
        }

        let encoded = searchQuery.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? searchQuery
        
        // ✅ Session token for cost optimization
        let sessionToken = UUID().uuidString
        
        // ✅ Build URL based on mode
        var urlString = """
https://maps.googleapis.com/maps/api/place/autocomplete/json?\
input=\(encoded)\
&components=country:in\
&sessiontoken=\(sessionToken)\
&key=\(apiKey)
"""
        
        // Add type restrictions based on mode
        switch mode {
        case .cities:
            urlString += "&types=(cities)"
        case .landmarks:
            urlString += "&types=establishment|point_of_interest"
        case .address:
            // ✅ No type restriction for address mode - let Google return best matches
            // This gives the most comprehensive results like Google Maps
            break
        }
        
        // Remove newlines from the URL string
        urlString = urlString.replacingOccurrences(of: "\n", with: "")

        print("🌐 Google Places API URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return []
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
            }
            
            // Try to decode the response
            let apiResponse = try JSONDecoder().decode(AutocompleteResponse.self, from: data)
            
            print("📊 API Status: \(apiResponse.status)")
            print("📍 Predictions count: \(apiResponse.predictions.count)")
            
            if apiResponse.status != "OK" && apiResponse.status != "ZERO_RESULTS" {
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("⚠️ API Response: \(jsonString)")
                }
            }
            
            return apiResponse.predictions.map { prediction in
                PlaceSuggestion(
                    id: prediction.placeId,
                    mainText: prediction.structuredFormatting.mainText,
                    secondaryText: prediction.structuredFormatting.secondaryText ?? ""
                )
            }
        } catch {
            print("❌ Google Places API Error: \(error)")
            return []
        }
    }

    private func firstComponent(in components: [AddressComponent], types: [String]) -> String {
        components.first { component in
            types.contains(where: { component.types.contains($0) })
        }?.longName ?? ""
    }
}

// MARK: - Response Models

private struct AutocompleteResponse: Decodable {
    let predictions: [Prediction]
    let status: String

    struct Prediction: Decodable {
        let placeId: String
        let structuredFormatting: StructuredFormatting

        enum CodingKeys: String, CodingKey {
            case placeId = "place_id"
            case structuredFormatting = "structured_formatting"
        }
    }

    struct StructuredFormatting: Decodable {
        let mainText: String
        let secondaryText: String?

        enum CodingKeys: String, CodingKey {
            case mainText = "main_text"
            case secondaryText = "secondary_text"
        }
    }
}

private struct PlaceDetailsResponse: Decodable {
    let result: PlaceResult?
    let status: String

    struct PlaceResult: Decodable {
        let formattedAddress: String
        let geometry: Geometry
        let addressComponents: [AddressComponent]
        let name: String?  // ✅ ADDED: Place name (building/society name from Google)
        let types: [String]?  // ✅ ADDED: Place types for better categorization

        enum CodingKeys: String, CodingKey {
            case formattedAddress = "formatted_address"
            case geometry
            case addressComponents = "address_components"
            case name
            case types
        }
    }

    struct Geometry: Decodable {
        let location: Location
    }

    struct Location: Decodable {
        let lat: Double
        let lng: Double
    }
}

private struct AddressComponent: Decodable {
    let longName: String
    let types: [String]

    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case types
    }
}
