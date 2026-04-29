import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var onSearch: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $searchText)
                .font(.system(size: 15))
                .onSubmit {
                    onSearch?()
                }
            
            Spacer()
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
