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
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                navBar
                
                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Women Section
                        categorySection(title: "Women", categories: womenCategories)
                        
                        // Men Section
                        categorySection(title: "Men", categories: menCategories)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
    
    private var navBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .semibold))
                    )
            }
            
            Spacer()
            
            Text("Categories")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Spacer()
            
            // Invisible placeholder to keep the title centered
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Color.white)
    }
    
    @ViewBuilder
    private func categorySection(title: String, categories: [Category]) -> some View {
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
                        categoryItem(category: category)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private func categoryItem(category: Category) -> some View {
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
