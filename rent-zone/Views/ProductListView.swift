import SwiftUI

// Determines the initial sort order for "View All" navigations
enum ProductSortMode {
    case none        // Default order from API
    case popular     // Sort by rating descending
    case recent      // Sort by creation date descending
}

struct ProductListView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    var categoryId: String? = nil
    @State var searchText: String = ""
    var sortMode: ProductSortMode = .none
    
    @State private var showSortSheet = false
    @State private var showFilterSheet = false
    @State private var hasFetchedCategory = false
    
    // Sort & Filter State
    @State private var selectedSort: SortOption? = nil
    @State private var priceRange: ClosedRange<Double> = 0...20000
    @State private var selectedSizes: Set<ClothingSize> = []
    @State private var selectedOccasions: Set<Occasion> = []
    @State private var selectedDate: Date? = nil
    @State private var favoriteProductIds: Set<String> = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var baseProducts: [Product] {
        let products = appStore.productStore.products
        switch sortMode {
        case .popular:
            return products.sorted { $0.rating > $1.rating }
        case .recent:
            return products.sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
        case .none:
            return products
        }
    }
    
    var filteredProducts: [Product] {
        var result = baseProducts
        
        // Filter by price range
        result = result.filter { priceRange.contains($0.rentPricePerDay) }
        
        // Filter by size
        if !selectedSizes.isEmpty {
            result = result.filter { product in
                selectedSizes.contains(where: { $0.rawValue == product.size })
            }
        }
        
        // Filter by occasion
        if !selectedOccasions.isEmpty {
            result = result.filter { product in
                guard let occasion = product.occasion else { return false }
                return selectedOccasions.contains(where: { $0.rawValue == occasion })
            }
        }
        
        // Filter by date availability
        if let date = selectedDate {
            result = result.filter { product in
                !product.bookedDates.contains(where: {
                    Calendar.current.isDate($0, inSameDayAs: date)
                })
            }
        }
        
        // Apply search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.pickupLocation.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply Sort
        if let sortOption = selectedSort {
            switch sortOption {
            case .priceLowToHigh:
                result.sort { $0.rentPricePerDay < $1.rentPricePerDay }
            case .priceHighToLow:
                result.sort { $0.rentPricePerDay > $1.rentPricePerDay }
            case .ratingHighToLow:
                result.sort { $0.rating > $1.rating }
            case .newest:
                result.sort { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
            }
        }
        
        return result
    }
    
    var hasActiveFilters: Bool {
        priceRange != 0...20000 ||
        !selectedSizes.isEmpty ||
        !selectedOccasions.isEmpty ||
        selectedDate != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            navBar
            
            // MARK: - Search Bar
            searchBar
            
            // MARK: - Sort & Filter Buttons
            sortFilterBar
            
            // MARK: - Product Grid
            ScrollView(showsIndicators: false) {
                if filteredProducts.isEmpty && !appStore.productStore.isLoading {
                    VStack(spacing: 20) {
                        Image(systemName: "tshirt")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("No outfits found")
                            .font(.headline)
                        Text("Try adjusting your filters or search terms")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 100)
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredProducts) { product in
                            ProductCardView(
                                product: product,
                                favoriteProductIds: $favoriteProductIds
                            )
                            .onAppear {
                                // Infinite scroll: trigger fetch when last item appears
                                if product.id == filteredProducts.last?.id {
                                    Task {
                                        await appStore.productStore.fetchNextPage()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    // Loading spinner for next page
                    if appStore.productStore.isLoadingMore {
                        ProgressView()
                            .padding(.vertical, 20)
                    }

                    Spacer().frame(height: 30)
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product)
        }
        .overlay {
            if showSortSheet {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture { showSortSheet = false }
                
                VStack(spacing: 0) {
                    Spacer()
                    SortSheetView(selectedSort: $selectedSort, dismiss: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showSortSheet = false
                        }
                    })
                    .padding(.bottom, 16)
                    .background(
                        UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: -4)
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSortSheet)
        .sheet(isPresented: $showFilterSheet) {
            FilterView(
                priceRange: $priceRange,
                selectedSizes: $selectedSizes,
                selectedOccasions: $selectedOccasions,
                selectedDate: $selectedDate,
                totalResults: filteredProducts.count
            )
        }
        .task {
            if let favorites = appStore.userStore.currentUser?.favouriteProducts {
                favoriteProductIds = Set(favorites)
            }
            // Fetch category-filtered products from the API if needed
            if let categoryId = categoryId, !hasFetchedCategory {
                hasFetchedCategory = true
                await appStore.productStore.fetchItems(categoryId: categoryId)
            }
        }
    }
    
    private var navBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
            
            Color.clear
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    private var searchBar: some View {
        SearchBarView(
            text: $searchText,
            placeholder: "Search outfits…"
        )
        .padding(.bottom, 4)
    }
    
    private var sortFilterBar: some View {
        HStack(spacing: 16) {
            Spacer()
            
            // Sort Button
            Button(action: { 
                withAnimation(.easeIn(duration: 0.2)) {
                    showSortSheet = true 
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.body.weight(.medium))
                    Text("Sort")
                        .font(.body.weight(.medium))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            Spacer()
            
            // Filter Button
            Button(action: { showFilterSheet = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal")
                        .font(.body.weight(.medium))
                    Text("Filter")
                        .font(.body.weight(.medium))
                    if hasActiveFilters {
                        Circle()
                            .fill(Color.brandPurple)
                            .frame(width: 7, height: 7)
                    }
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

