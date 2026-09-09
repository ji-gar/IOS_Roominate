import MapKit
import SwiftUI

struct CreatePostPreviewView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let onBack: () -> Void
    let onPublish: () -> Void

    private var draft: PostDraft { viewModel.draft }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    photoCarousel
                    titleBlock
                    overviewGrid
                    financialSection
                    preferenceSection
                    if !draft.amenities.isEmpty {
                        amenitiesSection
                    }
                    locationSection
                    if !draft.description.isEmpty {
                        aboutSection
                    }
                }
                .padding(16)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            bottomBar
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Sync amenities to ensure custom amenities added via "+" are included
            viewModel.syncAmenities()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16))
                    }
                    .foregroundStyle(AppTheme.primaryBlue)
                }
            }
        }
        .alert("Couldn't publish", isPresented: errorBinding) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong. Please try again.")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    // MARK: - Photos

    @ViewBuilder
    private var photoCarousel: some View {
        if viewModel.images.isEmpty {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.chipBackground)
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.4))
            }
            .frame(height: 220)
        } else {
            TabView {
                ForEach(viewModel.images) { item in
                    Image(uiImage: item.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                }
            }
            .frame(height: 220)
            .tabViewStyle(.page)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Title

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(draft.title.isEmpty ? "Untitled Listing" : draft.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer(minLength: 8)
                availableBadge
            }

            Text(formattedRent(draft.monthlyRent, suffix: " / month"))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)

            if !locationLine.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(locationLine)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }

    private var availableBadge: some View {
        Text("Available")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(AppTheme.availableGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.availableGreenBackground)
            .clipShape(Capsule())
    }

    // MARK: - Overview

    private var overviewGrid: some View {
        VStack(spacing: 12) {
            InfoCardRow(
                left: InfoCard(icon: "house", caption: "Property Type", value: orDash(draft.propertyType)),
                right: InfoCard(icon: "lock", caption: "Room Type", value: orDash(draft.typeOfSpace))
            )
            InfoCardRow(
                left: InfoCard(icon: "sofa", caption: "Furnishing", value: orDash(draft.homeFurnishing)),
                right: InfoCard(icon: "calendar", caption: "Move-in Date", value: orDash(viewModel.displayDate(for: draft.availableFrom)))
            )
        }
    }

    // MARK: - Financial

    private var financialSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionTitle(title: "Financial Details")
            InfoCardRow(
                left: InfoCard(icon: "creditcard", caption: "Security Deposit", value: formattedRent(draft.deposit)),
                right: InfoCard(icon: "bolt", caption: "Extra Cost", value: draft.extraCost.isEmpty ? "Included" : extraCostDisplay(draft.extraCost))
            )
            InfoCard(
                icon: "clock",
                caption: "Stay Duration",
                value: draft.lookingForLongTerm ? "Long Term" : "Short Term"
            )
        }
    }

    // MARK: - Preferences

    private var preferenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionTitle(title: "Flatmate Preference")
            InfoCardRow(
                left: InfoCard(icon: "person", caption: "Gender", value: orDash(draft.flatmatePreference)),
                right: InfoCard(icon: "fork.knife", caption: "Food", value: formattedFoodPreference)
            )
            InfoCardRow(
                left: InfoCard(icon: "nosign", caption: "Smoking", value: formattedSmokingPreference),
                right: InfoCard(icon: "briefcase", caption: "Profession", value: orDash(draft.profession))
            )
        }
    }

    // MARK: - Amenities

    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionTitle(title: "Amenities")
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                spacing: 10
            ) {
                ForEach(amenityItems, id: \.label) { amenity in
                    VStack(spacing: 6) {
                        Image(systemName: amenity.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(AppTheme.primaryBlue)
                            .frame(height: 20)
                        
                        Text(amenity.label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.chipBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            // Show custom amenities (those not in standard list) as text chips
            if !customAmenityLabels.isEmpty {
                FlexibleWrap(items: customAmenityLabels, spacing: 8, lineSpacing: 8) { item in
                    TagChip(text: item)
                }
            }
        }
    }
    
    private var amenityItems: [(label: String, icon: String)] {
        draft.amenities.compactMap { label in
            // Try to find matching AmenityItem for icon
            if let item = AmenityItem.all.first(where: { $0.label.lowercased() == label.lowercased() }) {
                return (label: item.label, icon: item.icon)
            }
            return nil
        }
    }
    
    private var customAmenityLabels: [String] {
        draft.amenities.filter { label in
            !AmenityItem.all.contains(where: { $0.label.lowercased() == label.lowercased() })
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionTitle(title: "Location & Map")
            mapView
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.infoCardBorder, lineWidth: 1)
                )
            if !fullAddress.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.iconTint)
                    Text(fullAddress)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @ViewBuilder
    private var mapView: some View {
        if #available(iOS 17.0, *) {
            Map(position: .constant(.region(viewModel.mapRegion)))
                .allowsHitTesting(false)
        } else {
            Map(coordinateRegion: $viewModel.mapRegion)
                .allowsHitTesting(false)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            DetailSectionTitle(title: "About this place")
            Text(draft.description)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            PrimaryButton(
                title: viewModel.editingPostId != nil ? "Update Post" : "Publish Post",
                isEnabled: !viewModel.isSubmitting,
                isLoading: viewModel.isSubmitting,
                action: onPublish
            )
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }

    // MARK: - Helpers

    private func orDash(_ value: String) -> String {
        value.isEmpty ? "—" : value
    }

    private var formattedFoodPreference: String {
        guard !draft.foodPreference.isEmpty else { return "—" }
        return draft.foodPreference
            .split(separator: ",")
            .map { part in
                let trimmed = part.trimmingCharacters(in: .whitespacesAndNewlines)
                switch trimmed.lowercased() {
                case "veg": return "Veg"
                case "non veg", "non_veg", "non-veg": return "Non-veg"
                default: return trimmed
                }
            }
            .joined(separator: ", ")
    }

    private var formattedSmokingPreference: String {
        guard !draft.smoking.isEmpty else { return "—" }
        return draft.smoking
            .split(separator: ",")
            .map { part in
                let trimmed = part.trimmingCharacters(in: .whitespacesAndNewlines)
                switch trimmed.lowercased() {
                case "yes": return "Smoker"
                case "no": return "Non Smoker"
                default: return trimmed
                }
            }
            .joined(separator: ", ")
    }

    private var locationLine: String {
        [draft.area, draft.city].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    private var fullAddress: String {
        [draft.landmark, draft.area, draft.city, draft.state, draft.pincode]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    private func formattedRent(_ value: String, suffix: String = "") -> String {
        guard !value.isEmpty else { return "—" }
        let digits = value.filter(\.isNumber)
        guard let amount = Int(digits) else { return "₹\(value)\(suffix)" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? digits
        return "₹\(formatted)\(suffix)"
    }

    /// Displays extra cost as a currency amount if purely numeric, otherwise shows the raw text as-is.
    private func extraCostDisplay(_ value: String) -> String {
        guard !value.isEmpty else { return "Included" }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.allSatisfy(\.isNumber), let amount = Int(trimmed) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            let formatted = formatter.string(from: NSNumber(value: amount)) ?? trimmed
            return "₹\(formatted)"
        }
        return trimmed
    }
}
