import SwiftUI

struct ContentView: View {
    @Environment(AppStore.self) var appStore
    
    var body: some View {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                Text("Categories")
                    .tabItem {
                        Label("Categories", systemImage: "square.grid.2x2")
                    }
                
                ChatListView()
                    .tabItem {
                        Label("Chat", systemImage: "message.fill")
                    }
                
                UploadView()
                    .tabItem {
                        Label("Rent", systemImage: "plus")
                    }
            }
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
}
