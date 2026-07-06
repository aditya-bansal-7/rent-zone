import Foundation
import Combine
import UIKit
import PhotosUI
import CoreLocation

@MainActor
class ChatService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = ChatService()
    
    @Published var conversations: [ChatConversation] = []
    @Published var activeConversationMessages: [ChatMessage] = []
    @Published var isUploadingAttachment = false
    @Published var attachmentError: String?
    
    var activeConversationId: String? = nil
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let locationManager = CLLocationManager()
    
    // Location completion callback
    var onLocationFetched: ((CLLocation) -> Void)?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Conversations
    
    func fetchConversations() async {
        guard let currentUserId = TokenStorage.userId else { return }
        do {
            let response: [ChatConversationDTO] = try await APIClient.shared.request(endpoint: "/chats", method: "GET", authenticated: true)
            self.conversations = response.map { $0.toChatConversation(currentUserId: currentUserId) }
        } catch {
            print("Error fetching conversations: \(error)")
        }
    }
    
    func searchConversations(query: String) async {
        guard let currentUserId = TokenStorage.userId else { return }
        do {
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let response: [ChatConversationDTO] = try await APIClient.shared.request(endpoint: "/chats/search?q=\(encodedQuery)", method: "GET", authenticated: true)
            self.conversations = response.map { $0.toChatConversation(currentUserId: currentUserId) }
        } catch {
            print("Error searching conversations: \(error)")
        }
    }
    
    func startConversation(otherUserId: String, productId: String?) async throws -> ChatConversation {
        guard let currentUserId = TokenStorage.userId else { throw APIError.unauthorized }
        var body: [String: Any] = ["otherUserId": otherUserId]
        if let productId { body["productId"] = productId }
        
        let dto: ChatConversationDTO = try await APIClient.shared.request(
            endpoint: "/chats",
            method: "POST",
            body: body,
            authenticated: true
        )
        
        let newConv = dto.toChatConversation(currentUserId: currentUserId)
        if !conversations.contains(where: { $0.id == newConv.id }) {
            conversations.insert(newConv, at: 0)
        }
        return newConv
    }
    
    func fetchMessages(for conversationId: String) async {
        guard let currentUserId = TokenStorage.userId else { return }
        self.activeConversationId = conversationId
        do {
            let response: [ChatMessageDTO] = try await APIClient.shared.request(endpoint: "/chats/\(conversationId)/messages", method: "GET", authenticated: true)
            self.activeConversationMessages = response.map { $0.toChatMessage(currentUserId: currentUserId) }
        } catch {
            print("Error fetching messages: \(error)")
        }
    }
    
    func markConversationAsRead(_ conversationId: String) async {
        do {
            let _: EmptyResponse = try await APIClient.shared.request(endpoint: "/chats/\(conversationId)/read", method: "PUT", authenticated: true)
        } catch {
            print("Error marking conversation as read: \(error)")
        }
    }
    
    // MARK: - Send Text Message
    
    func sendMessage(_ content: String, conversationId: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let payload: [String: Any] = [
            "action": "sendMessage",
            "conversationId": conversationId,
            "content": content
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
            if let jsonString = String(data: data, encoding: .utf8) {
                let message = URLSessionWebSocketTask.Message.string(jsonString)
                webSocketTask?.send(message) { error in
                    if let error = error {
                        print("WS Send Error: \(error)")
                    }
                }
            }
        } catch {
            print("Encoding error: \(error)")
        }
    }
    
    // MARK: - Send Image Message
    
    func sendImageMessage(image: UIImage, conversationId: String) async {
        isUploadingAttachment = true
        attachmentError = nil
        defer { isUploadingAttachment = false }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            attachmentError = "Could not process image"
            return
        }
        
        guard let url = URL(string: API.baseURL + "/chats/\(conversationId)/messages/image") else {
            attachmentError = "Invalid URL"
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenStorage.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            attachmentError = "Not authenticated"
            return
        }
        
        var bodyData = Data()
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"image\"; filename=\"chat_image.jpg\"\r\n".data(using: .utf8)!)
        bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        bodyData.append(imageData)
        bodyData.append("\r\n".data(using: .utf8)!)
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = bodyData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let wrapper = try decoder.decode(APIResponse<ChatMessageDTO>.self, from: data)
            
            guard wrapper.success, let dto = wrapper.data else {
                attachmentError = wrapper.message ?? "Upload failed"
                return
            }
            
            guard let currentUserId = TokenStorage.userId else { return }
            let newMsg = dto.toChatMessage(currentUserId: currentUserId)
            if let activeId = self.activeConversationId, activeId == conversationId {
                if !self.activeConversationMessages.contains(where: { $0.id == newMsg.id }) {
                    self.activeConversationMessages.append(newMsg)
                }
            }
        } catch {
            attachmentError = "Failed to send image: \(error.localizedDescription)"
            print("Image send error: \(error)")
        }
    }
    
    // MARK: - Send Location Message
    
    func sendLocationMessage(latitude: Double, longitude: Double, locationName: String?, conversationId: String) async {
        isUploadingAttachment = true
        attachmentError = nil
        defer { isUploadingAttachment = false }
        
        do {
            var body: [String: Any] = [
                "latitude": latitude,
                "longitude": longitude
            ]
            if let name = locationName { body["locationName"] = name }
            
            guard let url = URL(string: API.baseURL + "/chats/\(conversationId)/messages/location") else {
                attachmentError = "Invalid URL"
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = TokenStorage.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let wrapper = try decoder.decode(APIResponse<ChatMessageDTO>.self, from: data)
            
            guard wrapper.success, let dto = wrapper.data else {
                attachmentError = wrapper.message ?? "Location send failed"
                return
            }
            
            guard let currentUserId = TokenStorage.userId else { return }
            let newMsg = dto.toChatMessage(currentUserId: currentUserId)
            if let activeId = self.activeConversationId, activeId == conversationId {
                if !self.activeConversationMessages.contains(where: { $0.id == newMsg.id }) {
                    self.activeConversationMessages.append(newMsg)
                }
            }
        } catch {
            attachmentError = "Failed to send location: \(error.localizedDescription)"
            print("Location send error: \(error)")
        }
    }
    
    // MARK: - Location Manager
    
    func requestCurrentLocation(completion: @escaping (CLLocation) -> Void) {
        onLocationFetched = completion
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in
            self.onLocationFetched?(location)
            self.onLocationFetched = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.attachmentError = "Could not get location: \(error.localizedDescription)"
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }
    
    // MARK: - WebSocket
    
    func startWebSocket() {
        guard let token = TokenStorage.accessToken else { return }
        let hostString = API.baseURL.replacingOccurrences(of: "http://", with: "ws://").replacingOccurrences(of: "/api", with: "")
        
        guard let url = URL(string: "\(hostString)?token=\(token)") else { return }
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        receiveWSMessage()
    }
    
    func stopWebSocket() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    private func receiveWSMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("WS Error: \(error)")
            case .success(let msg):
                let text: String?
                switch msg {
                case .string(let str):
                    text = str
                case .data(let data):
                    text = String(data: data, encoding: .utf8)
                @unknown default:
                    text = nil
                }
                if let text {
                    Task { @MainActor [weak self] in
                        self?.handleIncomingMessage(text)
                    }
                }
                Task { @MainActor [weak self] in
                    self?.receiveWSMessage()
                }
            }
        }
    }
    
    private func handleIncomingMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let action = json["action"] as? String else { return }
                  
            if action == "newMessage" {
                guard let msgDict = json["message"] as? [String: Any],
                      let id = msgDict["id"] as? String,
                      let senderId = msgDict["senderId"] as? String,
                      let conversationId = msgDict["conversationId"] as? String,
                      let createdAt = msgDict["createdAt"] as? String else { return }
                
                let content = msgDict["content"] as? String ?? ""
                
                let isMine = (senderId == TokenStorage.userId)
                
                let fmt = ISO8601DateFormatter()
                let date = fmt.date(from: createdAt) ?? Date()
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "h:mm a"
                let timestamp = displayFormatter.string(from: date)
                
                let msgTypeStr = msgDict["messageType"] as? String ?? "text"
                let msgType: ChatMessageType = {
                    switch msgTypeStr {
                    case "image": return .image
                    case "location": return .location
                    default: return .text
                    }
                }()
                
                let newMsg = ChatMessage(
                    id: id,
                    content: content,
                    isFromCurrentUser: isMine,
                    timestamp: timestamp,
                    messageType: msgType,
                    imageUrl: msgDict["imageUrl"] as? String,
                    locationLat: msgDict["locationLat"] as? Double,
                    locationLng: msgDict["locationLng"] as? Double,
                    locationName: msgDict["locationName"] as? String
                )
                
                Task { @MainActor in
                    if let activeId = self.activeConversationId, activeId == conversationId {
                        if !self.activeConversationMessages.contains(where: { $0.id == newMsg.id }) {
                            self.activeConversationMessages.append(newMsg)
                        }
                    }
                    if let index = self.conversations.firstIndex(where: { $0.id == conversationId }) {
                        var conv = self.conversations[index]
                        conv.lastMessageTime = timestamp
                        conv.messages.insert(newMsg, at: 0)
                        
                        if !isMine && self.activeConversationId != conversationId {
                            conv.hasUnread = true
                            conv.unreadCount += 1
                        }
                        self.conversations[index] = conv
                    }
                }
            } else if action == "newNotification" {
                guard let notifDict = json["notification"] as? [String: Any] else { return }
                do {
                    let notifData = try JSONSerialization.data(withJSONObject: notifDict)
                    let decoder = JSONDecoder()
                    let dto = try decoder.decode(NotificationDTO.self, from: notifData)
                    let appNotif = dto.toNotification()
                    Task { @MainActor in
                        NotificationCenter.default.post(name: NSNotification.Name("NewAppNotification"), object: appNotif)
                    }
                } catch {
                    print("Error decoding WS notification: \(error)")
                }
            }
        } catch {
            print("WS JSON Error: \(error)")
        }
    }
    
    func deleteConversation(_ conversationId: String) async {
        do {
            let _: EmptyResponse = try await APIClient.shared.request(
                endpoint: "/chats/\(conversationId)",
                method: "DELETE",
                authenticated: true
            )
            conversations.removeAll(where: { $0.id == conversationId })
        } catch {
            print("Error deleting conversation: \(error)")
        }
    }
}
