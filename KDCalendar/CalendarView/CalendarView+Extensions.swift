
import UIKit

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        let subString = self[start..<end]
        return String(subString)
    }
}

extension Date {
    func convertToTimeZone(from fromTimeZone: TimeZone, to toTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(toTimeZone.secondsFromGMT(for: self) - fromTimeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
    
    func startOfWeek(using calendar: Calendar) -> Date {
        let monday = calendar.date(from: calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self))!
        
        if self < monday {
            let prevMonday = calendar.date(byAdding: .day, value: -7, to: monday)!
            return prevMonday
        } else {
            return monday
        }
        
    }
    
    func endOfWeek(using calendar: Calendar) -> Date {
        let startOfWeek = self.startOfWeek(using: calendar)
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
    }
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    func getAllMonthDates(using calendar: Calendar) -> [Date] {
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)

        let range = calendar.range(of: .day, in: .month, for: self)!
        let numDays = range.count
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        var arrDates = [Date]()
        for day in 1...numDays {
            let dateString = "\(dateComponents.year!) \(dateComponents.month!) \(day)"
            if let date = formatter.date(from: dateString) {
                arrDates.append(date)
            }
        }
        return arrDates
    }
}

