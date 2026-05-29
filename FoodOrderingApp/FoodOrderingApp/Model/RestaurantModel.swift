//
//  RestaurantModel.swift
//  FoodOrderingApp
//

import Foundation
import CoreLocation

struct RestaurantModel: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let imageURL: String?
    let address: String
    let latitude: Double
    let longitude: Double
    let rating: Double
    let cuisineType: String
    let phone: String?
    let workingHours: String?
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var workingHoursText: String {
        if let hours = workingHours {
            return hours
        }
        return "11:00 - 23:00"
    }
    
    init(id: UUID = UUID(), name: String, imageURL: String? = nil, address: String,
         latitude: Double, longitude: Double, rating: Double = 4.0,
         cuisineType: String = "Белорусская", phone: String? = nil, workingHours: String? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.cuisineType = cuisineType
        self.phone = phone
        self.workingHours = workingHours
    }
}
