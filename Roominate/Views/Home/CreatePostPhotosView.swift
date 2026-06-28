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

    private let minPhotos = 5
    private let maxPhotos = 10
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)

    private var remainingSlots: Int {
        max(0, maxPhotos - viewModel.images.count)
    }

    private var photosNeeded: Int {
        max(0, minPhotos - viewModel.images.count)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Upload pictures")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.top, 8)

                    Text(uploadHint)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)

                    if !viewModel.images.isEmpty {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.images) { item in
                                filledSlot(item)
                            }
                        }
                    }

                    if remainingSlots > 0 {
                        bulkPhotoPicker
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

    private var uploadHint: String {
        if viewModel.images.isEmpty {
            return "Select at least \(minPhotos) pictures in one go"
        }
        if photosNeeded > 0 {
            return "\(photosNeeded) more picture\(photosNeeded == 1 ? "" : "s") needed (minimum \(minPhotos))"
        }
        return "\(viewModel.images.count) of \(maxPhotos) pictures added"
    }

    private var bulkPhotoPicker: some View {
        PhotosPicker(
            selection: $pickerItems,
            maxSelectionCount: remainingSlots,
            matching: .images,
            photoLibrary: .shared()
        ) {
            HStack(spacing: 8) {
                if isLoadingPhotos {
                    ProgressView()
                        .tint(AppTheme.textSecondary)
                } else {
                    Image(systemName: viewModel.images.isEmpty ? "photo.on.rectangle.angled" : "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(bulkPickerLabel)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: viewModel.images.isEmpty ? 160 : 56)
            .background(Color(red: 0.93, green: 0.94, blue: 0.95))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isLoadingPhotos)
    }

    private var bulkPickerLabel: String {
        if viewModel.images.isEmpty {
            return "Select Photos"
        }
        if photosNeeded > 0 {
            return "Select \(photosNeeded) More"
        }
        return "Add More Photos"
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
            }
        }
    }
}
