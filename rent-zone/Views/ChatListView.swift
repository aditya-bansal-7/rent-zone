import SwiftUI

struct ChatListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var conversations: [ChatConversation] = [
        ChatConversation(
            participantName: "Shreya",
            participantImage: "sharara_orange",
            isOnline: true,
            isVerified: true,
            hasUnread: false,
            lastMessageTime: "Just Now",
            messages: [
                ChatMessage(content: "Hi! I'm interested in renting your floral dress", isFromCurrentUser: true, timestamp: "10:28 AM"),
                ChatMessage(content: "Sure! It's available this weekend", isFromCurrentUser: false, timestamp: "10:30 AM"),
                ChatMessage(content: "Perfect! Where can I pick it up?", isFromCurrentUser: true, timestamp: "10:32 AM")
            ],
            productContext: ChatProductContext(
                productName: "Rajasthani Poshak",
                productImage: "rajasthani_poshak",
                pricePerDay: 520,
                needDate: "23 Dec"
            )
        ),
        ChatConversation(
            participantName: "Yash",
            participantImage: nil,
            hasUnread: true,
            lastMessageTime: "3h ago"
        ),
        ChatConversation(
            participantName: "Kirtika",
            participantImage: nil,
            lastMessageTime: "5h ago"
        ),
        ChatConversation(
            participantName: "Vansh",
            participantImage: nil,
            lastMessageTime: "3h ago"
        ),
        ChatConversation(
            participantName: "Aditya Bansal",
            participantImage: nil,
            lastMessageTime: "3h ago"
        )
    ]
    
    @State private var selectedConversation: ChatConversation? = nil
    
    var body: some View {
        
        NavigationStack{
            
   
        VStack( spacing: 0) {
            // Chat list
            List {
                ForEach(conversations) { conversation in
                    Button {
                        // Mark as read and navigate
                        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                            conversations[index].hasUnread = false
                            conversations[index].isOnline = false
                            selectedConversation = conversations[index]
                        }
                    } label: {
                        ChatRowView(conversation: conversation)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                conversations.removeAll(where: { $0.id == conversation.id })
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                                conversations[index].hasUnread.toggle()
                                if !conversations[index].hasUnread {
                                    conversations[index].isOnline = false
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
            .navigationDestination(item: $selectedConversation) { conversation in
                PersonalChatView(conversation: conversation)
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
                if let imageName = conversation.participantImage {
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
