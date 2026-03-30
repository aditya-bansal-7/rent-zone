//
//  SubViews.swift
//  rentZoneDemo
//

import SwiftUI

// MARK: - User Header View
struct UserHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .overlay(
                    Text("P")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello 👋")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Payal Singh")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // Notification bell
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.title3)
                    .foregroundColor(.black)
            }
        }
    }
}

// MARK: - Search Bar View
struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search outfits…", text: $searchText)
                .font(.subheadline)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
}

// MARK: - Category Chips View
struct CategoryChipsView: View {
    @Binding var selectedCategory: String
    
    let categories = ["All Items", "Lehenga", "Garba", "Saree", "Kurta"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { cat in
                    Button(action: { selectedCategory = cat }) {
                        Text(cat)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(selectedCategory == cat ? .white : .black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == cat ? Color.black : Color.clear)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedCategory == cat ? Color.clear : Color(.systemGray4),
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Section Header View
struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.black)
                .tracking(1.2)
            
            Spacer()
            
            Button(action: {}) {
                Text("See All")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Product Grid View (for HomeView)
struct ProductGridView: View {
    let products: [Product]
    @Binding var favoriteProductIds: Set<UUID>
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(products) { product in
                ProductCardView(
                    product: product,
                    isFavorite: favoriteProductIds.contains(product.id),
                    onFavoriteTap: {
                        if favoriteProductIds.contains(product.id) {
                            favoriteProductIds.remove(product.id)
                        } else {
                            favoriteProductIds.insert(product.id)
                        }
                    }
                )
            }
        }
    }
}
