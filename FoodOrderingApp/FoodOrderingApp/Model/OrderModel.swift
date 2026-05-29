//
//  OrderModel.swift
//  FoodOrderingApp
//
//  Created by Team on 29.05.2026.
//

import Foundation

// MARK: - Order Status
enum OrderStatus: String, CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case preparing = "preparing"
    case delivering = "delivering"
    case delivered = "delivered"
    case cancelled = "cancelled"
    
    var localizedString: String {
        switch self {
        case .pending: return "Ожидает подтверждения"
        case .confirmed: return "Подтверждён"
        case .preparing: return "Готовится"
        case .delivering: return "Доставляется"
        case .delivered: return "Доставлен"
        case .cancelled: return "Отменён"
        }
    }
}

// MARK: - Order Model
struct OrderModel: Identifiable, Codable {
    // MARK: - Properties
    let id: UUID
    let userId: UUID
    let restaurantId: UUID
    let address: String
    let comment: String?
    let paymentMethod: String
    let totalPrice: Double
    let status: String
    let createdAt: Date
    let isPickup: Bool
    
    // MARK: - Computed Properties
    var orderStatus: OrderStatus {
        OrderStatus(rawValue: status) ?? .pending
    }
    
    // MARK: - Initialization
    init(id: UUID = UUID(), userId: UUID, restaurantId: UUID, address: String,
         comment: String? = nil, paymentMethod: String, totalPrice: Double,
         status: String = OrderStatus.pending.rawValue, createdAt: Date = Date(),
         isPickup: Bool = false) {
        self.id = id
        self.userId = userId
        self.restaurantId = restaurantId
        self.address = address
        self.comment = comment
        self.paymentMethod = paymentMethod
        self.totalPrice = totalPrice
        self.status = status
        self.createdAt = createdAt
        self.isPickup = isPickup
    }
}
