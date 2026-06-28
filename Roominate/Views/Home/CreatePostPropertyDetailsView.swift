import CoreLocation
import SwiftUI

struct CreatePostPropertyDetailsView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    private let propertyTypes = ["3BHK", "2BHK", "1BHK", "Other"]
    private let spaceTypes = ["Shared Room", "Private Room"]
    private let furnishings = ["Full Furnished", "Semi Furnished", "Unfurnished"]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Share Property Details\nwith Roomy")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    PlacesSearchTextField(
                        selectedText: $viewModel.draft.city,
                        mode: .cities,
                        placeholder: "Search city or area"
                    ) { details in
                        let city = details.city.isEmpty
                            ? IndianLocationsService.normalizedCityName(details.formattedAddress)
                            : details.city
                        viewModel.draft.city = city
                        if !details.state.isEmpty, details.state.lowercased() != "india" {
                            viewModel.draft.state = details.state
                        }
                        if IndianLocationsService.isValidCoordinate(details.coordinate) {
                            viewModel.updateMapCenter(details.coordinate)
                        }
                    }
                    .zIndex(1)

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
                        CreatePostSectionLabel(title: "Type of Space")

                        PostSpaceTypePicker(
                            options: spaceTypes,
                            selected: $viewModel.draft.typeOfSpace
                        )
                        .frame(height: 52)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        CreatePostSectionLabel(title: "Home Furnishing")

                        HStack(spacing: 10) {
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
