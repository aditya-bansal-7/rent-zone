import SwiftUI

struct ChatListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore
    
    @StateObject private var chatService = ChatService.shared
    @State private var searchText = ""
    @State private var showLoginSheet = false
    
    private var isLoggedIn: Bool {
        TokenStorage.isLoggedIn
    }
    
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
            
            // Search Bar — only show when logged in and has conversations or active search
            if isLoggedIn && (!chatService.conversations.isEmpty || !searchText.isEmpty) {
                SearchBarView(text: $searchText, placeholder: "Search")
                    .padding(.vertical, 8)
            }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .zIndex(1)
            
            // Empty state: not logged in
            if !isLoggedIn {
                chatEmptyStateView(
                    title: "Sign in to start chatting",
                    subtitle: "Connect with other users, negotiate rentals, and manage your conversations.",
                    showSignInButton: true
                )
            } else if chatService.conversations.isEmpty && !searchText.isEmpty {
                // No search results
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No results for \"\(searchText)\"")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
            } else if chatService.conversations.isEmpty {
                // Logged in but no conversations
                chatEmptyStateView(
                    title: "No conversations yet",
                    subtitle: "Start chatting by browsing products and messaging their owners.",
                    showSignInButton: false
                )
            } else {
                // Chat list
                List {
                    ForEach(chatService.conversations) { conversation in
                        Button {
                            // Mark as read and navigate
                            if let index = chatService.conversations.firstIndex(where: { $0.id == conversation.id }) {
                                chatService.conversations[index].hasUnread = false
                                chatService.conversations[index].unreadCount = 0
                                chatService.conversations[index].isOnline = false
                                appStore.selectedChatConversation = chatService.conversations[index]
                                
                                Task {
                                    await chatService.markConversationAsRead(conversation.id)
                                }
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
                                        chatService.conversations[index].unreadCount = 0
                                        Task {
                                            await chatService.markConversationAsRead(conversation.id)
                                        }
                                    } else {
                                        chatService.conversations[index].unreadCount = 1
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
        }

            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(item: $bindableAppStore.selectedChatConversation) { conversation in
                PersonalChatView(conversation: conversation)
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
            .onAppear {
                guard isLoggedIn else { return }
                Task {
                    if searchText.isEmpty {
                        await chatService.fetchConversations()
                    }
                    chatService.startWebSocket()
                }
            }
            .task(id: searchText) {
                guard isLoggedIn else { return }
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
    
    // MARK: - Empty State with Lottie Animation
    @ViewBuilder
    private func chatEmptyStateView(title: String, subtitle: String, showSignInButton: Bool) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            LottieView(animationName: "chat_empty")
                .frame(width: 220, height: 220)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if showSignInButton {
                Button {
                    showLoginSheet = true
                } label: {
                    Text("Sign In")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 48)
                        .background(
                            LinearGradient(
                                colors: [.brandPurple, .brandPurple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
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
                
                if conversation.hasUnread || conversation.unreadCount > 0 {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                        
                        Text("\(conversation.unreadCount > 0 ? conversation.unreadCount : 1)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 4, y: -4)
                } else if conversation.isOnline {
                    Circle()
                        .fill(Color.green)
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
