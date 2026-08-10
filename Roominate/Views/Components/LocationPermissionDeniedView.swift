import SwiftUI

/// Reusable view to show when location permission is denied
struct LocationPermissionDeniedView: View {
    @ObservedObject var locationManager: LocationManager
    var message: String = "Location access is required to use this feature"
    var compact: Bool = false
    
    var body: some View {
        if compact {
            compactView
        } else {
            fullView
        }
    }
    
    private var fullView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.textSecondary)
            
            VStack(spacing: 8) {
                Text("Location Access Needed")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text(message)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button {
                locationManager.openSettings()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "gear")
                    Text("Open Settings")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppTheme.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
        }
        .padding(.vertical, 32)
    }
    
    private var compactView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "location.slash.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppTheme.textSecondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Location Access Needed")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text("Enable location in Settings to use this feature")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                Spacer()
            }
            
            Button {
                locationManager.openSettings()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "gear")
                        .font(.system(size: 13))
                    Text("Open Settings")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(AppTheme.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 32) {
        LocationPermissionDeniedView(
            locationManager: LocationManager()
        )
        
        LocationPermissionDeniedView(
            locationManager: LocationManager(),
            compact: true
        )
        .padding()
    }
}
