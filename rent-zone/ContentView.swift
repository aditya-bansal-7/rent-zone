import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appStore: AppStore
    
    var body: some View {
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Text("Categories")
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Categories")
                }
            
            Text("Chat")
                .tabItem {
                    Image(systemName: "message")
                    Text("Chat")
                }
            
            Text("Rent")
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Rent")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStore())
}
