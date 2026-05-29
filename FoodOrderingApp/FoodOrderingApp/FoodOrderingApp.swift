//
//  FoodOrderingApp.swift
//  FoodOrderingApp
//

import SwiftUI
import CoreData

@main
struct FoodOrderingApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    // Загружаем данные из JSON
                    DataLoader.loadDataIfNeeded(context: persistenceController.container.viewContext)
                }
        }
    }
}
