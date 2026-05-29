//
//  RestaurantListView.swift
//  FoodOrderingApp
//

import SwiftUI

struct RestaurantListView: View {
    @StateObject private var vm = RestaurantListViewModel()
    @ObservedObject var cartVM: CartViewModel
    @State private var showMap = false
    @State private var showNearestAlert = false
    @State private var nearestRestaurant: RestaurantModel?
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $vm.searchText, placeholder: NSLocalizedString("restaurants_search", comment: ""))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vm.cuisines, id: \.self) { cuisine in
                            FilterChip(
                                title: cuisine,
                                isSelected: vm.selectedCuisine == cuisine || (cuisine == NSLocalizedString("restaurants_all", comment: "") && vm.selectedCuisine == nil),
                                action: {
                                    if cuisine == NSLocalizedString("restaurants_all", comment: "") {
                                        vm.selectedCuisine = nil
                                    } else {
                                        vm.selectedCuisine = cuisine
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                if vm.isLoading {
                    Spacer()
                    ProgressView(NSLocalizedString("restaurants_loading", comment: ""))
                    Spacer()
                } else if vm.filteredRestaurants.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "mappin.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(NSLocalizedString("restaurants_not_found", comment: ""))
                            .font(.headline)
                        Text(NSLocalizedString("restaurants_try_again", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List(vm.filteredRestaurants) { restaurant in
                        NavigationLink(destination: MenuView(restaurant: restaurant, cartVM: cartVM)) {
                            RestaurantRow(restaurant: restaurant, vm: vm)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(NSLocalizedString("restaurants_title", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: findNearestRestaurant) {
                        Image(systemName: "location")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showMap = true }) {
                        Image(systemName: "map")
                    }
                }
            }
            .sheet(isPresented: $showMap) {
                MapView(restaurants: vm.restaurants)
            }
            .alert(NSLocalizedString("map_nearest", comment: ""), isPresented: $showNearestAlert) {
                if let restaurant = nearestRestaurant {
                    Button(NSLocalizedString("common_ok", comment: ""), role: .cancel) { }
                } else {
                    Button(NSLocalizedString("common_ok", comment: ""), role: .cancel) { }
                }
            } message: {
                if let restaurant = nearestRestaurant {
                    Text("\(restaurant.name)\n\(restaurant.address)\n\(NSLocalizedString("map_distance", comment: "")) \(String(format: "%.1f", vm.getDistanceToRestaurant(restaurant) ?? 0)) \(NSLocalizedString("restaurants_distance_km", comment: ""))")
                } else {
                    Text(NSLocalizedString("map_location_unavailable", comment: ""))
                }
            }
            .onAppear {
                vm.loadRestaurants()
            }
        }
    }
    
    private func findNearestRestaurant() {
        Task {
            do {
                let location = try await LocationService.shared.getCurrentLocation()
                if let nearest = vm.nearestRestaurant(to: location) {
                    nearestRestaurant = nearest
                    showNearestAlert = true
                }
            } catch {
                showNearestAlert = true
                nearestRestaurant = nil
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct RestaurantRow: View {
    let restaurant: RestaurantModel
    let vm: RestaurantListViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageName = restaurant.imageURL {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image(systemName: "fork.knife")
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(restaurant.cuisineType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(restaurant.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let hours = restaurant.workingHours {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text(hours)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if let distance = vm.getDistanceToRestaurant(restaurant) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f", distance))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    Text(NSLocalizedString("restaurants_distance_km", comment: ""))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
