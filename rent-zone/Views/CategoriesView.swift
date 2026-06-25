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
    
    var currentCategories: [Category] {
        if selectedGender == .women {
            return [
                
                Category(id: "w2", name: "Shirts", images: "w_shirt", type: .women),
                Category(id: "w3", name: "Dresses", images: "w_dress", type: .women),
                Category(id: "w8", name: "Party Wear", images: "w_party", type: .women),
                Category(id: "w5", name: "Kurtis & Kurtas", images: "w_kurti", type: .women),
                Category(id: "w6", name: "Sarees", images: "w_saree", type: .women),
                Category(id: "w7", name: "Blazers & Formal Wear", images: "w_blazer", type: .women)
               
            ]
        } else {
            return [
                Category(id: "m10", name: "Blazers and Suits", images: "m_blazer", type: .men),
                Category(id: "m7", name: "Varsity Jacket", images: "m_varsity", type: .men),
                
                Category(id: "m6", name: "Denims", images: "m_jacket", type: .men),
                Category(id: "m3", name: "Formal Shirts", images: "m_formal_shirt", type: .men),
                Category(id: "m2", name: "Party Shirts", images: "m_shirt", type: .men),
                Category(id: "m12", name: "Co-ords & Sets", images: "m_coord", type: .men),
                Category(id: "m4", name: "Hoodies & Sweatshirts", images: "m_hoodie", type: .men),
                Category(id: "m5", name: "Kurtas", images: "m_kurta", type: .men),
                
                Category(id: "m8", name: "Leather Jacket", images: "m_leather", type: .men),
                Category(id: "m9", name: "Bombers", images: "m_bomber", type: .men),
                Category(id: "m11", name: "Tuxedo", images: "m_tuxedo", type: .men),
                Category(id: "m14", name: "Baggy Jeans", images: "m_baggy_jeans", type: .men),
                Category(id: "m15", name: "Ripped Jeans", images: "m_ripped_jeans", type: .men),
                Category(id: "m16", name: "Cargos", images: "m_cargos", type: .men),
                Category(id: "m17", name: "Parachute Pants", images: "m_parachute", type: .men),
                Category(id: "m18", name: "Formal Pants", images: "m_formal_pants", type: .men),
                Category(id: "m19", name: "Pleated Trousers", images: "m_pleated", type: .men),
                Category(id: "m20", name: "Ethnic Bottoms", images: "m_ethnic_bottoms", type: .men)
            ]
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Custom Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Categories")
                                .font(.system(size: 34, weight: .bold)) // Apple large title
                                .foregroundColor(.primary)
                            
                            Text("What are you renting for?")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // MARK: - Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.primary)
                        
                        TextField("Search", text: $searchText)
                            .font(.system(size: 17))
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    )
                    .padding(.horizontal)
                    
                    // MARK: - Native Segmented Picker
                    Picker("Select Category", selection: $selectedGender) {
                        Text("Men").tag(CategoryType.men)
                        Text("Women").tag(CategoryType.women)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // MARK: - Dress Categories (Grid)
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
                .padding(.bottom, 40)
            }
            // Hide standard navigation bar to use our custom one
            .navigationBarHidden(true)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
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
        case "Dresses": return ("Mini, Midi,\nParty & more", "figure.dress", .pink)
        case "Co-ord Sets": return ("Matching Sets,\nTrendy & more", "tshirt", .orange)
        case "Kurtis & Kurtas": return ("Ethnic, Festive,\nTraditional & more", "tshirt", .green)
        case "Sarees": return ("Traditional,\nFarewell,\nFestive & more", "tshirt", .pink)
        case "Blazers & Formal Wear": return ("Interview, Placement, & more", "suitcase", .purple)
        case "Party Wear": return ("Night Out,\nEvents,\nPremium & more", "party.popper", .pink)
        
        // Men
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
        case "Blazers & Suits": return ("Formal, Party,\nWedding & more", "suitcase", .blue)
        case "Tuxedo": return ("Premium, Wedding,\nBlack Tie & more", "tshirt", .black)
        case "Co-ords & Sets": return ("Matching Sets,\nCo-ords & more", "tshirt", .orange)
        case "Vests & Tanks": return ("Vests, Tank Tops,\nSleeveless & more", "tshirt", .red)
        case "Baggy Jeans": return ("Streetwear, Fests,\nRelaxed & more", "pants_icon", .blue)
        case "Ripped Jeans": return ("Concerts, Edgy,\nCasual & more", "pants_icon", .gray)
        case "Cargos": return ("Utility, Techwear,\nTrendy & more", "pants_icon", .green)
        case "Parachute Pants": return ("Streetwear, Dance,\nFests & more", "pants_icon", .orange)
        case "Formal Pants": return ("Smart Casual, Dates,\nEvents & more", "pants_icon", .yellow)
        case "Pleated Trousers": return ("Old Money, Upscale,\nEvents & more", "pants_icon", .purple)
        case "Ethnic Bottoms": return ("Dhotis, Pyjamas,\nCultural & more", "pants_icon", .red)
        
        default: return ("Discover more styles", "tshirt", .gray)
        }
    }
    var imageScale: CGFloat {
        if category.name == "Co-ord Sets" || category.name == "Blazers & Formal Wear" {
            return 1.35
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
                Image(category.images)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(imageScale)
                    .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.95)
                    .position(x: geo.size.width * 0.7, y: geo.size.height * 0.55)
                
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
                    
                    Spacer().frame(height: 4)
                    
                    Text(categoryDetails.subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
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

