//
//  LocationManager.swift
//  GPS Speed
//
//  Thin wrapper around CLLocationManager that publishes everything the UI
//  needs: current speed, trip max/average, total distance, GPS accuracy and
//  authorization status. Nothing is persisted — the trip resets each launch.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()

    /// Speeds below this (~1.8 km/h) are treated as "stopped" so GPS jitter
    /// doesn't inflate distance or drag the moving average around.
    private let movingThreshold: CLLocationSpeed = 0.5

    // MARK: Published state

    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    /// Current speed in m/s. 0 when stopped or when the fix has no valid speed.
    @Published private(set) var speed: CLLocationSpeed = 0
    @Published private(set) var maxSpeed: CLLocationSpeed = 0
    @Published private(set) var totalDistance: CLLocationDistance = 0
    /// Horizontal accuracy of the latest fix in meters; negative means invalid.
    @Published private(set) var horizontalAccuracy: CLLocationAccuracy = -1

    private var lastLocation: CLLocation?
    private var movingTime: TimeInterval = 0

    /// Moving average over the trip, in m/s.
    var averageSpeed: CLLocationSpeed {
        movingTime > 0 ? totalDistance / movingTime : 0
    }

    var signalQuality: GPSSignalQuality {
        GPSSignalQuality(accuracy: horizontalAccuracy)
    }

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = kCLDistanceFilterNone
        manager.activityType = .otherNavigation
        manager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: Control

    func requestPermissionAndStart() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break // denied/restricted — UI prompts the user to open Settings.
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    /// Reset trip stats (max, average, distance) without touching the live fix.
    func resetTrip() {
        maxSpeed = 0
        totalDistance = 0
        movingTime = 0
        lastLocation = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        horizontalAccuracy = location.horizontalAccuracy

        // Ignore fixes with no usable horizontal accuracy.
        guard location.horizontalAccuracy >= 0 else {
            speed = 0
            lastLocation = location
            return
        }

        // Prefer the fix's reported speed; negative means it's unavailable.
        let reportedSpeed = location.speed >= 0 ? location.speed : 0
        speed = reportedSpeed
        maxSpeed = max(maxSpeed, reportedSpeed)

        // Only accumulate distance/time while actually moving.
        if let last = lastLocation, reportedSpeed >= movingThreshold {
            let dt = location.timestamp.timeIntervalSince(last.timestamp)
            if dt > 0 {
                totalDistance += location.distance(from: last)
                movingTime += dt
            }
        }

        lastLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // A transient failure (e.g. no fix yet) just means no fresh data;
        // keep the last known values rather than zeroing them out.
    }
}
