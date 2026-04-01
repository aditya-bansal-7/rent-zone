import SwiftUI

struct ChatListView: View {
    @Environment(\.dismiss) private var dismiss
    
    let conversations: [ChatConversation] = [
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
    
    var body: some View {
        
        NavigationStack{
            
   
        VStack(spacing: 0) {
            // Header
            Text("Chat")
                .font(.system(size: 22, weight: .bold))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
            
            Divider().opacity(0.3)
            
            // Chat list
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(conversations) { conversation in
                        NavigationLink(value: conversation) {
                            ChatRowView(conversation: conversation)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
            .background(Color(white: 0.97))
            .navigationBarHidden(true)
            .navigationDestination(for: ChatConversation.self) { conversation in
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
            
            // 3-dot menu
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
    
}

#Preview {
    NavigationStack {
        ChatListView()
    }
}
