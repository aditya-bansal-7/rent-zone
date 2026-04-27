import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) var appStore
    @State private var searchText = ""
    @State private var selectedCategory = "All Items"
    @State private var favoriteProductIds: Set<String> = []
    @State private var isLoginSheetPresented = false
    @State private var showNotifications = false
    @State private var isProfileSheet = false

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
                    VStack(alignment: .leading, spacing: 16) {
                        UserHeaderView(showNotifications: $showNotifications)
                            .onTapGesture {
                                if appStore.userStore.currentUser == nil {
                                    isLoginSheetPresented = true
                                } else {
                                    isProfileSheet = true
                                }
                            }

                        SearchBarView(searchText: $searchText)

                        if !searchText.isEmpty {
                            // Search results
                            SectionHeaderView(title: "SEARCH RESULTS (\(filteredProducts.count))")
                            if filteredProducts.isEmpty {
                                Text("No outfits match \"\(searchText)\"")
                                    .foregroundStyle(.secondary)
                                    .padding()
                            } else {
                                ProductGridView(products: filteredProducts, favoriteProductIds: $favoriteProductIds)
                            }
                        } else {
                            CategoryChipsView(selectedCategory: $selectedCategory)

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
                                // Popular Outfits
                                SectionHeaderView(title: "POPULAR OUTFITS")
                                ProductGridView(products: popularProducts, favoriteProductIds: $favoriteProductIds)

                                // Recent Outfits
                                SectionHeaderView(title: "RECENT OUTFITS")
                                ProductGridView(products: recentProducts, favoriteProductIds: $favoriteProductIds)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
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

                // Notification overlay
                if showNotifications {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.25)) {
                                showNotifications = false
                            }
                        }

                    NotificationCentreView(isPresented: $showNotifications)
                        .padding(.top, 60)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showNotifications)
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

#Preview {
    HomeView()
        .environment(AppStore())
}
