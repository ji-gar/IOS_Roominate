import CoreLocation
import SwiftUI

struct CreatePostPropertyDetailsView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    private let propertyTypes = ["1RK", "1BHK", "2BHK", "3BHK", "Other"]
    private let spaceTypes = ["Shared Room", "Private Room"]
    private let furnishings = ["Full Furnished", "Semi Furnished", "Unfurnished"]
    
    private var pageTitle: String {
        viewModel.editingPostId != nil ? "Edit Post" : "Create Post"
    }

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
                        placeholder: "Search City"
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
                                    isSelected: viewModel.draft.propertyType == type
                                ) {
                                    viewModel.draft.propertyType = type
                                }
                                .contentShape(Rectangle())
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
                                    isSelected: viewModel.draft.homeFurnishing == item
                                ) {
                                    viewModel.draft.homeFurnishing = item
                                }
                                .contentShape(Rectangle())
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
                onBack: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    onBack()
                },
                onNext: onNext
            )
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationTitle(pageTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text(pageTitle)
                            .font(.system(size: 16))
                    }
                    .foregroundStyle(AppTheme.primaryBlue)
                }
            }
        }
    }
}
