//
//  UserModel.swift
//  FoodOrderingApp
//
//  Created by Team on 29.05.2026.
//

import Foundation

// MARK: - User Model
struct UserModel: Identifiable, Codable, Equatable {
    // MARK: - Properties
    let id: UUID
    let name: String
    let email: String
    let phone: String?
    let createdAt: Date
    
    // MARK: - Initialization
    init(id: UUID = UUID(), name: String, email: String, phone: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.createdAt = createdAt
    }
    
    // MARK: - Equatable
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        lhs.id == rhs.id
    }
}
