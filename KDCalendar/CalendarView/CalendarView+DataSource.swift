
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
        return dates.map { date in
            let isActiveDay = validateIsActiveDay(by: date)
            return CalendarDay(date: date, isActive: isActiveDay)
        }
    }
}

// MARK: - UICollectionViewDataSource (implementation)
extension CalendarView: UICollectionViewDataSource {
  
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        guard let dataSource = self.dataSource else { return 0 }
        
        switch style.viewType {
        case .month:
            
            // Непонятная проверка - чего дает?
//            if dataSource.startDate() != _startDateCache ||
//                dataSource?.endDate() != _endDateCache {
//                self.resetDateCaches()
//            }
            
            guard self.startDayCache.date <= self.endDayCache.date
            else { return 0 }

            let startDateComponents = self.calendar.dateComponents([.era, .year, .month, .day], from: startDayCache.date)
            let endDateComponents = self.calendar.dateComponents([.era, .year, .month, .day], from: endDayCache.date)
            
            let local = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())!
            let today = Date().convertToTimeZone(from: self.calendar.timeZone, to: local)
            
            // Устанавливается todayIndexPath, нужно ли это?
//            if (self.firstDayCache.date ... self.lastDayCache.date).contains(today) {
//                
//                let distanceFromTodayComponents = self.calendar.dateComponents([.month, .day], from: self.firstDayCache.date, to: today)
//                
//                self.todayIndexPath = IndexPath(item: distanceFromTodayComponents.day!, section: distanceFromTodayComponents.month!)
//            }
            
            // how many months should the whole calendar display?
            let numberOfMonths = self.calendar.dateComponents([.month], from: firstDayCache.date, to: lastDayCache.date).month!
            
            // TODO: - Устанавливается startIndexPath и endIndexPath, разобраться для чего
            // subtract one to include the day
//            self.startIndexPath = IndexPath(item: startDateComponents.day! - 1, section: 0)
//            self.endIndexPath = IndexPath(item: endDateComponents.day! - 1, section: numberOfMonths)
            
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
    func getCachedMonthSectionInfo(_ section: Int) -> (firstDay: Int, daysTotal: Int)? {
//        var result = _cachedMonthInfoForSection[section]
//        
//        if result != nil { return result! }
//        
//        var monthOffsetComponents = DateComponents()
//        monthOffsetComponents.month = section
//        
//        let date = self.calendar.date(byAdding: monthOffsetComponents, to: firstDayCache)
//        
//        var firstWeekdayOfMonthIndex    = date == nil ? 0 : self.calendar.component(.weekday, from: date!)
//        firstWeekdayOfMonthIndex       -= style.firstWeekday == .monday ? 1 : 0
//        firstWeekdayOfMonthIndex        = (firstWeekdayOfMonthIndex + 6) % 7 // push it modularly to map it in the range 0 to 6
//        
//        guard let rangeOfDaysInMonth = date == nil ? nil : self.calendar.range(of: .day, in: .month, for: date!)
//            else { return nil }
//        
//        result = (firstDay: firstWeekdayOfMonthIndex, daysTotal: rangeOfDaysInMonth.count)
//        
//        _cachedMonthInfoForSection[section] = result
//        
//        return result
        
        return nil
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
                    let isActive = self.validateIsActiveDay(by: day.date)
                    cell.isOutOfRange = isActive
            } else {
                cell.isOutOfRange = false
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
//        guard let (firstDayIndex, numberOfDaysTotal) = self.getCachedMonthSectionInfo(indexPath.section)
//        else { return }
//        
//        let lastDayIndex = firstDayIndex + numberOfDaysTotal
//        
//        let cellOutOfRange = { (indexPath: IndexPath) -> Bool in
//            
//            var isOutOfRange = false
//            
//            if self.startIndexPath.section == indexPath.section { // is 0
//                isOutOfRange = self.startIndexPath.item + firstDayIndex > indexPath.item
//            }
//            if self.endIndexPath.section == indexPath.section && !isOutOfRange {
//                isOutOfRange = self.endIndexPath.item + firstDayIndex < indexPath.item
//            }
//            
//            return isOutOfRange
//            
//        }
//        
//        let isSelected: Bool = {
//            guard let selectedDate = self.selectedDate,
//                  let date = self.dateFromIndexPath(indexPath)
//            else { return false }
//            return date == selectedDate
//        }()
//        
//        let isInRange = (firstDayIndex..<lastDayIndex).contains(indexPath.item)
//       
//        let isPassedDate: Bool = {
//            guard let date = self.dateFromIndexPath(indexPath)
//            else { return false }
//            if calendar.isDateInToday(date) {
//                return false
//            } else if date < Date() {
//                return true
//            }
//            return false
//        }()
//        
//        // the index of this cell is within the range of first and the last day of the month
//        if isInRange {
//            cell.isHidden = false
//            
//            // ex. if the first is wednesday (index of 3), subtract 2 to show it as 1
//            cell.day = (indexPath.item - firstDayIndex) + 1
//            cell.isOutOfRange = cellOutOfRange(indexPath) || isPassedDate
//            
//        } else {
//            cell.isHidden = true
//            cell.textLabel.text = ""
//        }
//        
//        // hack: send once at the beginning
//        if indexPath.section == 0 && indexPath.item == 0 {
//            self.scrollViewDidEndDecelerating(collectionView)
//        }
//        
//        guard !cell.isOutOfRange else { return  }
//        
//        // if is in range continue with additional styling
//        
//        if let idx = self.todayIndexPath {
//            cell.isToday = (idx.section == indexPath.section && idx.item + firstDayIndex == indexPath.item)
//        }
//        
//        if isSelected {
//            cell.isSelected = true
//        }
    }
}

// MARK: - Reset date caches (private)
private extension CalendarView {
    func resetDateCaches() {
        _startDayCache = nil
        _endDayCache = nil
        
        _firstDayCache = nil
        _lastDayCache = nil
        
        _cachedMonth.removeAll()
        _cachedWeek.removeAll()
    }
}
