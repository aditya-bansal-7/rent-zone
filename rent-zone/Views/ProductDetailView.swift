import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
             
                ZStack(alignment: .top) {
                    let images = product.imageURLs.isEmpty ? ["sharara_orange", "sharara_orange", "sharara_orange"] : product.imageURLs
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: UIScreen.main.bounds.width * 0.025) {
                            ForEach(Array(images.enumerated()), id: \.offset) { index, imageUrl in
                                Image(imageUrl)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width * 0.85, height: 450)
                                    .cornerRadius(20)
                                    .clipped()
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, UIScreen.main.bounds.width * 0.075)
        
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.85))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.85))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            
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
                .offset(y: -40)
                .padding(.bottom, -40)
                

                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Availability")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Text("Select Date")
                            .font(.system(size: 12, weight: .medium))
                            .underline()
                            .foregroundColor(.gray)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
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
                                        .stroke(Color.black.opacity(0.8), lineWidth: 1)
                                )
                                .overlay(
                                    DiagonalLineShape()
                                        .stroke(Color.black.opacity(0.8), lineWidth: isCrossed ? 1 : 0)
                                )
                                .opacity(isCrossed ? 0.3 : 1.0)
                            }
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                .padding(.top, 10)
           
                Button(action: {}) {
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
                
       
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Reviews")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                            Text("4.5")
                                .font(.system(size: 14, weight: .bold))
                        }
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
                .padding(24)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
                
            }
        }
        .navigationBarHidden(true)
        .background(Color(white: 0.98).edgesIgnoringSafeArea(.all))
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
            Text(value)
                .font(.system(size: 14, weight: .bold))
        }
    }
    
    // Safely gets the top padding offset inside an ignored safe area scroll container
    private func safeAreaTop() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.safeAreaInsets.top ?? 47
        }
        return 47
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
        name: "Rajisthani Poshak",
        rentPricePerDay: 520,
        securityDeposit: 500,
        condition: .new,
        size: "Medium",
        listedByUserId: UUID(),
        categoryId: UUID(),
        pickupLocation: "Jaipur",
        imageURLs: [],
        rating: 4.5,
        isPopular: true
    ))
}
