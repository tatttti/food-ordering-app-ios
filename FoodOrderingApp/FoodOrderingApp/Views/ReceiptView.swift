//
//  ReceiptView.swift
//  FoodOrderingApp
//

import SwiftUI

struct ReceiptView: View {
    let order: OrderModel
    let restaurant: RestaurantModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text(NSLocalizedString("receipt_order_confirmed", comment: ""))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(NSLocalizedString("receipt_thank_you", comment: ""))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(NSLocalizedString("receipt_order_id", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("#\(order.id.uuidString.prefix(8))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text(NSLocalizedString("restaurant_title", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(restaurant.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text(order.isPickup ? NSLocalizedString("cart_pickup", comment: "") : NSLocalizedString("cart_delivery", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(order.address)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text(NSLocalizedString("receipt_total", comment: ""))
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(Int(order.totalPrice)) \(NSLocalizedString("currency_rub", comment: ""))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text(NSLocalizedString("payment_method", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(getPaymentMethodTitle(order.paymentMethod))
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    if let comment = order.comment, !comment.isEmpty {
                        HStack {
                            Text(NSLocalizedString("cart_comment", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(comment)
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
            
            Spacer()
            
            Button(action: { isPresented = false }) {
                Text(NSLocalizedString("common_done", comment: ""))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
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
}
