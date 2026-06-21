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
    // Seeker flow (find a stay + flatmate)
    case seekerLocation
    case seekerBudget
    case seekerProperty
    case seekerPreview
}

// MARK: - Flow Container

struct CreatePostFlowView: View {
    @StateObject private var viewModel: CreatePostViewModel
    @State private var path: [CreatePostRoute] = []

    private let offerFormStepCount = 7
    private let seekerFormStepCount = 4

    private var isSeekerFlow: Bool { !viewModel.draft.postType }

    private let postService: PostServiceProtocol
    private let onDismiss: () -> Void
    private let onSuccess: () -> Void

    init(
        postService: PostServiceProtocol = PostService(),
        existingPost: Post? = nil,
        onDismiss: @escaping () -> Void,
        onSuccess: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: CreatePostViewModel(existingPost: existingPost))
        self.postService = postService
        self.onDismiss = onDismiss
        self.onSuccess = onSuccess
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if viewModel.editingPostId != nil {
                    Color.clear
                        .onAppear {
                            if path.isEmpty {
                                path.append(.overview)
                            }
                        }
                } else {
                    CreatePostTypeSelectionView(
                        onSelect: selectPostType,
                        onDismiss: onDismiss
                    )
                }
            }
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
        if isSeekerFlow {
            seekerDestination(for: route)
        } else {
            offerDestination(for: route)
        }
    }

    // MARK: - Seeker Flow (Find a Stay + Flatmate)

    @ViewBuilder
    private func seekerDestination(for route: CreatePostRoute) -> some View {
        switch route {
        case .overview:
            CreatePostOverviewView(
                isSeekerFlow: true,
                onStart: { path.append(.step1Intro) },
                onDismiss: { path.removeLast() }
            )

        case .step1Intro:
            CreatePostStepIntroView(
                stepIndex: 0,
                totalSteps: 3,
                stepLabel: "Step 1",
                title: "Location Preference",
                subtitle: "Tell us which city and areas you'd prefer to stay in.",
                systemImage: "mappin.and.ellipse",
                tint: Color(red: 0.20, green: 0.53, blue: 0.96),
                bgColor: Color(red: 0.86, green: 0.92, blue: 0.99),
                onBack: { path.removeLast() },
                onNext: { path.append(.seekerLocation) }
            )

        case .seekerLocation:
            CreatePostSeekerLocationView(
                viewModel: viewModel,
                currentStep: 1,
                totalSteps: seekerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.step2Intro) }
            )

        case .step2Intro:
            CreatePostStepIntroView(
                stepIndex: 1,
                totalSteps: 3,
                stepLabel: "Step 2",
                title: "Budget & Duration",
                subtitle: "Share your monthly budget, move-in timing, and preferred property type.",
                systemImage: "calendar.badge.clock",
                tint: Color(red: 0.91, green: 0.68, blue: 0.22),
                bgColor: Color(red: 0.96, green: 0.92, blue: 0.84),
                onBack: { path.removeLast() },
                onNext: { path.append(.seekerBudget) }
            )

        case .seekerBudget:
            CreatePostSeekerBudgetView(
                viewModel: viewModel,
                currentStep: 2,
                totalSteps: seekerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.seekerProperty) }
            )

        case .seekerProperty:
            CreatePostSeekerPropertyView(
                viewModel: viewModel,
                currentStep: 3,
                totalSteps: seekerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.step3Intro) }
            )

        case .step3Intro:
            CreatePostStepIntroView(
                stepIndex: 2,
                totalSteps: 3,
                stepLabel: "Step 3",
                title: "Roommate Preferences",
                subtitle: "Mention your preferences for gender, profession, and lifestyle habits.",
                systemImage: "person.2.fill",
                tint: Color(red: 0.82, green: 0.38, blue: 0.22),
                bgColor: Color(red: 0.99, green: 0.90, blue: 0.86),
                onBack: { path.removeLast() },
                onNext: { path.append(.preferences) }
            )

        case .preferences:
            CreatePostPreferencesView(
                viewModel: viewModel,
                currentStep: 4,
                totalSteps: seekerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.seekerPreview) }
            )

        case .seekerPreview:
            CreatePostSeekerPreviewView(
                viewModel: viewModel,
                onBack: { path.removeLast() },
                onPublish: submitPost
            )

        default:
            EmptyView()
        }
    }

    // MARK: - Offer Flow (Have a Stay to Offer)

    @ViewBuilder
    private func offerDestination(for route: CreatePostRoute) -> some View {
        switch route {
        case .overview:
            CreatePostOverviewView(
                isSeekerFlow: false,
                onStart: { path.append(.step1Intro) },
                onDismiss: { path.removeLast() }
            )

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
                totalSteps: offerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.amenities) }
            )

        case .amenities:
            CreatePostAmenitiesView(
                viewModel: viewModel,
                currentStep: 2,
                totalSteps: offerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.location) }
            )

        case .location:
            CreatePostLocationView(
                viewModel: viewModel,
                currentStep: 3,
                totalSteps: offerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.step2Intro) }
            )

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
                totalSteps: offerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.preferences) }
            )

        case .preferences:
            CreatePostPreferencesView(
                viewModel: viewModel,
                currentStep: 5,
                totalSteps: offerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.step3Intro) }
            )

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
                totalSteps: offerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.photos) }
            )

        case .photos:
            CreatePostPhotosView(
                viewModel: viewModel,
                currentStep: 7,
                totalSteps: offerFormStepCount,
                onBack: { path.removeLast() },
                onNext: { path.append(.preview) }
            )

        case .preview:
            CreatePostPreviewView(
                viewModel: viewModel,
                onBack: { path.removeLast() },
                onPublish: submitPost
            )

        default:
            EmptyView()
        }
    }

    private func submitPost() {
        Task {
            let ok = await viewModel.submit(postService: postService)
            if ok { onSuccess() }
        }
    }
}
