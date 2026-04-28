import SwiftUI

struct UploadView: View {

    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) var dismiss

    // Passed in from UploadViewCamera
    @State var selectedImages: [UIImage] = []

    var categories: [Category] {
        appStore.categoryStore.categories
    }

    @State private var name = ""
    @State private var selectedCategoryId = ""
    @State private var selectedCondition = "good"
    @State private var selectedSize = "M"
    @State private var price = ""
    @State private var securityDeposit = ""
    @State private var pickupLocation = ""
    @State private var selectedOccasion = ""
    @State private var fabricDescription = ""
    @State private var brandDescription = ""
    @State private var styleDescription = ""
    @State private var fitDescription = ""

    @State private var isUploading = false
    @State private var uploadError: String? = nil
    @State private var uploadSuccess = false
    @State private var uploadedProduct: Product? = nil
    @State private var showLoginSheet = false
    @State private var navigateToListing = false

    let conditions = [("new", "New"), ("likeNew", "Like New"), ("good", "Good"), ("worn", "Worn")]
    let sizes = ["XS", "S", "M", "L", "XL"]
    let occasions = ["Wedding", "Party", "Festival", "Casual", "Formal"]

    var body: some View {
        Form {
            // MARK: - Basic Info
            Section("Basic Info") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Product Name")
                        .font(.subheadline).foregroundStyle(.secondary)
                    TextField("e.g. Elegant Silk Saree", text: $name)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Picker("Category", selection: $selectedCategoryId) {
                        Text("Select a category").tag("")
                        ForEach(categories, id: \.id) { cat in
                            Text("\(cat.type == .women ? "👗" : "👔") \(cat.name)").tag(cat.id)
                        }
                    }
                    .pickerStyle(.menu)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Condition")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Picker("Condition", selection: $selectedCondition) {
                        ForEach(conditions, id: \.0) { cond in
                            Text(cond.1).tag(cond.0)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Size")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Picker("Size", selection: $selectedSize) {
                        ForEach(sizes, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Occasion")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Picker("Occasion", selection: $selectedOccasion) {
                        Text("None").tag("")
                        ForEach(occasions, id: \.self) { occ in
                            Text(occ).tag(occ)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            // MARK: - Pricing
            Section("Pricing") {
                HStack {
                    Text("₹")
                    TextField("Rent per day", text: $price)
                        .keyboardType(.numberPad)
                }

                HStack {
                    Text("₹")
                    TextField("Security deposit", text: $securityDeposit)
                        .keyboardType(.numberPad)
                }
            }

            // MARK: - Location
            Section("Pickup Location") {
                TextField("e.g. Andheri West, Mumbai", text: $pickupLocation)
            }

            // MARK: - Description
            Section("Outfit Details (optional)") {
                TextField("Fabric (e.g. Pure Silk)", text: $fabricDescription)
                TextField("Brand / Style inspiration", text: $brandDescription)
                TextField("Style (e.g. Festive Ethnic)", text: $styleDescription)
                TextField("Fit & Comfort notes", text: $fitDescription)
            }

            // MARK: - Selected Photos preview
            if !selectedImages.isEmpty {
                Section("Photos (\(selectedImages.count) selected)") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(selectedImages.indices, id: \.self) { idx in
                                Image(uiImage: selectedImages[idx])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            // MARK: - Error/Success
            if let error = uploadError {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }

            // MARK: - Submit
            Section {
                Button {
                    guard appStore.userStore.currentUser != nil else {
                        showLoginSheet = true
                        return
                    }
                    Task { await uploadProduct() }
                } label: {
                    HStack {
                        Spacer()
                        if isUploading {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                Text("Uploading Outfit...")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.black)
                            }
                        } else {
                            Text("List My Outfit")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.black)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(Color.purple.opacity(0.15))
                    .cornerRadius(30)
                }
                .disabled(isUploading || name.isEmpty || selectedCategoryId.isEmpty || price.isEmpty)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Provide Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
                .presentationDetents([.fraction(0.85), .large])
        }
        .navigationDestination(isPresented: $navigateToListing) {
            ListingInfoView()
        }
        .alert("Outfit Listed! 🎉", isPresented: $uploadSuccess) {
            Button("View My Listings") { navigateToListing = true }
            Button("Done") { dismiss() }
        } message: {
            Text("Your outfit has been successfully uploaded to Cloudinary and listed on Rent Zone.")
        }
    }

    // MARK: - Upload Flow

    private func uploadProduct() async {
        guard let priceVal = Double(price) else {
            uploadError = "Please enter a valid price"
            return
        }
        isUploading = true
        uploadError = nil

        do {
            // Step 1: Create product record
            var description: [String: String] = [:]
            if !fabricDescription.isEmpty { description["fabric"] = fabricDescription }
            if !brandDescription.isEmpty { description["brand"] = brandDescription }
            if !styleDescription.isEmpty { description["style"] = styleDescription }
            if !fitDescription.isEmpty { description["fitAndComfort"] = fitDescription }

            let product = try await ProductService.shared.createProduct(
                name: name,
                rentPricePerDay: priceVal,
                securityDeposit: Double(securityDeposit) ?? 500,
                condition: selectedCondition,
                size: selectedSize,
                categoryId: selectedCategoryId,
                pickupLocation: pickupLocation.isEmpty ? (appStore.userStore.currentUser?.location ?? "India") : pickupLocation,
                occasion: selectedOccasion.isEmpty ? nil : selectedOccasion,
                description: description
            )

            // Step 2: Upload images to Cloudinary via backend
            if !selectedImages.isEmpty {
                let updatedProduct = try await ProductService.shared.uploadImages(
                    productId: product.id,
                    images: selectedImages
                )
                appStore.productStore.addItem(updatedProduct)
                uploadedProduct = updatedProduct
            } else {
                appStore.productStore.addItem(product)
                uploadedProduct = product
            }

            await MainActor.run {
                self.isUploading = false
                self.uploadSuccess = true
                self.clearForm()
            }
        } catch {
            await MainActor.run {
                self.isUploading = false
                self.uploadError = error.localizedDescription
            }
        }
    }

    private func clearForm() {
        name = ""
        selectedCategoryId = ""
        selectedCondition = "good"
        selectedSize = "M"
        price = ""
        securityDeposit = ""
        pickupLocation = ""
        selectedOccasion = ""
        fabricDescription = ""
        brandDescription = ""
        styleDescription = ""
        fitDescription = ""
        selectedImages = []
    }
}

#Preview {
    NavigationStack {
        UploadView()
            .environment(AppStore())
    }
}
