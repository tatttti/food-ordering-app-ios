//
//  AuthService.swift
//  FoodOrderingApp
//

import Foundation
import CoreData
import Combine

final class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: UserModel?
    
    private var context: NSManagedObjectContext {
        PersistenceController.shared.context
    }
    
    private let userDefaultsKey = "currentUserId"
    
    private init() {
        loadCurrentUser()
    }
    
    func register(name: String, email: String, phone: String?, password: String) -> UserModel? {
        // Проверяем существует ли пользователь
        if let existingUser = fetchUser(byEmail: email) {
            print("📧 User already exists, logging in")
            let userId = existingUser.value(forKey: "id") as? UUID ?? UUID()
            let userName = existingUser.value(forKey: "name") as? String ?? name
            let userEmail = existingUser.value(forKey: "email") as? String ?? email
            let userPhone = existingUser.value(forKey: "phone") as? String
            let userCreatedAt = existingUser.value(forKey: "createdAt") as? Date ?? Date()
            
            let userModel = UserModel(
                id: userId,
                name: userName,
                email: userEmail,
                phone: userPhone,
                createdAt: userCreatedAt
            )
            currentUser = userModel
            saveCurrentUserId(userId)
            return userModel
        }
        
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            print("❌ Empty fields")
            return nil
        }
        
        guard password.count >= 6 else {
            print("❌ Password too short")
            return nil
        }
        
        // Создаем нового пользователя
        let user = User(context: context)
        let newId = UUID()
        user.setValue(newId, forKey: "id")
        user.setValue(name, forKey: "name")
        user.setValue(email, forKey: "email")
        user.setValue(phone, forKey: "phone")
        user.setValue(password, forKey: "passwordHash")
        user.setValue(Date(), forKey: "createdAt")
        
        PersistenceController.shared.save()
        
        // Проверяем что пользователь сохранился
        let verification = fetchUser(by: newId)
        if verification == nil {
            print("❌ CRITICAL: User was not saved to Core Data!")
            return nil
        }
        
        let userModel = UserModel(
            id: newId,
            name: name,
            email: email,
            phone: phone,
            createdAt: Date()
        )
        
        currentUser = userModel
        saveCurrentUserId(newId)
        
        print("✅ User registered and saved to Core Data with id: \(newId)")
        return userModel
    }
    
    func login(email: String, password: String) -> UserModel? {
        guard let user = fetchUser(byEmail: email) else {
            print("❌ User not found: \(email)")
            return nil
        }
        
        let storedPassword = user.value(forKey: "passwordHash") as? String ?? ""
        
        guard storedPassword == password else {
            print("❌ Wrong password")
            return nil
        }
        
        let userId = user.value(forKey: "id") as? UUID ?? UUID()
        let userName = user.value(forKey: "name") as? String ?? ""
        let userEmail = user.value(forKey: "email") as? String ?? email
        let userPhone = user.value(forKey: "phone") as? String
        let userCreatedAt = user.value(forKey: "createdAt") as? Date ?? Date()
        
        let userModel = UserModel(
            id: userId,
            name: userName,
            email: userEmail,
            phone: userPhone,
            createdAt: userCreatedAt
        )
        
        currentUser = userModel
        saveCurrentUserId(userId)
        
        print("✅ User logged in: \(email), id: \(userId)")
        return userModel
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        currentUser = nil
        print("✅ User logged out")
    }
    
    private func loadCurrentUser() {
        guard let userIdString = UserDefaults.standard.string(forKey: userDefaultsKey),
              let userId = UUID(uuidString: userIdString) else {
            print("⚠️ No saved user ID")
            return
        }
        
        // Ищем пользователя в Core Data
        if let user = fetchUser(by: userId) {
            let userName = user.value(forKey: "name") as? String ?? ""
            let userEmail = user.value(forKey: "email") as? String ?? ""
            let userPhone = user.value(forKey: "phone") as? String
            let userCreatedAt = user.value(forKey: "createdAt") as? Date ?? Date()
            
            currentUser = UserModel(
                id: userId,
                name: userName,
                email: userEmail,
                phone: userPhone,
                createdAt: userCreatedAt
            )
            print("✅ User loaded from Core Data: \(userEmail)")
        } else {
            // Пользователь есть в UserDefaults, но нет в Core Data
            print("⚠️ User ID found in UserDefaults but not in Core Data")
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }
    
    private func saveCurrentUserId(_ id: UUID) {
        UserDefaults.standard.set(id.uuidString, forKey: userDefaultsKey)
    }
    
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
}
