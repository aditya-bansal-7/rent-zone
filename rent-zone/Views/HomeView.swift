import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appStore: AppStore
    @State private var searchText = ""
    @State private var selectedCategory = "All Items"
    @State private var favoriteProductIds: Set<UUID> = []
    
    var popularProducts: [Product] {
        appStore.productStore.products.filter { $0.isPopular }
    }
    
    var recentProducts: [Product] {
        appStore.productStore.products.filter { !$0.isPopular }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                
                // User header
                userHeader
                
                // Search bar
                searchBar
                
                // Category chips
                categoryChips
                
                // Popular Outfits
                sectionHeader(title: "POPULAR OUTFITS")
                productGrid(products: popularProducts)
                
                // Recent Outfits
                sectionHeader(title: "RECENT OUTFITS")
                productGrid(products: recentProducts)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - User Header
    private var userHeader: some View {
        HStack {
            // Profile picture placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                    
                )
            
            Text("Payal Singh")
                .font(.system(size: 17, weight: .semibold))
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .offset(x: -10)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $searchText)
                .font(.system(size: 15))
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Category Chips
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(appStore.categoryStore.categories) { category in
                    categoryChip(category: category)
                }
            }
        }
    }
    
    private func categoryChip(category: Category) -> some View {
        let isSelected = selectedCategory == category.name
        return Button(action: {
            selectedCategory = category.name
        }) {
            HStack(spacing: 6) {
                Image(systemName: category.images)
                    .font(.system(size: 13))
                Text(category.name)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.black : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
    
    // MARK: - Section Header
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .tracking(0.5)
            
            Spacer()
            
            Button(action: {}) {
                Text("View All")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Product Grid
    private func productGrid(products: [Product]) -> some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(products) { product in
                productCard(product: product)
            }
        }
    }
    
    // MARK: - Product Card
    private func productCard(product: Product) -> some View {
        let isFavorite = favoriteProductIds.contains(product.id)
        return VStack(alignment: .leading, spacing: 6) {
            // Image area
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .aspectRatio(0.8, contentMode: .fit)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.gray.opacity(0.5))
                    )
                
                // Favorite button
                Button(action: {
                    if isFavorite {
                        favoriteProductIds.remove(product.id)
                    } else {
                        favoriteProductIds.insert(product.id)
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 13))
                            .foregroundColor(isFavorite ? .red : .gray)
                    }
                }
                .padding(8)
            }
            
            // Product name
            Text(product.name)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
            
            // Price and rating
            HStack {
                Text("₹ \(Int(product.rentPricePerDay))/day")
                    .font(.system(size: 12, weight: .semibold))
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    
                    Text(product.rating.formatted(.number.precision(.fractionLength(0...1))))
                        .font(.system(size: 12, weight: .medium))
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStore())
}
