import SwiftUI

struct CreatePostPreferencesView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    private let threeColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    private let twoColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Text("Set Your Preferences for\nRoomy")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    // Flatmate preference
                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Flatmate Preference")
                        LazyVGrid(columns: threeColumns, spacing: 10) {
                            ForEach(FlatmatePreferenceOption.allCases) { option in
                                IconChoiceChip(
                                    title: option.rawValue,
                                    icon: option.icon,
                                    isSelected: viewModel.draft.flatmatePreference == option.rawValue
                                ) {
                                    viewModel.draft.flatmatePreference = option.rawValue
                                }
                            }
                        }
                    }

                    // Food preference
                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Food Preference")
                        LazyVGrid(columns: twoColumns, spacing: 10) {
                            ForEach(FoodPreferenceOption.allCases) { option in
                                IconChoiceChip(
                                    title: option.rawValue,
                                    icon: option.icon,
                                    isSelected: viewModel.draft.foodPreference == option.rawValue
                                ) {
                                    viewModel.draft.foodPreference = option.rawValue
                                }
                            }
                        }
                    }

                    // Smoking
                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Smoking")
                        LazyVGrid(columns: twoColumns, spacing: 10) {
                            ForEach(SmokingOption.allCases) { option in
                                IconChoiceChip(
                                    title: option.rawValue,
                                    icon: option.icon,
                                    isSelected: viewModel.draft.smoking == option.apiValue
                                ) {
                                    viewModel.draft.smoking = option.apiValue
                                }
                            }
                        }
                    }

                    // Profession
                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Profession")
                        LazyVGrid(columns: twoColumns, spacing: 10) {
                            ForEach(ProfessionOption.allCases) { option in
                                IconChoiceChip(
                                    title: option.rawValue,
                                    icon: option.icon,
                                    isSelected: viewModel.draft.profession == option.rawValue
                                ) {
                                    viewModel.draft.profession = option.rawValue
                                }
                            }
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            CreatePostBottomBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                isNextEnabled: viewModel.isPreferencesValid,
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
