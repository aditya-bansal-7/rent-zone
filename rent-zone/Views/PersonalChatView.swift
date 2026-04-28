import SwiftUI

struct PersonalChatView: View {
    let conversation: ChatConversation
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chatService = ChatService.shared
    @State private var messageText = ""
    @State private var showReport = false
    @State private var showAttachmentMenu = false
    
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
                if let imageName = conversation.participantImage, imageName.hasPrefix("http"), let url = URL(string: imageName) {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image.resizable().scaledToFill()
                        } else {
                            Image(systemName: "person.crop.circle.fill").resizable().foregroundColor(.gray.opacity(0.4))
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else if let imageName = conversation.participantImage {
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
                    ForEach(chatService.activeConversationMessages) { message in
                        ChatBubbleView(message: message)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .background(Color(white: 0.97))
            
            // Attachment menu
            if showAttachmentMenu {
                VStack(spacing: 0) {
                    AttachmentMenuRow(label: "Camera", action: { showAttachmentMenu = false }) {
                        CameraIconView()
                    }
                    Divider().overlay(Color.gray.opacity(0.3))
                    AttachmentMenuRow(label: "Photos", action: { showAttachmentMenu = false }) {
                        PhotosIconView()
                    }
                    Divider().overlay(Color.gray.opacity(0.3))
                    AttachmentMenuRow(label: "Location", action: { showAttachmentMenu = false }) {
                        LocationIconView()
                    }
                }
                .if26AttachmentGlass()
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Message input
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        showAttachmentMenu.toggle()
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(showAttachmentMenu ? 45 : 0))
                }
                
                TextField("Type your message...", text: $messageText)
                    .font(.system(size: 15))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(white: 0.95))
                    .cornerRadius(20)
                
                Button(action: {
                    chatService.sendMessage(messageText, conversationId: conversation.id)
                    messageText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: -2)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .background(Color(white: 0.97))
        .sheet(isPresented: $showReport) {
            ReportUserView(reportedUserName: conversation.participantName, reportedUserImage: conversation.participantImage, reportedUserLocation: nil)
                .environment(AppStore())
        }
        .onAppear {
            Task {
                await chatService.fetchMessages(for: conversation.id)
            }
        }
        .onDisappear {
            chatService.activeConversationId = nil
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

struct AttachmentMenuRow<Icon: View>: View {
    let label: String
    let action: () -> Void
    @ViewBuilder let icon: () -> Icon
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                icon()
                    .frame(width: 44, height: 44)
                
                Text(label)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
    }
}

extension View {
    @ViewBuilder
    func if26AttachmentGlass() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: 18))
        } else {
            self
                .background(.ultraThinMaterial)
                .cornerRadius(18)
        }
    }
}

// Camera icon — gray circle with darker lens ring and center dot
struct CameraIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.55), Color(white: 0.42)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Lens outer ring
            Circle()
                .stroke(Color(white: 0.7), lineWidth: 2.5)
                .frame(width: 18, height: 18)
            
            // Lens inner
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(white: 0.3), Color(white: 0.15)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 14, height: 14)
            
            // Lens highlight
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 4, height: 4)
                .offset(x: -2, y: -2)
        }
    }
}

// Photos icon — colorful 8-petal flower like iOS Photos app
struct PhotosIconView: View {
    let petalColors: [Color] = [
        .red, .orange, .yellow, .green,
        Color(red: 0.2, green: 0.8, blue: 1.0),
        .blue, .purple,
        Color(red: 1.0, green: 0.4, blue: 0.6)
    ]
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
            
            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    Capsule()
                        .fill(petalColors[i].opacity(0.85))
                        .frame(width: 7, height: 13)
                        .offset(y: -6)
                        .rotationEffect(.degrees(Double(i) * 45))
                }
            }
            .frame(width: 28, height: 28)
        }
    }
}

// Location icon — green gradient circle with white ring and blue dot
struct LocationIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.85, blue: 0.45),
                            Color(red: 0.2, green: 0.7, blue: 0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // White ring
            Circle()
                .stroke(Color.white, lineWidth: 2.5)
                .frame(width: 16, height: 16)
            
            // Blue center dot
            Circle()
                .fill(Color(red: 0.2, green: 0.5, blue: 1.0))
                .frame(width: 9, height: 9)
        }
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
