//
//  PersistenceController.swift
//  FoodOrderingApp
//

import CoreData
import Combine

final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "FoodOrderingApp")
        
        // Включаем автоматическую миграцию (сохраняет данные)
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("❌ Core Data error: \(error)")
                // НЕ удаляем базу данных, просто логируем ошибку
            }
            
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }
    
    func save() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            print("✅ Saved")
        } catch {
            print("❌ Save error: \(error)")
        }
    }
}
