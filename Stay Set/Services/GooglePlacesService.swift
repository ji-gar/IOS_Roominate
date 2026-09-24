import Combine
import CoreLocation
import Foundation

struct PlaceSuggestion: Identifiable, Equatable {
    let id: String
    let mainText: String
    let secondaryText: String
    
    var entityType: EntityType {
        if id.hasPrefix("local-society-") {
            return .society
        } else if id.hasPrefix("local-landmark-") {
            return .landmark
        } else if id.hasPrefix("local-city-") {
            return .city
        } else {
            // Remote results - try to infer from secondary text
            if secondaryText.isEmpty {
                return .city
            }
            return .locality
        }
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

            let localResults = localSuggestions(for: trimmed, mode: mode)
            let key = APIConstants.googlePlacesAPIKey

            guard !key.isEmpty else {
                suggestions = localResults
                return
            }

            let remoteResults = await fetchRemoteSuggestions(query: trimmed, mode: mode, apiKey: key)
            
            // Stale-response guard: only update if this is still the latest search
            guard !Task.isCancelled, currentSeq >= sequenceNumber else { return }

            suggestions = merge(localResults, remoteResults)
        }
    }

    func fetchPlaceDetails(placeId: String) async -> PlaceDetails? {
        if placeId.hasPrefix("local-") {
            return nil
        }

        let key = APIConstants.googlePlacesAPIKey
        guard !key.isEmpty else { return nil }

        // ✅ ENHANCED: Request more fields including name and types
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

            // ✅ ENHANCED: Extract more specific address components
            let streetNumber = firstComponent(in: components, types: ["street_number"])
            let route = firstComponent(in: components, types: ["route"])
            let premise = firstComponent(in: components, types: ["premise"])
            let establishment = firstComponent(in: components, types: ["establishment"])
            
            // Area with priority order: sublocality_level_1 > sublocality_level_2 > neighborhood > sublocality
            let area = firstComponent(in: components, types: [
                "sublocality_level_1", "sublocality_level_2", "neighborhood", "sublocality", "locality"
            ])
            
            let city = firstComponent(in: components, types: [
                "locality", "administrative_area_level_2"
            ])
            
            let state = firstComponent(in: components, types: ["administrative_area_level_1"])
            let pincode = firstComponent(in: components, types: ["postal_code"])
            
            // ✅ ENHANCED: Build landmark with priority logic
            // Priority: establishment > premise > name > street address > formatted address
            var landmark = ""
            if !establishment.isEmpty {
                landmark = establishment
            } else if !premise.isEmpty {
                landmark = premise
            } else if let name = result.name, !name.isEmpty {
                // Use the place name from Google (works great for societies, buildings)
                landmark = name
            } else if !streetNumber.isEmpty || !route.isEmpty {
                // Build street address
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
            return nil
        }
    }

    func clear() {
        searchTask?.cancel()
        suggestions = []
    }

    func resolveSuggestion(_ suggestion: PlaceSuggestion, mode: PlacesSearchMode) async -> PlaceDetails {
        if suggestion.id.hasPrefix("local-") || APIConstants.googlePlacesAPIKey.isEmpty {
            return await GeocodingService.placeDetails(from: suggestion, mode: mode)
        }

        if let details = await fetchPlaceDetails(placeId: suggestion.id) {
            return details
        }

        return await GeocodingService.placeDetails(from: suggestion, mode: mode)
    }

    private func localSuggestions(for query: String, mode: PlacesSearchMode) -> [PlaceSuggestion] {
        switch mode {
        case .cities:
            return IndianLocationsService.matchingCities(for: query)
        case .landmarks(let city):
            return IndianLocationsService.matchingLandmarks(for: query, city: city)
        case .address:
            return IndianLocationsService.matchingAddresses(for: query)
        }
    }

    private func fetchRemoteSuggestions(
        query: String,
        mode: PlacesSearchMode,
        apiKey: String
    ) async -> [PlaceSuggestion] {
        let searchQuery: String
        let types: String
        
        switch mode {
        case .cities:
            searchQuery = query
            types = "(cities)"
            
        case .landmarks(let city):
            let normalizedCity = IndianLocationsService.normalizedCityName(city)
            searchQuery = normalizedCity.isEmpty ? query : "\(query) \(normalizedCity)"
            types = "establishment|point_of_interest"
            
        case .address:
            searchQuery = query
            // ✅ ENHANCED: Include ALL relevant types for comprehensive address search
            // This matches Google Maps behavior across all of India:
            // - address: Full street addresses with numbers
            // - establishment: Businesses, societies, buildings
            // - premise: Specific buildings and complexes
            // - sublocality: Neighborhoods and areas within cities
            // - locality: Cities and towns
            // - geocode: Generic geocodable addresses
            types = "address|establishment|premise|sublocality|locality|geocode"
        }

        let encoded = searchQuery.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? searchQuery
        
        // ✅ FIXED: Add session token for cost optimization
        // Groups autocomplete + place details into one billable session
        let sessionToken = UUID().uuidString
        
        var urlString = """
https://maps.googleapis.com/maps/api/place/autocomplete/json?\
input=\(encoded)\
&components=country:in\
&types=\(types)\
&sessiontoken=\(sessionToken)\
&key=\(apiKey)
"""
        
        // Remove newlines from the URL string
        urlString = urlString.replacingOccurrences(of: "\n", with: "")

        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AutocompleteResponse.self, from: data)
            return response.predictions.map { prediction in
                PlaceSuggestion(
                    id: prediction.placeId,
                    mainText: prediction.structuredFormatting.mainText,
                    secondaryText: prediction.structuredFormatting.secondaryText ?? ""
                )
            }
        } catch {
            return []
        }
    }

    private func merge(_ local: [PlaceSuggestion], _ remote: [PlaceSuggestion]) -> [PlaceSuggestion] {
        var seen = Set<String>()
        var merged: [PlaceSuggestion] = []

        // Priority ranking: Society → Landmark → Locality → City
        // Local results come first (they include societies and are more relevant)
        for suggestion in local {
            let key = suggestion.mainText.lowercased()
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            merged.append(suggestion)
        }
        
        // Then add remote results that aren't duplicates
        for suggestion in remote {
            let key = suggestion.mainText.lowercased()
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            merged.append(suggestion)
        }

        // Limit to 10 results for better UX
        return Array(merged.prefix(10))
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
