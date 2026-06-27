import SwiftUI

struct AuthOnboardingStepView: View {
    @Binding var location: String
    @Binding var university: String
    @Binding var phoneNumber: String
    @Binding var selectedCategory: CategoryType

    var body: some View {
        VStack(spacing: 16) {
            AuthInputField(placeholder: "Your City (e.g. Noida)", text: $location, iconName: "mappin.and.ellipse")
            AuthInputField(placeholder: "University / College", text: $university, iconName: "graduationcap")
            AuthInputField(placeholder: "Phone Number (Optional)", text: $phoneNumber, iconName: "phone", keyboardType: .phonePad)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("I'm interested in:")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                Picker("Select Category", selection: $selectedCategory) {
                    Text("Men").tag(CategoryType.men)
                    Text("Women").tag(CategoryType.women)
                }
                .pickerStyle(.segmented)
            }
            .padding(.top, 8)
        }
    }
}
