import Foundation

/// Sample data used to render the Home module until a backend is wired up.
enum MockListings {
    private static let author = ListingAuthor(
        name: "Shruti Jagtap",
        role: "UI/UX Designer 24",
        avatarURL: "https://i.pravatar.cc/150?img=47"
    )

    static let flats: [FlatListing] = [
        FlatListing(
            id: 1,
            author: author,
            imageURLs: [
                "https://picsum.photos/seed/room11/800/600",
                "https://picsum.photos/seed/room12/800/600"
            ],
            title: "Female Flatmate Needed Bagmane Tech Park",
            location: "Maninagar, Ahmedabad",
            lookingFor: "Female",
            deposit: "₹18000",
            rent: "₹13,000",
            moveIn: "10 apr - 12 mar",
            amenities: "Sofa, TV, Furnished Kitchen",
            isShortStay: true,
            isFeatured: true,
            monthlyRent: "₹13,000 / month",
            isAvailable: true,
            propertyType: "2BHK Apartment",
            roomType: "Private Room",
            furnishing: "Fully",
            moveInDate: "May 7, 2025",
            securityDeposit: "₹18000",
            brokerage: "None",
            utilities: "Electricity and Water Extra",
            genderPreference: "Female Only",
            foodPreference: "Vegetarian",
            smokingPreference: "Non Smoking",
            occupation: "Working Proffessional"
        ),
        FlatListing(
            id: 2,
            author: author,
            imageURLs: [
                "https://picsum.photos/seed/room21/800/600",
                "https://picsum.photos/seed/room22/800/600",
                "https://picsum.photos/seed/room23/800/600"
            ],
            title: "Female Flatmate Needed Bagmane Tech Park",
            location: "Maninagar, Ahmedabad",
            lookingFor: "Female",
            deposit: "₹18000",
            rent: "₹13,000",
            moveIn: "10th April",
            amenities: "Sofa, TV, Furnished Kitchen",
            isShortStay: false,
            isFeatured: false,
            monthlyRent: "₹13,000 / month",
            isAvailable: true,
            propertyType: "2BHK Apartment",
            roomType: "Private Room",
            furnishing: "Fully",
            moveInDate: "May 7, 2025",
            securityDeposit: "₹18000",
            brokerage: "None",
            utilities: "Electricity and Water Extra",
            genderPreference: "Female Only",
            foodPreference: "Vegetarian",
            smokingPreference: "Non Smoking",
            occupation: "Working Proffessional"
        ),
        FlatListing(
            id: 3,
            author: author,
            imageURLs: [
                "https://picsum.photos/seed/room31/800/600"
            ],
            title: "Female Flatmate Needed Bagmane Tech Park",
            location: "Maninagar, Ahmedabad",
            lookingFor: "Female",
            deposit: "₹18000",
            rent: "₹13,000",
            moveIn: "10th April",
            amenities: "Sofa, TV, Furnished Kitchen",
            isShortStay: false,
            isFeatured: false,
            monthlyRent: "₹13,000 / month",
            isAvailable: true,
            propertyType: "2BHK Apartment",
            roomType: "Private Room",
            furnishing: "Fully",
            moveInDate: "May 7, 2025",
            securityDeposit: "₹18000",
            brokerage: "None",
            utilities: "Electricity and Water Extra",
            genderPreference: "Female Only",
            foodPreference: "Vegetarian",
            smokingPreference: "Non Smoking",
            occupation: "Working Proffessional"
        )
    ]

    static let flatmates: [FlatmateListing] = [
        FlatmateListing(
            id: 101,
            author: author,
            title: "Female Flatmate Needed Bagmane Tech Park",
            location: "Maninagar, Ahmedabad",
            lookingFor: "Female",
            maxBudget: "₹15,000",
            fromDate: "15 May",
            toDate: "2 jul",
            isShortStay: true,
            isFeatured: true,
            tags: ["Female", "Non-veg", "No Smoking"],
            maxBudgetMonthly: "₹13,000 / month",
            isAvailable: true,
            preferredAreas: ["Indira nagar", "Koramangala", "Maninager", "Bandra"],
            propertyType: "2BHK Apartment",
            roomType: "Private Room",
            furnishing: "Fully",
            duration: "Temporary Stay",
            moveInDate: "May 7, 2025",
            moveOutDate: "july 2, 2025",
            genderPreference: "Female Only",
            foodPreference: "Vegetarian",
            smokingPreference: "Non Smoking",
            occupation: "Working Proffessional",
            lifestyleNotes: ["Early Riser", "Clean & tidy", "Occasional guests"],
            aboutMe: "I'm a product analyst working at Flipkart. I work from 9 to 6 on weekdays and occasionally work from home. I'm a clean and organized person who respects privacy. I enjoy cooking on weekends and occasionally invite friends over. I'm looking for a like-minded female flatmate who is professional and easy-going. I prefer someone who is vegetarian and non-smoker."
        ),
        FlatmateListing(
            id: 102,
            author: author,
            title: "Female Flatmate Needed Bagmane Tech Park",
            location: "Maninagar, Ahmedabad",
            lookingFor: "Female",
            maxBudget: "₹15,000",
            fromDate: "15 May",
            toDate: nil,
            isShortStay: false,
            isFeatured: false,
            tags: ["Female", "Non-veg", "No Smoking"],
            maxBudgetMonthly: "₹13,000 / month",
            isAvailable: true,
            preferredAreas: ["Indira nagar", "Koramangala", "Maninager", "Bandra"],
            propertyType: "2BHK Apartment",
            roomType: "Private Room",
            furnishing: "Fully",
            duration: "Temporary Stay",
            moveInDate: "May 7, 2025",
            moveOutDate: "july 2, 2025",
            genderPreference: "Female Only",
            foodPreference: "Vegetarian",
            smokingPreference: "Non Smoking",
            occupation: "Working Proffessional",
            lifestyleNotes: ["Early Riser", "Clean & tidy", "Occasional guests"],
            aboutMe: "I'm a product analyst working at Flipkart. I work from 9 to 6 on weekdays and occasionally work from home. I'm a clean and organized person who respects privacy. I enjoy cooking on weekends and occasionally invite friends over. I'm looking for a like-minded female flatmate who is professional and easy-going. I prefer someone who is vegetarian and non-smoker."
        )
    ]
}
