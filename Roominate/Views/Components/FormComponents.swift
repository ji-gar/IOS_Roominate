import SwiftUI

struct RequiredLabel: View {
    let title: String

    var body: some View {
        HStack(spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
            Text(Strings.Profile.required)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.errorRed)
        }
    }
}

struct SelectionCard: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(isSelected ? AppTheme.activeFieldBackground : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isSelected ? AppTheme.primaryBlue : AppTheme.fieldBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }
}
