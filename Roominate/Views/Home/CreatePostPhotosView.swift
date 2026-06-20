import PhotosUI
import SwiftUI

struct CreatePostPhotosView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var isLoadingPhotos = false
    @State private var activeSlotIndex: Int?

    private let minPhotos = 5
    private let maxPhotos = 10

    private var slotCount: Int {
        max(minPhotos, min(viewModel.images.count + 1, maxPhotos))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Upload pictures")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.top, 8)

                    Text("Upload at least \(minPhotos) pictures")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)

                    VStack(spacing: 14) {
                        ForEach(0 ..< slotCount, id: \.self) { index in
                            if index < viewModel.images.count {
                                filledSlot(viewModel.images[index])
                            } else {
                                addSlot(at: index)
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
                nextLabel: "Preview",
                isNextEnabled: viewModel.isPhotosValid,
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
        .onChange(of: pickerItems) { _, newItems in
            loadPhotos(newItems)
        }
    }

    private func filledSlot(_ item: DraftImage) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: item.image)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Button {
                viewModel.removeImage(item.id)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Circle())
            }
            .padding(10)
        }
    }

    private func addSlot(at index: Int) -> some View {
        PhotosPicker(
            selection: $pickerItems,
            maxSelectionCount: maxPhotos - viewModel.images.count,
            matching: .images,
            photoLibrary: .shared()
        ) {
            HStack(spacing: 8) {
                if isLoadingPhotos && activeSlotIndex == index {
                    ProgressView()
                        .tint(AppTheme.textSecondary)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("Add Stay")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(Color(red: 0.93, green: 0.94, blue: 0.95))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isLoadingPhotos || viewModel.images.count >= maxPhotos)
        .simultaneousGesture(TapGesture().onEnded {
            activeSlotIndex = index
        })
    }

    private func loadPhotos(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        isLoadingPhotos = true
        Task {
            var datas: [Data] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    datas.append(data)
                }
            }
            await MainActor.run {
                viewModel.addImages(datas)
                pickerItems = []
                isLoadingPhotos = false
                activeSlotIndex = nil
            }
        }
    }
}
