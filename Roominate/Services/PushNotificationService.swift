import Foundation
// TODO: Uncomment after adding Firebase SDK via SPM
// import FirebaseMessaging
import UIKit

// TODO: Remove this dummy Messaging class after Firebase SDK is added
// This is a temporary placeholder to prevent build errors
#if !canImport(FirebaseMessaging)
class Messaging {
    static func messaging() -> Messaging { Messaging() }
    func token() async throws -> String { throw NSError(domain: "Firebase not installed", code: -1) }
}
#endif

final class PushNotificationService {
    static let shared = PushNotificationService()
    
    private init() {}
    
    // Token pending registration after login
    var pendingFcmToken: String?
    
    // Track currently viewed conversation to suppress foreground notifications
    private var currentConversationId: Int?
    
    // MARK: - Permission Request
    
    /// Request push notification authorization from the user
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("✅ Push notification permission granted")
            } else {
                print("❌ Push notification permission denied")
            }
            
            return granted
        } catch {
            print("❌ Error requesting push permission:", error.localizedDescription)
            return false
        }
    }
    
    // MARK: - Token Management
    
    /// Register FCM token with backend
    @MainActor
    func registerToken(_ fcmToken: String) async {
        do {
            try await DeviceTokenAPI.register(deviceToken: fcmToken, platform: "ios")
            print("✅ FCM token registered with backend")
            pendingFcmToken = nil
        } catch {
            print("❌ Failed to register FCM token:", error.localizedDescription)
        }
    }
    
    /// Register pending token after login
    @MainActor
    func registerPendingTokenIfNeeded() async {
        // Check if there's a pending token
        if let pending = pendingFcmToken {
            await registerToken(pending)
            return
        }
        
        // Otherwise fetch current token and register
        do {
            let token = try await Messaging.messaging().token()
            await registerToken(token)
        } catch {
            print("❌ Failed to fetch FCM token:", error.localizedDescription)
        }
    }
    
    /// Unregister token before sign out
    @MainActor
    func unregisterToken() async {
        do {
            let token = try await Messaging.messaging().token()
            try await DeviceTokenAPI.unregister(deviceToken: token)
            print("✅ FCM token unregistered from backend")
        } catch {
            print("⚠️ Failed to unregister token (non-blocking):", error.localizedDescription)
        }
    }
    
    // MARK: - Conversation Tracking
    
    func setCurrentConversation(_ id: Int?) {
        currentConversationId = id
    }
    
    func isViewingConversation(_ id: Int) -> Bool {
        return currentConversationId == id
    }
    
    // MARK: - Notification Routing
    
    /// Handle notification tap and route to appropriate screen
    func handleNotificationTap(_ userInfo: [AnyHashable: Any]) {
        // Check if user is signed in
        guard TokenStorage.shared.token != nil else {
            // Store pending deep link and show login
            if let deepLink = userInfo["deep_link"] as? String {
                UserDefaults.standard.set(deepLink, forKey: "pendingDeepLink")
            }
            return
        }
        
        // Path 1: Use deep_link if available (authoritative)
        if let deepLinkString = userInfo["deep_link"] as? String,
           let url = URL(string: deepLinkString) {
            routeDeepLink(url)
            return
        }
        
        // Path 2: Fall back to type + IDs
        guard let type = userInfo["type"] as? String else {
            routeToHome()
            return
        }
        
        switch type {
        case "chat", "conversation_started", "deal_grabbed":
            if let conversationIdString = userInfo["conversation_id"] as? String,
               let conversationId = Int(conversationIdString) {
                routeToConversation(conversationId)
            } else {
                routeToHome()
            }
            
        case "account_warning":
            routeToAccount()
            
        default:
            // Unknown type - route to home
            routeToHome()
        }
    }
    
    /// Route using deep link URL
    private func routeDeepLink(_ url: URL) {
        switch url.host {
        case "chat":
            let conversationIdString = url.lastPathComponent
            if !conversationIdString.isEmpty,
               let conversationId = Int(conversationIdString) {
                routeToConversation(conversationId)
            } else {
                routeToHome()
            }
            
        case "account":
            routeToAccount()
            
        default:
            routeToHome()
        }
    }
    
    private func routeToConversation(_ conversationId: Int) {
        NotificationCenter.default.post(
            name: .routeToConversation,
            object: nil,
            userInfo: ["conversation_id": conversationId]
        )
    }
    
    private func routeToAccount() {
        NotificationCenter.default.post(name: .routeToAccount, object: nil)
    }
    
    private func routeToHome() {
        NotificationCenter.default.post(name: .routeToHome, object: nil)
    }
    
    // MARK: - Inline Reply
    
    /// Handle inline reply from notification action
    func handleInlineReply(conversationId: Int, message: String) async {
        do {
            // ChatService doesn't have a .shared singleton, create instance
            let chatService = ChatService()
            _ = try await chatService.sendMessage(
                conversationId: conversationId,
                body: message
            )
            print("✅ Inline reply sent successfully")
        } catch {
            print("❌ Failed to send inline reply:", error.localizedDescription)
        }
    }
    
    // MARK: - Badge Management
    
    /// Clear app badge count
    @MainActor
    func clearBadge() {
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    /// Check pending deep link after login
    func processPendingDeepLink() {
        guard let deepLinkString = UserDefaults.standard.string(forKey: "pendingDeepLink"),
              let url = URL(string: deepLinkString) else {
            return
        }
        
        // Clear stored link
        UserDefaults.standard.removeObject(forKey: "pendingDeepLink")
        
        // Route to destination
        routeDeepLink(url)
    }
}
