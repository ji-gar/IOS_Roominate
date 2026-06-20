import SwiftUI

struct CreatePostAmenitiesView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    private let room = AmenityRoom.livingRoom
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    amenitySection
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
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

    private var amenitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(room.sectionTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showCustomAmenityField.toggle()
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }

            if viewModel.showCustomAmenityField {
                OutlinedInputField(
                    label: "Amenities",
                    text: viewModel.customAmenityBinding(for: room)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .onSubmit {
                    viewModel.submitCustomAmenity(for: room)
                }
            }

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

            if !viewModel.selectedTags(for: room).isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.selectedTags(for: room), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.93, green: 0.94, blue: 0.95))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}
