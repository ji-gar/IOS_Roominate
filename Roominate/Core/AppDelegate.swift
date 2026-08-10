// TODO: Uncomment this entire file after adding Firebase SDK via Swift Package Manager
// Follow instructions in FIREBASE_SPM_SETUP.md

/*
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set Firebase Messaging delegate
        Messaging.messaging().delegate = self
        
        // Set UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Register notification categories (Reply action for chat)
        registerNotificationCategories()
        
        return true
    }
    
    // MARK: - APNs Registration
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Hand the APNs token to Firebase
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNs registration failed:", error.localizedDescription)
    }
    
    // MARK: - Notification Categories
    
    private func registerNotificationCategories() {
        let reply = UNTextInputNotificationAction(
            identifier: "REPLY",
            title: "Reply",
            options: [],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Message…"
        )
        
        let chatCategory = UNNotificationCategory(
            identifier: "CHAT_MESSAGE",
            actions: [reply],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([chatCategory])
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    /// Called when FCM token is refreshed or first generated.
    /// This is the token that must be sent to the backend.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        
        print("🔔 FCM Token received: \(fcmToken)")
        
        // Register with backend if user is signed in
        if TokenStorage.shared.token != nil {
            Task {
                await PushNotificationService.shared.registerToken(fcmToken)
            }
        } else {
            // Store for later registration after login
            PushNotificationService.shared.pendingFcmToken = fcmToken
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Called when a notification arrives while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        
        // Check if user is already viewing this conversation
        if let type = userInfo["type"] as? String, type == "chat",
           let conversationIdString = userInfo["conversation_id"] as? String,
           let conversationId = Int(conversationIdString),
           PushNotificationService.shared.isViewingConversation(conversationId) {
            // Already viewing this thread - don't show banner, just refresh
            NotificationCenter.default.post(
                name: .chatMessageReceived,
                object: nil,
                userInfo: ["conversation_id": conversationId]
            )
            return completionHandler([])
        }
        
        // Show banner, sound, badge, and in notification list
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    /// Called when user taps on a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle inline reply action
        if let reply = response as? UNTextInputNotificationResponse,
           response.actionIdentifier == "REPLY",
           let conversationIdString = userInfo["conversation_id"] as? String,
           let conversationId = Int(conversationIdString) {
            Task {
                await PushNotificationService.shared.handleInlineReply(
                    conversationId: conversationId,
                    message: reply.userText
                )
            }
            return completionHandler()
        }
        
        // Handle notification tap - route to appropriate screen
        PushNotificationService.shared.handleNotificationTap(userInfo)
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let chatMessageReceived = Notification.Name("chatMessageReceived")
    static let routeToConversation = Notification.Name("routeToConversation")
    static let routeToAccount = Notification.Name("routeToAccount")
    static let routeToHome = Notification.Name("routeToHome")
}
*/
