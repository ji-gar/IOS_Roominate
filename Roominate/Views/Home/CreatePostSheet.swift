import SwiftUI

// MARK: - Route

enum CreatePostRoute: Hashable {
    case overview
    case step1Intro
    case propertyDetails
    case amenities
    case location
    case step2Intro
    case availability
    case preferences
    case step3Intro
    case description
    case photos
    case preview
}

// MARK: - Flow Container

struct CreatePostFlowView: View {
    @StateObject private var viewModel: CreatePostViewModel
    @State private var path: [CreatePostRoute] = []

    /// Number of form screens that carry the bottom progress bar.
    private let formStepCount = 7

    private let postService: PostServiceProtocol
    private let onDismiss: () -> Void
    private let onSuccess: () -> Void

    init(
        postService: PostServiceProtocol = PostService(),
        onDismiss: @escaping () -> Void,
        onSuccess: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: CreatePostViewModel())
        self.postService = postService
        self.onDismiss = onDismiss
        self.onSuccess = onSuccess
    }

    var body: some View {
        NavigationStack(path: $path) {
            CreatePostTypeSelectionView(
                onSelect: selectPostType,
                onDismiss: onDismiss
            )
            .navigationDestination(for: CreatePostRoute.self) { route in
                destinationView(for: route)
            }
        }
    }

    private func selectPostType(_ postType: Bool) {
        viewModel.draft.postType = postType
        path.append(.overview)
    }

    @ViewBuilder
    private func destinationView(for route: CreatePostRoute) -> some View {
        switch route {
        case .overview:
            CreatePostOverviewView(
                onStart: { path.append(.step1Intro) },
                onDismiss: { path.removeLast() }
            )

        // MARK: Step 1 — Home & Amenities

        case .step1Intro:
            CreatePostStepIntroView(
                stepIndex: 0,
                totalSteps: 3,
                stepLabel: "Step 1",
                title: "Home & Amenities",
                subtitle: "Tell us about your place — number of rooms, type of furnishing, and included amenities.",
                systemImage: "sofa.fill",
                tint: Color(red: 0.91, green: 0.68, blue: 0.22),
                bgColor: Color(red: 0.96, green: 0.92, blue: 0.84),
                onBack: { path.removeLast() },
                onNext: { path.append(.propertyDetails) }
            )

        case .propertyDetails:
            CreatePostPropertyDetailsView(
                viewModel: viewModel,
                currentStep: 1,
                totalSteps: formStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.amenities) }
            )

        case .amenities:
            CreatePostAmenitiesView(
                viewModel: viewModel,
                currentStep: 2,
                totalSteps: formStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.location) }
            )

        case .location:
            CreatePostLocationView(
                viewModel: viewModel,
                currentStep: 3,
                totalSteps: formStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.step2Intro) }
            )

        // MARK: Step 2 — Availability & Rent

        case .step2Intro:
            CreatePostStepIntroView(
                stepIndex: 1,
                totalSteps: 3,
                stepLabel: "Step 2",
                title: "Get Availability & Rent",
                subtitle: "Let others know when the place is available and how much the rent is.",
                systemImage: "calendar.badge.clock",
                tint: Color(red: 0.20, green: 0.53, blue: 0.96),
                bgColor: Color(red: 0.86, green: 0.92, blue: 0.99),
                onBack: { path.removeLast() },
                onNext: { path.append(.availability) }
            )

        case .availability:
            CreatePostAvailabilityView(
                viewModel: viewModel,
                currentStep: 4,
                totalSteps: formStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.preferences) }
            )

        case .preferences:
            CreatePostPreferencesView(
                viewModel: viewModel,
                currentStep: 5,
                totalSteps: formStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.step3Intro) }
            )

        // MARK: Step 3 — Location & Photos

        case .step3Intro:
            CreatePostStepIntroView(
                stepIndex: 2,
                totalSteps: 3,
                stepLabel: "Step 3",
                title: "Add Location & Photos",
                subtitle: "Share a short description and upload clear photos to help others picture the space.",
                systemImage: "house.fill",
                tint: Color(red: 0.82, green: 0.38, blue: 0.22),
                bgColor: Color(red: 0.99, green: 0.90, blue: 0.86),
                onBack: { path.removeLast() },
                onNext: { path.append(.description) }
            )

        case .description:
            CreatePostDescriptionView(
                viewModel: viewModel,
                currentStep: 6,
                totalSteps: formStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.photos) }
            )

        case .photos:
            CreatePostPhotosView(
                viewModel: viewModel,
                currentStep: 7,
                totalSteps: formStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.preview) }
            )

        case .preview:
            CreatePostPreviewView(
                viewModel: viewModel,
                onBack: { path.removeLast() },
                onPublish: submitPost
            )
        }
    }

    private func submitPost() {
        Task {
            let ok = await viewModel.submit(postService: postService)
            if ok { onSuccess() }
        }
    }
}
