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
    
    @State private var selectedGender: CategoryType = .men
    @State private var searchText: String = ""
    @Namespace private var animation
    
    @State private var categories: [Category] = []
    @State private var isLoading: Bool = false
    
    
    // Mock Data for Event Categories
    var currentEventCategories: [EventCategory] {
        if selectedGender == .women {
            return [
                EventCategory(name: "College Fest", iconName: "party.popper", tintColor: Color(red: 0.94, green: 0.91, blue: 0.98)),
                EventCategory(name: "Freshers\nParty", iconName: "music.note", tintColor: Color(red: 1.0, green: 0.96, blue: 0.89)),
                EventCategory(name: "Farewell\nNight", iconName: "graduationcap", tintColor: Color(red: 0.91, green: 0.96, blue: 1.0)),
                EventCategory(name: "Date\nNight", iconName: "heart", tintColor: Color(red: 1.0, green: 0.92, blue: 0.96)),
                EventCategory(name: "Placement\nReady", iconName: "briefcase", tintColor: Color(red: 0.91, green: 0.96, blue: 0.93)),
                EventCategory(name: "Traditional\nDay", iconName: "camera.macro", tintColor: Color(red: 1.0, green: 0.92, blue: 0.89))
            ]
        } else {
            return [
                EventCategory(name: "College Fest\nLooks", iconName: "party.popper", tintColor: Color(red: 0.94, green: 0.91, blue: 0.98)),
                EventCategory(name: "Party\nNight", iconName: "music.note", tintColor: Color(red: 1.0, green: 0.96, blue: 0.89)),
                EventCategory(name: "Date\nNight", iconName: "heart", tintColor: Color(red: 0.91, green: 0.96, blue: 1.0)),
                EventCategory(name: "Professional\nWear", iconName: "briefcase", tintColor: Color(red: 0.91, green: 0.96, blue: 0.93)),
                EventCategory(name: "Traditional\nEvents", iconName: "camera.macro", tintColor: Color(red: 1.0, green: 0.92, blue: 0.96))
            ]
        }
    }
    
    var currentCategories: [Category] { categories }
    
    private func fetchCategories() {
        Task {
            isLoading = true
            do {
                let fetched = try await CategoryService.shared.getCategories(type: selectedGender.rawValue)
                await MainActor.run {
                    self.categories = fetched
                    self.isLoading = false
                }
            } catch {
                print("Failed to fetch categories: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    var body: some View {
        
        NavigationStack{
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Categories")
                            .font(.title)
                            .bold()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical,8)
                    
                    // MARK: - Search Bar
                    SearchBarView(text: $searchText, placeholder: "Search")
                    
                    // MARK: - Native Segmented Picker
                    Picker("Select Category", selection: $selectedGender) {
                        Text("Men").tag(CategoryType.men)
                        Text("Women").tag(CategoryType.women)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedGender) { _, _ in
                        fetchCategories()
                    }
                    
                    // MARK: - Dress Categories (Grid)
                    if isLoading {
                        VStack {
                            ProgressView()
                                .padding()
                            Text("Loading categories...")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                            let filteredCategories = currentCategories.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
                            ForEach(filteredCategories) { category in
                                NavigationLink(destination: ProductListView(title: category.name, categoryId: category.id)) {
                                    DressCategoryCardView(category: category)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    
                }
                .padding(.bottom, 40)
                
                // Hide standard navigation bar to use our custom one
                
            }
            .navigationBarHidden(true)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
                
            }
            .task {
                fetchCategories()
            }
        }
    }
}

// MARK: - Event Category Item View
struct EventCategoryItemView: View {
    let event: EventCategory
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: event.iconName)
                .font(.system(size: 20))
                .foregroundColor(.black)
            
            Text(event.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 96, height: 96)
        .background(event.tintColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Dress Category Card View
struct DressCategoryCardView: View {
    let category: Category
    
    var categoryDetails: (subtitle: String, icon: String, color: Color) {
        switch category.name {
        // Women
        case "Tops & Tees": return ("Casual, Crop,\nOversized & more", "tshirt", .purple)
        case "Shirts & Blouses": return ("Casual, Formal,\nSatin & more", "tshirt", .blue)
        case "Dresses": return ("Mini, Midi,\nParty & more", "tshirt", .pink)
        case "Co-ord Sets": return ("Matching Sets,\nTrendy & more", "tshirt", .orange)
        case "Kurtis & Kurtas": return ("Ethnic, Festive,\nTraditional & more", "tshirt", .green)
        case "Sarees": return ("Traditional,\nFarewell,\nFestive & more", "tshirt", .pink)
        case "Blazers": return ("Interview, Placement,\n& more", "tshirt", .purple)
        case "Party Wear": return ("Night Out,\nEvents,\nPremium & more", "tshirt", .pink)
        case "Lehenga": return ("Bridal, Festive,\nParty & more", "tshirt", .pink)
        case "Sharara": return ("Ethnic, Festive,\nWedding & more", "tshirt", .orange)
        case "Gown": return ("Party, Prom,\nWedding & more", "tshirt", .purple)
        
        // Men & Unisex
        case "T-Shirts & Polos": return ("Casual, Printed,\nOversized & more", "tshirt", .purple)
        case "Shirts": return ("Casual, Formal,\nChecked & more", "tshirt", .blue)
        case "Formal Shirts": return ("Solid, Satin,\nOffice Wear & more", "tshirt", .blue)
        case "Party Shirts": return ("Satin, Cuban Collar,\nPremium & more", "tshirt", .blue)
        case "Hoodies & Sweatshirts": return ("Hoodies, Sweatshirts,\nZips & more", "tshirt", .orange)
        case "Kurtas": return ("Ethnic, Festive,\nPrinted & more", "tshirt", .green)
        case "Jackets & Coats": return ("Denim, Bomber,\nWinter & more", "tshirt", .pink)
        case "Varsity Jacket": return ("College, Trendy,\nCasual & more", "tshirt", .red)
        case "Leather Jacket": return ("Biker, Casual,\nPremium & more", "tshirt", .black)
        case "Bombers": return ("Casual, Winter,\nStylish & more", "tshirt", .orange)
        case "Blazers and Suits": return ("Formal, Party,\nWedding & more", "tshirt", .blue)
        case "Tuxedo": return ("Premium, Wedding,\nBlack Tie & more", "tshirt", .black)
        case "Vests & Tanks": return ("Vests, Tank Tops,\nSleeveless & more", "tshirt", .red)
        case "Jeans": return ("Streetwear, Fests,\nRelaxed & more", "pants_icon", .blue)
        case "Cargos": return ("Utility, Techwear,\nTrendy & more", "pants_icon", .green)
        case "Formal Pants": return ("Smart Casual, Dates,\nEvents & more", "pants_icon", .yellow)
        case "Ethnic Bottoms": return ("Dhotis, Pyjamas,\nCultural & more", "pants_icon", .red)
        
        default: return ("Discover more styles", "tshirt", .gray)
        }
    }
    var imageScale: CGFloat {
        if category.name == "Co-ord Sets" || category.name == "Blazers" {
            return 1.35
        } else if category.name == "Ethnic Bottoms" {
            return 0.85
        } else if category.name == "Party Shirts" {
            return 0.75
        }
        return 1.0
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                
                // Image positioned at right side, scaled up
                if category.images.hasPrefix("http"), let url = URL(string: category.images) {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(imageScale)
                                .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.95)
                                .position(x: geo.size.width * 0.7, y: geo.size.height * 0.55)
                        } else if case .empty = phase {
                            // Loading state
                            ProgressView()
                                .frame(width: 80, height: 100)
                                .position(x: geo.size.width * 0.75, y: geo.size.height * 0.5)
                        } else {
                            // Image Placeholder
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 24))
                            }
                            .frame(width: 80, height: 100)
                            .position(x: geo.size.width * 0.75, y: geo.size.height * 0.5)
                        }
                    }
                } else if let uiImage = UIImage(named: category.images) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(imageScale)
                        .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.95)
                        .position(x: geo.size.width * 0.7, y: geo.size.height * 0.55)
                } else {
                    // Image Placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                    .frame(width: 80, height: 100)
                    .position(x: geo.size.width * 0.75, y: geo.size.height * 0.5)
                }
                
                // Content strictly limited to left side (52% width)
                VStack(alignment: .leading, spacing: 0) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)
                        Circle()
                            .fill(categoryDetails.color.opacity(0.12))
                            .frame(width: 36, height: 36)
                        
                        if categoryDetails.icon == "pants_icon" {
                            Image(categoryDetails.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                        } else {
                            Image(systemName: categoryDetails.icon)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    // Titles
                    Text(category.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.leading, 12)
                .frame(width: geo.size.width * 0.52, alignment: .leading)
                

            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(height: 156)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    CategoriesView()
        .environment(AppStore())
}




