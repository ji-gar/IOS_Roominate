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
                    Text("Set your preferences for\nflatmate")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Flatmate Preference")
                        LazyVGrid(columns: threeColumns, spacing: 10) {
                            ForEach(FlatmatePreferenceOption.allCases) { option in
                                IconChoiceChip(
                                    title: option.rawValue,
                                    icon: option.icon,
                                    isSelected: viewModel.isPreferenceSelected(
                                        option.rawValue,
                                        in: viewModel.draft.flatmatePreference
                                    )
                                ) {
                                    viewModel.togglePreference(
                                        option.rawValue,
                                        in: \.flatmatePreference
                                    )
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Food Preference")
                        LazyVGrid(columns: twoColumns, spacing: 10) {
                            ForEach(FoodPreferenceOption.allCases) { option in
                                IconChoiceChip(
                                    title: option.rawValue,
                                    icon: option.icon,
                                    isSelected: viewModel.isPreferenceSelected(
                                        option.rawValue,
                                        in: viewModel.draft.foodPreference
                                    )
                                ) {
                                    viewModel.togglePreference(
                                        option.rawValue,
                                        in: \.foodPreference
                                    )
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Smoking")
                        LazyVGrid(columns: twoColumns, spacing: 10) {
                            ForEach(SmokingOption.allCases) { option in
                                IconChoiceChip(
                                    title: option.rawValue,
                                    icon: option.icon,
                                    isSelected: viewModel.isPreferenceSelected(
                                        option.apiValue,
                                        in: viewModel.draft.smoking
                                    )
                                ) {
                                    viewModel.togglePreference(
                                        option.apiValue,
                                        in: \.smoking
                                    )
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Profession")
                        LazyVGrid(columns: twoColumns, spacing: 10) {
                            ForEach(ProfessionOption.allCases) { option in
                                IconChoiceChip(
                                    title: option.rawValue,
                                    icon: option.icon,
                                    isSelected: viewModel.isPreferenceSelected(
                                        option.rawValue,
                                        in: viewModel.draft.profession
                                    )
                                ) {
                                    viewModel.togglePreference(
                                        option.rawValue,
                                        in: \.profession
                                    )
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
