//
//  CartView.swift
//  FoodOrderingApp
//

import SwiftUI

struct CartView: View {
    @ObservedObject var cartVM: CartViewModel
    let restaurant: RestaurantModel
    
    @State private var address = ""
    @State private var paymentMethod: CartPaymentMethod = .cash
    @State private var comment = ""
    @State private var isPickup = false
    @State private var showPaymentSheet = false
    @State private var showAlert = false
    @State private var showReceipt = false
    @State private var alertMessage = ""
    @State private var isProcessing = false
    @State private var createdOrder: OrderModel?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if cartVM.items.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "cart")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text(NSLocalizedString("cart_empty", comment: ""))
                        .font(.headline)
                    Text(NSLocalizedString("cart_add_dishes", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(cartVM.items.keys), id: \.id) { dish in
                            CartItemRow(
                                dish: dish,
                                quantity: cartVM.items[dish] ?? 0,
                                onIncrease: { cartVM.add(dish) },
                                onDecrease: { cartVM.decrease(dish) },
                                onRemove: { cartVM.remove(dish) }
                            )
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(NSLocalizedString("cart_pickup", comment: ""), isOn: $isPickup)
                                .font(.headline)
                            
                            if !isPickup {
                                TextField(NSLocalizedString("cart_delivery_address", comment: ""), text: $address)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.orange)
                                    Text(NSLocalizedString("cart_pickup_from", comment: "") + " \(restaurant.address)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal)
                        
                        TextField(NSLocalizedString("cart_comment", comment: ""), text: $comment)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        Button(action: { showPaymentSheet = true }) {
                            HStack {
                                Text(NSLocalizedString("cart_payment_method", comment: ""))
                                    .font(.headline)
                                Spacer()
                                Text(paymentMethod.title)
                                    .foregroundColor(.orange)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                
                VStack(spacing: 12) {
                    HStack {
                        Text(NSLocalizedString("cart_total", comment: ""))
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(Int(cartVM.totalPrice)) \(NSLocalizedString("currency_rub", comment: ""))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    
                    Button(action: createOrder) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.orange)
                                .cornerRadius(12)
                        } else {
                            Text(NSLocalizedString("cart_checkout", comment: ""))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(!isFormValid || isProcessing)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle(NSLocalizedString("cart_title", comment: ""))
        .sheet(isPresented: $showPaymentSheet) {
            CartPaymentView(selectedMethod: $paymentMethod)
        }
        .alert(NSLocalizedString("order_created", comment: ""), isPresented: $showAlert) {
            Button(NSLocalizedString("common_ok", comment: "")) {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showReceipt) {
            if let order = createdOrder {
                ReceiptView(order: order, restaurant: restaurant, isPresented: $showReceipt)
            }
        }
    }
    
    private var isFormValid: Bool {
        !cartVM.items.isEmpty && (isPickup || !address.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    
    private func createOrder() {
        guard let user = AuthService.shared.currentUser else {
            alertMessage = NSLocalizedString("error_user_not_authorized", comment: "")
            showAlert = true
            return
        }
        
        isProcessing = true
        
        let itemsArray = cartVM.items.map { (dish, qty) in
            (dish: dish, quantity: qty)
        }
        
        let orderAddress = isPickup ? restaurant.address : address
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let order = OrderService.shared.createOrder(
                user: user,
                restaurant: restaurant,
                items: itemsArray,
                address: orderAddress,
                paymentMethod: paymentMethod.rawValue,
                comment: comment.isEmpty ? nil : comment,
                isPickup: isPickup
            )
            
            DispatchQueue.main.async {
                isProcessing = false
                
                if let order = order {
                    cartVM.clear()
                    createdOrder = order
                    showReceipt = true
                } else {
                    alertMessage = NSLocalizedString("order_failed", comment: "")
                    showAlert = true
                }
            }
        }
    }
}

enum CartPaymentMethod: String, CaseIterable, Identifiable {
    case online = "online"
    case erip = "erip"
    case terminal = "terminal"
    case cash = "cash"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .online: return NSLocalizedString("payment_online", comment: "")
        case .erip: return NSLocalizedString("payment_erip", comment: "")
        case .terminal: return NSLocalizedString("payment_terminal", comment: "")
        case .cash: return NSLocalizedString("payment_cash", comment: "")
        }
    }
}

struct CartPaymentView: View {
    @Binding var selectedMethod: CartPaymentMethod
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("payment_select", comment: ""))) {
                    Picker(NSLocalizedString("payment_select", comment: ""), selection: $selectedMethod) {
                        ForEach(CartPaymentMethod.allCases) { method in
                            Text(method.title).tag(method)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle(NSLocalizedString("payment_select", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common_done", comment: "")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common_cancel", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CartItemRow: View {
    let dish: DishModel
    let quantity: Int
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.headline)
                Text("\(Int(dish.price)) \(NSLocalizedString("currency_rub", comment: ""))")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: onDecrease) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                }
                
                Text("\(quantity)")
                    .font(.headline)
                    .frame(width: 30)
                
                Button(action: onIncrease) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                }
            }
            
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
