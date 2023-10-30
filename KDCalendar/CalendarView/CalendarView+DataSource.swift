
import UIKit

internal extension CalendarView {
    
    var startDayCache: CalendarDay {
        if _startDayCache == nil {
            _startDayCache = dataSource?.days().first
        }
        
        return _startDayCache ?? CalendarDay(date: Date(), isActive: true)
    }
    
    var endDayCache: CalendarDay {
        if _endDayCache == nil {
            _endDayCache = dataSource?.days().last
        }
        
        return _endDayCache ?? CalendarDay(date: Date(), isActive: true)
    }
    
    
    var firstDayCache: CalendarDay {
        if _firstDayCache == nil {
            let startDateComponents = self.calendar.dateComponents([.era, .year, .month, .day], from: startDayCache.date)
            
            var firstDayOfStartMonthComponents = startDateComponents
            firstDayOfStartMonthComponents.day = 1
            
            let firstDayOfStartMonthDate = self.calendar.date(from: firstDayOfStartMonthComponents)!
            let isActiveDay = self.validateIsActiveDay(by: firstDayOfStartMonthDate)
            _firstDayCache = CalendarDay(date: firstDayOfStartMonthDate, isActive: isActiveDay)
        }
        
        return _firstDayCache ?? CalendarDay(date: Date(), isActive: true)
    }
    
    var lastDayCache: CalendarDay {
        if _lastDayCache == nil {
            var lastDayOfEndMonthComponents = self.calendar.dateComponents([.era, .year, .month], from: self.endDayCache.date)
            let range = self.calendar.range(of: .day, in: .month, for: self.endDayCache.date)!
            lastDayOfEndMonthComponents.day = range.count
            
            let lastDate = self.calendar.date(from: lastDayOfEndMonthComponents)!
            let isActiveDay = self.validateIsActiveDay(by: lastDate)
            _lastDayCache = CalendarDay(date: lastDate, isActive: isActiveDay)
        }
        
        return _lastDayCache ?? CalendarDay(date: Date(), isActive: true)
    }
    
    var cachedWeek: [CalendarDay] {
        guard _cachedWeek.isEmpty else { return _cachedWeek }
        let today = Date()
        let startWeekDate = today.startOfWeek(using: calendar)
        let endWeekDate = today.endOfWeek(using: calendar)
        let dates = Date.dates(from: startWeekDate, to: endWeekDate)
        
        let weekDays = dates.map { date in
            let isActiveDay = validateIsActiveDay(by: date)
            return CalendarDay(date: date, isActive: isActiveDay)
        }
        _cachedWeek = weekDays
        return weekDays
    }
}

// MARK: - UICollectionViewDataSource (implementation)
extension CalendarView: UICollectionViewDataSource {
  
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        guard self.dataSource != nil else { return 0 }
        
        switch style.viewType {
        case .month:
                        
            guard self.startDayCache.date <= self.endDayCache.date
            else { return 0 }
            
            // how many months should the whole calendar display?
            let numberOfMonths = self.calendar.dateComponents([.month], from: firstDayCache.date, to: lastDayCache.date).month!
            
            // if we are for example on the same month and the difference is 0 we still need 1 to display it
            return numberOfMonths + 1
            
        case .week:
            return 1
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch style.viewType {
        case .month:
            return 42 // rows:7 x cols:6
        case .week:
            return 7
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dayCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDayCell
        
        dayCell.style = style
        
        dayCell.transform = _isRtl
            ? CGAffineTransform(scaleX: -1.0, y: 1.0)
            : CGAffineTransform.identity
        
        switch style.viewType {
        case .month:
            configureMonthDayCell(dayCell, indexPath: indexPath)
        case .week:
            configureWeekDayCell(dayCell, indexPath: indexPath)
        }
                
        return dayCell
    }
}

// MARK: - Get cached month section info (internal)
internal extension CalendarView {
    func getCachedMonthSectionInfo(_ section: Int) -> (firstDay: Int, days: [CalendarDay])? {
        
        var result = _cachedMonths[section]
        if result != nil { return result! }
        
        var monthOffsetComponents = DateComponents()
        monthOffsetComponents.month = section
        
        guard let date = self.calendar.date(byAdding: monthOffsetComponents, to: firstDayCache.date)
        else { return nil }
        
        var firstWeekdayOfMonthIndex = self.calendar.component(.weekday, from: date)
        firstWeekdayOfMonthIndex -= style.firstWeekday == .monday ? 1 : 0
        firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex + 6) % 7 // push it modularly to map it in the range 0 to 6
        
        guard self.calendar.range(of: .day, in: .month, for: date) != nil
        else { return nil }
        
        let monthDates = date.getAllMonthDates(using: calendar)
        let monthDays = monthDates.map { date in
            let isActive = self.validateIsActiveDay(by: date)
            return CalendarDay(date: date, isActive: isActive)
        }
        result = (firstDay: firstWeekdayOfMonthIndex, days: monthDays)
        
        _cachedMonths[section] = result
        
        return result
    }
}

// MARK: - Configure week day cell (private)
private extension CalendarView {
    func configureWeekDayCell(_ cell: CalendarDayCell, indexPath: IndexPath) {
        cell.isHidden = false
        
        let day = self.cachedWeek[indexPath.row]
        cell.day = self.dayNumber(from: day)
        
        if calendar.isDateInToday(day.date) {
            cell.isToday = true
        } else {
            // Validate is active
            let today = Date()
            if day.date < today || day.date < self.startDayCache.date || day.date > self.endDayCache.date {
                cell.isOutOfRange = true
            } else {
                let isActive = self.validateIsActiveDay(by: day.date)
                print("Is active: \(isActive)")
                cell.isOutOfRange = !isActive
            }
            
            // Validate is selected
            guard let selectedDay = self.selectedDay,
                  selectedDay.date == day.date
            else {
                cell.isSelected = false
                return
            }
            cell.isSelected = true
        }
        print("ConfigureWeekDayCell: \(day.date)")
    }
}

// MARK: - Configure month day cell (private)
private extension CalendarView {
    func configureMonthDayCell(_ cell: CalendarDayCell, indexPath: IndexPath) {
        guard let (firstDayIndex, days) = self.getCachedMonthSectionInfo(indexPath.section)
        else { return }
        
        let lastDayIndex = firstDayIndex + days.count
        
        let isInRange = (firstDayIndex..<lastDayIndex).contains(indexPath.item)
        if isInRange {
            let dayIndex = (indexPath.item - firstDayIndex)
            let day = days[dayIndex]
            cell.isHidden = false
            cell.day = self.dayNumber(from: day)
            
            if calendar.isDateInToday(day.date) {
                cell.isToday = true
                cell.isOutOfRange = !day.isActive
            } else if day.date < Date() {
                cell.isOutOfRange = true
            } else {
                cell.isOutOfRange = !day.isActive
            }
           
        } else {
            cell.isHidden = true
            cell.textLabel.text = ""
        }
        
        // Validate is selected
        guard let selectedDay = self.selectedDay,
              let day = self.calendarDay(indexPath: indexPath),
              selectedDay.date == day.date
        else {
            cell.isSelected = false
            return
        }
        cell.isSelected = true
    }
}

// MARK: - Reset date caches (private)
private extension CalendarView {
    func resetDateCaches() {
        _startDayCache = nil
        _endDayCache = nil
        
        _firstDayCache = nil
        _lastDayCache = nil
        
        _cachedMonths.removeAll()
        _cachedWeek.removeAll()
    }
}
