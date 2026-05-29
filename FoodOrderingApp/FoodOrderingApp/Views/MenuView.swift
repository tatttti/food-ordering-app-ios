//
//  MenuView.swift
//  FoodOrderingApp
//

import SwiftUI

struct MenuView: View {
    let restaurant: RestaurantModel
    @ObservedObject var cartVM: CartViewModel
    @StateObject private var vm = MenuViewModel()
    @State private var selectedCategory: String = NSLocalizedString("restaurants_all", comment: "")
    @State private var showCart = false
    
    var body: some View {
        VStack {
            if !vm.categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vm.categories, id: \.self) { category in
                            FilterChip(
                                title: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredDishes) { dish in
                        DishRow(
                            dish: dish,
                            quantity: cartVM.items[dish] ?? 0,
                            onAdd: { cartVM.add(dish) },
                            onRemove: { cartVM.decrease(dish) }
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle(restaurant.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showCart = true }) {
                    ZStack {
                        Image(systemName: "cart")
                        if cartVM.itemCount() > 0 {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Text("\(cartVM.itemCount())")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 10, y: -10)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCart) {
            NavigationView {
                CartView(cartVM: cartVM, restaurant: restaurant)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                vm.loadDishes(for: restaurant.id)
            }
        }
    }
    
    private var filteredDishes: [DishModel] {
        if selectedCategory == NSLocalizedString("restaurants_all", comment: "") {
            return vm.dishes
        }
        return vm.dishes.filter { $0.category == selectedCategory }
    }
}

struct DishRow: View {
    let dish: DishModel
    let quantity: Int
    let onAdd: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageName = dish.imageURL {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image(systemName: "photo")
                    .frame(width: 80, height: 80)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.headline)
                
                if let description = dish.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text("\(Int(dish.price)) \(NSLocalizedString("currency_rub", comment: ""))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                if quantity > 0 {
                    Button(action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                    
                    Text("\(quantity)")
                        .font(.headline)
                        .frame(width: 30)
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                } else {
                    Button(action: onAdd) {
                        Text(NSLocalizedString("menu_add_to_cart", comment: ""))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
