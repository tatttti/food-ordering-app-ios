//
//  FoodOrderingAppTests.swift
//  FoodOrderingAppTests
//

import XCTest
@testable import FoodOrderingApp

final class FoodOrderingAppTests: XCTestCase {
    
    // MARK: - Test 1
    func testAppExists() {
        XCTAssertTrue(true)
    }
    
    // MARK: - Test 2
    func testBundleID() {
        let bundle = Bundle.main.bundleIdentifier
        XCTAssertNotNil(bundle)
    }
    
    // MARK: - Test 3
    func testAuthServiceExists() {
        let auth = AuthService.shared
        XCTAssertNotNil(auth)
    }
    
    // MARK: - Test 4
    func testPersistenceControllerExists() {
        let controller = PersistenceController.shared
        XCTAssertNotNil(controller)
    }
    
    // MARK: - Test 5
    func testCartViewModelExists() {
        let cart = CartViewModel()
        XCTAssertNotNil(cart)
    }
    
    // MARK: - Test 6
    func testAddToCart() {
        let cart = CartViewModel()
        let dish = DishModel(id: UUID(), restaurantId: UUID(), name: "Test", price: 10, imageURL: nil, category: "Test", description: nil, isAvailable: true)
        cart.add(dish)
        XCTAssertEqual(cart.itemCount(), 1)
    }
    
    // MARK: - Test 7
    func testCartTotalPrice() {
        let cart = CartViewModel()
        let dish = DishModel(id: UUID(), restaurantId: UUID(), name: "Test", price: 15, imageURL: nil, category: "Test", description: nil, isAvailable: true)
        cart.add(dish)
        cart.add(dish)
        XCTAssertEqual(cart.totalPrice, 30)
    }
    
    // MARK: - Test 8
    func testClearCart() {
        let cart = CartViewModel()
        let dish = DishModel(id: UUID(), restaurantId: UUID(), name: "Test", price: 10, imageURL: nil, category: "Test", description: nil, isAvailable: true)
        cart.add(dish)
        cart.clear()
        XCTAssertEqual(cart.itemCount(), 0)
    }
    
    // MARK: - Test 9
    func testRemoveFromCart() {
        let cart = CartViewModel()
        let dish = DishModel(id: UUID(), restaurantId: UUID(), name: "Test", price: 10, imageURL: nil, category: "Test", description: nil, isAvailable: true)
        cart.add(dish)
        cart.remove(dish)
        XCTAssertEqual(cart.itemCount(), 0)
    }
    
    // MARK: - Test 10
    func testDecreaseQuantity() {
        let cart = CartViewModel()
        let dish = DishModel(id: UUID(), restaurantId: UUID(), name: "Test", price: 10, imageURL: nil, category: "Test", description: nil, isAvailable: true)
        cart.add(dish)
        cart.add(dish)
        cart.decrease(dish)
        XCTAssertEqual(cart.itemCount(), 1)
    }
}
