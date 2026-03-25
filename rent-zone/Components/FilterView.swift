//
//  FilterView.swift
//  rentZoneDemo
//

import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var priceRange: ClosedRange<Double>
    @Binding var selectedSizes: Set<ClothingSize>
    @Binding var selectedOccasions: Set<Occasion>
    @Binding var selectedDate: Date?
    
    let totalResults: Int
    
    // Internal temp state for live editing
    @State private var tempLow: Double = 0
    @State private var tempHigh: Double = 20000
    @State private var tempSizes: Set<ClothingSize> = []
    @State private var tempOccasions: Set<Occasion> = []
    @State private var tempDate: Date? = nil
    @State private var showDatePicker = false
    
    private var hasActiveFilters: Bool {
        tempLow != 0 || tempHigh != 20000 ||
        !tempSizes.isEmpty || !tempOccasions.isEmpty ||
        tempDate != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            header
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // MARK: - Price Range
                    priceRangeSection
                    
                    // MARK: - Size
                    sizeSection
                    
                    // MARK: - Occasion
                    occasionSection
                    
                    // MARK: - Date
                    dateSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            
            Spacer()
            
            // MARK: - Bottom Button
            bottomButton
        }
        .background(Color.white)
        .onAppear {
            tempLow = priceRange.lowerBound
            tempHigh = priceRange.upperBound
            tempSizes = selectedSizes
            tempOccasions = selectedOccasions
            tempDate = selectedDate
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("Filters")
                .font(.title2.weight(.bold))
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: resetFilters) {
                Text("Reset")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
    
    // MARK: - Price Range
    private var priceRangeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Range")
                .font(.headline.weight(.bold))
                .foregroundColor(.black)
            
            HStack {
                Text("₹\(Int(tempLow))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("₹\(Int(tempHigh))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            RangeSliderView(low: $tempLow, high: $tempHigh, range: 0...20000)
                .frame(height: 30)
        }
    }
    
    // MARK: - Size
    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Size")
                .font(.headline.weight(.bold))
                .foregroundColor(.black)
            
            HStack(spacing: 10) {
                ForEach(ClothingSize.allCases, id: \.self) { size in
                    Button(action: {
                        if tempSizes.contains(size) {
                            tempSizes.remove(size)
                        } else {
                            tempSizes.insert(size)
                        }
                    }) {
                        Text(size.rawValue)
                            .font(.caption.weight(.medium))
                            .foregroundColor(tempSizes.contains(size) ? .white : .black)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(tempSizes.contains(size)
                                          ? Color(red: 0.55, green: 0.45, blue: 0.85)
                                          : Color.clear)
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        tempSizes.contains(size)
                                        ? Color.clear
                                        : Color(.systemGray4),
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Occasion
    private var occasionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ocassion")
                .font(.headline.weight(.bold))
                .foregroundColor(.black)
            
            ForEach(Occasion.allCases, id: \.self) { occasion in
                Button(action: {
                    if tempOccasions.contains(occasion) {
                        tempOccasions.remove(occasion)
                    } else {
                        tempOccasions.insert(occasion)
                    }
                }) {
                    HStack {
                        Text(occasion.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        if tempOccasions.contains(occasion) {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.85))
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }
    
    // MARK: - Date
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date")
                .font(.headline.weight(.bold))
                .foregroundColor(.black)
            
            Button(action: {
                showDatePicker.toggle()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.black)
                    
                    Text(tempDate != nil ? formattedDate(tempDate!) : "Select date")
                        .font(.subheadline)
                        .foregroundColor(tempDate != nil ? .black : .gray)
                    
                    Spacer()
                    
                    if tempDate != nil {
                        Button(action: {
                            tempDate = nil
                            showDatePicker = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
            }
            
            if showDatePicker {
                DatePicker(
                    "Select Date",
                    selection: Binding(
                        get: { tempDate ?? Date() },
                        set: { tempDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color(red: 0.55, green: 0.45, blue: 0.85))
            }
        }
    }
    
    // MARK: - Bottom Button
    private var bottomButton: some View {
        Button(action: {
            applyFilters()
            dismiss()
        }) {
            Text(hasActiveFilters ? "Show \(totalResults) Results" : "Close")
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
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
        .background(Color.white)
    }
    
    // MARK: - Helpers
    private func resetFilters() {
        tempLow = 0
        tempHigh = 20000
        tempSizes = []
        tempOccasions = []
        tempDate = nil
        showDatePicker = false
    }
    
    private func applyFilters() {
        priceRange = tempLow...tempHigh
        selectedSizes = tempSizes
        selectedOccasions = tempOccasions
        selectedDate = tempDate
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Custom Range Slider

struct RangeSliderView: View {
    @Binding var low: Double
    @Binding var high: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width - 28 // thumb diameter accounted
            let lowOffset = CGFloat((low - range.lowerBound) / (range.upperBound - range.lowerBound)) * width
            let highOffset = CGFloat((high - range.lowerBound) / (range.upperBound - range.lowerBound)) * width
            
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.systemGray4))
                    .frame(height: 3)
                    .padding(.horizontal, 14)
                
                // Active track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.black)
                    .frame(width: highOffset - lowOffset, height: 3)
                    .offset(x: lowOffset + 14)
                
                // Low thumb
                Circle()
                    .fill(Color.black)
                    .frame(width: 22, height: 22)
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    .offset(x: lowOffset + 3)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newVal = range.lowerBound + Double(value.location.x / width) * (range.upperBound - range.lowerBound)
                                low = min(max(newVal, range.lowerBound), high - 100)
                            }
                    )
                
                // High thumb
                Circle()
                    .fill(Color.black)
                    .frame(width: 22, height: 22)
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    .offset(x: highOffset + 3)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newVal = range.lowerBound + Double(value.location.x / width) * (range.upperBound - range.lowerBound)
                                high = max(min(newVal, range.upperBound), low + 100)
                            }
                    )
            }
        }
    }
}

#Preview {
    FilterView(
        priceRange: .constant(0...20000),
        selectedSizes: .constant([]),
        selectedOccasions: .constant([]),
        selectedDate: .constant(nil),
        totalResults: 54
    )
}
