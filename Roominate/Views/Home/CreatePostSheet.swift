import SwiftUI

// MARK: - Route

enum CreatePostRoute: Hashable {
    case step1Intro
    case propertyDetails
    case amenities
    case location
}

// MARK: - Flow Container

struct CreatePostFlowView: View {
    @StateObject private var viewModel: CreatePostViewModel
    @State private var path: [CreatePostRoute] = []

    private let postService: PostServiceProtocol
    private let onDismiss: () -> Void
    private let onSuccess: () -> Void

    init(
        postType: Bool = true,
        postService: PostServiceProtocol = PostService(),
        onDismiss: @escaping () -> Void,
        onSuccess: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: CreatePostViewModel(postType: postType))
        self.postService = postService
        self.onDismiss = onDismiss
        self.onSuccess = onSuccess
    }

    var body: some View {
        NavigationStack(path: $path) {
            CreatePostOverviewView(
                onStart: { path.append(.step1Intro) },
                onDismiss: onDismiss
            )
            .navigationDestination(for: CreatePostRoute.self) { route in
                destinationView(for: route)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: CreatePostRoute) -> some View {
        switch route {
        case .step1Intro:
            CreatePostStep1IntroView(
                onBack: { path.removeLast() },
                onNext:  { path.append(.propertyDetails) }
            )

        case .propertyDetails:
            CreatePostPropertyDetailsView(
                viewModel: viewModel,
                currentStep: 2,
                totalSteps: 5,
                onBack: { path.removeLast() },
                onNext:  { path.append(.amenities) }
            )

        case .amenities:
            CreatePostAmenitiesView(
                viewModel: viewModel,
                currentStep: 3,
                totalSteps: 5,
                onBack: { path.removeLast() },
                onNext:  { path.append(.location) }
            )

        case .location:
            CreatePostLocationView(
                viewModel: viewModel,
                currentStep: 4,
                totalSteps: 5,
                onBack: { path.removeLast() },
                onNext: submitPost
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
