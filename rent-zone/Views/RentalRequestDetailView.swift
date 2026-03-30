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
            
            Text("Rental Request")
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
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
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
                    
                    Text("Please confirm availability for these dates.")
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
            .padding(.bottom, 36)
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
