import SwiftUI

/// Card shown in the "Flat" segment of the Home feed.
struct FlatCard: View {
    let listing: FlatListing
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    var onReport: (() -> Void)? = nil

    @State private var currentImage = 0
    @State private var showCardMenu = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AuthorRow(author: listing.author, onMenuTap: { showCardMenu.toggle() })

            imageCarousel

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

            VStack(alignment: .leading, spacing: 8) {
                InlineDetail(label: "Looking for", value: listing.lookingFor)
                InlineDetail(label: "Deposit", value: listing.deposit, valueIsBold: false)
                InlineDetail(label: "Rent", value: listing.rent, valueIsBold: false)

                HStack(spacing: 10) {
                    InlineDetail(label: "Move In", value: listing.moveIn, valueIsBold: false)
                    if listing.isShortStay {
                        ShortStayBadge()
                    }
                }

                Text(listing.amenities)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textPrimary)
            }
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

    private var imageCarousel: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $currentImage) {
                ForEach(Array(listing.imageURLs.enumerated()), id: \.offset) { index, url in
                    RemoteImage(urlString: url)
                        .frame(maxWidth: .infinity)
                        .frame(height: 190)
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: listing.imageURLs.count > 1 ? .automatic : .never))
            .frame(height: 190)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            FavoriteButton(isFavorite: isFavorite, action: onToggleFavorite)
                .padding(10)
        }
    }
}
