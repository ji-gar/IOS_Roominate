import SwiftUI

struct CreatePostSeekerPropertyView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    private let propertyTypes = ["1BHK", "2BHK", "3BHK", "Other"]
    private let spaceTypes = ["Shared Room", "Private Room"]
    private let furnishings = ["Fully Furnished", "Semi Furnished", "Unfurnished"]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Select Your Preferred\nProperty Type")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Location", isRequired: false)
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textSecondary)
                            Text(viewModel.draft.city.isEmpty ? "Select city in previous step" : viewModel.draft.city)
                                .font(.system(size: 15))
                                .foregroundStyle(
                                    viewModel.draft.city.isEmpty
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary
                                )
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.fieldBorder, lineWidth: 1)
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Property Type")
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                            spacing: 10
                        ) {
                            ForEach(propertyTypes, id: \.self) { type in
                                PostOptionChip(
                                    title: type,
                                    isSelected: viewModel.isMultiValueSelected(
                                        type,
                                        in: viewModel.draft.propertyType
                                    )
                                ) {
                                    viewModel.toggleMultiValue(type, in: \.propertyType)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Room Type")
                        PostSpaceTypePicker(
                            options: spaceTypes,
                            selected: $viewModel.draft.typeOfSpace
                        )
                        .frame(height: 52)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Home Furnishing")
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2),
                            spacing: 10
                        ) {
                            ForEach(furnishings, id: \.self) { item in
                                PostOptionChip(
                                    title: item,
                                    isSelected: viewModel.isMultiValueSelected(
                                        item,
                                        in: viewModel.draft.homeFurnishing
                                    )
                                ) {
                                    viewModel.toggleMultiValue(item, in: \.homeFurnishing)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .scrollClipDisabled()

            CreatePostBottomBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                isNextEnabled: viewModel.isSeekerPropertyValid,
                onBack: onBack,
                onNext: onNext
            )
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { createPostBackToolbar(action: onBack) }
    }
}
