import SwiftUI
import Combine
import UserNotifications

@MainActor
final class PushNotificationViewModel: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isRegistered: Bool = false
    
    private let pushService = PushNotificationService.shared
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            self.authorizationStatus = settings.authorizationStatus
        }
    }
    
    func requestAuthorization() async {
        let granted = await pushService.requestAuthorization()
        if granted {
            authorizationStatus = .authorized
        }
    }
    
    // MARK: - Registration Lifecycle
    
    /// Call this after successful login
    func registerAfterLogin() async {
        await pushService.registerPendingTokenIfNeeded()
        isRegistered = true
        
        // Process any pending deep link from notification tap while logged out
        pushService.processPendingDeepLink()
    }
    
    /// Call this on app launch if user is already signed in
    func registerOnLaunch() async {
        guard TokenStorage.shared.isSignedIn else { return }
        await pushService.registerPendingTokenIfNeeded()
        isRegistered = true
    }
    
    /// Call this before sign out
    func unregisterBeforeSignOut() async {
        await pushService.unregisterToken()
        isRegistered = false
    }
    
    // MARK: - Badge Management
    
    func clearBadge() {
        pushService.clearBadge()
    }
    
    // MARK: - Settings
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
