import CoreLocation
import MapKit
import SwiftUI

struct CreatePostLocationView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var mapPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 23.022505, longitude: 72.571365),
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        )
    )

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Where's your\nStay located?")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    PlacesSearchTextField(
                        selectedText: $searchText,
                        mode: .address,
                        placeholder: "Search location",
                        fieldStyle: .outlined
                    ) { details in
                        viewModel.applyPlaceDetails(details)
                        searchText = details.landmark.isEmpty ? details.area : details.landmark
                        updateMapPosition()
                    }
                    .zIndex(40)

                    mapView
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppTheme.infoCardBorder, lineWidth: 1)
                        )
                        .zIndex(0)

                    VStack(alignment: .leading, spacing: 12) {
                        PlacesSearchTextField(
                            selectedText: $viewModel.draft.landmark,
                            mode: .landmarks(city: viewModel.draft.city),
                            placeholder: "Landmark",
                            fieldStyle: .outlined
                        ) { details in
                            viewModel.applyPlaceDetails(details)
                            updateMapPosition()
                        }
                        .zIndex(30)

                        OutlinedInputField(label: "Area", text: $viewModel.draft.area)

                        PlacesSearchTextField(
                            selectedText: $viewModel.draft.city,
                            mode: .cities,
                            placeholder: "City",
                            fieldStyle: .outlined
                        ) { details in
                            viewModel.applyPlaceDetails(
                                PlaceDetails(
                                    coordinate: details.coordinate,
                                    landmark: viewModel.draft.landmark,
                                    area: viewModel.draft.area,
                                    city: IndianLocationsService.normalizedCityName(
                                        details.city.isEmpty ? details.formattedAddress : details.city
                                    ),
                                    state: details.state,
                                    pincode: details.pincode,
                                    formattedAddress: details.formattedAddress
                                )
                            )
                            updateMapPosition()
                        }
                        .zIndex(20)

                        OutlinedInputField(label: "State", text: $viewModel.draft.state)

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
            .scrollClipDisabled()
            .scrollIndicators(.hidden)

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
        .onAppear {
            searchText = viewModel.draft.landmark
            if IndianLocationsService.isValidCoordinate(viewModel.mapRegion.center),
               viewModel.draft.city.isEmpty {
                updateMapPosition()
            } else if let coordinate = GeocodingService.coordinate(forCity: viewModel.draft.city) {
                viewModel.updateMapCenter(coordinate)
                updateMapPosition()
            }
        }
        .onChange(of: viewModel.mapRegion.center.latitude) { _, _ in
            updateMapPosition()
        }
        .onChange(of: locationManager.userLocation?.latitude) { _, _ in
            guard let coordinate = locationManager.userLocation else { return }
            viewModel.updateMapCenter(coordinate)
            updateMapPosition()
            reverseGeocode(coordinate)
        }
    }

    @ViewBuilder
    private var mapView: some View {
        ZStack(alignment: .topTrailing) {
            if #available(iOS 17.0, *) {
                Map(position: $mapPosition) {
                    Marker("Stay", coordinate: viewModel.mapRegion.center)
                }
                .mapStyle(.standard(elevation: .flat))
            } else {
                Map(coordinateRegion: $viewModel.mapRegion, annotationItems: [MapPin(coordinate: viewModel.mapRegion.center)]) { pin in
                    MapMarker(coordinate: pin.coordinate, tint: .red)
                }
            }

            Button {
                locationManager.requestCurrentLocation()
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
            }
            .padding(10)
        }
    }

    private func updateMapPosition() {
        if #available(iOS 17.0, *) {
            withAnimation(.easeInOut(duration: 0.25)) {
                mapPosition = .region(viewModel.mapRegion)
            }
        }
    }

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { placemarks, _ in
            guard let placemark = placemarks?.first else { return }
            Task { @MainActor in
                if viewModel.draft.landmark.isEmpty {
                    viewModel.draft.landmark = placemark.name ?? placemark.thoroughfare ?? ""
                }
                if viewModel.draft.area.isEmpty {
                    viewModel.draft.area = placemark.subLocality ?? placemark.locality ?? ""
                }
                if viewModel.draft.city.isEmpty {
                    viewModel.draft.city = placemark.locality ?? ""
                }
                if viewModel.draft.state.isEmpty {
                    viewModel.draft.state = placemark.administrativeArea ?? ""
                }
                if viewModel.draft.pincode.isEmpty {
                    viewModel.draft.pincode = placemark.postalCode ?? ""
                }
            }
        }
    }
}

private struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
