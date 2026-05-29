//
//  OrdersViewModel.swift
//  FoodOrderingApp
//

import Foundation
import Combine

final class OrdersViewModel: ObservableObject {
    @Published var orders: [OrderModel] = []
    
    func load() {
        if let user = AuthService.shared.currentUser {
            orders = OrderService.shared.getOrders(for: user)
        }
    }
}
