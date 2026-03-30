import SwiftUI

struct NotificationCentreView: View {
    @EnvironmentObject var appStore: AppStore
    @Binding var isPresented: Bool
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
            // Header: All / Unread tabs + Close
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    tabButton(title: "All", index: 0)
                    tabButton(title: "Unread", index: 1)
                }
                .padding(4)
                .background(.ultraThinMaterial)
                .cornerRadius(22)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 30, height: 30)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Notification list
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(displayedNotifications) { notification in
                        NotificationCardView(
                            notification: notification,
                            onViewRequest: {
                                selectedNotification = notification
                            }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            }
        }
        .frame(maxHeight: 420)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 36))
        .if26GlassEffect(cornerRadius: 36)
        .padding(.horizontal, 16)
        .sheet(item: $selectedNotification) { notification in
            RentalRequestDetailView(notification: notification)
                .environmentObject(appStore)
        }
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        }) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(selectedTab == index ? .primary : .secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(selectedTab == index ? AnyShapeStyle(.regularMaterial) : AnyShapeStyle(.clear))
                .cornerRadius(18)
        }
    }
}
