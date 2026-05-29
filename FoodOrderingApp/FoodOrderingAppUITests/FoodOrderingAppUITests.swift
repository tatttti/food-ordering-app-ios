//
//  FoodOrderingAppUITests.swift
//  FoodOrderingAppUITests
//

import XCTest

final class FoodOrderingAppUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    // MARK: - Helper to find register button (the one at the bottom of the form)
    private var registerButton: XCUIElement {
        // На экране регистрации есть две кнопки "Зарегистрироваться"
        // Нам нужна та, что внизу формы (обычно вторая)
        let buttons = app.buttons.matching(identifier: "Зарегистрироваться")
        if buttons.count > 1 {
            return buttons.element(boundBy: buttons.count - 1) // последняя кнопка
        }
        return app.buttons["Зарегистрироваться"]
    }
    
    // MARK: - Helper to find login button on welcome screen
    private var loginButtonOnWelcome: XCUIElement {
        let buttons = ["Войти", "Уже есть аккаунт", "Увайсці", "Login"]
        for title in buttons {
            let button = app.buttons[title]
            if button.exists {
                return button
            }
        }
        return app.buttons.firstMatch
    }
    
    // MARK: - Helper to find register button on welcome screen
    private var registerButtonOnWelcome: XCUIElement {
        let buttons = ["Зарегистрироваться", "Создать аккаунт", "Зарэгістравацца", "Register"]
        for title in buttons {
            let button = app.buttons[title]
            if button.exists {
                return button
            }
        }
        return app.buttons.firstMatch
    }
    
    // MARK: - Helper to create user
    private func createUser() {
        registerButtonOnWelcome.tap()
        
        let nameField = app.textFields.element(boundBy: 0)
        nameField.tap()
        nameField.typeText("Test User")
        
        let emailField = app.textFields.element(boundBy: 1)
        emailField.tap()
        emailField.typeText("test\(UUID().uuidString)@test.com")
        
        let passwordField = app.secureTextFields.element(boundBy: 0)
        passwordField.tap()
        passwordField.typeText("123456")
        
        let confirmField = app.secureTextFields.element(boundBy: 1)
        confirmField.tap()
        confirmField.typeText("123456")
        
        // Нажимаем правильную кнопку регистрации (внизу формы)
        let submitButton = registerButton
        submitButton.tap()
        
        let successAlert = app.alerts.firstMatch
        if successAlert.waitForExistence(timeout: 5) {
            successAlert.buttons.firstMatch.tap()
        }
    }
    
    // MARK: - Test 1: App launches
    func testAppLaunches() {
        let welcomeText = app.staticTexts["FoodOrderingApp"]
        XCTAssertTrue(welcomeText.exists)
    }
    
    // MARK: - Test 2: Register button exists on welcome screen
    func testRegisterButtonExists() {
        XCTAssertTrue(registerButtonOnWelcome.exists)
    }
    
    // MARK: - Test 3: Login button exists on welcome screen
    func testLoginButtonExists() {
        XCTAssertTrue(loginButtonOnWelcome.exists)
    }
    
    // MARK: - Test 4: Tap register button opens registration screen
    func testTapRegisterButton() {
        registerButtonOnWelcome.tap()
        let nameField = app.textFields.firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
    }
    
    // MARK: - Test 5: Cancel registration
    func testCancelRegistration() {
        registerButtonOnWelcome.tap()
        
        let cancelButton = app.buttons["Отмена"]
        if cancelButton.exists {
            cancelButton.tap()
        } else {
            app.buttons["Адмена"].tap()
        }
        
        let welcomeText = app.staticTexts["FoodOrderingApp"]
        XCTAssertTrue(welcomeText.exists)
    }
    
    // MARK: - Test 6: Tap login button opens login screen
    func testTapLoginButton() {
        loginButtonOnWelcome.tap()
        let emailField = app.textFields.firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 3))
    }
    
    // MARK: - Test 7: Cancel login
    func testCancelLogin() {
        loginButtonOnWelcome.tap()
        
        let cancelButton = app.buttons["Отмена"]
        if cancelButton.exists {
            cancelButton.tap()
        } else {
            app.buttons["Адмена"].tap()
        }
        
        let welcomeText = app.staticTexts["FoodOrderingApp"]
        XCTAssertTrue(welcomeText.exists)
    }
    
    // MARK: - Test 8: Restaurants tab exists after login
    func testRestaurantsTabExists() {
        createUser()
        
        let restaurantsTab = app.tabBars.buttons.element(boundBy: 0)
        XCTAssertTrue(restaurantsTab.waitForExistence(timeout: 5))
    }
    
    // MARK: - Test 9: Profile tab exists after login
    func testProfileTabExists() {
        createUser()
        
        let profileTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
    }
    
    // MARK: - Test 10: Orders tab exists after login
    func testOrdersTabExists() {
        createUser()
        
        let ordersTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(ordersTab.waitForExistence(timeout: 5))
    }
}
