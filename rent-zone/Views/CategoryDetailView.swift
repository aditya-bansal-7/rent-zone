//
//  CategoryDetailView.swift
//  rentZoneDemo
//

import SwiftUI

struct CategoryDetailView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) private var dismiss
    
    let categoryTitle: String
    
    @State private var showSortSheet = false
    @State private var showFilterSheet = false
    @State private var showSearchBar = false
    @State private var searchText = ""
    
    // Sort & Filter State
    @State private var selectedSort: SortOption? = nil
    @State private var priceRange: ClosedRange<Double> = 0...20000
    @State private var selectedSizes: Set<ClothingSize> = []
    @State private var selectedOccasions: Set<Occasion> = []
    @State private var selectedDate: Date? = nil
    @State private var favoriteProductIds: Set<UUID> = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var filteredProducts: [Product] {
        var result = appStore.productStore.sortedAndFiltered(
            sortOption: selectedSort,
            priceRange: priceRange,
            selectedSizes: selectedSizes,
            selectedOccasions: selectedOccasions,
            selectedDate: selectedDate
        )
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
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
        .background(Color.white)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .overlay {
            if showSortSheet {
                Color.black.opacity(0.01)
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
            
            Text(categoryTitle)
                .font(.title3.weight(.bold))
                .foregroundColor(.black)
            
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
            Button(action: { showSortSheet = true }) {
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

#Preview {
    NavigationStack {
        CategoryDetailView(categoryTitle: "Dandiya Dresses")
            .environment(AppStore())
    }
}
