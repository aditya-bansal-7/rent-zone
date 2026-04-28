import SwiftUI

struct FavoritesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) var appStore
    @State private var favoriteProductIds: Set<String> = []
    
    private var user: User? { appStore.userStore.currentUser }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGray6).opacity(0.3)
                    .ignoresSafeArea()
                
                if appStore.productStore.isLoading && appStore.productStore.favoriteProducts.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading favorites...")
                        Spacer()
                    }
                } else if appStore.productStore.favoriteProducts.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No favorites yet")
                            .font(.headline)
                        Text("Tap the heart on any outfit to save it here!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            ProductGridView(products: appStore.productStore.favoriteProducts, favoriteProductIds: $favoriteProductIds)
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
            }
            .task {
                if let favorites = appStore.userStore.currentUser?.favouriteProducts {
                    favoriteProductIds = Set(favorites)
                }
                await appStore.productStore.fetchFavorites()
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
    FavoritesView()
        .environment(AppStore())
}
