import SwiftUI

// MARK: - Event Category Mock
struct EventCategory: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let tintColor: Color
}

struct CategoriesView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedGender: CategoryType = .women
    
    // Mock Data for Event Categories
    let eventCategories: [EventCategory] = [
        EventCategory(name: "Navratri", iconName: "sparkles", tintColor: .orange),
        EventCategory(name: "Diwali", iconName: "flame.fill", tintColor: .yellow),
        EventCategory(name: "Wedding", iconName: "heart.fill", tintColor: .red),
        EventCategory(name: "Haldi", iconName: "sun.max.fill", tintColor: .yellow),
        EventCategory(name: "Freshers", iconName: "party.popper.fill", tintColor: .purple),
        EventCategory(name: "Party", iconName: "music.note", tintColor: .blue)
    ]
    
    var currentCategories: [Category] {
        appStore.categoryStore.categories.filter { $0.type == selectedGender }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // MARK: - Native Segmented Picker
                    Picker("Select Category", selection: $selectedGender) {
                        Text("Women").tag(CategoryType.women)
                        Text("Men").tag(CategoryType.men)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // MARK: - Event Categories (Horizontal)
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Shop by Event")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // Add a leading padding spacer to match horizontal layout smoothly
                                Spacer().frame(width: 0)
                                
                                ForEach(eventCategories) { event in
                                    EventCategoryItemView(event: event)
                                }
                                
                                Spacer().frame(width: 0)
                            }
                        }
                    }
                    
                    // MARK: - Dress Categories (Square Grid)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Shop by Category")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 24) {
                            ForEach(currentCategories) { category in
                                NavigationLink(destination: ProductListView(title: category.name, categoryId: category.id)) {
                                    DressCategoryItemView(category: category)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Categories")
            // Native large titles look much better for root tabs
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
        }
    }
}

// MARK: - Event Category Item View
struct EventCategoryItemView: View {
    let event: EventCategory
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(event.tintColor.opacity(0.15))
                    .frame(width: 72, height: 72)
                
                Image(systemName: event.iconName)
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(event.tintColor)
            }
            
            Text(event.name)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Dress Category Item View (Apple Native Styling)
// Apple native grids (like Music/Podcasts/Photos) usually have the image as a card, 
// and the text sitting cleanly below it without a shared background box.
struct DressCategoryItemView: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                
                Image(category.images)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            }
            .aspectRatio(1, contentMode: .fill) // Enforce square
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            Text(category.name)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
}

#Preview {
    CategoriesView()
        .environment(AppStore())
}
