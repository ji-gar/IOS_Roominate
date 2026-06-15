import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var draft: ListingFilters
    @State private var matchCount: Int?
    @State private var isCountLoading = false
    @State private var countTask: Task<Void, Never>?

    /// Returns the number of posts matching the given filters (for the live "N properties match" label).
    let matchCountProvider: (ListingFilters) async -> Int?
    let onApply: (ListingFilters) -> Void

    init(
        filters: ListingFilters,
        matchCountProvider: @escaping (ListingFilters) async -> Int?,
        onApply: @escaping (ListingFilters) -> Void
    ) {
        _draft = State(initialValue: filters)
        self.matchCountProvider = matchCountProvider
        self.onApply = onApply
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    rentSection
                    citySection
                    propertyTypeSection
                    lookingForSection
                    roomTypeSection
                    furnishingSection
                    moveInSection
                    amenitiesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            footer
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear { scheduleCountRefresh() }
        .onChange(of: draft) { _, _ in scheduleCountRefresh() }
    }

    // MARK: - Chrome

    private var grabber: some View {
        Capsule()
            .fill(AppTheme.segmentTrack)
            .frame(width: 40, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private var header: some View {
        HStack {
            Text("Filters")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Button("Reset all") {
                withAnimation(.easeInOut(duration: 0.2)) {
                    draft.reset()
                }
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(AppTheme.primaryBlue)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Sections

    private var rentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FilterSectionHeader("Monthly Rent")

            HStack {
                Text("\(currency(draft.minRent)) — \(currency(draft.maxRent))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text("Range selected")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.primaryBlue)
            }

            RentRangeSlider(
                lowerValue: $draft.minRent,
                upperValue: $draft.maxRent,
                bounds: ListingFilters.rentBounds,
                step: ListingFilters.rentStep
            )

            HStack {
                Text(currency(ListingFilters.rentBounds.lowerBound))
                Spacer()
                Text(currency(ListingFilters.rentBounds.upperBound))
            }
            .font(.system(size: 12))
            .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var citySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FilterSectionHeader("City")
            FlowLayout(spacing: 10, lineSpacing: 10) {
                ForEach(ListingFilters.cities, id: \.self) { city in
                    FilterChip(title: city, isSelected: draft.city == city) {
                        draft.city = draft.city == city ? nil : city
                    }
                }
            }
        }
    }

    private var propertyTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FilterSectionHeader("Property Type")
            FlowLayout(spacing: 10, lineSpacing: 10) {
                ForEach(ListingFilters.PropertyType.allCases) { type in
                    FilterChip(title: type.rawValue, isSelected: draft.propertyType == type) {
                        draft.propertyType = draft.propertyType == type ? nil : type
                    }
                }
            }
        }
    }

    private var lookingForSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FilterSectionHeader("Looking For")
            HStack(spacing: 4) {
                ForEach(ListingFilters.LookingFor.allCases) { option in
                    lookingForSegment(option)
                }
            }
            .padding(4)
            .background(AppTheme.segmentTrack)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func lookingForSegment(_ option: ListingFilters.LookingFor) -> some View {
        let isSelected = draft.lookingFor == option
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                draft.lookingFor = option
            }
        } label: {
            Text(option.rawValue)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var roomTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FilterSectionHeader("Room Type")
            HStack(spacing: 12) {
                ForEach(ListingFilters.RoomType.allCases) { type in
                    RoomTypeCard(roomType: type, isSelected: draft.roomType == type) {
                        draft.roomType = draft.roomType == type ? nil : type
                    }
                }
            }
        }
    }

    private var furnishingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            FilterSectionHeader("Furnishing")
            ForEach(ListingFilters.Furnishing.allCases) { option in
                FurnishingToggleRow(
                    title: option.rawValue,
                    isOn: binding(for: option)
                )
            }
        }
    }

    private func binding(for option: ListingFilters.Furnishing) -> Binding<Bool> {
        Binding(
            get: { draft.furnishing.contains(option) },
            set: { isOn in
                if isOn { draft.furnishing.insert(option) }
                else { draft.furnishing.remove(option) }
            }
        )
    }

    private var moveInSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FilterSectionHeader("Move-in Date")
            HStack(spacing: 12) {
                MoveInDateField(caption: "From", date: $draft.moveInFrom)
                MoveInDateField(caption: "To", date: $draft.moveInTo)
            }
        }
    }

    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FilterSectionHeader("Amenities")
            FlowLayout(spacing: 10, lineSpacing: 10) {
                ForEach(ListingFilters.Amenity.allCases) { amenity in
                    FilterChip(
                        title: amenity.rawValue,
                        systemImage: amenity.systemImage,
                        isSelected: draft.amenities.contains(amenity)
                    ) {
                        if draft.amenities.contains(amenity) {
                            draft.amenities.remove(amenity)
                        } else {
                            draft.amenities.insert(amenity)
                        }
                    }
                }
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            PrimaryButton(title: "Apply Filters") {
                onApply(draft)
                dismiss()
            }
            matchLabel
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.06), radius: 8, y: -4)
                .ignoresSafeArea()
        )
    }

    private var matchLabel: some View {
        Group {
            if isCountLoading {
                Text("Updating matches…")
            } else if let matchCount {
                Text("\(matchCount) properties match")
            } else {
                Text(" ")
            }
        }
        .font(.system(size: 13))
        .foregroundStyle(AppTheme.textSecondary)
        .frame(height: 16)
    }

    // MARK: - Match count

    private func scheduleCountRefresh() {
        countTask?.cancel()
        isCountLoading = true
        countTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            let count = await matchCountProvider(draft)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                matchCount = count
                isCountLoading = false
            }
        }
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: value)) ?? String(Int(value))
        return "₹\(formatted)"
    }
}

#Preview {
    FilterView(
        filters: ListingFilters(),
        matchCountProvider: { _ in 248 },
        onApply: { _ in }
    )
}
