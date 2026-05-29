//
//  RegistrationView.swift
//  FoodOrderingApp
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isRegistering = false
    @State private var registrationSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("reg_personal_data", comment: ""))) {
                    TextField(NSLocalizedString("reg_name", comment: ""), text: $name)
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    TextField(NSLocalizedString("reg_email", comment: ""), text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField(NSLocalizedString("reg_phone", comment: ""), text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text(NSLocalizedString("reg_password", comment: ""))) {
                    SecureField(NSLocalizedString("reg_password", comment: ""), text: $password)
                        .textContentType(.newPassword)
                    
                    SecureField(NSLocalizedString("reg_confirm_password", comment: ""), text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                
                Section {
                    Button(action: register) {
                        if isRegistering {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text(NSLocalizedString("cart_processing", comment: ""))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange)
                            .cornerRadius(12)
                        } else {
                            Text(NSLocalizedString("reg_register", comment: ""))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .disabled(!isFormValid || isRegistering)
                }
            }
            .navigationTitle(NSLocalizedString("reg_register", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common_cancel", comment: "")) {
                        dismiss()
                    }
                }
            }
            .alert(NSLocalizedString("error_title", comment: ""), isPresented: $showError) {
                Button(NSLocalizedString("common_ok", comment: ""), role: .cancel) { }
            } message: {
                Text(errorMessage ?? NSLocalizedString("error_something_wrong", comment: ""))
            }
            .alert(NSLocalizedString("reg_success", comment: ""), isPresented: $registrationSuccess) {
                Button(NSLocalizedString("common_ok", comment: ""), role: .cancel) {
                    dismiss()
                }
            } message: {
                Text(NSLocalizedString("reg_success_message", comment: ""))
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func register() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if name.isEmpty {
            errorMessage = NSLocalizedString("error_name_empty", comment: "")
            showError = true
            return
        }
        
        if email.isEmpty {
            errorMessage = NSLocalizedString("error_email_empty", comment: "")
            showError = true
            return
        }
        
        if !isValidEmail(email) {
            errorMessage = NSLocalizedString("error_invalid_email", comment: "")
            showError = true
            return
        }
        
        if password.isEmpty {
            errorMessage = NSLocalizedString("error_password_empty", comment: "")
            showError = true
            return
        }
        
        if password.count < 6 {
            errorMessage = NSLocalizedString("error_password_min_length", comment: "")
            showError = true
            return
        }
        
        if password != confirmPassword {
            errorMessage = NSLocalizedString("error_passwords_not_match", comment: "")
            showError = true
            return
        }
        
        isRegistering = true
        
        let phoneToSave = phone.isEmpty ? nil : phone
        
        DispatchQueue.global().async {
            let user = authService.register(
                name: name,
                email: email,
                phone: phoneToSave,
                password: password
            )
            
            DispatchQueue.main.async {
                isRegistering = false
                
                if user != nil {
                    registrationSuccess = true
                } else {
                    errorMessage = NSLocalizedString("error_user_exists", comment: "")
                    showError = true
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

