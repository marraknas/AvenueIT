//
//  LocationManager.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 24/4/26.
//

import Foundation
import CoreLocation
import Observation

// AI Usage: used AI to help with the CLLocationManagerDelegate pattern
// and the nonisolated/MainActor threading, as these are beyond course scope
// and I needed help bridging threading code

@MainActor
@Observable
final class LocationManager: NSObject {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    var cityName = ""
    var stateCode = ""
    var coordinate: CLLocationCoordinate2D?
    var isResolving = false
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var overrideCoordinate: CLLocationCoordinate2D?
    var overrideCityName = ""

    var effectiveLatitude: Double? {
        (overrideCoordinate ?? coordinate)?.latitude
    }

    var displayName: String {
        if !overrideCityName.isEmpty { return overrideCityName }
        if cityName.isEmpty { return "Location unavailable" }
        return stateCode.isEmpty ? cityName : "\(cityName), \(stateCode)"
    }

    var effectiveCoordinate: CLLocationCoordinate2D? {
        overrideCoordinate ?? coordinate
    }

    override init() {
        super.init()
        manager.delegate = self
        authorizationStatus = manager.authorizationStatus
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isResolving = true
            manager.requestLocation()
        default:
            break
        }
    }

    func geocodeZipCode(_ zip: String) async {
        do {
            let placemarks = try await geocoder.geocodeAddressString("\(zip), US")
            if let placemark = placemarks.first, let location = placemark.location {
                overrideCoordinate = location.coordinate
                let city = placemark.locality ?? placemark.administrativeArea ?? zip
                let state = placemark.administrativeArea ?? ""
                overrideCityName = state.isEmpty ? city : "\(city), \(state)"
            }
        } catch {
            print("ZIP geocoding failed: \(error.localizedDescription)")
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                isResolving = true
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in
            coordinate = location.coordinate
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    cityName = placemark.locality ?? ""
                    stateCode = placemark.administrativeArea ?? ""
                }
            } catch {
                print("Geocoder error: \(error.localizedDescription)")
            }
            isResolving = false
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("Location error: \(error.localizedDescription)")
            isResolving = false
        }
    }
}
