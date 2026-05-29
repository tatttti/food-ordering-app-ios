//
//  User+CoreDataProperties.swift
//  FoodOrderingApp
//
//  Created by Golovkova Tanya on 29.05.2026.
//

//
//  User+CoreDataProperties.swift
//  FoodOrderingApp
//

import Foundation
import CoreData

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var passwordHash: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var orders: NSSet?
}

// MARK: Generated accessors for orders
extension User {

    @objc(addOrdersObject:)
    @NSManaged public func addToOrders(_ value: Order)

    @objc(removeOrdersObject:)
    @NSManaged public func removeFromOrders(_ value: Order)

    @objc(addOrders:)
    @NSManaged public func addToOrders(_ values: NSSet)

    @objc(removeOrders:)
    @NSManaged public func removeFromOrders(_ values: NSSet)
}
