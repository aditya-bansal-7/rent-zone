import SwiftUI

struct CalendarPickerView: View {
    @Binding var selectedDate: Date?
    @Binding var displayedMonth: Date
    
    private let calendar = Calendar.current
    private let dayLabels = ["SUN", "MON", "WED", "THU", "FRI", "SAT", "SUN"]
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    private var daysInMonth: [Int?] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let startingWeekday = calendar.component(.weekday, from: firstDay) // 1 = Sunday
        
        var days: [Int?] = Array(repeating: nil, count: startingWeekday - 1)
        for day in range {
            days.append(day)
        }
        return days
    }
    
    private func dateFor(day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: displayedMonth)
        components.day = day
        return calendar.date(from: components)!
    }
    
    private func isSelected(day: Int) -> Bool {
        guard let selected = selectedDate else { return false }
        return calendar.isDate(dateFor(day: day), inSameDayAs: selected)
    }
    
    private func isToday(day: Int) -> Bool {
        calendar.isDate(dateFor(day: day), inSameDayAs: Date())
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header with navigation
            HStack {
                HStack(spacing: 4) {
                    Text(monthYearString)
                        .font(.system(size: 18, weight: .bold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.purple.opacity(0.6))
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.purple.opacity(0.5))
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.purple.opacity(0.5))
                    }
                }
            }
            
            // Day of week headers
            let weekdaySymbols = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, day in
                    if let day = day {
                        Button(action: {
                            selectedDate = dateFor(day: day)
                        }) {
                            Text("\(day)")
                                .font(.system(size: 16, weight: isSelected(day: day) || isToday(day: day) ? .bold : .regular))
                                .foregroundColor(isSelected(day: day) ? .black : (isToday(day: day) ? .purple : .black))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(isSelected(day: day) ? Color(red: 230/255, green: 210/255, blue: 255/255) : (isToday(day: day) ? Color(red: 243/255, green: 236/255, blue: 255/255) : Color.clear))
                                )
                        }
                    } else {
                        Text("")
                            .frame(width: 36, height: 36)
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}
