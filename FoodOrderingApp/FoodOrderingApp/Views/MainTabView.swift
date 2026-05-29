//
//  MainTabView.swift
//  FoodOrderingApp
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var cartVM = CartViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RestaurantListView(cartVM: cartVM)
                .tabItem {
                    Label(NSLocalizedString("restaurants_title", comment: ""), systemImage: "fork.knife")
                }
                .tag(0)
            
            OrdersListView()
                .tabItem {
                    Label(NSLocalizedString("orders_title", comment: ""), systemImage: "list.bullet")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label(NSLocalizedString("profile_title", comment: ""), systemImage: "person.circle")
                }
                .tag(2)
        }
        .environmentObject(cartVM)
    }
}
