//
//  OrderItemModel.swift
//  FoodOrderingApp
//
//  Created by Team on 29.05.2026.
//

import Foundation

// MARK: - Order Item Model
struct OrderItemModel: Identifiable, Codable {
    // MARK: - Properties
    let id: UUID
    let orderId: UUID
    let dishId: UUID
    let quantity: Int
    let priceAtOrder: Double
    
    // MARK: - Initialization
    init(id: UUID = UUID(), orderId: UUID, dishId: UUID, quantity: Int, priceAtOrder: Double = 0) {
        self.id = id
        self.orderId = orderId
        self.dishId = dishId
        self.quantity = quantity
        self.priceAtOrder = priceAtOrder
    }
}
