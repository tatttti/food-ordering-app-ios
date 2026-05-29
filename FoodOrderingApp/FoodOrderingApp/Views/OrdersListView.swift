//
//  OrdersListView.swift
//  FoodOrderingApp
//

import SwiftUI

struct OrdersListView: View {
    @StateObject private var orderService = OrderService.shared
    @State private var selectedSegment = 0
    @State private var selectedOrder: OrderModel?
    @State private var showOrderDetail = false
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(NSLocalizedString("orders_type", comment: ""), selection: $selectedSegment) {
                    Text(NSLocalizedString("orders_active", comment: "")).tag(0)
                    Text(NSLocalizedString("orders_history", comment: "")).tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                let orders = selectedSegment == 0 ? orderService.currentOrders : orderService.orderHistory
                
                if orders.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: selectedSegment == 0 ? "clock" : "archivebox")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(selectedSegment == 0 ? NSLocalizedString("orders_no_active", comment: "") : NSLocalizedString("orders_no_history", comment: ""))
                            .font(.headline)
                    }
                    Spacer()
                } else {
                    List(orders) { order in
                        OrderCard(order: order)
                            .onTapGesture {
                                selectedOrder = order
                                showOrderDetail = true
                            }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(NSLocalizedString("orders_title", comment: ""))
            .onAppear {
                if let user = AuthService.shared.currentUser {
                    orderService.loadOrders(for: user)
                }
            }
            .sheet(isPresented: $showOrderDetail) {
                if let order = selectedOrder {
                    OrderDetailView(order: order)
                }
            }
        }
    }
}

struct OrderCard: View {
    let order: OrderModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(format: NSLocalizedString("orders_number", comment: ""), String(order.id.uuidString.prefix(8))))
                    .font(.headline)
                Spacer()
                StatusBadge(status: order.orderStatus)
            }
            
            HStack {
                Image(systemName: order.isPickup ? "bag" : "location")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text(order.isPickup ? NSLocalizedString("cart_pickup", comment: "") : NSLocalizedString("cart_delivery", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("\(Int(order.totalPrice)) \(NSLocalizedString("currency_rub", comment: ""))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(formatDate(order.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}

struct StatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        Text(status.localizedString)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .preparing: return .purple
        case .delivering: return .green
        case .delivered: return .gray
        case .cancelled: return .red
        }
    }
}

struct OrderDetailView: View {
    let order: OrderModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelAlert = false
    @State private var isCancelling = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("order_status", comment: ""))
                            .font(.headline)
                        StatusBadge(status: order.orderStatus)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("order_details", comment: ""))
                            .font(.headline)
                        
                        InfoRow(icon: "number", title: NSLocalizedString("orders_number", comment: ""), value: order.id.uuidString)
                        InfoRow(icon: "calendar", title: NSLocalizedString("orders_date", comment: ""), value: formatDate(order.createdAt))
                        InfoRow(icon: "rublesign", title: NSLocalizedString("cart_total", comment: ""), value: "\(Int(order.totalPrice)) \(NSLocalizedString("currency_rub", comment: ""))")
                        InfoRow(icon: "creditcard", title: NSLocalizedString("payment_method", comment: ""), value: getPaymentMethodTitle(order.paymentMethod))
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(order.isPickup ? NSLocalizedString("cart_pickup", comment: "") : NSLocalizedString("cart_delivery", comment: ""))
                            .font(.headline)
                        InfoRow(icon: "location", title: NSLocalizedString("delivery_address", comment: ""), value: order.address)
                    }
                    .padding(.horizontal)
                    
                    if canCancelOrder {
                        Button(action: { showCancelAlert = true }) {
                            if isCancelling {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            } else {
                                Text(NSLocalizedString("orders_cancel", comment: ""))
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(isCancelling)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(NSLocalizedString("order_details", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common_close", comment: "")) { dismiss() }
                }
            }
            .alert(NSLocalizedString("orders_cancel", comment: ""), isPresented: $showCancelAlert) {
                Button(NSLocalizedString("common_yes", comment: ""), role: .destructive) { cancelOrder() }
                Button(NSLocalizedString("common_no", comment: ""), role: .cancel) { }
            } message: {
                Text(NSLocalizedString("orders_cancel_confirm", comment: ""))
            }
        }
    }
    
    private var canCancelOrder: Bool {
        let cancellableStatuses: Set<OrderStatus> = [.pending, .confirmed]
        return cancellableStatuses.contains(order.orderStatus)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
    
    private func getPaymentMethodTitle(_ method: String) -> String {
        switch method {
        case "online": return NSLocalizedString("payment_online", comment: "")
        case "erip": return NSLocalizedString("payment_erip", comment: "")
        case "terminal": return NSLocalizedString("payment_terminal", comment: "")
        case "cash": return NSLocalizedString("payment_cash", comment: "")
        default: return method
        }
    }
    
    private func cancelOrder() {
        isCancelling = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let success = OrderService.shared.cancelOrder(orderId: order.id)
            DispatchQueue.main.async {
                isCancelling = false
                if success { dismiss() }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
            }
            Spacer()
        }
    }
}
