import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void

    init(
        title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundStyle(isEnabled ? Color.white : AppTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.buttonHeight)
            .background(isEnabled ? AppTheme.primaryBlue : AppTheme.disabledButton)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
        .disabled(!isEnabled || isLoading)
    }
}

struct OutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.primaryBlue)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.buttonHeight)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppTheme.primaryBlue, lineWidth: 1.5)
                )
        }
    }
}

struct TextLinkButton: View {
    let prefix: String
    let linkText: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(prefix)
                .foregroundStyle(AppTheme.textPrimary)
            Button(action: action) {
                Text(linkText)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .font(.system(size: 14))
    }
}
