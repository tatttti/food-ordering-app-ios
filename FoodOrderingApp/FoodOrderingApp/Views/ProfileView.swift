//
//  ProfileView.swift
//  FoodOrderingApp
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showLogoutAlert = false
    @State private var orderStats = OrderStats(activeOrders: 0, totalSpent: 0, totalOrders: 0)
    
    var body: some View {
        NavigationView {
            if let user = authService.currentUser {
                ScrollView {
                    VStack(spacing: 24) {
                        ProfileHeader(user: user)
                        
                        OrderStatisticsCard(stats: orderStats)
                        
                        VStack(spacing: 0) {
                            ProfileMenuItem(icon: "questionmark.circle", title: NSLocalizedString("profile_about", comment: ""), subtitle: NSLocalizedString("profile_about_subtitle", comment: "")) { }
                            Divider()
                            ProfileMenuItem(icon: "arrow.right.square", title: NSLocalizedString("profile_logout", comment: ""), subtitle: NSLocalizedString("profile_logout_subtitle", comment: ""), iconColor: .red, titleColor: .red) {
                                showLogoutAlert = true
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .navigationTitle(NSLocalizedString("profile_title", comment: ""))
                .background(Color(.systemGroupedBackground))
                .alert(NSLocalizedString("profile_logout", comment: ""), isPresented: $showLogoutAlert) {
                    Button(NSLocalizedString("profile_logout", comment: ""), role: .destructive) { authService.logout() }
                    Button(NSLocalizedString("common_cancel", comment: ""), role: .cancel) { }
                } message: {
                    Text(NSLocalizedString("profile_logout_confirm", comment: ""))
                }
                .onAppear {
                    loadOrderStatistics()
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    Text(NSLocalizedString("profile_not_authorized", comment: ""))
                        .font(.headline)
                }
                .navigationTitle(NSLocalizedString("profile_title", comment: ""))
            }
        }
    }
    
    private func loadOrderStatistics() {
        guard let user = authService.currentUser else { return }
        let allOrders = OrderService.shared.getOrders(for: user)
        let activeOrders = allOrders.filter { $0.orderStatus != .delivered && $0.orderStatus != .cancelled }
        let totalSpent = allOrders.filter { $0.orderStatus == .delivered }.reduce(0) { $0 + $1.totalPrice }
        
        orderStats = OrderStats(activeOrders: activeOrders.count, totalSpent: totalSpent, totalOrders: allOrders.count)
    }
}

struct ProfileHeader: View {
    let user: UserModel
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.orange.opacity(0.2)).frame(width: 100, height: 100)
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.system(size: 40)).fontWeight(.bold).foregroundColor(.orange)
            }
            Text(user.name).font(.title2).fontWeight(.bold)
            Label(user.email, systemImage: "envelope").font(.subheadline).foregroundColor(.secondary)
            if let phone = user.phone, !phone.isEmpty {
                Label(phone, systemImage: "phone").font(.subheadline).foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
    }
}

struct OrderStatisticsCard: View {
    let stats: OrderStats
    
    var body: some View {
        HStack(spacing: 0) {
            StatItem(title: "\(stats.activeOrders)", subtitle: NSLocalizedString("profile_active_orders", comment: ""), icon: "clock")
            Divider().frame(height: 50)
            StatItem(title: "\(stats.totalOrders)", subtitle: NSLocalizedString("profile_total_orders", comment: ""), icon: "list.bullet")
            Divider().frame(height: 50)
            StatItem(title: "\(Int(stats.totalSpent)) \(NSLocalizedString("currency_rub", comment: ""))", subtitle: NSLocalizedString("profile_total_spent", comment: ""), icon: "rublesign")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(.orange)
            Text(title).font(.title3).fontWeight(.bold)
            Text(subtitle).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    var iconColor: Color = .blue
    var titleColor: Color = .primary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon).foregroundColor(iconColor).frame(width: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).foregroundColor(titleColor)
                    Text(subtitle).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct OrderStats {
    let activeOrders: Int
    let totalSpent: Double
    let totalOrders: Int
}
