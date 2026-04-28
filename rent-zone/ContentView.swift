import SwiftUI

struct ContentView: View {
    @Environment(AppStore.self) var appStore
    
    var body: some View {
        @Bindable var bindableAppStore = appStore
        
        TabView(selection: $bindableAppStore.activeTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView()
            }
            
            Tab("Categories", systemImage: "square.grid.2x2", value: 1) {
                CategoriesView()
            }
            
            Tab("Chat", systemImage: "message.fill", value: 2) {
                ChatListView()
            }
            
            Tab("Rent", systemImage: "plus", value: 3) {
                UploadViewCamera()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
}
