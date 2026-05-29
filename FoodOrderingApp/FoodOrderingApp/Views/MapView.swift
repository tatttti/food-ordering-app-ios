//
//  MapView.swift
//  FoodOrderingApp
//

import SwiftUI
import MapKit

struct MapView: View {
    let restaurants: [RestaurantModel]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.9, longitude: 27.56),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedRestaurant: RestaurantModel?
    @State private var showRestaurantDetail = false
    @State private var userLocation: CLLocation?
    @State private var showUserLocation = false
    
    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: showUserLocation,
                annotationItems: restaurants
            ) { restaurant in
                MapAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: restaurant.latitude,
                        longitude: restaurant.longitude
                    )
                ) {
                    RestaurantAnnotation(restaurant: restaurant) {
                        selectedRestaurant = restaurant
                        showRestaurantDetail = true
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                setupMap()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: centerOnUserLocation) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle(NSLocalizedString("map_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showUserLocation.toggle() }) {
                    Image(systemName: showUserLocation ? "location.fill" : "location")
                }
            }
        }
        .sheet(isPresented: $showRestaurantDetail) {
            if let restaurant = selectedRestaurant {
                RestaurantDetailSheet(restaurant: restaurant, userLocation: userLocation)
            }
        }
    }
    
    private func setupMap() {
        region.center = CLLocationCoordinate2D(latitude: 53.9, longitude: 27.56)
        
        Task {
            do {
                let location = try await LocationService.shared.getCurrentLocation()
                userLocation = location
                if restaurants.isEmpty {
                    region.center = location.coordinate
                }
            } catch {
                print("Failed to get user location: \(error)")
            }
        }
    }
    
    private func centerOnUserLocation() {
        Task {
            do {
                let location = try await LocationService.shared.getCurrentLocation()
                userLocation = location
                withAnimation {
                    region.center = location.coordinate
                }
            } catch {
                print("Failed to center on user location: \(error)")
            }
        }
    }
}

struct RestaurantAnnotation: View {
    let restaurant: RestaurantModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                    )
                
                Text(restaurant.name)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
        }
    }
}

struct RestaurantDetailSheet: View {
    let restaurant: RestaurantModel
    let userLocation: CLLocation?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let imageURL = restaurant.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        case .failure:
                            Color.gray
                                .frame(height: 200)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Color.orange
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(restaurant.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", restaurant.rating))
                        }
                    }
                    
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.orange)
                        Text(restaurant.cuisineType)
                    }
                    .font(.subheadline)
                    
                    Divider()
                    
                    HStack(alignment: .top) {
                        Image(systemName: "location")
                            .foregroundColor(.orange)
                        Text(restaurant.address)
                    }
                    .font(.subheadline)
                    
                    if let distance = getDistance() {
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.orange)
                            Text(String(format: NSLocalizedString("map_distance", comment: ""), distance))
                        }
                        .font(.subheadline)
                    }
                    
                    Divider()
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: MenuView(restaurant: restaurant, cartVM: CartViewModel())) {
                            Text(NSLocalizedString("menu_title", comment: ""))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: openInMaps) {
                            Text(NSLocalizedString("map_open_in_maps", comment: ""))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray5))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("restaurant_detail", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common_close", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getDistance() -> Double? {
        guard let userLocation = userLocation else { return nil }
        return restaurant.clLocation.distance(from: userLocation) / 1000
    }
    
    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant.name
        mapItem.openInMaps()
    }
}
