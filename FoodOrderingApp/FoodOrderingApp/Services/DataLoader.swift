//
//  DataLoader.swift
//  FoodOrderingApp
//

import Foundation
import CoreData

struct DataLoader {
    
    static func loadDataIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        let count = (try? context.count(for: request)) ?? 0
        if count > 0 {
            print("✅ Data already loaded, skipping...")
            return
        }
        
        guard let url = Bundle.main.url(forResource: "restaurants", withExtension: "json") else {
            print("❌ restaurants.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let restaurantsData = json?["restaurants"] as? [[String: Any]] else {
                print("❌ Invalid JSON structure")
                return
            }
            
            print("📝 Loading \(restaurantsData.count) restaurants from JSON...")
            
            for restData in restaurantsData {
                // Создаем ресторан
                let restaurant = Restaurant(context: context)
                restaurant.setValue(UUID(), forKey: "id")
                restaurant.setValue(restData["nameKey"] as? String ?? "", forKey: "nameKey")
                restaurant.setValue(NSLocalizedString(restData["nameKey"] as? String ?? "", comment: ""), forKey: "name")
                restaurant.setValue(restData["address"] as? String ?? "", forKey: "address")
                restaurant.setValue(restData["latitude"] as? Double ?? 0, forKey: "latitude")
                restaurant.setValue(restData["longitude"] as? Double ?? 0, forKey: "longitude")
                restaurant.setValue(restData["rating"] as? Double ?? 4.0, forKey: "rating")
                restaurant.setValue(restData["cuisineKey"] as? String ?? "cuisine_belarusian", forKey: "cuisineKey")
                restaurant.setValue(NSLocalizedString(restData["cuisineKey"] as? String ?? "cuisine_belarusian", comment: ""), forKey: "cuisineType")
                restaurant.setValue(restData["imageURL"] as? String, forKey: "imageURL")
                restaurant.setValue(restData["phone"] as? String, forKey: "phone")
                restaurant.setValue(restData["workingHours"] as? String, forKey: "workingHours")
                
                // Загружаем блюда
                if let dishesData = restData["dishes"] as? [[String: Any]] {
                    let restaurantName = restData["nameKey"] as? String ?? "unknown"
                    print("   Loading \(dishesData.count) dishes for \(restaurantName)")
                    
                    for dishData in dishesData {
                        let dish = Dish(context: context)
                        dish.setValue(UUID(), forKey: "id")
                        dish.setValue(dishData["nameKey"] as? String ?? "", forKey: "nameKey")
                        dish.setValue(NSLocalizedString(dishData["nameKey"] as? String ?? "", comment: ""), forKey: "name")
                        dish.setValue(dishData["price"] as? Double ?? 0, forKey: "price")
                        dish.setValue(dishData["categoryKey"] as? String ?? "", forKey: "categoryKey")
                        dish.setValue(NSLocalizedString(dishData["categoryKey"] as? String ?? "", comment: ""), forKey: "category")
                        dish.setValue(dishData["descKey"] as? String ?? "", forKey: "descKey")
                        dish.setValue(NSLocalizedString(dishData["descKey"] as? String ?? "", comment: ""), forKey: "dishDescription")
                        dish.setValue(dishData["imageURL"] as? String, forKey: "imageURL")
                        dish.setValue(true, forKey: "isAvailable")
                        dish.setValue(restaurant, forKey: "restaurant")
                    }
                }
            }
            
            try context.save()
            print("✅ Data loaded successfully from JSON with localization support!")
            
            // Выводим статистику
            let restaurantCount = try? context.count(for: Restaurant.fetchRequest())
            let dishCount = try? context.count(for: Dish.fetchRequest())
            print("   📊 Statistics: \(restaurantCount ?? 0) restaurants, \(dishCount ?? 0) dishes")
            
        } catch {
            print("❌ Error loading JSON: \(error)")
            print("   Error details: \(error.localizedDescription)")
        }
    }
}
