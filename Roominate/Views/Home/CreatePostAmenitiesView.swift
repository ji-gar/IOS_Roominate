import SwiftUI

struct CreatePostAmenitiesView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Tell Roomy What's Included\nin Your Stay")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    ForEach(AmenityRoom.allCases) { room in
                        amenitySection(for: room)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            CreatePostBottomBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
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

    private func amenitySection(for room: AmenityRoom) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(room.rawValue)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(AmenityItem.all) { amenity in
                    AmenityChipView(
                        amenity: amenity,
                        isSelected: viewModel.isAmenitySelected(room: room, amenity: amenity)
                    ) {
                        viewModel.toggleAmenity(room: room, amenity: amenity)
                    }
                    .aspectRatio(1.0, contentMode: .fit)
                }
            }
        }
    }
}
