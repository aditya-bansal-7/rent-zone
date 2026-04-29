import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) private var dismiss
    @State private var showMenu = false
    @State private var currentImageIndex: Int? = 0
    @State private var isFavorite = false
    @State private var showRentConfirmation = false
    @State private var showCalendar = false
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    @State private var calendarDisplayedMonth = Date()
    @State private var isRequestingRent = false
    @State private var rentError: String? = nil

    @State private var showAddReview = false
    @State private var localReviews: [Review] = []
    @State private var didInitReviews = false

    @State private var showVirtualTryOn = false
    @State private var showSellerProfile = false


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
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .padding(.bottom, 16)
                        }
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
                                    shareProduct()
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
                            .background {
                                Group {
                                    if #available(iOS 26.0, *) {
                                        Color.clear
                                    } else {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial)
                                    }
                                }
                            }
                            .if26GlassEffect(cornerRadius: 16)
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

                    Button(action: { showVirtualTryOn = true }) {
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
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Availability")
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            
                            if startDate != nil {
                                Button(action: {
                                    withAnimation {
                                        startDate = nil
                                        endDate = nil
                                    }
                                }) {
                                    Text("Clear")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.red.opacity(0.8))
                                }
                                .padding(.trailing, 8)
                            }

                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    showCalendar.toggle()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: showCalendar ? "list.bullet" : "calendar")
                                    Text(showCalendar ? "Show Chips" : "Calendar")
                                }
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black)
                            }
                        }
                        
                        Text(selectionInstruction)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    if showCalendar {
                        CalendarPickerView(
                            startDate: $startDate,
                            endDate: $endDate,
                            displayedMonth: $calendarDisplayedMonth,
                            bookedDates: product.bookedDates
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        // Show chips whenever calendar is closed
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<14, id: \.self) { offset in
                                    let date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: offset, to: Date())!)
                                    let day = Calendar.current.component(.day, from: date)
                                    let monthStr = date.formatted(.dateTime.month(.abbreviated)).uppercased()
                                    
                                    let isBooked = product.bookedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                                    let isSelected = (startDate != nil && Calendar.current.isDate(startDate!, inSameDayAs: date)) || (endDate != nil && Calendar.current.isDate(endDate!, inSameDayAs: date))
                                    let inRange = startDate != nil && endDate != nil && date > startDate! && date < endDate!
                                    
                                    Button(action: { handleDateSelection(date) }) {
                                        VStack(spacing: 4) {
                                            Text("\(day)")
                                                .font(.system(size: 22, weight: .bold))
                                            Text(monthStr)
                                                .font(.system(size: 10, weight: .bold))
                                        }
                                        .foregroundColor(.black)
                                        .frame(width: 55, height: 65)
                                        .background(isSelected ? Color(red: 230/255, green: 210/255, blue: 255/255) : (inRange ? Color(red: 243/255, green: 236/255, blue: 255/255) : Color.white))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black, lineWidth: 1.5)
                                        )
                                        .overlay(
                                            DiagonalLineShape()
                                                .stroke(Color.black, lineWidth: isBooked ? 1.5 : 0)
                                        )
                                        .opacity(isBooked ? 0.4 : 1.0)
                                    }
                                    .disabled(isBooked)
                                }
                            }
                            .padding(.horizontal, 2)
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // Guided date display & Cost Breakdown
                    if let start = startDate {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 20) {
                                dateBlock(title: "PICKUP", date: start, icon: "shippingbox.fill")
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .font(.system(size: 20, weight: .bold))
                                
                                if let end = endDate {
                                    dateBlock(title: "RETURN", date: end, icon: "arrow.uturn.backward.circle.fill")
                                } else {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("RETURN")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.gray)
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                            .frame(width: 80, height: 45)
                                            .overlay(
                                                Text("Select")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.gray.opacity(0.5))
                                            )
                                    }
                                }
                            }
                            
                            if let end = endDate {
                                let days = Int(end.timeIntervalSince(start) / 86400) + 1
                                costBreakdownView(days: days)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.top, 8)
                        .transition(.asymmetric(insertion: .push(from: .bottom), removal: .opacity))
                    }
                }
                .cardStyle()
                .padding(.top, 10)

                // Seller Card
                Button(action: { showSellerProfile = true }) {
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
                }
                .buttonStyle(.plain)
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
                            Text(rentButtonText)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(startDate != nil && endDate != nil ? Color(red: 243/255, green: 236/255, blue: 255/255) : Color.gray.opacity(0.1))
                    .cornerRadius(30)
                }
                .disabled(isRequestingRent || startDate == nil || endDate == nil)
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

                        Text("\(displayReviews.count) Reviews")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    // Add Review Button
                    Button(action: { showAddReview = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 16, weight: .medium))
                            Text("Write a Review")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.black)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(red: 243/255, green: 236/255, blue: 255/255))
                        )
                    }

                    if displayReviews.isEmpty {
                        Text("No reviews yet. Be the first to review!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(displayReviews.prefix(3)) { review in
                            ReviewItemView(
                                name: review.userName ?? "User",
                                rating: review.rating,
                                text: review.content,
                                profileImage: review.userImage,
                                reviewImages: review.imageURLs
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
        .onAppear {
            if !didInitReviews {
                localReviews = product.reviews
                didInitReviews = true
            }
        }
        .sheet(isPresented: $showAddReview) {
            AddReviewView(product: product) { newReview in
                localReviews.insert(newReview, at: 0)
            }
            .environment(appStore)
        }
        .alert("Request Sent! 🎉", isPresented: $showRentConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your rental request for \(product.name) has been sent to the owner.")
        }
        .fullScreenCover(isPresented: $showVirtualTryOn) {
            VirtualTryOnView(product: product)
        }
        .sheet(isPresented: $showSellerProfile) {
            if let listedBy = product.listedBy {
                NavigationStack {
                    OtherUserProfileView(
                        user: User(
                            id: listedBy.id,
                            name: listedBy.name,
                            location: listedBy.location ?? "India",
                            isVerified: listedBy.isVerified ?? false,
                            profileImage: listedBy.profileImage
                        ),
                        userId: listedBy.id
                    )
                    .environment(appStore)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { showSellerProfile = false }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .frame(width: 30, height: 30)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Computed

    private var selectionInstruction: String {
        if startDate == nil {
            return "Step 1: Select your pickup date"
        } else if endDate == nil {
            return "Step 2: Select your return date"
        } else {
            return "Review your rental duration"
        }
    }

    private var displayReviews: [Review] {
        didInitReviews ? localReviews : product.reviews
    }

    private var rentButtonText: String {
        if let start = startDate, let end = endDate {
            let days = Int(end.timeIntervalSince(start) / 86400) + 1
            let total = Int(product.rentPricePerDay) * days + Int(product.securityDeposit)
            return "Request to Rent • ₹\(total)"
        }
        return startDate == nil ? "Select Dates" : "Select End Date"
    }

    // MARK: - Actions

    private func shareProduct() {
        let shareText = "Check out \(product.name) on RentZone! ₹\(Int(product.rentPricePerDay))/day"
        var items: [Any] = [shareText]
        if let firstImage = product.imageURLs.first, let url = URL(string: firstImage) {
            items.append(url)
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = [] // Show all available share options

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            // Find the topmost presented view controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            activityVC.popoverPresentationController?.sourceView = topVC.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: topVC.view.bounds.midX, y: 0, width: 0, height: 0)
            topVC.present(activityVC, animated: true)
        }
    }

    private func handleDateSelection(_ date: Date) {
        let calendar = Calendar.current
        if startDate == nil || (startDate != nil && endDate != nil) {
            startDate = date
            endDate = nil
        } else if let start = startDate {
            if date < start {
                startDate = date
                endDate = nil
            } else if calendar.isDate(date, inSameDayAs: start) {
                // Allow 1-day rental if clicking start date again
                endDate = date
            } else {
                // Check if any booked dates are in between
                let hasBookedInRange = product.bookedDates.contains { bookedDate in
                    bookedDate > start && bookedDate < date
                }
                if !hasBookedInRange {
                    endDate = date
                } else {
                    startDate = date
                    endDate = nil
                }
            }
        }
    }

    private func handleRentRequest() async {
        guard let start = startDate, let end = endDate else {
            rentError = "Please select rental dates"
            return
        }
        
        guard appStore.userStore.currentUser != nil else {
            rentError = "Please sign in to request a rental"
            return
        }
        
        isRequestingRent = true
        rentError = nil
        do {
            let days = max(1, Int(end.timeIntervalSince(start) / 86400) + 1)
            let rental = try await RentalService.shared.createRental(
                productId: product.id,
                startDate: start,
                endDate: end,
                totalPrice: product.rentPricePerDay * Double(days)
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

    private func dateBlock(title: String, date: Date, icon: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                }
                Text(title)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                let day = Calendar.current.component(.day, from: date)
                let monthStr = date.formatted(.dateTime.month(.abbreviated)).uppercased()
                
                Text("\(day)")
                    .font(.system(size: 20, weight: .bold))
                Text(monthStr)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
        }
    }

    private func costBreakdownView(days: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Duration:")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(days) days")
                    .font(.system(size: 14, weight: .bold))
            }
            
            HStack {
                Text("Rental Price (₹\(Int(product.rentPricePerDay)) x \(days)):")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Text("₹\(Int(product.rentPricePerDay) * days)")
                    .font(.system(size: 14, weight: .bold))
            }
            
            HStack {
                Text("Security Deposit (Refundable):")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Text("₹\(Int(product.securityDeposit))")
                    .font(.system(size: 14, weight: .bold))
            }
            
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                Text("Total to Pay:")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("₹\(Int(product.rentPricePerDay) * days + Int(product.securityDeposit))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
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
    var reviewImages: [String] = []

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

                Spacer()

                HStack(spacing: 2) {
                    ForEach(0..<rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 10))
                    }
                    ForEach(0..<(5 - rating), id: \.self) { _ in
                        Image(systemName: "star")
                            .foregroundColor(Color(.systemGray3))
                            .font(.system(size: 10))
                    }
                }
            }

            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.black.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            // Review Images
            if !reviewImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(reviewImages, id: \.self) { imageStr in
                            if let url = URL(string: imageStr) {
                                AsyncImage(url: url) { phase in
                                    if case .success(let image) = phase {
                                        image.resizable().scaledToFill()
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray5))
                                            .overlay(ProgressView())
                                    }
                                }
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.bottom, 4)
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
