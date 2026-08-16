import SwiftUI

struct CreatePostSeekerPreviewView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let onBack: () -> Void
    let onPublish: () -> Void

    private var draft: PostDraft { viewModel.draft }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    summaryCard
                    if !viewModel.preferredAreas.isEmpty {
                        preferredAreasSection
                    }
                    overviewGrid
                    preferenceSection
                }
                .padding(16)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            bottomBar
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Preview Post")
        .navigationBarTitleDisplayMode(.inline)
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

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(locationTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(formattedRent(draft.monthlyRent, suffix: " / month"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                Spacer(minLength: 8)
                AvailableBadge()
            }

            if !draft.title.isEmpty {
                Text(draft.title)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var preferredAreasSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            DetailSectionTitle(title: "Preferred Areas")
            WrapChips(items: viewModel.preferredAreas)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var overviewGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionTitle(title: "Property Details")
            InfoCardRow(
                left: InfoCard(icon: "house", caption: "Property Type", value: orDash(draft.propertyType)),
                right: InfoCard(icon: "lock", caption: "Room Type", value: orDash(draft.typeOfSpace))
            )
            InfoCardRow(
                left: InfoCard(icon: "sofa", caption: "Furnishing", value: orDash(draft.homeFurnishing)),
                right: InfoCard(
                    icon: "calendar",
                    caption: "Move-in Date",
                    value: viewModel.moveInImmediately
                        ? "Immediately"
                        : orDash(viewModel.displayDate(for: draft.availableFrom))
                )
            )
        }
    }

    private var preferenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionTitle(title: "Flatmate Preference")
            InfoCardRow(
                left: InfoCard(icon: "person", caption: "Gender", value: orDash(draft.flatmatePreference)),
                right: InfoCard(icon: "fork.knife", caption: "Food", value: orDash(draft.foodPreference))
            )
            InfoCardRow(
                left: InfoCard(icon: "nosign", caption: "Smoking", value: smokingDisplay),
                right: InfoCard(icon: "briefcase", caption: "Profession", value: orDash(draft.profession))
            )
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            PrimaryButton(
                title: "Post Now",
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

    private var locationTitle: String {
        if draft.state.isEmpty {
            return draft.city
        }
        return "\(draft.city), \(draft.state)"
    }

    private func orDash(_ value: String) -> String {
        value.isEmpty ? "—" : value
    }

    private var smokingDisplay: String {
        let formatted = draft.smoking
            .split(separator: ",")
            .map { part in
                switch part.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
                case "yes": return "Smoker"
                case "no": return "Non Smoker"
                default: return part.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            .joined(separator: ", ")
        return formatted.isEmpty ? "—" : formatted
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
}
