import MapKit
import SwiftUI

struct CreatePostLocationView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Where's your\nStay located?")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    // Map
                    mapView
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppTheme.infoCardBorder, lineWidth: 1)
                        )

                    // Address fields
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Address")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)

                        OutlinedInputField(label: "Landmark", text: $viewModel.draft.landmark)
                        OutlinedInputField(label: "Area",     text: $viewModel.draft.area)
                        OutlinedInputField(label: "City",     text: $viewModel.draft.city)
                        OutlinedInputField(label: "State",    text: $viewModel.draft.state)
                        OutlinedInputField(
                            label: "Pincode",
                            text: $viewModel.draft.pincode,
                            keyboardType: .numberPad
                        )
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            CreatePostBottomBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                nextLabel: "Next",
                isNextEnabled: viewModel.isLocationValid,
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

    @ViewBuilder
    private var mapView: some View {
        if #available(iOS 17.0, *) {
            Map(position: .constant(
                .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 23.022505, longitude: 72.571365),
                    span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                ))
            ))
            .allowsHitTesting(false)
        } else {
            Map(coordinateRegion: $viewModel.mapRegion)
                .allowsHitTesting(false)
        }
    }
}
