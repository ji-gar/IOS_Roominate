import SwiftUI

/// Card shown in the "Flat-mate" segment of the Home feed.
struct FlatmateCard: View {
    let listing: FlatmateListing
    let isFavorite: Bool
    let onSave: () -> Void
    let onChat: () -> Void
    var onReport: (() -> Void)? = nil

    @State private var showCardMenu = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AuthorRow(author: listing.author, onMenuTap: { showCardMenu.toggle() })

            Text(listing.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textSecondary)
                Text(listing.location)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            InlineDetail(label: "Looking for", value: listing.lookingFor)
            InlineDetail(label: "Max Budget", value: listing.maxBudget)

            HStack(spacing: 10) {
                dateLine
                if listing.isShortStay {
                    ShortStayBadge()
                }
            }

            HStack(spacing: 8) {
                ForEach(listing.tags, id: \.self) { tag in
                    TagChip(text: tag)
                }
            }
            .padding(.top, 2)

            HStack(spacing: 12) {
                cardActionButton(
                    title: "Save",
                    systemImage: isFavorite ? "heart.fill" : "heart",
                    isHighlighted: isFavorite,
                    action: onSave
                )
                cardActionButton(title: "Chat", systemImage: "message", action: onChat)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(listing.isFeatured ? AppTheme.cardHighlight : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.infoCardBorder, lineWidth: listing.isFeatured ? 0 : 1)
        )
        .overlay(alignment: .topTrailing) {
            if showCardMenu {
                cardContextMenu
                    .padding(.top, 44)
                    .padding(.trailing, 10)
                    .zIndex(10)
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            if showCardMenu { showCardMenu = false }
        })
    }

    private var cardContextMenu: some View {
        VStack(spacing: 0) {
            contextMenuRow(systemIcon: "flag", title: "Report") {
                showCardMenu = false
                onReport?()
            }
            Divider()
                .padding(.horizontal, 12)
            contextMenuRow(systemIcon: "square.and.arrow.up", title: "Share") {
                showCardMenu = false
            }
        }
        .frame(width: 130)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 4)
    }

    private func contextMenuRow(systemIcon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemIcon)
                    .font(.system(size: 13))
                    .frame(width: 16)
                Text(title)
                    .font(.system(size: 14))
            }
            .foregroundStyle(AppTheme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private var dateLine: some View {
        HStack(spacing: 4) {
            Text("From")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
            Text(listing.fromDate)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            if let toDate = listing.toDate {
                Text("To")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                Text(toDate)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
    }

    private func cardActionButton(
        title: String,
        systemImage: String,
        isHighlighted: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(isHighlighted ? AppTheme.errorRed : AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppTheme.infoCardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
