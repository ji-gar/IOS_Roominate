import SwiftUI

struct FlatmateDetailView: View {
    let listing: FlatmateListing

    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite = false

    var body: some View {
        VStack(spacing: 0) {
            DetailNavBar(title: "View Listing", onBack: { dismiss() }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 44, height: 44)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    profileCard
                    locationPreferences
                    overviewGrid
                    preferenceSection
                    lifestyleSection
                    aboutSection
                }
                .padding(16)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            DetailBottomBar(
                isFavorite: isFavorite,
                onToggleFavorite: { isFavorite.toggle() },
                onInterested: {}
            )
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var profileCard: some View {
        VStack(spacing: 8) {
            AvatarView(urlString: listing.author.avatarURL, size: 72)
            Text(listing.author.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Text(listing.author.role)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
            Text(listing.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var locationPreferences: some View {
        VStack(alignment: .leading, spacing: 14) {
            DetailSectionTitle(title: "Location Preferences")

            VStack(alignment: .leading, spacing: 6) {
                Text("Max Budget")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                HStack {
                    Text(listing.maxBudgetMonthly)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    if listing.isAvailable {
                        AvailableBadge()
                    }
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

            VStack(alignment: .leading, spacing: 8) {
                Text("Preferred Areas")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                WrapChips(items: listing.preferredAreas)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var overviewGrid: some View {
        VStack(spacing: 12) {
            InfoCardRow(
                left: InfoCard(icon: "house", caption: "Property Type", value: listing.propertyType),
                right: InfoCard(icon: "lock", caption: "Room Type", value: listing.roomType)
            )
            InfoCardRow(
                left: InfoCard(icon: "sofa", caption: "Furnishing", value: listing.furnishing),
                right: InfoCard(icon: "clock", caption: "Duration", value: listing.duration)
            )
            InfoCardRow(
                left: InfoCard(icon: "calendar", caption: "Move-in Date", value: listing.moveInDate),
                right: InfoCard(icon: "calendar", caption: "Move-out Date", value: listing.moveOutDate)
            )
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

    private var lifestyleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("Lifestyle Notes")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                WrapChips(items: listing.lifestyleNotes)
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            DetailSectionTitle(title: "About Me")
            Text(listing.aboutMe)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(3)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.infoCardBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    NavigationStack {
        FlatmateDetailView(listing: MockListings.flatmates[0])
    }
}
