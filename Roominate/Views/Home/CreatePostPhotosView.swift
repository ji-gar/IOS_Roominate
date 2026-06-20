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

    private let maxPhotos = 10
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Add Photos of Your\nPlace")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    Text("Add clear, well-lit photos so roommates can picture the space. You can add up to \(maxPhotos) photos.")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    if viewModel.images.isEmpty {
                        emptyState
                    } else {
                        photoGrid
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
                isNextEnabled: !viewModel.images.isEmpty,
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

    // MARK: - Empty State

    private var emptyState: some View {
        PhotosPicker(
            selection: $pickerItems,
            maxSelectionCount: maxPhotos,
            matching: .images,
            photoLibrary: .shared()
        ) {
            VStack(spacing: 12) {
                if isLoadingPhotos {
                    ProgressView()
                        .tint(AppTheme.primaryBlue)
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 38))
                        .foregroundStyle(AppTheme.primaryBlue)
                }

                Text(isLoadingPhotos ? "Adding photos…" : "Tap to add photos")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("JPG or PNG")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(AppTheme.screenBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        AppTheme.fieldBorder,
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 5])
                    )
            )
        }
        .disabled(isLoadingPhotos)
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.images) { item in
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: item.image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 104)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))

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
                    .padding(6)
                }
            }

            if viewModel.images.count < maxPhotos {
                PhotosPicker(
                    selection: $pickerItems,
                    maxSelectionCount: maxPhotos - viewModel.images.count,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack(spacing: 6) {
                        if isLoadingPhotos {
                            ProgressView().tint(AppTheme.primaryBlue)
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(AppTheme.primaryBlue)
                        }
                        Text("Add")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 104)
                    .background(AppTheme.screenBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                AppTheme.fieldBorder,
                                style: StrokeStyle(lineWidth: 1.5, dash: [6, 5])
                            )
                    )
                }
                .disabled(isLoadingPhotos)
            }
        }
    }

    // MARK: - Loading

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
