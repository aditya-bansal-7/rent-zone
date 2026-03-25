import SwiftUI

struct PersonalChatView: View {
    let conversation: ChatConversation
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var showReport = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }
                
                // Avatar
                if let imageName = conversation.participantImage {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray.opacity(0.4))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(conversation.participantName)
                            .font(.system(size: 16, weight: .bold))
                        if conversation.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                        }
                    }
                    if conversation.isOnline {
                        Text("Online")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                Button(action: { showReport = true }) {
                    VStack(spacing: 2) {
                        Image(systemName: "exclamationmark.bubble")
                            .font(.system(size: 18))
                        Text("Report")
                            .font(.system(size: 9, weight: .medium))
                        
                    }
                    .offset(x:-10)
                    .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.white)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            
            // Messages
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Product context card
                    if let product = conversation.productContext {
                        HStack(spacing: 12) {
                            Image(product.productImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 70)
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.productName)
                                    .font(.system(size: 16, weight: .bold))
                                HStack(alignment: .bottom, spacing: 2) {
                                    Text("₹\(Int(product.pricePerDay))")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("/day")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                Text("Need on \(product.needDate)")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: 280, alignment: .leading)
                        .background(Color(red: 243/255, green: 236/255, blue: 255/255))
                        .cornerRadius(18)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    // Chat messages
                    ForEach(conversation.messages) { message in
                        ChatBubbleView(message: message)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .background(Color(white: 0.97))
            
            // Message input
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                TextField("Type your message...", text: $messageText)
                    .font(.system(size: 15))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(white: 0.95))
                    .cornerRadius(20)
                
                Button(action: {}) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: -2)
        }
        .navigationBarHidden(true)
        .background(Color(white: 0.97))
        .sheet(isPresented: $showReport) {
            ReportUserView()
                .environmentObject(AppStore())
        }
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 6) {
            Text(message.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    message.isFromCurrentUser
                    ? Color(red: 243/255, green: 236/255, blue: 255/255)
                    : Color.white
                )
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            
            Text(message.timestamp)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: message.isFromCurrentUser ? .trailing : .leading)
    }
}

#Preview {
    PersonalChatView(conversation: ChatConversation(
        participantName: "Shreya Singh",
        participantImage: "sharara_orange",
        isOnline: true,
        isVerified: true,
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
    ))
}
