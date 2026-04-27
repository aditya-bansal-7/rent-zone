import SwiftUI
import MapKit

struct ProductDetailEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) var appStore
    
    let product: Product
    
    @State private var name: String
    @State private var selectedCondition: ProductCondition
    @State private var selectedSize: String
    @State private var pricePerDay: String
    @State private var pickupLocation: String
    
    // Description fields
    @State private var fabricDescription: String
    @State private var brandDescription: String
    @State private var styleDescription: String
    @State private var fitDescription: String
    
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Map camera position for pickup location
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 28.4744, longitude: 77.5040),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    
    init(product: Product) {
        self.product = product
        _name = State(initialValue: product.name)
        _selectedCondition = State(initialValue: product.condition)
        _selectedSize = State(initialValue: product.size)
        _pricePerDay = State(initialValue: "\(Int(product.rentPricePerDay))")
        _pickupLocation = State(initialValue: product.pickupLocation)
        
        // Map dictionary to separate fields
        _fabricDescription = State(initialValue: product.description[.fabric] ?? "")
        _brandDescription = State(initialValue: product.description[.brand] ?? "")
        _styleDescription = State(initialValue: product.description[.style] ?? "")
        _fitDescription = State(initialValue: product.description[.fitAndComfort] ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: - Photo Grid
                        photoGrid
                        
                        // MARK: - Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Product Name")
                                .font(.system(size: 18, weight: .bold))
                            TextField("Name", text: $name)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // MARK: - Condition & Size
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Condition")
                                    .font(.system(size: 16, weight: .bold))
                                Picker("Condition", selection: $selectedCondition) {
                                    ForEach(ProductCondition.allCases, id: \.self) { condition in
                                        Text(condition.rawValue.capitalized).tag(condition)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Size")
                                    .font(.system(size: 16, weight: .bold))
                                Picker("Size", selection: $selectedSize) {
                                    ForEach(["XS", "S", "M", "L", "XL", "XXL"], id: \.self) { size in
                                        Text(size).tag(size)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        
                        // MARK: - Price
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Price")
                                .font(.system(size: 18, weight: .bold))
                            
                            HStack(spacing: 8) {
                                Text("₹")
                                    .foregroundColor(.secondary)
                                TextField("0", text: $pricePerDay)
                                    .keyboardType(.numberPad)
                                Text("/day")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // MARK: - Descriptions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Outfit Details")
                                .font(.system(size: 18, weight: .bold))
                            
                            descriptionField(title: "Fabric", text: $fabricDescription)
                            descriptionField(title: "Brand", text: $brandDescription)
                            descriptionField(title: "Style", text: $styleDescription)
                            descriptionField(title: "Fit & Comfort", text: $fitDescription)
                        }
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // MARK: - Update Button
                        Button(action: handleUpdate) {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Update Product")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                
                if isLoading {
                    Color.black.opacity(0.1).ignoresSafeArea()
                }
            }
            .navigationTitle("Edit Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: handleDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private func descriptionField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            TextField(title, text: text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
    
    private var photoGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(product.imageURLs, id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private func handleUpdate() {
        guard let price = Double(pricePerDay) else {
            errorMessage = "Invalid price"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        var description: [String: String] = [:]
        if !fabricDescription.isEmpty { description["fabric"] = fabricDescription }
        if !brandDescription.isEmpty { description["brand"] = brandDescription }
        if !styleDescription.isEmpty { description["style"] = styleDescription }
        if !fitDescription.isEmpty { description["fitAndComfort"] = fitDescription }
        
        let body: [String: Any] = [
            "name": name,
            "condition": selectedCondition.rawValue,
            "size": selectedSize,
            "rentPricePerDay": price,
            "description": description
        ]
        
        Task {
            do {
                let updated = try await ProductService.shared.updateProduct(id: product.id, body: body)
                await MainActor.run {
                    appStore.productStore.updateItem(updated)
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleDelete() {
        isLoading = true
        Task {
            do {
                try await ProductService.shared.deleteProduct(id: product.id)
                await MainActor.run {
                    appStore.productStore.removeItem(id: product.id)
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
