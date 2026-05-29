//
//  Restaurant+CoreDataProperties.swift
//  FoodOrderingApp
//

import Foundation
import CoreData

extension Restaurant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Restaurant> {
        return NSFetchRequest<Restaurant>(entityName: "Restaurant")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var nameKey: String?
    @NSManaged public var address: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var rating: Double
    @NSManaged public var cuisineType: String?
    @NSManaged public var cuisineKey: String?
    @NSManaged public var phone: String?
    @NSManaged public var workingHours: String?
    @NSManaged public var dishes: NSSet?
    @NSManaged public var orders: NSSet?
}

// MARK: Generated accessors for dishes
extension Restaurant {

    @objc(addDishesObject:)
    @NSManaged public func addToDishes(_ value: Dish)

    @objc(removeDishesObject:)
    @NSManaged public func removeFromDishes(_ value: Dish)

    @objc(addDishes:)
    @NSManaged public func addToDishes(_ values: NSSet)

    @objc(removeDishes:)
    @NSManaged public func removeFromDishes(_ values: NSSet)
}

// MARK: Generated accessors for orders
extension Restaurant {

    @objc(addOrdersObject:)
    @NSManaged public func addToOrders(_ value: Order)

    @objc(removeOrdersObject:)
    @NSManaged public func removeFromOrders(_ value: Order)

    @objc(addOrders:)
    @NSManaged public func addToOrders(_ values: NSSet)

    @objc(removeOrders:)
    @NSManaged public func removeFromOrders(_ values: NSSet)
}
