import SwiftUI
import GoogleMaps
// TODO: Uncomment after adding Firebase SDK via SPM
// import FirebaseCore
// import FirebaseMessaging
// import UserNotifications

@main
struct RoominateApp: App {
    // TODO: Uncomment after adding Firebase SDK
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Initialize Google Maps with API key from Info.plist
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
            GMSServices.provideAPIKey(apiKey)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
