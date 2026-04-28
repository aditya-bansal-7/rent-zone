import SwiftUI

struct ChatListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore
    
    @StateObject private var chatService = ChatService.shared
    
    var body: some View {
        @Bindable var bindableAppStore = appStore
        
        NavigationStack{
        VStack( spacing: 0) {
            // Chat list
            List {
                ForEach(chatService.conversations) { conversation in
                    Button {
                        // Mark as read and navigate
                        if let index = chatService.conversations.firstIndex(where: { $0.id == conversation.id }) {
                            chatService.conversations[index].hasUnread = false
                            chatService.conversations[index].isOnline = false
                            appStore.selectedChatConversation = chatService.conversations[index]
                        }
                    } label: {
                        ChatRowView(conversation: conversation)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                chatService.conversations.removeAll(where: { $0.id == conversation.id })
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            if let index = chatService.conversations.firstIndex(where: { $0.id == conversation.id }) {
                                chatService.conversations[index].hasUnread.toggle()
                                if !chatService.conversations[index].hasUnread {
                                    chatService.conversations[index].isOnline = false
                                }
                            }
                        } label: {
                            Label(conversation.hasUnread ? "Mark Read" : "Mark Unread", systemImage: conversation.hasUnread ? "envelope.open" : "envelope.badge")
                        }
                        .tint(.blue)
                    }
                }
            }
            .listStyle(.plain)
        }
            .background(Color(white: 0.97))
            .navigationTitle("Chat")
            .navigationDestination(item: $bindableAppStore.selectedChatConversation) { conversation in
                PersonalChatView(conversation: conversation)
            }
            .onAppear {
                Task {
                    await chatService.fetchConversations()
                    chatService.startWebSocket()
                }
            }
        }
    }
}

struct ChatRowView: View {
    let conversation: ChatConversation
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar with online indicator
            ZStack(alignment: .topTrailing) {
                if let imageName = conversation.participantImage, imageName.hasPrefix("http"), let url = URL(string: imageName) {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image.resizable().scaledToFill()
                        } else {
                            Image(systemName: "person.crop.circle.fill").resizable().foregroundColor(.gray.opacity(0.4))
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                } else if let imageName = conversation.participantImage {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray.opacity(0.4))
                }
                
                if conversation.hasUnread || conversation.isOnline {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 2, y: -2)
                }
            }
            
            // Name and time
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.participantName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                Text(conversation.lastMessageTime)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 8)
        .background(Color.clear)
    }
    
}

#Preview {
    NavigationStack {
        ChatListView()
    }
}
