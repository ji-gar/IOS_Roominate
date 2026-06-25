import SwiftUI

struct FlatDetailView: View {
    let listing: FlatListing
    var onStartChat: ((Int, String, Int?, Int?) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @StateObject private var startChatVM = StartChatViewModel()
    @State private var isFavorite = false

    var body: some View {
        VStack(spacing: 0) {
            DetailNavBar(title: "Search", onBack: { dismiss() }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 44, height: 44)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    authorRow
                    heroImage
                    titleBlock
                    overviewGrid
                    financialSection
                    preferenceSection
                }
                .padding(16)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            DetailBottomBar(
                isFavorite: isFavorite,
                isLoading: startChatVM.isLoading,
                onToggleFavorite: { isFavorite.toggle() },
                onInterested: {
                    Task {
                        await startChatVM.startChat(postId: listing.id, receiverName: listing.author.name) { id, name, postId, otherUserId in
                            onStartChat?(id, name, postId, otherUserId)
                        }
                    }
                }
            )
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var authorRow: some View {
        HStack(spacing: 10) {
            AvatarView(urlString: listing.author.avatarURL, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(listing.author.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(listing.author.role)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Image(systemName: "link.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(AppTheme.primaryBlue)
        }
    }

    private var heroImage: some View {
        ZStack(alignment: .topTrailing) {
            RemoteImage(urlString: listing.imageURLs.first)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14))
            FavoriteButton(isFavorite: isFavorite, action: { isFavorite.toggle() })
                .padding(12)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(listing.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            HStack {
                Text(listing.monthlyRent)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                if listing.isAvailable {
                    AvailableBadge()
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                Text(listing.location)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    private var overviewGrid: some View {
        VStack(spacing: 12) {
            InfoCardRow(
                left: InfoCard(icon: "house", caption: "Property Type", value: listing.propertyType),
                right: InfoCard(icon: "lock", caption: "Room Type", value: listing.roomType)
            )
            InfoCardRow(
                left: InfoCard(icon: "sofa", caption: "Furnishing", value: listing.furnishing),
                right: InfoCard(icon: "calendar", caption: "Move-in Date", value: listing.moveInDate)
            )
        }
    }

    private var financialSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionTitle(title: "Financial Details")
            InfoCardRow(
                left: InfoCard(icon: "creditcard", caption: "Security Deposit", value: listing.securityDeposit),
                right: InfoCard(icon: "scissors", caption: "Brokerage", value: listing.brokerage)
            )
            InfoCard(icon: "bolt", caption: "Utilities", value: listing.utilities)
        }
    }

    private var preferenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionTitle(title: "Flatmate Preference")
            InfoCardRow(
                left: InfoCard(icon: "person", caption: "Gender", value: listing.genderPreference),
                right: InfoCard(icon: "fork.knife", caption: "Food Preference", value: listing.foodPreference)
            )
            InfoCardRow(
                left: InfoCard(icon: "nosign", caption: "Smoking", value: listing.smokingPreference),
                right: InfoCard(icon: "briefcase", caption: "Occupation", value: listing.occupation)
            )
        }
    }
}

#Preview {
    NavigationStack {
        FlatDetailView(listing: MockListings.flats[0])
    }
}
