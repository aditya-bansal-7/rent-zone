import SwiftUI

struct TryOnResultView: View {
    let product: Product
    let userImage: UIImage
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore
    @State private var isSaved = false
    @State private var isRequestingRent = false
    @State private var showRentConfirmation = false
    @State private var rentError: String? = nil

    private let lavender = Color(red: 220/255, green: 208/255, blue: 255/255)

    var body: some View {
        ZStack {
            Color(white: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                HStack(alignment: .center) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background {
                                Group {
                                    if #available(iOS 26.0, *) {
                                        Color.clear
                                    } else {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                    }
                                }
                            }
                            .if26GlassEffect(cornerRadius: 22)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Try-On Result")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    // Invisible spacer to center title
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // MARK: - Result Image
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Image(uiImage: userImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                        // MARK: - Request to Rent Button
                        Button(action: {
                            Task {
                                await handleRentRequest()
                            }
                        }) {
                            ZStack {
                                if isRequestingRent {
                                    HStack(spacing: 10) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        Text("Sending...")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                } else {
                                    Text("Request to Rent")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background {
                                Group {
                                    if #available(iOS 26.0, *) {
                                        Color.clear
                                    } else {
                                        Capsule()
                                            .fill(lavender)
                                    }
                                }
                            }
                            .if26GlassEffect(cornerRadius: 28)
                            .clipShape(Capsule())
                        }
                        .disabled(isRequestingRent)
                        .padding(.horizontal, 50)

                        // Error message
                        if let rentError {
                            Text(rentError)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }

                        // MARK: - Save & Share Row
                        HStack(spacing: 16) {
                            // Save to Favourites Button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isSaved.toggle()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: isSaved ? "heart.fill" : "heart")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(isSaved ? .red : .black)
                                    Text(isSaved ? "Saved" : "Save")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background {
                                    Group {
                                        if #available(iOS 26.0, *) {
                                            Color.clear
                                        } else {
                                            Capsule()
                                                .fill(Color(.systemGray6))
                                        }
                                    }
                                }
                                .if26GlassEffect(cornerRadius: 25)
                                .clipShape(Capsule())
                            }

                            // Share Button
                            Button(action: {
                                shareResult()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("Share")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background {
                                    Group {
                                        if #available(iOS 26.0, *) {
                                            Color.clear
                                        } else {
                                            Capsule()
                                                .fill(Color(.systemGray6))
                                        }
                                    }
                                }
                                .if26GlassEffect(cornerRadius: 25)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Request Sent! 🎉", isPresented: $showRentConfirmation) {
            Button("OK", role: .cancel) {
                dismiss()
            }
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
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? Date()
            
            let components = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: startDate), to: Calendar.current.startOfDay(for: endDate))
            let days = max(1, components.day ?? 1)
            let totalPrice = Double(days) * product.rentPricePerDay
            
            let rental = try await RentalService.shared.createRental(
                productId: product.id,
                startDate: startDate,
                endDate: endDate,
                totalPrice: totalPrice
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

    private func shareResult() {
        let shareText = "Check out how \(product.name) looks on me! 👗 via RentZone"
        let items: [Any] = [shareText, userImage]

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = []

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            activityVC.popoverPresentationController?.sourceView = topVC.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.maxY - 100, width: 0, height: 0)
            topVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    TryOnResultView(
        product: Product(
            id: "preview",
            name: "Sharara",
            rentPricePerDay: 400,
            securityDeposit: 500,
            condition: .new,
            size: "M",
            listedByUserId: "user1",
            categoryId: "cat1",
            pickupLocation: "Jaipur",
            imageURLs: ["https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&q=80"],
            rating: 4.5
        ),
        userImage: UIImage(systemName: "person.fill")!
    )
    .environment(AppStore())
}
