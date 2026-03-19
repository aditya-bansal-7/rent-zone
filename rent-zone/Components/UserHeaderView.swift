import SwiftUI

struct UserHeaderView: View {
    var body: some View {
        HStack {
            // Profile picture placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                    
                )
            
            Text("Payal Singh")
                .font(.system(size: 17, weight: .semibold))
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .offset(x: -10)
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    UserHeaderView()
}
