import SwiftUI

struct CreatePostPropertyDetailsView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    // Property type options
    private let propertyTypes = ["1BHK", "2BHK", "3BHK", "Other"]
    private let spaceTypes    = ["Shared Room", "Private Room"]
    private let furnishings   = ["Ful Furn.", "Half", "Non furn."]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Page title
                    Text("Share Property Details\nwith Roomy")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    // Area & City
                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Area & City")

                        HStack(spacing: 10) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textSecondary)

                            TextField("Enter your city or area", text: $viewModel.draft.city)
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    viewModel.draft.city.isEmpty
                                    ? AppTheme.fieldBorder
                                    : AppTheme.primaryBlue.opacity(0.5),
                                    lineWidth: 1
                                )
                        )
                    }

                    // Property Type
                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Property Type")

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                            spacing: 10
                        ) {
                            ForEach(propertyTypes, id: \.self) { type in
                                PostOptionChip(
                                    title: type,
                                    isSelected: viewModel.draft.propertyType == type
                                ) {
                                    viewModel.draft.propertyType = type
                                }
                            }
                        }
                    }

                    // Type of Space
                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Type of Space")

                        PostSpaceTypePicker(
                            options: spaceTypes,
                            selected: $viewModel.draft.typeOfSpace
                        )
                        .frame(height: 52)
                    }

                    // Home Furnishing
                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Home Furnishing")

                        HStack(spacing: 10) {
                            ForEach(furnishings, id: \.self) { item in
                                PostOptionChip(
                                    title: item,
                                    isSelected: viewModel.draft.homeFurnishing == item
                                ) {
                                    viewModel.draft.homeFurnishing = item
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
                isNextEnabled: viewModel.isPropertyDetailsValid,
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
