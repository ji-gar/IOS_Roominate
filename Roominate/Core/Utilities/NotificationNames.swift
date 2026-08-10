import Foundation

// MARK: - Push Notification Routing

extension Notification.Name {
    /// Posted when a chat message is received in foreground for the currently viewed conversation
    static let chatMessageReceived = Notification.Name("chatMessageReceived")
    
    /// Posted when user taps a notification that should route to a conversation
    /// userInfo contains: ["conversation_id": Int]
    static let routeToConversation = Notification.Name("routeToConversation")
    
    /// Posted when user taps a notification that should route to account/profile screen
    static let routeToAccount = Notification.Name("routeToAccount")
    
    /// Posted when user taps a notification that should route to home screen
    static let routeToHome = Notification.Name("routeToHome")
}
