import SwiftUI

struct NotificationCentreView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var selectedNotification: AppNotification?
    
    private var displayedNotifications: [AppNotification] {
        if selectedTab == 0 {
            return appStore.notificationStore.notifications
        } else {
            return appStore.notificationStore.unreadNotifications
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            // MARK: - Segmented Control (Native iOS style like Categories)
            Picker("Filter", selection: $selectedTab) {
                Text("All").tag(0)
                Text("Unread").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // MARK: - Notification List
            if displayedNotifications.isEmpty {
                Spacer()
                VStack(spacing: 14) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 44, weight: .light))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text(selectedTab == 0 ? "No notifications yet" : "All caught up!")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(selectedTab == 0 ? "You'll be notified about rental requests here." : "You have no unread notifications.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(displayedNotifications) { notification in
                            NotificationRowView(
                                notification: notification,
                                onTap: {
                                    appStore.notificationStore.markRead(id: notification.id)
                                    selectedNotification = notification
                                }
                            )
                            
                            // Subtle divider
                            if notification.id != displayedNotifications.last?.id {
                                Divider()
                                    .padding(.leading, 94) // 20 padding + 60 image + 14 spacing (image width unchanged)
                            }
                        }
                    }
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            appStore.notificationStore.markAllRead()
        }
        .sheet(item: $selectedNotification) { notification in
            RentalRequestDetailView(notification: notification)
                .environment(appStore)
        }
    }
    

}

// MARK: - Notification Row View
struct NotificationRowView: View {
    let notification: AppNotification
    var onTap: () -> Void = {}
    
    private var relativeTime: String {
        let interval = Date().timeIntervalSince(notification.createdAt)
        if interval < 60 { return "Just now" }
        let minutes = Int(interval / 60)
        if minutes < 60 { return "\(minutes) min ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours) hours ago" }
        let days = hours / 24
        if days == 1 { return "Yesterday" }
        return "\(days) days ago"
    }
    
    private var rentalPeriodText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        
        let startDateStr = formatter.string(from: notification.rentalDate ?? notification.createdAt)
        
        if let endDate = notification.rentalEndDate {
            let endDateStr = formatter.string(from: endDate)
            let days = notification.rentalDays ?? {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day], from: notification.rentalDate ?? notification.createdAt, to: endDate)
                return max(1, (components.day ?? 1) + 1)
            }()
            return "\(startDateStr) → \(endDateStr) • \(days) Days"
        } else if let days = notification.rentalDays {
            // Compute end date from start + days
            let startDate = notification.rentalDate ?? notification.createdAt
            let endDate = Calendar.current.date(byAdding: .day, value: days - 1, to: startDate) ?? startDate
            let endDateStr = formatter.string(from: endDate)
            return "\(startDateStr) → \(endDateStr) • \(days) Days"
        } else {
            return startDateStr
        }
    }
    
    private var statusColor: Color {
        switch notification.status {
        case .accepted: return .green
        case .pending: return .orange
        case .rejected: return .red
        }
    }
    
    private var statusText: String {
        switch notification.status {
        case .accepted: return "Approved"
        case .pending: return "Pending"
        case .rejected: return "Declined"
        }
    }
    
    private var messageText: AttributedString {
        // Build the content message with garment name in medium weight
        let content = notification.content
        var attributed = AttributedString(content)
        
        // Find product name in the content and make it medium weight
        if let productName = notification.productName {
            // Look for the product name wrapped in quotes
            let quotedName = "\"\(productName)\""
            if let range = attributed.range(of: quotedName) {
                attributed[range].font = .system(size: 14, weight: .medium)
            }
        }
        
        return attributed
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                // MARK: - Product Image (60×60)
                productThumbnail
                
                // MARK: - Center Content
                VStack(alignment: .leading, spacing: 4) {
                    // Message
                    Text(messageText)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)

                    Spacer()
                    
                    // Rental Period

                    if let price = notification.totalPrice {
                        HStack(spacing: 3) {
                            Image(systemName: "tag")
                                .font(.system(size: 10))
                            Text("₹\(Int(price).formatted())")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 3) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(rentalPeriodText)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                    
                    // Rental Price
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // MARK: - Trailing Section
                VStack(alignment: .trailing, spacing: 4) {
                    // Status badge
                    Text(statusText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(statusColor)
                        .padding(4)
                    
                    Spacer()
                    // Relative time
                    Text(relativeTime)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(notification.isRead ? 0.85 : 1.0)
    }
    
    // MARK: - Product Thumbnail
    @ViewBuilder
    private var productThumbnail: some View {
        if let imageName = notification.productImageName {
            Group {
                if imageName.hasPrefix("http"), let url = URL(string: imageName) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            placeholderImage
                        case .empty:
                            ProgressView()
                                .frame(width: 60, height: 80)
                        @unknown default:
                            placeholderImage
                        }
                    }
                } else {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 60, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            placeholderImage
        }
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(uiColor: .systemGray5))
            .frame(width: 60, height: 80)
            .overlay(
                Image(systemName: "tshirt")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary.opacity(0.5))
            )
    }
}
