import SwiftUI

struct CalendarPickerView: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var displayedMonth: Date
    let bookedDates: [Date]
    
    private let calendar = Calendar.current
    private let weekdaySymbols = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    private var daysInMonth: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let startingWeekday = calendar.component(.weekday, from: firstDay) // 1 = Sunday
        
        var days: [Date?] = Array(repeating: nil, count: startingWeekday - 1)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
    
    private func isSelected(_ date: Date) -> Bool {
        if let start = startDate, calendar.isDate(date, inSameDayAs: start) { return true }
        if let end = endDate, calendar.isDate(date, inSameDayAs: end) { return true }
        return false
    }
    
    private func isInRange(_ date: Date) -> Bool {
        guard let start = startDate, let end = endDate else { return false }
        return date > start && date < end
    }
    
    private func isBooked(_ date: Date) -> Bool {
        bookedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }
    
    private func isPast(_ date: Date) -> Bool {
        date < calendar.startOfDay(for: Date())
    }

    private func handleDateSelection(_ date: Date) {
        if isBooked(date) || isPast(date) { return }
        
        if startDate == nil || (startDate != nil && endDate != nil) {
            startDate = date
            endDate = nil
        } else if let start = startDate {
            if date < start {
                startDate = date
                endDate = nil
            } else if calendar.isDate(date, inSameDayAs: start) {
                // Allow 1-day rental
                endDate = date
            } else {
                // Check if any booked dates are in between
                let hasBookedInRange = bookedDates.contains { bookedDate in
                    bookedDate > start && bookedDate < date
                }
                if !hasBookedInRange {
                    endDate = date
                } else {
                    startDate = date
                    endDate = nil
                }
            }
        }
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
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        let booked = isBooked(date)
                        let past = isPast(date)
                        let selected = isSelected(date)
                        let inRange = isInRange(date)
                        let today = isToday(date)
                        
                        Button(action: {
                            handleDateSelection(date)
                        }) {
                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 16, weight: selected || today ? .bold : .regular))
                                .foregroundColor(selected ? .black : (booked || past ? .gray.opacity(0.3) : (today ? .purple : .black)))
                                .frame(width: 36, height: 36)
                                .background(
                                    ZStack {
                                        if inRange {
                                            Rectangle()
                                                .fill(Color(red: 243/255, green: 236/255, blue: 255/255))
                                                .frame(height: 36)
                                        }
                                        
                                        if selected {
                                            Circle()
                                                .fill(Color(red: 230/255, green: 210/255, blue: 255/255))
                                        } else if today {
                                            Circle()
                                                .fill(Color(red: 243/255, green: 236/255, blue: 255/255))
                                        }
                                        
                                        if booked {
                                            DiagonalLineShape()
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        }
                                    }
                                )
                        }
                        .disabled(booked || past)
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
