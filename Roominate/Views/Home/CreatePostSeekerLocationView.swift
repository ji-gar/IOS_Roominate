import SwiftUI

struct CreatePostSeekerLocationView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Share Your Location\nPreference")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Select City")
                        PlacesSearchTextField(
                            selectedText: $viewModel.draft.city,
                            mode: .cities,
                            placeholder: "Search city"
                        ) { details in
                            let city = details.city.isEmpty
                                ? IndianLocationsService.normalizedCityName(details.formattedAddress)
                                : details.city
                            viewModel.draft.city = city
                            if !details.state.isEmpty, details.state.lowercased() != "india" {
                                viewModel.draft.state = details.state
                            }
                            if !details.pincode.isEmpty {
                                viewModel.draft.pincode = details.pincode
                            }
                        }
                        .zIndex(2)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Preferred Area")
                        PlacesSearchTextField(
                            selectedText: $viewModel.preferredAreaQuery,
                            mode: viewModel.draft.city.isEmpty
                                ? .address
                                : .landmarks(city: viewModel.draft.city),
                            placeholder: "Search preferred area"
                        ) { details in
                            let area = details.area.isEmpty ? details.landmark : details.area
                            let label = area.isEmpty ? details.formattedAddress : area
                            viewModel.addPreferredArea(label)
                            if !details.pincode.isEmpty {
                                viewModel.draft.pincode = details.pincode
                            }
                        }
                        .zIndex(1)
                        .disabled(viewModel.draft.city.isEmpty)
                        .opacity(viewModel.draft.city.isEmpty ? 0.55 : 1)
                    }

                    if !viewModel.preferredAreas.isEmpty {
                        FlowLayout(spacing: 8, lineSpacing: 8) {
                            ForEach(viewModel.preferredAreas, id: \.self) { area in
                                RemovableTagChip(text: area) {
                                    viewModel.removePreferredArea(area)
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
                isNextEnabled: viewModel.isSeekerLocationValid,
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
