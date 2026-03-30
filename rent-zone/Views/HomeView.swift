import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appStore: AppStore
    @State private var searchText = ""
    @State private var selectedCategory = "All Items"
    @State private var favoriteProductIds: Set<UUID> = []
    @State private var isLoginSheetPresented = false
    @State private var isProfileSheetPresented = false
    
    var popularProducts: [Product] {
        appStore.productStore.products.filter { $0.isPopular }
    }
    
    var recentProducts: [Product] {
        appStore.productStore.products.filter { !$0.isPopular }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                UserHeaderView()
                    .onTapGesture {
                        isProfileSheetPresented = true
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
        .sheet(isPresented: $isProfileSheetPresented) {
            ProfileView()
        }
    }
    
}

#Preview {
    HomeView()
        .environmentObject(AppStore())
}
