//
//  KeychainManager.swift
//  FoodOrderingApp
//
//  Created by Golovkova Tanya on 29.05.2026.
//

//
//  KeychainManager.swift
//  FoodOrderingApp
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    // Сохранить данные
    func save(key: String, data: String) -> Bool {
        guard let dataToSave = data.data(using: .utf8) else { return false }
        
        // Удаляем старые данные
        delete(key: key)
        
        // Создаем запрос для сохранения
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: dataToSave,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // Получить данные
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let result = String(data: data, encoding: .utf8) {
            return result
        }
        return nil
    }
    
    // Удалить данные
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
