import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) var appStore
    @State private var searchText = ""
    @State private var selectedCategory = "All Items"
    @State private var favoriteProductIds: Set<UUID> = []
    @State private var isLoginSheetPresented = false
    @State private var showNotifications = false
    @State private var isProfileSheet = false
    
    var popularProducts: [Product] {
        appStore.productStore.products.filter { $0.isPopular }
    }
    
    var recentProducts: [Product] {
        appStore.productStore.products.filter { !$0.isPopular }
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
                        
                        CategoryChipsView(selectedCategory: $selectedCategory)
                        
                        // Popular Outfits
                        SectionHeaderView(title: "POPULAR OUTFITS")
                        ProductGridView(products: popularProducts, favoriteProductIds: $favoriteProductIds)
                        
                        // Recent Outfits
                        SectionHeaderView(title: "RECENT OUTFITS")
                        ProductGridView(products: recentProducts, favoriteProductIds: $favoriteProductIds)
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
        }
    }
    
}

#Preview {
    HomeView()
        .environment(AppStore())
}
