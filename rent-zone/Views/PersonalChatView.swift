import SwiftUI
import PhotosUI
import CoreLocation
import MapKit

struct PersonalChatView: View {
    let conversation: ChatConversation
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chatService = ChatService.shared
    @State private var messageText = ""
    @State private var showReport = false
    @State private var showAttachmentMenu = false
    
    // Camera
    @State private var showCamera = false
    
    // Photos picker
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    // Location picker
    @State private var showLocationPicker = false
    
    // Scroll
    @State private var scrollProxy: ScrollViewProxy?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color(UIColor.systemBackground))
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
                                .foregroundColor(.brandPurple)
                                .font(.system(size: 14))
                        }
                    }
                    if conversation.isOnline {
                        Text("Online")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
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
                    .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(UIColor.systemBackground))
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            
            // Upload progress bar
            if chatService.isUploadingAttachment {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Sending attachment…")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color(UIColor.systemGroupedBackground))
            }
            
            // Error banner
            if let error = chatService.attachmentError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                    Spacer()
                    Button("Dismiss") { chatService.attachmentError = nil }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.brandPurple)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
            }
            
            // Messages
            ScrollViewReader { proxy in
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
                                            .foregroundColor(.primary)
                                        Text("/day")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                    Text("Need on \(product.needDate)")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: 280, alignment: .leading)
                            .background(Color.brandPurple.opacity(0.15))
                            .cornerRadius(18)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        // Chat messages
                        ForEach(chatService.activeConversationMessages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                .background(Color(UIColor.systemGroupedBackground))
                .onChange(of: chatService.activeConversationMessages.count) { _, _ in
                    if let lastId = chatService.activeConversationMessages.last?.id {
                        withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                    }
                }
                .onAppear {
                    if let lastId = chatService.activeConversationMessages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            
            // Attachment menu
            if showAttachmentMenu {
                VStack(spacing: 0) {
                    AttachmentMenuRow(label: "Camera", action: {
                        showAttachmentMenu = false
                        showCamera = true
                    }) {
                        CameraIconView()
                    }
                    Divider().overlay(Color.gray.opacity(0.3))
                    AttachmentMenuRow(label: "Photos", action: {
                        showAttachmentMenu = false
                        showPhotoPicker = true
                    }) {
                        PhotosIconView()
                    }
                    Divider().overlay(Color.gray.opacity(0.3))
                    AttachmentMenuRow(label: "Location", action: {
                        showAttachmentMenu = false
                        showLocationPicker = true
                    }) {
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
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                
                Button(action: {
                    chatService.sendMessage(messageText, conversationId: conversation.id)
                    messageText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(messageText.isEmpty ? .gray : .brandPurple)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: -2)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .background(Color(UIColor.systemGroupedBackground))
        // Camera sheet
        .fullScreenCover(isPresented: $showCamera) {
            PremiumCameraView(onImageCaptured: { image in
                showCamera = false
                Task {
                    await chatService.sendImageMessage(image: image, conversationId: conversation.id)
                }
            }, onDismiss: { showCamera = false })
            .ignoresSafeArea()
        }
        // Location picker
        .fullScreenCover(isPresented: $showLocationPicker) {
            LocationPickerView { coordinate, name in
                showLocationPicker = false
                Task {
                    await chatService.sendLocationMessage(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude,
                        locationName: name,
                        conversationId: conversation.id
                    )
                }
            } onDismiss: {
                showLocationPicker = false
            }
        }
        // Photos picker
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await chatService.sendImageMessage(image: uiImage, conversationId: conversation.id)
                }
                selectedPhotoItem = nil
            }
        }
        .sheet(isPresented: $showReport) {
            ReportUserView(reportedUserName: conversation.participantName, reportedUserImage: conversation.participantImage, reportedUserLocation: nil)
                .environment(AppStore())
        }
        .onAppear {
            Task {
                await chatService.fetchMessages(for: conversation.id)
                await chatService.markConversationAsRead(conversation.id)
            }
        }
        .onDisappear {
            chatService.activeConversationId = nil
            Task {
                await chatService.markConversationAsRead(conversation.id)
            }
        }
    }
}

// MARK: - Chat Bubble View

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 6) {
            switch message.messageType {
            case .text:
                Text(message.content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isFromCurrentUser
                        ? Color.brandPurple
                        : Color(UIColor.secondarySystemBackground)
                    )
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
                
            case .image:
                ImageBubbleView(imageUrl: message.imageUrl, isFromCurrentUser: message.isFromCurrentUser)
                
            case .location:
                LocationBubbleView(
                    lat: message.locationLat ?? 0,
                    lng: message.locationLng ?? 0,
                    locationName: message.locationName,
                    isFromCurrentUser: message.isFromCurrentUser
                )
            }
            
            Text(message.timestamp)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: message.isFromCurrentUser ? .trailing : .leading)
    }
}

// MARK: - Image Bubble

struct ImageBubbleView: View {
    let imageUrl: String?
    let isFromCurrentUser: Bool
    @State private var showFullScreen = false
    
    var body: some View {
        Group {
            if let urlString = imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 220, maxHeight: 280)
                            .clipped()
                            .cornerRadius(16)
                            .onTapGesture { showFullScreen = true }
                    case .failure:
                        failedImagePlaceholder
                    default:
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .frame(width: 180, height: 180)
                            ProgressView()
                        }
                    }
                }
            } else {
                failedImagePlaceholder
            }
        }
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .sheet(isPresented: $showFullScreen) {
            FullScreenImageView(imageUrl: imageUrl)
        }
    }
    
    private var failedImagePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(width: 180, height: 120)
            VStack(spacing: 6) {
                Image(systemName: "photo.slash")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
                Text("Image unavailable")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Full Screen Image

struct FullScreenImageView: View {
    let imageUrl: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            
            if let urlString = imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ProgressView().tint(.white)
                    }
                }
            }
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .padding(20)
            }
        }
    }
}

// MARK: - Location Bubble

struct LocationBubbleView: View {
    let lat: Double
    let lng: Double
    let locationName: String?
    let isFromCurrentUser: Bool
    
    @State private var showMap = false
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    var displayName: String {
        locationName ?? "\(lat.formatted(.number.precision(.fractionLength(4)))), \(lng.formatted(.number.precision(.fractionLength(4))))"
    }
    
    var body: some View {
        Button(action: { showMap = true }) {
            VStack(alignment: .leading, spacing: 0) {
                // Mini map snapshot
                Map(position: .constant(.region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )))) {
                    Marker("Location", coordinate: coordinate)
                        .tint(Color.brandPurple)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .cornerRadius(14)
                .disabled(true)
                
                // Location label — wraps across multiple lines
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11))
                        .foregroundColor(isFromCurrentUser ? .white.opacity(0.9) : .brandPurple)
                        .padding(.top, 1)
                    Text(displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isFromCurrentUser ? .white : .primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isFromCurrentUser ? Color.brandPurple : Color(UIColor.secondarySystemBackground))
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 260)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .sheet(isPresented: $showMap) {
            FullScreenMapView(coordinate: coordinate, locationName: locationName)
        }
    }
}

struct LocationPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Full Screen Map

struct FullScreenMapView: View {
    let coordinate: CLLocationCoordinate2D
    let locationName: String?
    @Environment(\.dismiss) private var dismiss
    
    @State private var position: MapCameraPosition
    
    init(coordinate: CLLocationCoordinate2D, locationName: String?) {
        self.coordinate = coordinate
        self.locationName = locationName
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))
    }
    
    var body: some View {
        NavigationView {
            Map(position: $position) {
                Marker("Location", coordinate: coordinate)
                    .tint(Color.brandPurple)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(locationName ?? "Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: openInMaps) {
                        Label("Open in Maps", systemImage: "map")
                    }
                }
            }
        }
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = locationName ?? "Shared Location"
        mapItem.openInMaps()
    }
}


// MARK: - Attachment Menu Helpers

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
