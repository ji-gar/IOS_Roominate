import CoreLocation
import Foundation

enum GeocodingService {
  static let cityCoordinates: [String: CLLocationCoordinate2D] = [
    // Tier 1 Cities
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
    
    // NCR Cities
    "Gurugram": .init(latitude: 28.4595, longitude: 77.0266),
    "Gurgaon": .init(latitude: 28.4595, longitude: 77.0266),
    "Noida": .init(latitude: 28.5355, longitude: 77.3910),
    "Greater Noida": .init(latitude: 28.4744, longitude: 77.5040),
    "Faridabad": .init(latitude: 28.4089, longitude: 77.3178),
    "Ghaziabad": .init(latitude: 28.6692, longitude: 77.4538),
    
    // Tier 2 Cities - Maharashtra
    "Thane": .init(latitude: 19.2183, longitude: 72.9781),
    "Navi Mumbai": .init(latitude: 19.0330, longitude: 73.0297),
    "Nagpur": .init(latitude: 21.1458, longitude: 79.0882),
    "Nashik": .init(latitude: 19.9975, longitude: 73.7898),
    "Aurangabad": .init(latitude: 19.8762, longitude: 75.3433),
    
    // Tier 2 Cities - Karnataka
    "Mysuru": .init(latitude: 12.2958, longitude: 76.6394),
    "Mysore": .init(latitude: 12.2958, longitude: 76.6394),
    "Mangalore": .init(latitude: 12.9141, longitude: 74.8560),
    "Hubli": .init(latitude: 15.3647, longitude: 75.1240),
    
    // Tier 2 Cities - Tamil Nadu
    "Coimbatore": .init(latitude: 11.0168, longitude: 76.9558),
    "Madurai": .init(latitude: 9.9252, longitude: 78.1198),
    "Trichy": .init(latitude: 10.7905, longitude: 78.7047),
    "Tiruchirappalli": .init(latitude: 10.7905, longitude: 78.7047),
    "Salem": .init(latitude: 11.6643, longitude: 78.1460),
    
    // Tier 2 Cities - Other States
    "Jaipur": .init(latitude: 26.9124, longitude: 75.7873),
    "Lucknow": .init(latitude: 26.8467, longitude: 80.9462),
    "Chandigarh": .init(latitude: 30.7333, longitude: 76.7794),
    "Indore": .init(latitude: 22.7196, longitude: 75.8577),
    "Bhopal": .init(latitude: 23.2599, longitude: 77.4126),
    "Kochi": .init(latitude: 9.9312, longitude: 76.2673),
    "Cochin": .init(latitude: 9.9312, longitude: 76.2673),
    "Visakhapatnam": .init(latitude: 17.6869, longitude: 83.2185),
    "Vizag": .init(latitude: 17.6869, longitude: 83.2185),
    "Surat": .init(latitude: 21.1702, longitude: 72.8311),
    "Vadodara": .init(latitude: 22.3072, longitude: 73.1812),
    "Rajkot": .init(latitude: 22.3039, longitude: 70.8022),
    
    // Gujarat - Tier 3
    "Vapi": .init(latitude: 20.3711, longitude: 72.9045),
    "Anand": .init(latitude: 22.5645, longitude: 72.9289),
    "Gandhinagar": .init(latitude: 23.2156, longitude: 72.6369),
    "Bhavnagar": .init(latitude: 21.7645, longitude: 72.1519),
    "Jamnagar": .init(latitude: 22.4707, longitude: 70.0577),
    
    // Goa
    "Goa": .init(latitude: 15.2993, longitude: 74.1240),
    "Panaji": .init(latitude: 15.4909, longitude: 73.8278),
    "Margao": .init(latitude: 15.2708, longitude: 73.9528),
    
    // Mumbai Localities (for better granularity)
    "Santacruz": .init(latitude: 19.0810, longitude: 72.8404),
    "Santa Cruz": .init(latitude: 19.0810, longitude: 72.8404),
    "Kurla": .init(latitude: 19.0728, longitude: 72.8826),
    "Andheri": .init(latitude: 19.1136, longitude: 72.8697),
    "Bandra": .init(latitude: 19.0596, longitude: 72.8295),
    "Borivali": .init(latitude: 19.2304, longitude: 72.8577),
    "Powai": .init(latitude: 19.1176, longitude: 72.9060),
    "Worli": .init(latitude: 19.0176, longitude: 72.8170),
    "Dadar": .init(latitude: 19.0178, longitude: 72.8478),
    "Goregaon": .init(latitude: 19.1700, longitude: 72.8479),
    "Malad": .init(latitude: 19.1760, longitude: 72.8484),
    "Kandivali": .init(latitude: 19.2050, longitude: 72.8540),
    "Chembur": .init(latitude: 19.0633, longitude: 72.8964),
    "Ghatkopar": .init(latitude: 19.0860, longitude: 72.9081),
    "Mulund": .init(latitude: 19.1722, longitude: 72.9565),
    "Vikhroli": .init(latitude: 19.1140, longitude: 72.9310),
    "Lower Parel": .init(latitude: 18.9975, longitude: 72.8274),
    "Matunga": .init(latitude: 19.0270, longitude: 72.8564),
    "Parel": .init(latitude: 19.0088, longitude: 72.8369),
    
    // Pune Localities
    "Hinjewadi": .init(latitude: 18.5912, longitude: 73.7397),
    "Kothrud": .init(latitude: 18.5074, longitude: 73.8077),
    "Baner": .init(latitude: 18.5593, longitude: 73.7820),
    "Wakad": .init(latitude: 18.5978, longitude: 73.7639),
    "Hadapsar": .init(latitude: 18.5089, longitude: 73.9260),
    "Kharadi": .init(latitude: 18.5515, longitude: 73.9470),
    
    // Bangalore Localities
    "Whitefield": .init(latitude: 12.9698, longitude: 77.7499),
    "Koramangala": .init(latitude: 12.9279, longitude: 77.6271),
    "Indiranagar": .init(latitude: 12.9716, longitude: 77.6412),
    "Electronic City": .init(latitude: 12.8456, longitude: 77.6603),
    "HSR Layout": .init(latitude: 12.9121, longitude: 77.6446),
    "Marathahalli": .init(latitude: 12.9591, longitude: 77.6974),
  ]

  static func coordinate(forCity city: String) -> CLLocationCoordinate2D? {
    cityCoordinates[IndianLocationsService.normalizedCityName(city)]
  }

  static func forwardGeocode(_ address: String) async -> CLLocationCoordinate2D? {
    let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    // Try city lookup first (fast, no API call)
    if let cityCoord = coordinate(forCity: trimmed) {
      return cityCoord
    }

    // ✅ ENHANCED: Try geocoding with India suffix first
    let geocoder = CLGeocoder()
    do {
      let placemarks = try await geocoder.geocodeAddressString("\(trimmed), India")
      if let coordinate = placemarks.first?.location?.coordinate {
        return coordinate
      }
    } catch {
      // Fallback: Try without "India" suffix for better local matches
      // This helps when the address already contains detailed location info
      do {
        let placemarks = try await geocoder.geocodeAddressString(trimmed)
        return placemarks.first?.location?.coordinate
      } catch {
        return nil
      }
    }
    
    return nil
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
    let normalized = IndianLocationsService.normalizedCityName(city).lowercased()
    
    // Maharashtra cities and localities
    if ["mumbai", "pune", "thane", "nagpur", "nashik", "aurangabad", "santacruz", "santa cruz",
        "kurla", "andheri", "bandra", "borivali", "powai", "worli", "dadar", "goregaon",
        "juhu", "kandivali", "malad", "vile parle", "chembur", "mulund", "ghatkopar",
        "vikhroli", "kanjurmarg", "bhandup", "matunga", "sion", "wadala", "parel"].contains(normalized) {
      return "Maharashtra"
    }
    
    // Gujarat cities and localities
    if ["ahmedabad", "surat", "vadodara", "rajkot", "vapi", "gandhinagar", "anand",
        "bhavnagar", "jamnagar", "valsad", "bharuch", "navsari", "gandhidham"].contains(normalized) {
      return "Gujarat"
    }
    
    // Karnataka
    if ["bengaluru", "bangalore", "mysuru", "mangalore"].contains(normalized) {
      return "Karnataka"
    }
    
    // Delhi NCR
    if ["delhi", "new delhi", "gurugram", "noida", "faridabad", "ghaziabad", "greater noida"].contains(normalized) {
      return "Delhi NCR"
    }
    
    // Telangana
    if ["hyderabad", "secunderabad"].contains(normalized) {
      return "Telangana"
    }
    
    // Tamil Nadu
    if ["chennai", "coimbatore", "madurai"].contains(normalized) {
      return "Tamil Nadu"
    }
    
    // West Bengal
    if ["kolkata", "howrah"].contains(normalized) {
      return "West Bengal"
    }
    
    // Rajasthan
    if ["jaipur", "jodhpur", "udaipur"].contains(normalized) {
      return "Rajasthan"
    }
    
    // Uttar Pradesh
    if ["lucknow", "kanpur", "agra", "varanasi"].contains(normalized) {
      return "Uttar Pradesh"
    }
    
    // Union Territories
    if normalized == "chandigarh" { return "Chandigarh" }
    if normalized == "goa" { return "Goa" }
    
    return ""
  }
}
