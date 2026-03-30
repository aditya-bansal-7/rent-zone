//
//  SortSheetView.swift
//  rentZoneDemo
//

import SwiftUI

struct SortSheetView: View {
    @Binding var selectedSort: SortOption?
    var dismiss: () -> Void = {}
    
    @State private var tempSort: SortOption? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Sort by")
                .font(.title2.weight(.bold))
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)
            
            // Options
            VStack(alignment: .leading, spacing: 0) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        tempSort = option
                    }) {
                        HStack {
                            Text(option.rawValue)
                                .font(.body)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if tempSort == option {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                    }
                }
            }
            
            // Done Button
            Button(action: {
                selectedSort = tempSort
                dismiss()
            }) {
                Text("Done")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.92, green: 0.87, blue: 1.0),
                                        Color(red: 0.95, green: 0.91, blue: 1.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .onAppear {
            tempSort = selectedSort
        }
    }
}

#Preview {
    SortSheetView(selectedSort: .constant(nil), dismiss: {})
}
