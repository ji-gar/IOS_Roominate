import Combine
import CoreLocation
import Foundation

struct PlaceSuggestion: Identifiable, Equatable {
    let id: String
    let mainText: String
    let secondaryText: String

    var fullText: String {
        secondaryText.isEmpty ? mainText : "\(mainText), \(secondaryText)"
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

    func search(query: String, mode: PlacesSearchMode = .cities) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            suggestions = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
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
            guard !Task.isCancelled else { return }

            suggestions = merge(localResults, remoteResults)
        }
    }

    func fetchPlaceDetails(placeId: String) async -> PlaceDetails? {
        if placeId.hasPrefix("local-") {
            return nil
        }

        let key = APIConstants.googlePlacesAPIKey
        guard !key.isEmpty else { return nil }

        let fields = "geometry,address_components,formatted_address"
        let urlString =
            "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=\(fields)&key=\(key)"

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

            let area = firstComponent(in: components, types: [
                "sublocality_level_1", "sublocality", "neighborhood", "sublocality_level_2"
            ])
            let city = firstComponent(in: components, types: [
                "locality", "administrative_area_level_2"
            ])
            let state = firstComponent(in: components, types: ["administrative_area_level_1"])
            let pincode = firstComponent(in: components, types: ["postal_code"])
            let landmark = firstComponent(in: components, types: [
                "premise", "route", "point_of_interest", "establishment"
            ])

            return PlaceDetails(
                coordinate: coordinate,
                landmark: landmark.isEmpty ? result.formattedAddress : landmark,
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
        switch mode {
        case .cities:
            searchQuery = query
        case .landmarks(let city):
            let normalizedCity = IndianLocationsService.normalizedCityName(city)
            searchQuery = normalizedCity.isEmpty ? query : "\(query) \(normalizedCity)"
        case .address:
            searchQuery = query
        }

        let encoded = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
        var urlString =
            "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encoded)&components=country:in&key=\(apiKey)"

        switch mode {
        case .cities:
            urlString += "&types=(cities)"
        case .landmarks, .address:
            break
        }

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

        for suggestion in local + remote {
            let key = suggestion.mainText.lowercased()
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            merged.append(suggestion)
        }

        return Array(merged.prefix(8))
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

        enum CodingKeys: String, CodingKey {
            case formattedAddress = "formatted_address"
            case geometry
            case addressComponents = "address_components"
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
