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
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
             
                ZStack(alignment: .top) {
                    // Image Carousel with next image peek
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(product.imageURLs.enumerated()), id: \.offset) { index, imageName in
                                Image(imageName)
                                    .resizable()
                                    .scaledToFill()
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
                        Button(action: {
                            dismiss()
                        }) {
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
                                Button(action: {
                                    isFavorite.toggle()
                                }) {
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
                        detailRow(title: "Condition:", value: product.condition.rawValue.capitalized)
                        detailRow(title: "Size:", value: product.size == "Medium" || product.size == "M" ? "Medium" : product.size)
                    }
                    
                    Button(action: {}) {
                        HStack(spacing: 12) {
                            Text("👗")
                                .font(.system(size: 18))
                            Text("Try on")
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
                        if let fitAndComfort = product.description[.fitAndComfort] {
                            descriptionRow(title: "Fit & Comfort:", value: fitAndComfort)
                        }
                    }
                }
                .cardStyle()
                .padding(.top, 10)

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
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(24...28, id: \.self) { day in
                                    let isCrossed = (day == 26 || day == 27)
                                    VStack(spacing: 6) {
                                        Text("\(day)")
                                            .font(.system(size: 20, weight: .bold))
                                        Text("DEC")
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
                                            .stroke(Color.black.opacity(0.6), lineWidth: isCrossed ? 1 : 0)
                                    )
                                    .opacity(isCrossed ? 0.35 : 1.0)
                                }
                            }
                        }
                    }
                }
                .cardStyle()
                .padding(.top, 10)

                // Profile Card
                HStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Shreya Singh")
                                .font(.system(size: 16, weight: .bold))
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                        }
                        Text("Verified User")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("4.5")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                    }
                }
                .cardStyle()
                .padding(.top, 10)
           
                // Request to Rent Button
                Button(action: {
                    appStore.notificationStore.sendRentalRequest(
                        product: product,
                        fromUserName: appStore.userStore.users.first?.name ?? "A User"
                    )
                    showRentConfirmation = true
                }) {
                    Text("Request to Rent")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 243/255, green: 236/255, blue: 255/255))
                        .cornerRadius(30)
                }
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
                            Text("4.5")
                                .font(.system(size: 14, weight: .bold))
                        }
                        
                        Spacer()
                        
                        Text("20 Reviews")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    ReviewItemView(
                        name: "Shreya Singh",
                        rating: 5,
                        text: "Rented for Trip to Jaipur. It looks awsm on me 💕"
                    )
                    
                    ReviewItemView(
                        name: "Kirtika Kandari",
                        rating: 4,
                        text: "Rented for my clg fest performance such a savior at last moment"
                    )
                }
                .cardStyle()
                .padding(.top, 24)
                .padding(.bottom, 40)
                
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .background(Color(white: 0.98).edgesIgnoringSafeArea(.all))
        .alert("Request Sent!", isPresented: $showRentConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your rental request for \(product.name) has been sent to the owner.")
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

// Consistent card styling modifier
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

struct DiagonalLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

struct ReviewItemView: View {
    let name: String
    let rating: Int
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(name)
                    .font(.system(size: 14, weight: .bold))
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 10))
                Text("\(rating)")
                    .font(.system(size: 12, weight: .bold))
            }
            
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.black.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 4)
            
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 48, height: 48)
                        .cornerRadius(6)
                }
            }
        }
    }
}

#Preview {
    ProductDetailView(product: Product(
        name: "Sharara",
        rentPricePerDay: 400,
        securityDeposit: 500,
        condition: .new,
        size: "Medium",
        description: [
            .fabric: "Silk blend With Embroidery",
            .brand: "Biba Inspired",
            .style: "Festive Ethnic",
            .fitAndComfort: "Elegant look with Comfortable Wear"
        ],
        listedByUserId: UUID(),
        categoryId: UUID(),
        pickupLocation: "Jaipur",
        imageURLs: ["sharara_orange", "sharara"],
        rating: 4.5,
        isPopular: true
    ))
}
