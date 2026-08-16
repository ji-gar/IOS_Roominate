import SwiftUI

/// Keeps typed text and placeholder text visible in both light and dark mode.
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
