import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appStore: AppStore
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
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
            
            NavigationStack {
                UploadView()
            }
                .tabItem {
                    Image(systemName: "plus")
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
