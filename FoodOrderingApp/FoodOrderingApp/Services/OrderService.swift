//
//  OrderService.swift
//  FoodOrderingApp
//

import Foundation
import CoreData
import Combine

final class OrderService: ObservableObject {
    static let shared = OrderService()
    
    @Published var currentOrders: [OrderModel] = []
    @Published var orderHistory: [OrderModel] = []
    
    private var context: NSManagedObjectContext {
        PersistenceController.shared.context
    }
    
    private init() {}
    
    // MARK: - Create Order
    func createOrder(
        user: UserModel,
        restaurant: RestaurantModel,
        items: [(dish: DishModel, quantity: Int)],
        address: String,
        paymentMethod: String,
        comment: String?,
        isPickup: Bool
    ) -> OrderModel? {
        
        print("========== START CREATE ORDER ==========")
        print("Looking for user with id: \(user.id)")
        print("User email: \(user.email)")
        
        // 1. Находим пользователя по ID
        var userCD = fetchUser(by: user.id)
        
        // 2. Если не нашли - пробуем найти по email
        if userCD == nil {
            print("⚠️ User not found by ID, trying by email: \(user.email)")
            userCD = fetchUser(byEmail: user.email)
        }
        
        // 3. Если всё равно не нашли - создаем пользователя заново
        if userCD == nil {
            print("⚠️ User not found in Core Data, recreating...")
            userCD = createUserInCoreData(user: user)
        }
        
        guard let finalUser = userCD else {
            print("❌ ERROR: Cannot find or create user")
            return nil
        }
        let userId = finalUser.value(forKey: "id") as? UUID
        print("✅ User found/created with id: \(userId?.uuidString ?? "unknown")")
        
        // 4. Находим ресторан
        guard let restaurantCD = fetchRestaurant(by: restaurant.id) else {
            print("❌ ERROR: Restaurant not found with id: \(restaurant.id)")
            return nil
        }
        print("✅ Restaurant found: \(restaurantCD.name ?? "unknown")")
        
        // 5. Проверяем корзину
        guard !items.isEmpty else {
            print("❌ ERROR: Cart is empty")
            return nil
        }
        print("✅ Cart has \(items.count) items")
        
        // 6. Проверяем адрес
        if !isPickup && address.trimmingCharacters(in: .whitespaces).isEmpty {
            print("❌ ERROR: Address required for delivery")
            return nil
        }
        print("✅ Address valid: \(isPickup ? "Pickup" : address)")
        
        // 7. Создаем заказ
        let order = Order(context: context)
        order.id = UUID()
        order.address = isPickup ? restaurant.address : address
        order.comment = comment
        order.paymentMethod = paymentMethod
        order.createdAt = Date()
        order.status = "pending"
        order.isPickup = isPickup
        order.user = finalUser
        order.restaurant = restaurantCD
        print("✅ Order created with id: \(order.id?.uuidString.prefix(8) ?? "nil")")
        
        // 8. Добавляем блюда
        var totalPrice: Double = 0
        
        for item in items {
            // Находим блюдо в Core Data
            guard let dishCD = fetchDish(by: item.dish.id) else {
                print("⚠️ WARNING: Dish not found: \(item.dish.name)")
                continue
            }
            
            let orderItem = OrderItem(context: context)
            orderItem.id = UUID()
            orderItem.quantity = Int16(item.quantity)
            orderItem.priceAtOrder = dishCD.price
            orderItem.dish = dishCD
            orderItem.order = order
            
            let itemTotal = dishCD.price * Double(item.quantity)
            totalPrice += itemTotal
            print("   Added: \(dishCD.name ?? "dish") x\(item.quantity) = \(itemTotal) ₽")
        }
        
        order.totalPrice = totalPrice
        print("💰 Total price: \(totalPrice) ₽")
        
        // 9. Сохраняем
        do {
            try context.save()
            print("✅ Order saved to Core Data successfully!")
        } catch {
            print("❌ ERROR saving order: \(error)")
            print("Error details: \(error.localizedDescription)")
            return nil
        }
        
        // 10. Возвращаем модель
        let orderModel = OrderModel(
            id: order.id!,
            userId: user.id,
            restaurantId: restaurant.id,
            address: order.address!,
            comment: order.comment,
            paymentMethod: order.paymentMethod!,
            totalPrice: order.totalPrice,
            status: order.status!,
            createdAt: order.createdAt!,
            isPickup: order.isPickup
        )
        
        print("========== ORDER CREATED SUCCESSFULLY ==========")
        return orderModel
    }
    
    // MARK: - Get Orders
    func getOrders(for user: UserModel) -> [OrderModel] {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        guard let results = try? context.fetch(request) else {
            print("❌ Failed to fetch orders")
            return []
        }
        
        return results.compactMap { order in
            guard let id = order.id,
                  let address = order.address,
                  let paymentMethod = order.paymentMethod,
                  let status = order.status,
                  let createdAt = order.createdAt,
                  let restaurant = order.restaurant,
                  let restaurantId = restaurant.id,
                  let user = order.user,
                  let userId = user.id else { return nil }
            
            return OrderModel(
                id: id,
                userId: userId,
                restaurantId: restaurantId,
                address: address,
                comment: order.comment,
                paymentMethod: paymentMethod,
                totalPrice: order.totalPrice,
                status: status,
                createdAt: createdAt,
                isPickup: order.isPickup
            )
        }
    }
    
    func loadOrders(for user: UserModel) {
        let allOrders = getOrders(for: user)
        
        DispatchQueue.main.async {
            self.currentOrders = allOrders.filter { order in
                let status = order.orderStatus
                return status == .pending || status == .confirmed || status == .preparing || status == .delivering
            }
            self.orderHistory = allOrders.filter { order in
                let status = order.orderStatus
                return status == .delivered || status == .cancelled
            }
        }
    }
    
    // MARK: - Update Order
    func updateOrderStatus(orderId: UUID, newStatus: String) -> Bool {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", orderId as CVarArg)
        
        guard let order = try? context.fetch(request).first else {
            print("❌ Order not found for status update")
            return false
        }
        
        order.status = newStatus
        
        do {
            try context.save()
            print("✅ Order status updated to: \(newStatus)")
            
            if let user = AuthService.shared.currentUser {
                loadOrders(for: user)
            }
            return true
        } catch {
            print("❌ Failed to update status: \(error)")
            return false
        }
    }
    
    func cancelOrder(orderId: UUID) -> Bool {
        return updateOrderStatus(orderId: orderId, newStatus: "cancelled")
    }
    
    // MARK: - Private Helpers
    
    private func fetchUser(by id: UUID) -> User? {
        let req: NSFetchRequest<User> = User.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(req).first
    }
    
    private func fetchUser(byEmail email: String) -> User? {
        let req: NSFetchRequest<User> = User.fetchRequest()
        req.predicate = NSPredicate(format: "email == %@", email)
        return try? context.fetch(req).first
    }
    
    private func createUserInCoreData(user: UserModel) -> User? {
        let newUser = User(context: context)
        newUser.setValue(user.id, forKey: "id")
        newUser.setValue(user.name, forKey: "name")
        newUser.setValue(user.email, forKey: "email")
        newUser.setValue(user.phone, forKey: "phone")
        newUser.setValue("default", forKey: "passwordHash")
        newUser.setValue(Date(), forKey: "createdAt")
        
        do {
            try context.save()
            print("✅ User recreated in Core Data: \(user.email)")
            return newUser
        } catch {
            print("❌ Failed to recreate user: \(error)")
            return nil
        }
    }
    
    private func fetchRestaurant(by id: UUID) -> Restaurant? {
        let req: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(req).first
    }
    
    private func fetchDish(by id: UUID) -> Dish? {
        let req: NSFetchRequest<Dish> = Dish.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(req).first
    }
}
