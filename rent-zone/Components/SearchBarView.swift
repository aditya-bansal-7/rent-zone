import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $searchText)
                .font(.system(size: 15))
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    SearchBarView(searchText: .constant(""))
}
