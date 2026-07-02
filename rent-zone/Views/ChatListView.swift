import SwiftUI

struct ChatListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore
    
    @StateObject private var chatService = ChatService.shared
    @State private var searchText = ""
    
    var body: some View {
        @Bindable var bindableAppStore = appStore
        
        NavigationStack{
        VStack(spacing: 0) {
            VStack(spacing: 0) {
            HStack( spacing: 2) {
                Text("Chat")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical,8)
            
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.primary)
                
                TextField("Search", text: $searchText)
                    .font(.system(size: 17))
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .zIndex(1)
            
            // Chat list
            List {
                ForEach(filteredConversations) { conversation in
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
                            Task {
                                await chatService.deleteConversation(conversation.id)
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
                        .tint(.brandPurple)
                    }
                }
            }
            .padding(.top, -20)
            .zIndex(0)
            
        }

            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(item: $bindableAppStore.selectedChatConversation) { conversation in
                PersonalChatView(conversation: conversation)
            }
            .onAppear {
                Task {
                    if searchText.isEmpty {
                        await chatService.fetchConversations()
                    }
                    chatService.startWebSocket()
                }
            }
            .task(id: searchText) {
                if searchText.isEmpty {
                    await chatService.fetchConversations()
                } else {
                    do {
                        try await Task.sleep(nanoseconds: 500_000_000)
                        await chatService.searchConversations(query: searchText)
                    } catch {
                        // Task cancelled
                    }
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
                    .foregroundColor(.primary)
                if let lastMessage = conversation.messages.first {
                    HStack(spacing: 2) {
                        Text(lastMessage.isFromCurrentUser ? "You:" : "\(conversation.participantName):")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(lastMessage.content)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                Text(conversation.lastMessageTime)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            
        }
      
        .padding(.vertical, 8)
       
    }
    
}

#Preview {
    NavigationStack {
        ChatListView()
    }
}
