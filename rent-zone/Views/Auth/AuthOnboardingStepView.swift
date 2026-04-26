import SwiftUI

struct AuthOnboardingStepView: View {
    @Binding var location: String
    @Binding var university: String
    @Binding var phoneNumber: String
    @Binding var selectedCategory: CategoryType

    var body: some View {
        VStack(spacing: 16) {
            AuthInputField(placeholder: "Your City (e.g. Mumbai)", text: $location, iconName: "mappin.and.ellipse")
            AuthInputField(placeholder: "University / College", text: $university, iconName: "graduationcap")
            AuthInputField(placeholder: "Phone Number (Optional)", text: $phoneNumber, iconName: "phone", keyboardType: .phonePad)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("I'm interested in:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    ForEach([CategoryType.men, CategoryType.women], id: \.self) { cat in
                        Button(action: { selectedCategory = cat }) {
                            Text(cat.rawValue.capitalized)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(selectedCategory == cat ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(selectedCategory == cat ? Color.black : Color(white: 0.96))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}
