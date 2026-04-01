import SwiftUI

struct CategoriesView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) var dismiss
    
    var womenCategories: [Category] {
        appStore.categoryStore.categories.filter { $0.type == .women }
    }
    
    var menCategories: [Category] {
        appStore.categoryStore.categories.filter { $0.type == .men }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Women Section
                        CategorySectionView(title: "Women", categories: womenCategories)
                        
                        // Men Section
                        CategorySectionView(title: "Men", categories: menCategories)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Categories")
        }
    }

}

struct CategorySectionView: View {
    let title: String
    let categories: [Category]
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Section Header
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    // View All action
                }) {
                    Text("View All")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            
            // Grid
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryDetailView(categoryTitle: category.name)) {
                        CategoryItemView(category: category)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct CategoryItemView: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: 12) {
            Image(category.images)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
            
            Text(category.name)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    CategoriesView()
        .environment(AppStore())
}
