//
//  MenuViewModel.swift
//  FoodOrderingApp
//

import Foundation
import CoreData
import Combine

final class MenuViewModel: ObservableObject {
    @Published var dishes: [DishModel] = []
    @Published var categories: [String] = [NSLocalizedString("restaurants_all", comment: "")]
    @Published var isLoading = false
    
    private var context: NSManagedObjectContext {
        PersistenceController.shared.context
    }
    
    func loadDishes(for restaurantId: UUID) {
        isLoading = true
        
        let req: NSFetchRequest<Dish> = Dish.fetchRequest()
        req.predicate = NSPredicate(format: "restaurant.id == %@", restaurantId as CVarArg)
        
        guard let results = try? context.fetch(req) else {
            isLoading = false
            return
        }
        
        dishes = results.compactMap { dish in
            guard let id = dish.id,
                  let name = dish.name else { return nil }
            
            let category = dish.value(forKey: "category") as? String ?? NSLocalizedString("category_main_dishes", comment: "")
            let description = dish.value(forKey: "dishDescription") as? String
            let isAvailable = dish.value(forKey: "isAvailable") as? Bool ?? true
            
            return DishModel(
                id: id,
                restaurantId: restaurantId,
                name: name,
                price: dish.price,
                imageURL: dish.imageURL,
                category: category,
                description: description,
                isAvailable: isAvailable
            )
        }
        
        let uniqueCategories = Set(dishes.map { $0.category })
        categories = [NSLocalizedString("restaurants_all", comment: "")] + uniqueCategories.sorted()
        
        isLoading = false
    }
}
