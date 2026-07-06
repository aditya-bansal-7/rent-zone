import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) var appStore
    @State private var searchText = ""
    @State private var favoriteProductIds: Set<String> = []
    @State private var isLoginSheetPresented = false
    @State private var showNotifications = false
    @State private var isProfileSheet = false
    @State private var navigateToSearch = false
    
    var allProducts: [Product] {
        appStore.productStore.products
    }
    
    var popularProducts: [Product] {
        // Sort by rating descending and take top 4
        allProducts.sorted { $0.rating > $1.rating }.prefix(4).map { $0 }
    }
    
    var recentProducts: [Product] {
        // Array is already sorted by createdAt desc from backend
        allProducts.prefix(4).map { $0 }
    }
    
    var filteredProducts: [Product] {
        if searchText.isEmpty { return allProducts }
        return allProducts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.pickupLocation.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    VStack {
                        
                        
                        VStack(alignment: .leading, spacing: 16) {
                            UserHeaderView(showNotifications: $showNotifications)
                                .onTapGesture {
                                    if appStore.userStore.currentUser == nil {
                                        isLoginSheetPresented = true
                                    } else {
                                        isProfileSheet = true
                                    }
                                }
                            
                        }
                        .padding(.horizontal, 16)
                        
                        
                        
                        
                        SearchBarView(text: $searchText, placeholder: "Search")
                        
                        VStack(alignment: .leading, spacing: 16) {
                            
                            if !searchText.isEmpty {
                                // Search results
                                if filteredProducts.isEmpty {
                                    Text("No outfits match \"\(searchText)\"")
                                        .foregroundStyle(.secondary)
                                        .padding(.vertical, 40)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    SectionHeaderView(title: "SEARCH RESULTS (\(filteredProducts.count))", showViewAll: false)
                                    ProductGridView(products: filteredProducts, favoriteProductIds: $favoriteProductIds)
                                }
                            } else {
                                
                                if appStore.productStore.isLoading {
                                    VStack(spacing: 16) {
                                        ProgressView()
                                        Text("Loading outfits...")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else if allProducts.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "tshirt")
                                            .font(.system(size: 48))
                                            .foregroundStyle(.gray.opacity(0.5))
                                        Text("No outfits available yet")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                        Text("Be the first to list your outfit!")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    SectionHeaderView(
                                        title: "POPULAR OUTFITS",
                                        destination: ProductListView(title: "Popular Outfits", sortMode: .popular)
                                    )
                                    ProductGridView(products: popularProducts, favoriteProductIds: $favoriteProductIds)
                                    
                                    // Recent Outfits
                                    SectionHeaderView(
                                        title: "RECENT OUTFITS",
                                        destination: ProductListView(title: "Recent Outfits", sortMode: .recent)
                                    )
                                    ProductGridView(products: recentProducts, favoriteProductIds: $favoriteProductIds)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    
                    .navigationDestination(isPresented: $navigateToSearch) {
                        ProductListView(title: "Search Results", searchText: searchText)
                    }
                    .sheet(isPresented: $isLoginSheetPresented) {
                        LoginView()
                    }
                    .sheet(isPresented: $isProfileSheet) {
                        ProfileView()
                    }
                    .refreshable {
                        await appStore.productStore.fetchItems()
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .navigationDestination(isPresented: $showNotifications) {
                    NotificationCentreView()
                        .environment(appStore)
                }
                
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(product: product)
                }
                .task {
                    if let favorites = appStore.userStore.currentUser?.favouriteProducts {
                        favoriteProductIds = Set(favorites)
                    }
                    if allProducts.isEmpty {
                        await appStore.productStore.fetchItems()
                    }
                }
                .onChange(of: appStore.userStore.currentUser?.favouriteProducts) { _, newValue in
                    if let newValue {
                        favoriteProductIds = Set(newValue)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AppStore())
}
