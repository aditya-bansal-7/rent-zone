import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var locationServicesEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Change Password")) {
                        Label("Change Password", systemImage: "lock")
                    }
                    NavigationLink(destination: Text("Email Notifications")) {
                        Label("Email Preferences", systemImage: "envelope")
                    }
                }
                
                Section(header: Text("App Settings")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Push Notifications", systemImage: "bell")
                    }
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark Mode", systemImage: "moon")
                    }
                    Toggle(isOn: $locationServicesEnabled) {
                        Label("Location Services", systemImage: "location")
                    }
                }
                
                Section(header: Text("Data")) {
                    Button(action: {}) {
                        Label("Clear Cache", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
