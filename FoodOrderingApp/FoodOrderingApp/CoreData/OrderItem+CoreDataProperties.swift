//
//  OrderItem+CoreDataProperties.swift
//  FoodOrderingApp
//
//  Created by Golovkova Tanya on 29.05.2026.
//

//
//  OrderItem+CoreDataProperties.swift
//  FoodOrderingApp
//

import Foundation
import CoreData

extension OrderItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderItem> {
        return NSFetchRequest<OrderItem>(entityName: "OrderItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var quantity: Int16
    @NSManaged public var priceAtOrder: Double
    @NSManaged public var order: Order?
    @NSManaged public var dish: Dish?
}
