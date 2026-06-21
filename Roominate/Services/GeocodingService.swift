import CoreLocation
import Foundation

enum GeocodingService {
  static let cityCoordinates: [String: CLLocationCoordinate2D] = [
    "Ahmedabad": .init(latitude: 23.0225, longitude: 72.5714),
    "Mumbai": .init(latitude: 19.0760, longitude: 72.8777),
    "Bengaluru": .init(latitude: 12.9716, longitude: 77.5946),
    "Bangalore": .init(latitude: 12.9716, longitude: 77.5946),
    "Delhi": .init(latitude: 28.6139, longitude: 77.2090),
    "New Delhi": .init(latitude: 28.6139, longitude: 77.2090),
    "Pune": .init(latitude: 18.5204, longitude: 73.8567),
    "Hyderabad": .init(latitude: 17.3850, longitude: 78.4867),
    "Chennai": .init(latitude: 13.0827, longitude: 80.2707),
    "Kolkata": .init(latitude: 22.5726, longitude: 88.3639),
    "Gurugram": .init(latitude: 28.4595, longitude: 77.0266),
    "Noida": .init(latitude: 28.5355, longitude: 77.3910),
    "Jaipur": .init(latitude: 26.9124, longitude: 75.7873),
    "Surat": .init(latitude: 21.1702, longitude: 72.8311),
    "Lucknow": .init(latitude: 26.8467, longitude: 80.9462),
    "Chandigarh": .init(latitude: 30.7333, longitude: 76.7794),
    "Goa": .init(latitude: 15.2993, longitude: 74.1240),
    "Thane": .init(latitude: 19.2183, longitude: 72.9781),
  ]

  static func coordinate(forCity city: String) -> CLLocationCoordinate2D? {
    cityCoordinates[IndianLocationsService.normalizedCityName(city)]
  }

  static func forwardGeocode(_ address: String) async -> CLLocationCoordinate2D? {
    let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    if let cityCoord = coordinate(forCity: trimmed) {
      return cityCoord
    }

    let geocoder = CLGeocoder()
    do {
      let placemarks = try await geocoder.geocodeAddressString("\(trimmed), India")
      return placemarks.first?.location?.coordinate
    } catch {
      return nil
    }
  }

  static func pincode(forAddress address: String) async -> String? {
    let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    let geocoder = CLGeocoder()
    do {
      let placemarks = try await geocoder.geocodeAddressString("\(trimmed), India")
      return placemarks.first?.postalCode
    } catch {
      return nil
    }
  }

  static func pincode(for coordinate: CLLocationCoordinate2D) async -> String? {
    guard IndianLocationsService.isValidCoordinate(coordinate) else { return nil }

    let geocoder = CLGeocoder()
    do {
      let placemarks = try await geocoder.reverseGeocodeLocation(
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
      )
      return placemarks.first?.postalCode
    } catch {
      return nil
    }
  }

  static func placeDetails(
    from suggestion: PlaceSuggestion,
    mode: PlacesSearchMode
  ) async -> PlaceDetails {
    let city: String
    let area: String
    let landmark: String
    let state: String

    switch mode {
    case .cities:
      city = suggestion.mainText
      area = ""
      landmark = ""
      state = indianState(for: city)
    case .landmarks:
      landmark = suggestion.mainText
      city = IndianLocationsService.city(fromLandmarkSecondary: suggestion.secondaryText)
      area = suggestion.mainText
      state = indianState(for: city)
    case .address:
      if suggestion.id.hasPrefix("local-city-") {
        city = suggestion.mainText
        area = ""
        landmark = ""
        state = indianState(for: city)
      } else if suggestion.id.hasPrefix("local-landmark-") {
        landmark = suggestion.mainText
        city = IndianLocationsService.city(fromLandmarkSecondary: suggestion.secondaryText)
        area = suggestion.mainText
        state = indianState(for: city)
      } else {
        city = IndianLocationsService.normalizedCityName(suggestion.secondaryText)
        area = suggestion.mainText
        landmark = suggestion.mainText
        state = ""
      }
    }

    let geocodeQuery = [landmark, area, city, "India"]
      .filter { !$0.isEmpty }
      .joined(separator: ", ")

    let resolvedCoordinate: CLLocationCoordinate2D
    if let cityCoord = Self.coordinate(forCity: city) {
      resolvedCoordinate = cityCoord
    } else if let landmarkCoord = Self.coordinate(forCity: landmark) {
      resolvedCoordinate = landmarkCoord
    } else if let geocoded = await forwardGeocode(geocodeQuery) {
      resolvedCoordinate = geocoded
    } else {
      resolvedCoordinate = .init(latitude: 0, longitude: 0)
    }

    var resolvedPincode = ""
    if IndianLocationsService.isValidCoordinate(resolvedCoordinate),
       let pincode = await pincode(for: resolvedCoordinate) {
      resolvedPincode = pincode
    } else if let pincode = await pincode(forAddress: geocodeQuery) {
      resolvedPincode = pincode
    }

    return PlaceDetails(
      coordinate: resolvedCoordinate,
      landmark: landmark,
      area: area.isEmpty ? landmark : area,
      city: city,
      state: state,
      pincode: resolvedPincode,
      formattedAddress: suggestion.fullText
    )
  }

  private static func indianState(for city: String) -> String {
    switch IndianLocationsService.normalizedCityName(city) {
    case "Mumbai", "Pune", "Thane", "Nagpur", "Nashik": return "Maharashtra"
    case "Ahmedabad", "Surat", "Vadodara", "Rajkot": return "Gujarat"
    case "Bengaluru", "Bangalore", "Mysuru", "Mangalore": return "Karnataka"
    case "Delhi", "New Delhi", "Gurugram", "Noida", "Faridabad", "Ghaziabad": return "Delhi NCR"
    case "Hyderabad": return "Telangana"
    case "Chennai", "Coimbatore", "Madurai": return "Tamil Nadu"
    case "Kolkata": return "West Bengal"
    case "Jaipur", "Jodhpur", "Udaipur": return "Rajasthan"
    case "Lucknow", "Kanpur", "Agra", "Varanasi": return "Uttar Pradesh"
    case "Chandigarh": return "Chandigarh"
    case "Goa": return "Goa"
    default: return ""
    }
  }
}
