//
//  DishModel.swift
//  FoodOrderingApp
//
//  Created by Team on 29.05.2026.
//

import Foundation

// MARK: - Dish Model
struct DishModel: Identifiable, Hashable, Codable {
    // MARK: - Properties
    let id: UUID
    let restaurantId: UUID
    let name: String
    let price: Double
    let imageURL: String?
    let category: String
    let description: String?
    let isAvailable: Bool
    
    // MARK: - Initialization
    init(id: UUID = UUID(), restaurantId: UUID, name: String, price: Double,
         imageURL: String? = nil, category: String = "Основные блюда",
         description: String? = nil, isAvailable: Bool = true) {
        self.id = id
        self.restaurantId = restaurantId
        self.name = name
        self.price = price
        self.imageURL = imageURL
        self.category = category
        self.description = description
        self.isAvailable = isAvailable
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
