//
//  RootView.swift
//  FoodOrderingApp
//

import SwiftUI

struct RootView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        Group {
            if authService.currentUser == nil {
                WelcomeView()
            } else {
                MainTabView()
            }
        }
    }
}

struct WelcomeView: View {
    @State private var showRegistration = false
    @State private var showLogin = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [.orange.opacity(0.3), .red.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.orange)
                        .shadow(radius: 10)
                    
                    Text("FoodOrderingApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(NSLocalizedString("welcome_subtitle", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button(action: { showRegistration = true }) {
                            Text(NSLocalizedString("reg_register", comment: ""))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: { showLogin = true }) {
                            Text(NSLocalizedString("reg_login", comment: ""))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showRegistration) {
                RegistrationView()
            }
            .sheet(isPresented: $showLogin) {
                LoginSheetView()
            }
        }
    }
}

struct LoginSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("login_title", comment: ""))) {
                    TextField(NSLocalizedString("reg_email", comment: ""), text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField(NSLocalizedString("reg_password", comment: ""), text: $password)
                        .textContentType(.password)
                }
                
                Section {
                    Button(action: login) {
                        Text(NSLocalizedString("reg_login", comment: ""))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.orange)
                    .disabled(email.isEmpty || password.isEmpty)
                }
            }
            .navigationTitle(NSLocalizedString("login_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common_cancel", comment: "")) { dismiss() }
                }
            }
            .alert(NSLocalizedString("error_title", comment: ""), isPresented: $showError) {
                Button(NSLocalizedString("common_ok", comment: ""), role: .cancel) { }
            } message: {
                Text(errorMessage ?? NSLocalizedString("error_something_wrong", comment: ""))
            }
        }
    }
    
    private func login() {
        if let _ = authService.login(email: email, password: password) {
            dismiss()
        } else {
            errorMessage = NSLocalizedString("login_error", comment: "")
            showError = true
        }
    }
}
