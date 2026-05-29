//
//  Order+CoreDataProperties.swift
//  FoodOrderingApp
//
//  Created by Golovkova Tanya on 29.05.2026.
//

//
//  Order+CoreDataProperties.swift
//  FoodOrderingApp
//

import Foundation
import CoreData

extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var address: String?
    @NSManaged public var comment: String?
    @NSManaged public var paymentMethod: String?
    @NSManaged public var totalPrice: Double
    @NSManaged public var status: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isPickup: Bool
    @NSManaged public var user: User?
    @NSManaged public var restaurant: Restaurant?
    @NSManaged public var items: NSSet?
}

// MARK: Generated accessors for items
extension Order {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: OrderItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: OrderItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}
