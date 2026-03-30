import SwiftUI
import MapKit

struct ProductDetailEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) var appStore
    
    let product: Product
    
    @State private var selectedCategory: String
    @State private var selectedCondition: ProductCondition
    @State private var selectedSize: String
    @State private var pricePerDay: String
    @State private var descriptionText: String
    @State private var pickupLocation: String
    @State private var imageURLs: [String]
    
    // Map camera position for pickup location
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 28.4744, longitude: 77.5040),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    
    init(product: Product) {
        self.product = product
        _selectedCategory = State(initialValue: "Lehenga")
        _selectedCondition = State(initialValue: product.condition)
        _selectedSize = State(initialValue: product.size)
        _pricePerDay = State(initialValue: "\(Int(product.rentPricePerDay))")
        _descriptionText = State(initialValue: "Rust-orange embroidered ethnic outfit available for rent.")
        _pickupLocation = State(initialValue: product.pickupLocation)
        _imageURLs = State(initialValue: product.imageURLs)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Photo Grid
                    photoGrid
                    
                    // MARK: - Category
                    dropdownField(
                        title: "Category",
                        icon: "figure.stand",
                        value: selectedCategory
                    )
                    
                    // MARK: - Condition
                    dropdownField(
                        title: "Condition",
                        icon: "star.fill",
                        value: selectedCondition.rawValue.capitalized
                    )
                    
                    // MARK: - Size
                    dropdownField(
                        title: "Size",
                        icon: "figure.stand",
                        value: sizeDisplayName(selectedSize)
                    )
                    
                    // MARK: - Price
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Text("₹")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            
                            TextField("0", text: $pricePerDay)
                                .font(.system(size: 16))
                                .keyboardType(.numberPad)
                            
                            Text("/day")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                    
                    // MARK: - Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $descriptionText)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .frame(minHeight: 100)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    // MARK: - Pick-Up Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pick-Up Location")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Map(position: $mapPosition) {
                            Marker(
                                "Payal Singh (You)",
                                systemImage: "car.fill",
                                coordinate: CLLocationCoordinate2D(latitude: 28.4744, longitude: 77.5040)
                            )
                            .tint(.red)
                        }
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            VStack {
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: "car.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.green)
                                            .padding(4)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                        
                                        Text("Payal Singh (You)")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    )
                                    Spacer()
                                }
                                .padding(12)
                                Spacer()
                            }
                        )
                    }
                    
                    // MARK: - Update Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Update")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.purple.opacity(0.15))
                            )
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Update Details")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    // MARK: - Photo Grid
    private var photoGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
        
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(imageURLs, id: \.self) { imageURL in
                Image(imageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                    )
            }
            
            // Add photo button
            Button(action: {}) {
                VStack(spacing: 6) {
                    Image(systemName: "camera")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary)
                    Text("Add")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .foregroundColor(Color(.systemGray3))
                )
            }
        }
    }
    
    // MARK: - Dropdown Field
    private func dropdownField(title: String, icon: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    private func sizeDisplayName(_ size: String) -> String {
        switch size {
        case "XS": return "Extra Small"
        case "S": return "Small"
        case "M": return "Medium"
        case "L": return "Large"
        case "XL": return "Extra Large"
        default: return size
        }
    }
}

#Preview {
    ProductDetailEditView(
        product: Product(
            name: "Sharara",
            rentPricePerDay: 300,
            securityDeposit: 800,
            condition: .new,
            size: "L",
            listedByUserId: UUID(),
            categoryId: UUID(),
            pickupLocation: "Greater Noida",
            imageURLs: ["sharara", "sharara_orange"]
        )
    )
    .environment(AppStore())
}
