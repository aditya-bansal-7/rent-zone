import SwiftUI

struct RentalRequestDetailView: View {
    let notification: AppNotification
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
            
            Text(notification.type == .general ? notification.title : "Rental Request")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 20)
                .padding(.bottom, 24)
            
            // Requester profile
            HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray.opacity(0.5))
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(notification.requesterName ?? "Unknown User")
                            .font(.system(size: 17, weight: .bold))
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                    }
                    Text("Verified User")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            // Product info card
            HStack(spacing: 14) {
                if let imageName = notification.productImageName {
                    Group {
                        if imageName.hasPrefix("http"), let url = URL(string: imageName) {
                            AsyncImage(url: url) { phase in
                                if case .success(let image) = phase {
                                    image.resizable().scaledToFill()
                                } else {
                                    Rectangle().fill(Color.gray.opacity(0.2))
                                }
                            }
                        } else {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .frame(width: 70, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(notification.productName ?? "Product")
                        .font(.system(size: 16, weight: .bold))
                    
                    HStack(spacing: 12) {
                        Text("₹ \(Int(notification.totalPrice ?? 0)) total")
                            .font(.system(size: 13, weight: .semibold))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(formattedDate)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(notification.type == .general ? notification.content : "Please confirm availability for these dates.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
            .if26GlassEffect(cornerRadius: 16)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Action buttons
            if notification.type == .rentalRequest {
                HStack(spacing: 16) {
                    Button(action: {
                        appStore.notificationStore.rejectRequest(id: notification.id)
                        dismiss()
                    }) {
                        Text("Reject")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
                            )
                    }
                    
                    Button(action: {
                        appStore.notificationStore.acceptRequest(id: notification.id)
                        dismiss()
                    }) {
                        Text("Accept")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .cornerRadius(30)
                    }
                }
                .padding(.horizontal, 24)
            }
                
                Button(action: {
                    Task {
                        var targetUserId = notification.fromUserId
                        if targetUserId == nil, let productId = notification.productId {
                            do {
                                let product = try await ProductService.shared.getProduct(id: productId)
                                targetUserId = product.listedByUserId
                            } catch {
                                print("Fallback product fetch failed: \(error)")
                            }
                        }
                        
                        if let otherUserId = targetUserId, let productId = notification.productId {
                            do {
                                let conv = try await ChatService.shared.startConversation(otherUserId: otherUserId, productId: productId)
                                await MainActor.run {
                                    appStore.selectedChatConversation = conv
                                    appStore.activeTab = 2 // Switch to Chat tab
                                    dismiss()
                                    NotificationCenter.default.post(name: NSNotification.Name("DismissNotificationCenter"), object: nil)
                                }
                            } catch {
                                print("Error starting chat: \(error)")
                            }
                        } else {
                            print("Cannot start chat: missing fromUserId (\(String(describing: targetUserId))) or productId (\(String(describing: notification.productId)))")
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "message.fill")
                        Text("Chat")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
                .padding(.top, 10)
        }
        .background(.ultraThickMaterial)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: notification.rentalDate ?? notification.createdAt)
    }
}
