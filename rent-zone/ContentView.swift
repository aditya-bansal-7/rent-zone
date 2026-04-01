import SwiftUI

struct ContentView: View {
    @Environment(AppStore.self) var appStore
    
    var body: some View {
            TabView {
                Tab("Home", systemImage: "house.fill") {
                    HomeView()
                }
                
                Tab("Categories", systemImage: "square.grid.2x2") {
                    CategoriesView()
                }
                
                Tab("Chat", systemImage: "message.fill") {
                    ChatListView()
                }
                
                Tab("Rent", systemImage: "plus") {
                    UploadView()
                }
            }
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
}
