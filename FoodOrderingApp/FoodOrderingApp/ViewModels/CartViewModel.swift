//
//  CartViewModel.swift
//  FoodOrderingApp
//

import Foundation
import Combine

final class CartViewModel: ObservableObject {
    @Published var items: [DishModel: Int] = [:]
    @Published var totalPrice: Double = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    func add(_ dish: DishModel) {
        items[dish, default: 0] += 1
    }
    
    func add(_ dish: DishModel, quantity: Int) {
        items[dish, default: 0] += quantity
    }
    
    func remove(_ dish: DishModel) {
        items.removeValue(forKey: dish)
    }
    
    func decrease(_ dish: DishModel) {
        guard let current = items[dish] else { return }
        if current <= 1 {
            items.removeValue(forKey: dish)
        } else {
            items[dish] = current - 1
        }
    }
    
    func clear() {
        items.removeAll()
    }
    
    func itemCount() -> Int {
        items.values.reduce(0, +)
    }
    
    func getOrderItems(orderId: UUID = UUID()) -> [OrderItemModel] {
        items.map { dish, quantity in
            OrderItemModel(
                orderId: orderId,
                dishId: dish.id,
                quantity: quantity,
                priceAtOrder: dish.price
            )
        }
    }
    
    private func setupBindings() {
        $items
            .sink { [weak self] items in
                self?.totalPrice = items.reduce(0) { $0 + $1.key.price * Double($1.value) }
            }
            .store(in: &cancellables)
    }
}
