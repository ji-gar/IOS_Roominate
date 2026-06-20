import SwiftUI

struct CreatePostAvailabilityView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Text("Add Rent & Availability\nDetails")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    // Monthly Rent
                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Monthly Rent")
                        CreatePostCurrencyField(amount: $viewModel.draft.monthlyRent, placeholder: "10,000")
                    }

                    // Deposit
                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Deposit")
                        CreatePostCurrencyField(amount: $viewModel.draft.deposit, placeholder: "20,000")
                    }

                    // Extra cost
                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Extra Cost (Maintenance, etc.)", isRequired: false)
                        CreatePostCurrencyField(amount: $viewModel.draft.extraCost, placeholder: "0")
                    }

                    // Stay duration
                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Stay Duration")
                        CreatePostToggleRow(
                            title: "Looking for Long Term",
                            subtitle: viewModel.draft.lookingForLongTerm
                                ? "Open to a long term stay"
                                : "Short term / temporary stay only",
                            isOn: $viewModel.draft.lookingForLongTerm
                        )
                    }

                    // Available from
                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Available From")
                        CreatePostDateField(
                            placeholder: "Select start date",
                            displayValue: viewModel.displayDate(for: viewModel.draft.availableFrom),
                            date: $viewModel.availableFromDate
                        )
                    }

                    // Available to (short term only)
                    if !viewModel.draft.lookingForLongTerm {
                        VStack(alignment: .leading, spacing: 10) {
                            CreatePostSectionLabel(title: "Available To")
                            CreatePostDateField(
                                placeholder: "Select end date",
                                displayValue: viewModel.displayDate(for: viewModel.draft.availableTo),
                                date: $viewModel.availableToDate,
                                minimumDate: viewModel.availableFromDate
                            )
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .animation(.easeInOut(duration: 0.2), value: viewModel.draft.lookingForLongTerm)
            }

            CreatePostBottomBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                isNextEnabled: viewModel.isAvailabilityValid,
                onBack: onBack,
                onNext: onNext
            )
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Create Post")
                            .font(.system(size: 16))
                    }
                    .foregroundStyle(AppTheme.primaryBlue)
                }
            }
        }
    }
}
