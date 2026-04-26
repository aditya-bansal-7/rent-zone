import SwiftUI

struct UploadView: View {
    
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) var dismiss
    
    var selectedImages: [String] = []
    
    var categories: [Category] {
        appStore.categoryStore.categories
    }
    
    @State private var selectedCategory = ""
    @State private var selectedCondition = ""
    @State private var selectedSize = ""
    @State private var price = ""
    @State private var description = ""
    @State private var navigateToListing = false
    
    let conditions = ["New", "Like New", "Used"]
    let sizes = ["XS", "S", "M", "L", "XL"]
    
    // Map condition string to ProductCondition enum
    private func conditionEnum(_ value: String) -> ProductCondition {
        switch value {
        case "New": return .new
        case "Like New": return .likeNew
        case "Used": return .good
        default: return .good
        }
    }
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    Text("Category")
                        .font(.title2)
                        .bold()
                    
                    Picker("Select the Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Condition")
                        .font(.title2)
                        .bold()
                    
                    Picker("Select Condition", selection: $selectedCondition) {
                        ForEach(conditions, id: \.self) { condition in
                            Text(condition).tag(condition)
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Size")
                        .font(.title2)
                        .bold()
                    
                    Picker("Select Size", selection: $selectedSize) {
                        ForEach(sizes, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Price")
                        .font(.title2)
                        .bold()
                    
                    TextField("Enter Price", text: $price)
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.title2)
                        .bold()
                    
                    TextField("Describe Your Outfit", text: $description, axis: .vertical)
                        .frame(height: 100, alignment: .topLeading)
                }
                
                // Location placeholder
                VStack(alignment: .leading) {
                    Text("Pick-Up Location")
                        .font(.title2)
                        .bold()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 200)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 30))
                                .foregroundStyle(.gray)
                            Text("Location Preview")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            
            Section {
                Button {
                    createProduct()
                    navigateToListing = true
                } label: {
                    Text("List")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.2))
                        .foregroundStyle(.black)
                        .cornerRadius(30)
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Provide Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToListing) {
            ListingInfoView()
        }
    }
    
    // Create and add product to store
    private func createProduct() {
        let categoryId = categories.first(where: { $0.name == selectedCategory })?.id ?? UUID()
        let userId = appStore.userStore.users.first?.id ?? UUID()
        
        let product = Product(
            name: selectedCategory.isEmpty ? "New Outfit" : selectedCategory,
            rentPricePerDay: Double(price) ?? 0,
            securityDeposit: 500,
            condition: conditionEnum(selectedCondition),
            size: selectedSize,
            listedByUserId: userId,
            categoryId: categoryId,
            pickupLocation: "Greater Noida",
            imageURLs: selectedImages
        )
        
        appStore.productStore.addItem(product)
    }
}

#Preview {
    NavigationStack {
        UploadView()
            .environment(AppStore())
    }
}
