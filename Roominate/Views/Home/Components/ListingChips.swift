import SwiftUI

/// Small gray pill used for attribute tags (Female, Non-veg, etc.).
struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(AppTheme.chipBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// Blue "Short Stay" badge.
struct ShortStayBadge: View {
    var title: String = "Short Stay"

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// Green "Available" badge used on detail screens.
struct AvailableBadge: View {
    var title: String = "Available"

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(AppTheme.availableGreen)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.availableGreenBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// Heart toggle button overlaid on listing images.
struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isFavorite ? AppTheme.errorRed : AppTheme.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}
