import CoreLocation
import Foundation

enum IndianLocationsService {
    static let cities: [String] = [
        // Tier 1 Cities
        "Ahmedabad", "Bangalore", "Bengaluru", "Chennai", "Delhi", "New Delhi",
        "Hyderabad", "Kolkata", "Mumbai", "Pune",
        
        // NCR
        "Faridabad", "Ghaziabad", "Goa", "Gurugram", "Noida", "Greater Noida",
        
        // Tier 2 Cities - Maharashtra
        "Aurangabad", "Nagpur", "Nashik", "Thane", "Navi Mumbai", "Kalyan",
        "Vasai", "Virar", "Panvel", "Mira Road",
        
        // Tier 2 Cities - Karnataka
        "Mysuru", "Mysore", "Hubli", "Mangalore", "Belgaum",
        
        // Tier 2 Cities - Tamil Nadu
        "Coimbatore", "Madurai", "Tiruchirappalli", "Trichy", "Salem",
        "Tirunelveli", "Vellore", "Erode",
        
        // Tier 2 Cities - Other States
        "Agra", "Ajmer", "Aligarh", "Amritsar", "Bhopal", "Bhubaneswar",
        "Chandigarh", "Dehradun", "Guwahati", "Gwalior", "Indore",
        "Jaipur", "Jalandhar", "Jammu", "Jamshedpur", "Jodhpur",
        "Kanpur", "Kochi", "Kota", "Lucknow", "Ludhiana",
        "Meerut", "Patna", "Raipur", "Rajkot", "Ranchi",
        "Srinagar", "Surat", "Thiruvananthapuram", "Trivandrum",
        "Udaipur", "Vadodara", "Varanasi", "Visakhapatnam",
        "Vijayawada", "Warangal",
        
        // Tier 3 Cities - Gujarat
        "Vapi", "Daman", "Silvassa", "Gandhinagar", "Anand",
        "Bhavnagar", "Jamnagar", "Valsad", "Bharuch", "Navsari",
        "Gandhidham", "Morbi", "Nadiad", "Surendranagar", "Mehsana",
        "Bhuj", "Junagadh", "Veraval", "Porbandar", "Godhra",
        
        // Tier 3 Cities - Other States
        "Amravati", "Kolhapur", "Sangli", "Solapur", "Latur",
        "Nanded", "Ahmednagar", "Jalgaon", "Akola", "Dhule",
        "Satara", "Yavatmal", "Ratnagiri", "Palghar", "Raigad",
        "Karjat", "Khopoli", "Ambernath", "Ulhasnagar", "Bhiwandi",
        "Dombivli", "Badlapur", "Tirupati", "Nellore", "Guntur",
        "Kakinada", "Rajahmundry", "Kadapa", "Anantapur", "Kurnool",
        "Tiruppur", "Thanjavur", "Dindigul", "Karur", "Thoothukudi",
        "Hosur", "Tumakuru", "Shimoga", "Davangere", "Gulbarga",
        "Bikaner", "Kota", "Alwar", "Bharatpur", "Sikar",
        "Pali", "Tonk", "Barmer", "Chittorgarh", "Bhilwara",
        "Haldwani", "Haridwar", "Roorkee", "Rudrapur", "Kashipur",
        "Ramnagar", "Kotdwar", "Rishikesh", "Muzaffarnagar", "Saharanpur",
        "Moradabad", "Bareilly", "Rampur", "Shahjahanpur", "Firozabad",
        "Mathura", "Etawah", "Mainpuri", "Budaun", "Sambhal",
        "Amroha", "Hapur", "Bulandshahr", "Khurja", "Greater Noida West",
        "Ghazipur", "Azamgarh", "Mau", "Ballia", "Jaunpur",
        "Sultanpur", "Pratapgarh", "Rae Bareli", "Unnao", "Hardoi",
        "Sitapur", "Lakhimpur", "Bahraich", "Shravasti", "Balrampur",
        "Gonda", "Faizabad", "Ayodhya", "Ambedkar Nagar", "Basti",
        "Sant Kabir Nagar", "Gorakhpur", "Deoria", "Kushinagar", "Maharajganj",
        "Siddharthnagar", "Mirzapur", "Sonbhadra", "Chandauli", "Varanasi",
        "Bhadohi", "Jhansi", "Lalitpur", "Mahoba", "Banda",
        "Chitrakoot", "Hamirpur", "Jalaun", "Orai", "Auraiya"
    ]
    
    // Comprehensive society index for major Indian cities
    private static let societies: [(name: String, city: String, locality: String)] = [
        // Mumbai - Western Suburbs
        ("Blue Grotto", "Mumbai", "Santacruz West"),
        ("Blue Grotto CHS", "Mumbai", "Santacruz West"),
        ("Hiranandani Gardens", "Mumbai", "Powai"),
        ("Lokhandwala Complex", "Mumbai", "Andheri West"),
        ("Oberoi Splendor", "Mumbai", "Andheri East"),
        ("Raheja Vihar", "Mumbai", "Powai"),
        ("Oberoi Woods", "Mumbai", "Goregaon East"),
        ("Runwal Greens", "Mumbai", "Mulund West"),
        ("Lodha Amara", "Mumbai", "Kolshet Road"),
        ("Lodha Splendora", "Mumbai", "Ghodbunder Road"),
        ("Peninsula Ashok Gardens", "Mumbai", "Parel"),
        ("Peninsula Ashok Towers", "Mumbai", "Parel"),
        ("Godrej Summit", "Mumbai", "Bhandup West"),
        ("Kalpataru Riverside", "Mumbai", "Panvel"),
        ("Kalpataru Sparkle", "Mumbai", "Bandra East"),
        ("Oberoi Sky City", "Mumbai", "Borivali East"),
        ("Rustomjee Urbania", "Mumbai", "Thane West"),
        ("Runwal Elegante", "Mumbai", "Andheri West"),
        ("Mahindra Splendour", "Mumbai", "Bhandup West"),
        ("Tata New Haven", "Mumbai", "Thane"),
        
        // Mumbai - South & Central
        ("Lodha The Park", "Mumbai", "Worli"),
        ("Lodha Altamount", "Mumbai", "Altamount Road"),
        ("Lodha Bellissimo", "Mumbai", "Mahalaxmi"),
        ("Lodha World One", "Mumbai", "Lower Parel"),
        ("Omkar 1973", "Mumbai", "Worli"),
        ("Palais Royale", "Mumbai", "Worli"),
        ("Imperial Heights", "Mumbai", "Tardeo"),
        ("Raheja Empress", "Mumbai", "Prabhadevi"),
        ("Raheja Imperia", "Mumbai", "Worli"),
        ("Kalpataru Paramount", "Mumbai", "Andheri West"),
        ("Transcon Triumph", "Mumbai", "Andheri West"),
        ("Oberoi Esquire", "Mumbai", "Goregaon East"),
        ("Oberoi Exquisite", "Mumbai", "Goregaon East"),
        ("Oberoi Garden Estate", "Mumbai", "Goregaon East"),
        
        // Mumbai - Andheri & Suburbs
        ("Oberoi Splendor Grande", "Mumbai", "Andheri East"),
        ("K Raheja Vistas", "Mumbai", "Powai"),
        ("Lake Homes", "Mumbai", "Powai"),
        ("Powai Vihar Complex", "Mumbai", "Powai"),
        ("Rustomjee Paramount", "Mumbai", "Andheri West"),
        ("Vastu Shilpa", "Mumbai", "Andheri West"),
        ("Lokhandwala Minerva", "Mumbai", "Andheri West"),
        ("Versova Palace", "Mumbai", "Versova"),
        ("Raheja Atlantis", "Mumbai", "Andheri West"),
        ("Emerald Isle", "Mumbai", "Powai"),
        
        // Mumbai - Bandra & Kurla
        ("Pali Hill Residency", "Mumbai", "Bandra West"),
        ("Silver Crest", "Mumbai", "Bandra West"),
        ("Bandra Reclamation", "Mumbai", "Bandra West"),
        ("Kalina CHS", "Mumbai", "Santacruz East"),
        ("Sumer Nagar", "Mumbai", "Bandra West"),
        ("Chuim Village", "Mumbai", "Bandra West"),
        ("Vinay Unique Garden", "Mumbai", "Kurla West"),
        ("Kalpataru Crest", "Mumbai", "Bandra East"),
        ("Kanakia Spaces", "Mumbai", "BKC"),
        
        // Thane
        ("Hiranandani Estate", "Thane", "Thane West"),
        ("Lodha Splendora", "Thane", "Ghodbunder Road"),
        ("Lodha Amara", "Thane", "Kolshet Road"),
        ("Runwal Forests", "Thane", "Kanjurmarg East"),
        ("Runwal Garden City", "Thane", "Dombivli East"),
        ("Kalpataru Habitat", "Thane", "Thane West"),
        ("Wadhwa Wise City", "Thane", "Panvel"),
        ("Rustomjee Urbania", "Thane", "Thane West"),
        ("Ashar Pulse", "Thane", "Thane West"),
        ("Vijay Galaxy", "Thane", "Thane West"),
        
        // Bengaluru - North
        ("Prestige Shantiniketan", "Bengaluru", "Whitefield"),
        ("Sobha City", "Bengaluru", "Thanisandra"),
        ("Brigade Gateway", "Bengaluru", "Rajajinagar"),
        ("Prestige Lakeside Habitat", "Bengaluru", "Varthur"),
        ("Sobha Dream Gardens", "Bengaluru", "Balagere"),
        ("Salarpuria Sattva Greenage", "Bengaluru", "Bommanahalli"),
        ("Mantri Espana", "Bengaluru", "Bellandur"),
        ("Purva Venezia", "Bengaluru", "Yelahanka"),
        ("Embassy Pristine", "Bengaluru", "Bellandur"),
        ("Prestige Song of the South", "Bengaluru", "Begur"),
        
        // Bengaluru - Central & South
        ("Adarsh Palm Retreat", "Bengaluru", "Bellandur"),
        ("Prestige Ferns Residency", "Bengaluru", "Haralur Road"),
        ("Sobha Indraprastha", "Bengaluru", "Rajaji Nagar"),
        ("Mantri Serenity", "Bengaluru", "Subramanyapura"),
        ("Purva Riviera", "Bengaluru", "Marathahalli"),
        ("Brigade Millennium", "Bengaluru", "JP Nagar"),
        ("Prestige Falcon City", "Bengaluru", "Konanakunte"),
        ("Embassy Boulevard", "Bengaluru", "Hebbal"),
        ("Sobha Habitech", "Bengaluru", "Whitefield"),
        ("RMZ Galleria", "Bengaluru", "Yelahanka"),
        
        // Pune
        ("Amanora Park Town", "Pune", "Hadapsar"),
        ("Kumar Picasso", "Pune", "Hadapsar"),
        ("Magarpatta City", "Pune", "Hadapsar"),
        ("Blue Ridge", "Pune", "Hinjewadi"),
        ("Kolte Patil Life Republic", "Pune", "Marunji"),
        ("Godrej Prakriti", "Pune", "Somatane"),
        ("Pristine Equilife", "Pune", "Mahalunge"),
        ("Paranjape Blue Ridge", "Pune", "Hinjewadi"),
        ("Kumar Primavera", "Pune", "Kalyani Nagar"),
        ("Kohinoor City", "Pune", "Kuruli"),
        ("Nyati Empress", "Pune", "Viman Nagar"),
        ("Gera Park View", "Pune", "Kharadi"),
        
        // Gurugram
        ("DLF Park Place", "Gurugram", "Golf Course Road"),
        ("Ireo Victory Valley", "Gurugram", "Sector 67"),
        ("DLF Magnolias", "Gurugram", "Golf Course Road"),
        ("DLF Camellias", "Gurugram", "Golf Course Road"),
        ("Ireo Grand Arch", "Gurugram", "Sector 58"),
        ("M3M Merlin", "Gurugram", "Golf Course Extension"),
        ("Emaar Palm Drive", "Gurugram", "Sector 83"),
        ("Godrej Summit", "Gurugram", "Sector 104"),
        ("Bestech Park View", "Gurugram", "Sector 66"),
        ("Tulip Orange", "Gurugram", "Sector 70"),
        ("Vatika City", "Gurugram", "Sector 49"),
        
        // Noida & Greater Noida
        ("Supertech Supernova", "Noida", "Sector 94"),
        ("Jaypee Greens", "Noida", "Greater Noida"),
        ("ATS Allure", "Noida", "Sector 22D"),
        ("Mahagun Moderne", "Noida", "Sector 78"),
        ("Gaur City", "Noida", "Greater Noida West"),
        ("Amrapali Silicon City", "Noida", "Sector 76"),
        ("Logix Blossom Greens", "Noida", "Sector 143"),
        ("Supertech Eco Village", "Noida", "Greater Noida West"),
        
        // Hyderabad
        ("Aparna Sarovar Grande", "Hyderabad", "Nallagandla"),
        ("My Home Avatar", "Hyderabad", "Gachibowli"),
        ("Prestige Lakeside Habitat", "Hyderabad", "Varthur"),
        ("Mantri Serenity", "Hyderabad", "Subramanyapura"),
        ("Aparna Kanopy Tulip", "Hyderabad", "Manikonda"),
        ("My Home Bhooja", "Hyderabad", "Raidurgam"),
        ("Prestige Jasdan Classic", "Hyderabad", "Nanakramguda"),
        ("Aparna Hill Park", "Hyderabad", "Chandanagar"),
        
        // Chennai
        ("Prestige Sunrise Park", "Chennai", "OMR"),
        ("Mantri Serenity", "Chennai", "Kottivakkam"),
        ("Casagrand Aristo", "Chennai", "Korattur"),
        ("Sobha Turquoise", "Chennai", "Sholinganallur"),
        ("Provident Sunworth", "Chennai", "Kattankulathur"),
        ("Godrej Garden City", "Chennai", "Chengalpattu"),
        ("Lancor The Central Park", "Chennai", "Sholinganallur"),
        ("DLF Westend Heights", "Chennai", "Akkarai"),
        
        // Ahmedabad
        ("Goyal Riviera Blues", "Ahmedabad", "Makarba"),
        ("Shivalik Shilp", "Ahmedabad", "Vastrapur"),
        ("Sangath Skyz", "Ahmedabad", "Shela"),
        ("Sobhabag Elegance", "Ahmedabad", "Thaltej"),
        ("Sun South Park", "Ahmedabad", "Bopal"),
        ("Goyal Orchid Harmony", "Ahmedabad", "Shela"),
        ("Shivalik Heights", "Ahmedabad", "Ambli"),
        
        // Kolkata
        ("PS Srijan Tech Park", "Kolkata", "Salt Lake"),
        ("Merlin 5th Avenue", "Kolkata", "Ballygunge"),
        ("PS Panache", "Kolkata", "Rajarhat"),
        ("Ideal Ideal Heights", "Kolkata", "VIP Road"),
        ("Shapoorji Pallonji Shukhobrishti", "Kolkata", "New Town"),
        ("Merlin Waterfront", "Kolkata", "Howrah"),
        
        // Vapi (Tier-3 city coverage)
        ("Sai Krupa Society", "Vapi", "GIDC"),
        ("Radhika Complex", "Vapi", "Gunjan"),
        ("Shreeji Residency", "Vapi", "Chala"),
        ("Swastik Heights", "Vapi", "Daman Road"),
        ("Green Valley", "Vapi", "GIDC")
    ]

    private static let landmarksByCity: [String: [String]] = [
        "Ahmedabad": [
            "Thaltej", "CG Road", "C.G. Road", "Satellite", "Bopal",
            "Maninagar", "Vastrapur", "Navrangpura", "Paldi", "Ashram Road",
            "Bodakdev", "SG Highway", "S.G. Highway", "Science City",
            "Gota", "Naranpura", "Ellisbridge", "Law Garden", "Memnagar",
            "Ambawadi", "Jodhpur Village", "Shilaj", "Shela", "Gift City",
            "Vastral", "Nikol", "Chandkheda", "Odhav", "Naroda", "Narol",
            "Rakhial", "CTM", "Odhav GIDC", "Vatva", "Maninagar East",
            "Isanpur", "Bapunagar", "Gomtipur", "New Maninagar", "Motera",
            "Sabarmati", "Ranip", "Kali", "Bhat", "New Ranip", "Shahpur"
        ],
        "Mumbai": [
            "Andheri", "Andheri East", "Andheri West", "Bandra", "Bandra East", "Bandra West",
            "Borivali", "Borivali East", "Borivali West", "Colaba", "Dadar", "Dadar East", "Dadar West",
            "Goregaon", "Goregaon East", "Goregaon West", "Juhu", "Kandivali", "Kandivali East", "Kandivali West",
            "Lower Parel", "Malad", "Malad East", "Malad West", "Powai", "Worli", "Santacruz", "Santacruz East",
            "Santacruz West", "Santa Cruz", "Kurla", "Kurla East", "Kurla West", "Vile Parle", "Vile Parle East",
            "Vile Parle West", "Chembur", "Mulund", "Mulund East", "Mulund West", "Ghatkopar", "Ghatkopar East",
            "Ghatkopar West", "Vikhroli", "Vikhroli East", "Vikhroli West", "Kanjurmarg", "Kanjurmarg East",
            "Kanjurmarg West", "Bhandup", "Bhandup East", "Bhandup West", "Matunga", "Matunga East", "Matunga West",
            "Sion", "Wadala", "Parel", "Grant Road", "Marine Drive", "Churchgate", "Fort", "CST",
            "Tardeo", "Breach Candy", "Malabar Hill", "Girgaon", "Opera House", "Charni Road", "Mumbai Central",
            "Mahim", "Prabhadevi", "Elphinstone", "Chinchpokli", "Reay Road", "Dockyard Road", "Sewri",
            "Cotton Green", "Currey Road", "Sandhurst Road"
        ],
        "Thane": [
            "Ghodbunder Road", "Hiranandani Estate", "Kolshet", "Majiwada", "Naupada",
            "Thane West", "Thane East", "Vartak Nagar", "Kapurbawdi", "Wagle Estate",
            "Vasant Vihar", "Teen Hath Naka", "Panchpakhadi", "Manpada", "Pokhran Road"
        ],
        "Bengaluru": [
            "Koramangala", "Indiranagar", "Whitefield", "HSR Layout",
            "Electronic City", "Marathahalli", "Jayanagar", "MG Road",
            "BTM Layout", "JP Nagar", "Bannerghatta Road", "Sarjapur Road",
            "Bellandur", "Domlur", "CV Raman Nagar", "Hennur", "Yelahanka",
            "Hebbal", "RT Nagar", "Malleswaram", "Rajajinagar", "Basavanagudi"
        ],
        "Bangalore": [
            "Koramangala", "Indiranagar", "Whitefield", "HSR Layout",
            "Electronic City", "Marathahalli", "Jayanagar", "MG Road",
            "BTM Layout", "JP Nagar", "Bannerghatta Road", "Sarjapur Road",
            "Bellandur", "Domlur", "CV Raman Nagar", "Hennur", "Yelahanka",
            "Hebbal", "RT Nagar", "Malleswaram", "Rajajinagar", "Basavanagudi"
        ],
        "Delhi": [
            "Connaught Place", "Dwarka", "Karol Bagh", "Lajpat Nagar",
            "Rohini", "Saket", "Vasant Kunj", "Hauz Khas", "Nehru Place",
            "South Extension", "Green Park", "Rajouri Garden", "Pitampura",
            "Janakpuri", "Mayur Vihar", "Preet Vihar", "Kalkaji"
        ],
        "New Delhi": [
            "Connaught Place", "Dwarka", "Karol Bagh", "Lajpat Nagar",
            "Rohini", "Saket", "Vasant Kunj", "Hauz Khas", "Nehru Place",
            "South Extension", "Green Park", "Rajouri Garden", "Pitampura",
            "Janakpuri", "Mayur Vihar", "Preet Vihar", "Kalkaji"
        ],
        "Pune": [
            "Hinjewadi", "Kothrud", "Baner", "Wakad", "Koregaon Park",
            "Viman Nagar", "Aundh", "Hadapsar", "Kalyani Nagar", "Magarpatta",
            "Kharadi", "Pimple Saudagar", "Pimple Nilakh", "Shivaji Nagar",
            "Deccan", "Swargate", "Katraj", "Bavdhan"
        ],
        "Hyderabad": [
            "Banjara Hills", "Gachibowli", "Hitech City", "Jubilee Hills",
            "Kondapur", "Madhapur", "Secunderabad", "Kukatpally", "Miyapur",
            "Uppal", "LB Nagar", "Dilsukhnagar", "Ameerpet", "Begumpet"
        ],
        "Chennai": [
            "Adyar", "Anna Nagar", "OMR", "T Nagar", "Velachery", "Porur",
            "Tambaram", "Chromepet", "Guindy", "Nungambakkam", "Mylapore",
            "Sholinganallur", "Perungudi", "Thoraipakkam", "Manapakkam"
        ],
        "Gurugram": [
            "Cyber City", "DLF Phase 1", "DLF Phase 2", "DLF Phase 3", "DLF Phase 4",
            "DLF Phase 5", "Golf Course Road", "MG Road", "Sohna Road", "Sector 29",
            "Sector 14", "Sector 15", "Sector 28", "Sector 54", "Sector 56"
        ],
        "Noida": [
            "Sector 18", "Sector 62", "Sector 63", "Sector 15", "Sector 16",
            "Sector 137", "Greater Noida", "Noida Extension"
        ],
        "Kolkata": [
            "Park Street", "Salt Lake", "New Town", "Ballygunge", "Howrah",
            "Esplanade", "Sealdah", "Rajarhat", "Dum Dum", "Behala"
        ],
        "Vapi": [
            "GIDC", "Gunjan", "Chala", "Daman Road", "Silvassa Road"
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

        // Priority 1: Search societies first (highest priority for rental app)
        for suggestion in matchingSocieties(for: query, limit: limit) {
            let key = suggestion.mainText.lowercased()
            guard seen.insert(key).inserted else { continue }
            results.append(suggestion)
        }

        // Priority 2: Cities
        for suggestion in matchingCities(for: query, limit: limit) {
            let key = suggestion.mainText.lowercased()
            guard seen.insert(key).inserted else { continue }
            results.append(suggestion)
        }

        // Priority 3: Landmarks/localities
        for suggestion in matchingLandmarksAcrossCities(for: query, limit: limit) {
            let key = "\(suggestion.mainText.lowercased())-\(suggestion.secondaryText.lowercased())"
            guard seen.insert(key).inserted else { continue }
            results.append(suggestion)
            if results.count >= limit { break }
        }

        return Array(results.prefix(limit))
    }
    
    static func matchingSocieties(for query: String, limit: Int = 8) -> [PlaceSuggestion] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.count >= 2 else { return [] }

        let lowercasedQuery = normalized.lowercased()
        
        // Fuzzy matching for societies with typo tolerance
        let matches = societies.filter { society in
            let societyName = society.name.lowercased()
            
            // Exact prefix match (highest priority)
            if societyName.hasPrefix(lowercasedQuery) {
                return true
            }
            
            // Contains match
            if societyName.contains(lowercasedQuery) {
                return true
            }
            
            // Simple fuzzy match: check if most characters are present
            let queryChars = Set(lowercasedQuery.filter { !$0.isWhitespace })
            let nameChars = Set(societyName.filter { !$0.isWhitespace })
            let matchingChars = queryChars.intersection(nameChars)
            
            // If 80% of query characters are in the name, consider it a match
            return queryChars.count > 0 && 
                   Double(matchingChars.count) / Double(queryChars.count) >= 0.8
        }

        return Array(matches.prefix(limit)).map { society in
            PlaceSuggestion(
                id: "local-society-\(society.city)-\(society.name)",
                mainText: society.name,
                secondaryText: "\(society.locality), \(society.city)"
            )
        }
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
