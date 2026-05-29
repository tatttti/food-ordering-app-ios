//
//  RestaurantListViewModel.swift
//  FoodOrderingApp
//

import Foundation
import CoreData
import CoreLocation
import Combine

final class RestaurantListViewModel: ObservableObject {
    @Published var restaurants: [RestaurantModel] = []
    @Published var filteredRestaurants: [RestaurantModel] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCuisine: String?
    
    private var context: NSManagedObjectContext {
        PersistenceController.shared.context
    }
    private var cancellables = Set<AnyCancellable>()
    
    let cuisines = [NSLocalizedString("restaurants_all", comment: ""), NSLocalizedString("cuisine_belarusian", comment: "")]
    
    init() {
        setupSearchBinding()
    }
    
    func loadRestaurants() {
        isLoading = true
        
        let req: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        guard let results = try? context.fetch(req) else {
            isLoading = false
            return
        }
        
        restaurants = results.compactMap { restaurant in
            guard let id = restaurant.id,
                  let name = restaurant.name,
                  let address = restaurant.address else { return nil }
            
            let cuisineType = restaurant.value(forKey: "cuisineType") as? String ?? NSLocalizedString("cuisine_belarusian", comment: "")
            let phone = restaurant.value(forKey: "phone") as? String
            let workingHours = restaurant.value(forKey: "workingHours") as? String
            
            return RestaurantModel(
                id: id,
                name: name,
                imageURL: restaurant.imageURL,
                address: address,
                latitude: restaurant.latitude,
                longitude: restaurant.longitude,
                rating: restaurant.rating,
                cuisineType: cuisineType,
                phone: phone,
                workingHours: workingHours
            )
        }
        
        applyFilters()
        isLoading = false
    }
    
    func nearestRestaurant(to location: CLLocation) -> RestaurantModel? {
        return restaurants.min { first, second in
            first.clLocation.distance(from: location) < second.clLocation.distance(from: location)
        }
    }
    
    func getDistanceToRestaurant(_ restaurant: RestaurantModel) -> Double? {
        guard let currentLocation = LocationService.shared.currentLocation else { return nil }
        return restaurant.clLocation.distance(from: currentLocation) / 1000
    }
    
    private func setupSearchBinding() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    private func applyFilters() {
        var filtered = restaurants
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let cuisine = selectedCuisine, cuisine != NSLocalizedString("restaurants_all", comment: "") {
            filtered = filtered.filter { $0.cuisineType == cuisine }
        }
        
        filteredRestaurants = filtered
    }
}
