import SwiftUI

struct ContentView: View {
    @Environment(AppStore.self) var appStore
    
    var body: some View {
        NavigationStack {
            TabView {
                Tab("Home", systemImage: "house.fill") {
                    HomeView()
                }
                
                Tab("Categories", systemImage: "square.grid.2x2") {
                    Text("Categories")
                }
                
                Tab("Chat", systemImage: "message.fill") {
                    ChatListView()
                }
                
                Tab("Rent", systemImage: "plus") {
                    UploadView()
                }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .navigationDestination(for: ChatConversation.self) { conversation in
                PersonalChatView(conversation: conversation)
            }
            .tint(.blue)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
}
