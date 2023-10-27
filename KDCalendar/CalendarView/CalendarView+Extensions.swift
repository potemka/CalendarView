
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
          let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
          return calendar.date(byAdding: .day, value: 1, to: sunday!)!
      }
    
    func endOfWeek(using calendar: Calendar, isFirstMonday: Bool = true) -> Date {
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
}

