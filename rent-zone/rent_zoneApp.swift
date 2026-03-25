import SwiftUI

@main
struct rent_zoneApp: App {
    @State private var appStore = AppStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appStore)
        }
    }
}
