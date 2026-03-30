import SwiftUI

struct NotificationCardView: View {
    let notification: AppNotification
    var onViewRequest: () -> Void = {}
    
    private var relativeTime: String {
        let interval = Date().timeIntervalSince(notification.createdAt)
        let hours = Int(interval / 3600)
        if hours < 1 { return "Just now" }
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        if days == 1 { return "Yesterday" }
        return "\(days)d ago"
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: notification.rentalDate ?? notification.createdAt)
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(alignment: .top, spacing: 12) {
                // Product thumbnail
                if let imageName = notification.productImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 72)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(notification.content)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Text(formattedDate)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        switch notification.status {
                        case .pending:
                            Button(action: onViewRequest) {
                                Text("View Request")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.primary.opacity(0.5), lineWidth: 1)
                                    )
                            }
                        case .rejected:
                            Text("Rejected")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.red)
                        case .accepted:
                            Text("Accepted")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Text(relativeTime)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(.regularMaterial)
        .if26GlassEffect(cornerRadius: 16)
        .opacity(notification.status == .rejected ? 0.6 : 1.0)
    }
}
