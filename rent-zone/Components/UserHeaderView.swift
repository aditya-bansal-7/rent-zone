import SwiftUI

struct UserHeaderView: View {
    @Environment(AppStore.self) var appStore
    @Binding var showNotifications: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Home")
                    .font(.title)
                    .bold()
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showNotifications.toggle()
                }
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                    
                    if appStore.notificationStore.hasUnread {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 9, height: 9)
                            .offset(x: 2, y: -2)
                    }
                }
                .frame(width: 44, height: 44)
            }
            
            if let user = appStore.userStore.currentUser {
                if let profileImage = user.profileImage, let url = URL(string: profileImage) {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image.resizable().scaledToFill()
                        } else {
                            Circle()
                                .fill(Color.purple.opacity(0.8))
                                .overlay(
                                    Text(String(user.name.prefix(1)))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.purple.opacity(0.8))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Text(String(user.name.prefix(1)))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    )
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    UserHeaderView( showNotifications: .constant(false))
        .environment(AppStore())
}
