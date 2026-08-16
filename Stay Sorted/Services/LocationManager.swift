import Combine
import CoreLocation
import Foundation
import UIKit

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationDenied = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    private let hasRequestedLocationKey = "hasRequestedLocationPermission"

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    /// Request location permission - only prompts once on first app run
    /// After that, respects the user's iOS system permission choice
    func requestCurrentLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            // Only request if user hasn't been asked before (first time ever)
            let hasRequested = UserDefaults.standard.bool(forKey: hasRequestedLocationKey)
            if !hasRequested {
                manager.requestWhenInUseAuthorization()
                UserDefaults.standard.set(true, forKey: hasRequestedLocationKey)
            }
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission already granted, just get location
            authorizationDenied = false
            manager.requestLocation()
        case .denied, .restricted:
            // User previously denied or permission is restricted
            authorizationDenied = true
        default:
            break
        }
    }
    
    /// Open iOS Settings app to the app's location permission page
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    /// Check current authorization status without requesting
    func checkAuthorizationStatus() {
        authorizationStatus = manager.authorizationStatus
        authorizationDenied = (authorizationStatus == .denied || authorizationStatus == .restricted)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                authorizationDenied = false
                manager.requestLocation()
            case .denied, .restricted:
                authorizationDenied = true
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            userLocation = locations.first?.coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
