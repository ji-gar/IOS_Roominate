import Foundation

enum DeviceTokenAPI {
    
    // MARK: - Models
    
    struct RegisterRequest: Codable {
        let deviceToken: String
        let platform: String
        
        enum CodingKeys: String, CodingKey {
            case deviceToken = "device_token"
            case platform
        }
    }
    
    struct UnregisterRequest: Codable {
        let deviceToken: String
        
        enum CodingKeys: String, CodingKey {
            case deviceToken = "device_token"
        }
    }
    
    struct DeviceTokenResponse: Codable {
        let success: Bool
        let message: String
        let data: DeviceTokenData?
    }
    
    struct DeviceTokenData: Codable {
        let platform: String
    }
    
    // MARK: - API Methods
    
    /// Register device token with backend
    /// POST /api/device-tokens
    static func register(deviceToken: String, platform: String) async throws {
        let request = RegisterRequest(deviceToken: deviceToken, platform: platform)
        
        let _: DeviceTokenResponse = try await APIClient.shared.request(
            path: "/device-tokens",
            method: .post,
            body: request,
            requiresAuth: true
        )
    }
    
    /// Unregister device token from backend
    /// DELETE /api/device-tokens
    static func unregister(deviceToken: String) async throws {
        let request = UnregisterRequest(deviceToken: deviceToken)
        
        // Note: DELETE with body is supported by URLSession
        let _: DeviceTokenResponse = try await APIClient.shared.request(
            path: "/device-tokens",
            method: .delete,
            body: request,
            requiresAuth: true
        )
    }
}
