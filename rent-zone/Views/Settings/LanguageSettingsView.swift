import SwiftUI

struct LanguageSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguage = "English"
    
    let languages = ["English", "Hindi", "Spanish", "French", "German", "Mandarin"]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select Language")) {
                    ForEach(languages, id: \.self) { language in
                        Button(action: {
                            selectedLanguage = language
                        }) {
                            HStack {
                                Text(language)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedLanguage == language {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Language")
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
    LanguageSettingsView()
}
