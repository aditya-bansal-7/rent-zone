import SwiftUI

struct ProductListView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    var categoryId: String? = nil
    @State var searchText: String = ""
    var initialProducts: [Product]? = nil
    
    @State private var showSortSheet = false
    @State private var showFilterSheet = false
    @State private var showSearchBar = false
    
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
        if let initialProducts = initialProducts {
            return initialProducts
        } else if let categoryId = categoryId {
            return appStore.productStore.products.filter { $0.categoryId == categoryId }
        } else {
            return appStore.productStore.products
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
                break 
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
            
            // MARK: - Search Bar (toggleable)
            if showSearchBar {
                searchBar
            }
            
            // MARK: - Sort & Filter Buttons
            sortFilterBar
            
            // MARK: - Product Grid
            ScrollView(showsIndicators: false) {
                if filteredProducts.isEmpty {
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
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
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
                            .fill(Color.white)
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
            if !searchText.isEmpty {
                showSearchBar = true
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
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showSearchBar.toggle()
                    if !showSearchBar { searchText = "" }
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    private var searchBar: some View {
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
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .transition(.opacity.combined(with: .move(edge: .top)))
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
                .foregroundColor(.black)
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
                            .fill(Color.purple)
                            .frame(width: 7, height: 7)
                    }
                }
                .foregroundColor(.black)
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
        .background(Color.white)
    }
}
