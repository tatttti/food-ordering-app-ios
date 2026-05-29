//
//  LocationService.swift
//  FoodOrderingApp
//

import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        // Запрашиваем разрешение если нужно
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            // Даем время на ответ
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            self.manager.requestLocation()
            
            // Таймаут на случай ошибки
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if self.locationContinuation != nil {
                    self.locationContinuation?.resume(throwing: LocationError.timeout)
                    self.locationContinuation = nil
                }
            }
        }
    }
    
    enum LocationError: Error {
        case timeout
        case denied
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Доступ к геолокации запрещён"
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.locationContinuation?.resume(returning: location)
            self.locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Ошибка: \(error.localizedDescription)"
            self.locationContinuation?.resume(throwing: error)
            self.locationContinuation = nil
        }
    }
}
