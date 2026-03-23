import SwiftUI

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .tracking(0.5)
            
            Spacer()
            
            Button(action: {}) {
                Text("View All")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    SectionHeaderView(title: "POPULAR OUTFITS")
}
