import SwiftUI

/// Keeps typed text visible on light field backgrounds when the device uses dark mode.
struct AppTextInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(AppTheme.textPrimary)
            .tint(AppTheme.primaryBlue)
    }
}

extension View {
    func appTextInputStyle() -> some View {
        modifier(AppTextInputStyle())
    }
}
