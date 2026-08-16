import SwiftUI
import UserNotifications

/// Example view for requesting push notification permission
/// Can be shown after onboarding or when user first opens chat
struct PushPermissionView: View {
    @StateObject private var viewModel = PushNotificationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 72))
                .foregroundColor(.blue)
            
            // Title
            Text("Stay Connected")
                .font(.title)
                .fontWeight(.bold)
            
            // Description
            Text("Get notified when someone messages you or shows interest in your listings")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.requestAuthorization()
                        if viewModel.authorizationStatus == .authorized {
                            dismiss()
                        }
                    }
                } label: {
                    Text("Enable Notifications")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Not Now")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .onAppear {
            viewModel.checkAuthorizationStatus()
        }
    }
}

#Preview {
    PushPermissionView()
}
