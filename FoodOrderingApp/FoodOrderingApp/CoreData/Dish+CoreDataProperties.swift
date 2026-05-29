//
//  Dish+CoreDataProperties.swift
//  FoodOrderingApp
//

import Foundation
import CoreData

extension Dish {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dish> {
        return NSFetchRequest<Dish>(entityName: "Dish")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var nameKey: String?
    @NSManaged public var price: Double
    @NSManaged public var category: String?
    @NSManaged public var categoryKey: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var dishDescription: String?
    @NSManaged public var descKey: String?
    @NSManaged public var isAvailable: Bool
    @NSManaged public var restaurant: Restaurant?
    @NSManaged public var orderItems: NSSet?
}

// MARK: Generated accessors for orderItems
extension Dish {

    @objc(addOrderItemsObject:)
    @NSManaged public func addToOrderItems(_ value: OrderItem)

    @objc(removeOrderItemsObject:)
    @NSManaged public func removeFromOrderItems(_ value: OrderItem)

    @objc(addOrderItems:)
    @NSManaged public func addToOrderItems(_ values: NSSet)

    @objc(removeOrderItems:)
    @NSManaged public func removeFromOrderItems(_ values: NSSet)
}
