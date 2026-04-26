import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) private var dismiss
    @State private var showMenu = false
    @State private var currentImageIndex = 0
    @State private var isFavorite = false
    @State private var showRentConfirmation = false
    @State private var showCalendar = false
    @State private var selectedDate: Date? = nil
    @State private var calendarDisplayedMonth = Date()
    @State private var isRequestingRent = false
    @State private var rentError: String? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                ZStack(alignment: .top) {
                    // Image Carousel
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(product.imageURLs.enumerated()), id: \.offset) { index, imageStr in
                                Group {
                                    if imageStr.hasPrefix("http"), let url = URL(string: imageStr) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image.resizable().scaledToFill()
                                            case .failure(_), .empty:
                                                Rectangle().fill(Color(.systemGray4))
                                                    .overlay(ProgressView())
                                            @unknown default:
                                                Rectangle().fill(Color(.systemGray4))
                                            }
                                        }
                                    } else {
                                        Image(imageStr)
                                            .resizable()
                                            .scaledToFill()
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width - 40, height: 450)
                                .clipped()
                                .cornerRadius(20)
                            }
                        }
                        .scrollTargetLayout()
                        .padding(.horizontal, 16)
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .frame(height: 450)

                    HStack(alignment: .top) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        Spacer()

                        if showMenu {
                            HStack(spacing: 24) {
                                Button(action: { isFavorite.toggle() }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundColor(isFavorite ? .red : .black)
                                        Text("Favourite")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.black)
                                    }
                                }

                                Button(action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        showMenu = false
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 22, weight: .medium))
                                        Text("Share")
                                            .font(.system(size: 10, weight: .medium))
                                    }
                                    .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                            .transition(.scale(scale: 0.3, anchor: .topTrailing).combined(with: .opacity))
                        } else {
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    showMenu = true
                                }
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 44, height: 44)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                            }
                            .transition(.scale(scale: 0.3, anchor: .topTrailing).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }

                // Product Info Card
                VStack(alignment: .leading, spacing: 16) {
                    Text(product.name)
                        .font(.system(size: 24, weight: .bold))

                    HStack(alignment: .bottom, spacing: 4) {
                        Text("₹\(Int(product.rentPricePerDay))")
                            .font(.system(size: 28, weight: .bold))
                        Text("/day")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.bottom, 4)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        detailRow(title: "Security Deposit:", value: "₹\(Int(product.securityDeposit))")
                        detailRow(title: "Condition:", value: conditionLabel(product.condition))
                        detailRow(title: "Size:", value: product.size)
                        detailRow(title: "Pickup:", value: product.pickupLocation)
                        if let occasion = product.occasion {
                            detailRow(title: "Occasion:", value: occasion)
                        }
                    }

                    Button(action: {}) {
                        HStack(spacing: 12) {
                            Text("👗")
                                .font(.system(size: 18))
                            Text("Virtual Try On")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 243/255, green: 236/255, blue: 255/255))
                        .cornerRadius(30)
                        .padding(.top, 8)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: -5)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                .offset(y: -40)
                .padding(.bottom, -40)

                // Description Card
                if !product.description.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Description")
                            .font(.system(size: 20, weight: .bold))

                        VStack(alignment: .leading, spacing: 8) {
                            if let fabric = product.description[.fabric] {
                                descriptionRow(title: "Fabric:", value: fabric)
                            }
                            if let brand = product.description[.brand] {
                                descriptionRow(title: "Brand:", value: brand)
                            }
                            if let style = product.description[.style] {
                                descriptionRow(title: "Style:", value: style)
                            }
                            if let fit = product.description[.fitAndComfort] {
                                descriptionRow(title: "Fit & Comfort:", value: fit)
                            }
                        }
                    }
                    .cardStyle()
                    .padding(.top, 10)
                }

                // Availability Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Availability")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                showCalendar.toggle()
                            }
                        }) {
                            Text("Select Date")
                                .font(.system(size: 12, weight: .medium))
                                .underline()
                                .foregroundColor(.gray)
                        }
                    }

                    if showCalendar {
                        CalendarPickerView(
                            selectedDate: $selectedDate,
                            displayedMonth: $calendarDisplayedMonth
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        // Show next 5 days as availability preview
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<7, id: \.self) { offset in
                                    let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
                                    let day = Calendar.current.component(.day, from: date)
                                    let monthStr = date.formatted(.dateTime.month(.abbreviated)).uppercased()
                                    let isBooked = product.bookedDates.contains(where: {
                                        Calendar.current.isDate($0, inSameDayAs: date)
                                    })
                                    VStack(spacing: 6) {
                                        Text("\(day)")
                                            .font(.system(size: 20, weight: .bold))
                                        Text(monthStr)
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                                    )
                                    .overlay(
                                        DiagonalLineShape()
                                            .stroke(Color.black.opacity(0.6), lineWidth: isBooked ? 1 : 0)
                                    )
                                    .opacity(isBooked ? 0.35 : 1.0)
                                }
                            }
                        }
                    }
                }
                .cardStyle()
                .padding(.top, 10)

                // Seller Card
                HStack(spacing: 14) {
                    if let profileImg = product.listedBy?.profileImage, let url = URL(string: profileImg) {
                        AsyncImage(url: url) { phase in
                            if case .success(let image) = phase {
                                image.resizable().scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.gray.opacity(0.5))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(product.listedBy?.name ?? "Owner")
                                .font(.system(size: 16, weight: .bold))
                            if product.listedBy?.isVerified == true {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 14))
                            }
                        }
                        Text(product.listedBy?.location ?? "India")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text(product.rating.formatted(.number.precision(.fractionLength(1))))
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                    }
                }
                .cardStyle()
                .padding(.top, 10)

                // Request to Rent
                if let rentError {
                    Text(rentError)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }

                Button(action: { Task { await handleRentRequest() } }) {
                    ZStack {
                        if isRequestingRent {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text("Request to Rent")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(red: 243/255, green: 236/255, blue: 255/255))
                    .cornerRadius(30)
                }
                .disabled(isRequestingRent)
                .padding(.horizontal, 20)
                .padding(.top, 24)

                // Reviews Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Reviews")
                            .font(.system(size: 20, weight: .bold))

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                            Text(product.rating.formatted(.number.precision(.fractionLength(1))))
                                .font(.system(size: 14, weight: .bold))
                        }

                        Spacer()

                        Text("\(product.reviews.count) Reviews")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    if product.reviews.isEmpty {
                        Text("No reviews yet. Be the first to rent!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(product.reviews.prefix(3)) { review in
                            ReviewItemView(
                                name: review.userName ?? "User",
                                rating: review.rating,
                                text: review.content,
                                profileImage: review.userImage
                            )
                        }
                    }
                }
                .cardStyle()
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .background(Color(white: 0.98).edgesIgnoringSafeArea(.all))
        .alert("Request Sent! 🎉", isPresented: $showRentConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your rental request for \(product.name) has been sent to the owner.")
        }
    }

    // MARK: - Actions

    private func handleRentRequest() async {
        guard appStore.userStore.currentUser != nil else {
            rentError = "Please sign in to request a rental"
            return
        }
        isRequestingRent = true
        rentError = nil
        do {
            let startDate = selectedDate ?? Date()
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? Date()
            let rental = try await RentalService.shared.createRental(
                productId: product.id,
                startDate: startDate,
                endDate: endDate
            )
            appStore.rentalStore.addItem(rental)
            await MainActor.run {
                self.isRequestingRent = false
                self.showRentConfirmation = true
            }
        } catch {
            await MainActor.run {
                self.isRequestingRent = false
                self.rentError = error.localizedDescription
            }
        }
    }

    // MARK: - Helpers

    private func conditionLabel(_ cond: ProductCondition) -> String {
        switch cond {
        case .new: return "New"
        case .likeNew: return "Like New"
        case .good: return "Good"
        case .worn: return "Worn"
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
            Text(value)
                .font(.system(size: 14, weight: .bold))
        }
    }

    private func descriptionRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
            Text(value)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black.opacity(0.8))
        }
    }
}

// MARK: - Card Style Extension
extension View {
    func if26GlassEffect(cornerRadius: CGFloat = 20) -> some View {
        Group {
            if #available(iOS 26.0, *) {
                self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            } else {
                self
                    .cornerRadius(cornerRadius)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
            }
        }
    }

    func cardStyle() -> some View {
        self
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
    }
}

// MARK: - Diagonal Line
struct DiagonalLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

// MARK: - Review Item View
struct ReviewItemView: View {
    let name: String
    let rating: Int
    let text: String
    var profileImage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if let img = profileImage, let url = URL(string: img) {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image.resizable().scaledToFill()
                        } else {
                            Circle().fill(Color(.systemGray4))
                        }
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.gray)
                }

                Text(name)
                    .font(.system(size: 14, weight: .bold))

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 10))
                    Text("\(rating)")
                        .font(.system(size: 12, weight: .bold))
                }
            }

            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.black.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 4)
        }
    }
}

#Preview {
    ProductDetailView(product: Product(
        id: "preview",
        name: "Sharara",
        rentPricePerDay: 400,
        securityDeposit: 500,
        condition: .new,
        size: "M",
        description: [
            .fabric: "Silk blend With Embroidery",
            .brand: "Biba Inspired",
            .style: "Festive Ethnic",
            .fitAndComfort: "Elegant look with Comfortable Wear"
        ],
        listedByUserId: "user1",
        categoryId: "cat1",
        pickupLocation: "Jaipur",
        imageURLs: ["https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&q=80"],
        rating: 4.5
    ))
    .environment(AppStore())
}
