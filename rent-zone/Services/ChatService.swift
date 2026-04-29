import Foundation
import Combine

@MainActor
class ChatService: ObservableObject {
    static let shared = ChatService()
    
    @Published var conversations: [ChatConversation] = []
    @Published var activeConversationMessages: [ChatMessage] = []
    var activeConversationId: String? = nil
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    private init() {}
    
    func fetchConversations() async {
        guard let currentUserId = TokenStorage.userId else { return }
        do {
            let response: [ChatConversationDTO] = try await APIClient.shared.request(endpoint: "/chats", method: "GET", authenticated: true)
            self.conversations = response.map { $0.toChatConversation(currentUserId: currentUserId) }
        } catch {
            print("Error fetching conversations: \(error)")
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
    
    func startWebSocket() {
        guard let token = TokenStorage.accessToken else { return }
        let hostString = API.baseURL.replacingOccurrences(of: "http://", with: "ws://").replacingOccurrences(of: "/api", with: "")
        
        guard let url = URL(string: "\(hostString)?token=\(token)") else { return }
        var request = URLRequest(url: url)
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
                switch msg {
                case .string(let text):
                    self?.handleIncomingMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleIncomingMessage(text)
                    }
                @unknown default:
                    break
                }
                self?.receiveWSMessage()
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
                      let content = msgDict["content"] as? String,
                      let senderId = msgDict["senderId"] as? String,
                      let conversationId = msgDict["conversationId"] as? String,
                      let createdAt = msgDict["createdAt"] as? String else { return }
                
                let isMine = (senderId == TokenStorage.userId)
                
                let fmt = ISO8601DateFormatter()
                let date = fmt.date(from: createdAt) ?? Date()
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "h:mm a"
                let timestamp = displayFormatter.string(from: date)
                
                let newMsg = ChatMessage(id: id, content: content, isFromCurrentUser: isMine, timestamp: timestamp)
                
                Task { @MainActor in
                    if let activeId = self.activeConversationId, activeId == conversationId {
                        if !self.activeConversationMessages.contains(where: { $0.id == newMsg.id }) {
                            self.activeConversationMessages.append(newMsg)
                        }
                    }
                    // Update conversation list last message
                    if let index = self.conversations.firstIndex(where: { $0.id == conversationId }) {
                        var conv = self.conversations[index]
                        conv.lastMessageTime = timestamp
                        if !isMine && activeConversationId != conversationId {
                            conv.hasUnread = true
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
