import SwiftUI

/// Avatar + name + role row with an optional trailing menu button, used on cards.
struct AuthorRow: View {
    let author: ListingAuthor
    var showsMenu: Bool = true
    var onMenuTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 10) {
            AvatarView(urlString: author.avatarURL, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(author.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(author.role)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer(minLength: 0)

            if showsMenu {
                Button(action: { onMenuTap?() }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// A label/value styled line used inside the Flat card (e.g. "Rent  ₹13,000").
struct InlineDetail: View {
    let label: String
    let value: String
    var valueIsBold: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.system(size: 14, weight: valueIsBold ? .semibold : .regular))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}
