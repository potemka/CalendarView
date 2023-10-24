/*
 * CalendarView+DataSource.swift
 * Created by Michael Michailidis on 24/10/2017.
 * http://blog.karmadust.com/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit

internal extension CalendarView {
    
    var startDateCache: Date {
        if _startDateCache == nil {
            _startDateCache = dataSource?.startDate()
        }
        
        return _startDateCache ?? Date()
    }
    
    var endDateCache: Date {
        if _endDateCache == nil {
            _endDateCache = dataSource?.endDate()
        }
        
        return _endDateCache ?? Date()
    }
    
    
    var firstDayCache: Date {
        if _firstDayCache == nil {
            let startDateComponents = self.calendar.dateComponents([.era, .year, .month, .day], from: startDateCache)
            
            var firstDayOfStartMonthComponents = startDateComponents
            firstDayOfStartMonthComponents.day = 1
            
            let firstDayOfStartMonthDate = self.calendar.date(from: firstDayOfStartMonthComponents)!
            
            _firstDayCache = firstDayOfStartMonthDate
        }
        
        return _firstDayCache ?? Date()
    }
    
    var lastDayCache: Date {
        if _lastDayCache == nil {
            var lastDayOfEndMonthComponents = self.calendar.dateComponents([.era, .year, .month], from: self.endDateCache)
            let range = self.calendar.range(of: .day, in: .month, for: self.endDateCache)!
            lastDayOfEndMonthComponents.day = range.count
            
            _lastDayCache = self.calendar.date(from: lastDayOfEndMonthComponents)!
        }
        
        return _lastDayCache ?? Date()
    }
    
    var cachedWeek: [Date] {
        guard _cachedWeek.isEmpty else { return _cachedWeek }
        let today = Date()
        let startWeekDate = today.startOfWeek(using: calendar)
        let endWeekDate = today.endOfWeek(using: calendar)
        return Date.dates(from: startWeekDate, to: endWeekDate)
    }
}

// MARK: - UICollectionViewDataSource (implementation)
extension CalendarView: UICollectionViewDataSource {
  
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        guard self.dataSource != nil else { return 0 }
        
        switch style.viewType {
        case .month:
            if dataSource?.startDate() != _startDateCache ||
                dataSource?.endDate() != _endDateCache {
                self.resetDateCaches()
            }
            
            guard self.startDateCache <= self.endDateCache else { fatalError("Start date cannot be later than end date.") }

            let startDateComponents = self.calendar.dateComponents([.era, .year, .month, .day], from: startDateCache)
            let endDateComponents = self.calendar.dateComponents([.era, .year, .month, .day], from: endDateCache)
            
            let local = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())!
            let today = Date().convertToTimeZone(from: self.calendar.timeZone, to: local)
            
            if (self.firstDayCache ... self.lastDayCache).contains(today) {
                
                let distanceFromTodayComponents = self.calendar.dateComponents([.month, .day], from: self.firstDayCache, to: today)
                
                self.todayIndexPath = IndexPath(item: distanceFromTodayComponents.day!, section: distanceFromTodayComponents.month!)
            }
            
            // how many months should the whole calendar display?
            let numberOfMonths = self.calendar.dateComponents([.month], from: firstDayCache, to: lastDayCache).month!
            
            // subtract one to include the day
            self.startIndexPath = IndexPath(item: startDateComponents.day! - 1, section: 0)
            self.endIndexPath = IndexPath(item: endDateComponents.day! - 1, section: numberOfMonths)
            
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
        
        dayCell.isHidden = true
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
        var result = _cachedMonthInfoForSection[section]
        
        if result != nil { return result! }
        
        var monthOffsetComponents = DateComponents()
        monthOffsetComponents.month = section
        
        let date = self.calendar.date(byAdding: monthOffsetComponents, to: firstDayCache)
        
        var firstWeekdayOfMonthIndex    = date == nil ? 0 : self.calendar.component(.weekday, from: date!)
        firstWeekdayOfMonthIndex       -= style.firstWeekday == .monday ? 1 : 0
        firstWeekdayOfMonthIndex        = (firstWeekdayOfMonthIndex + 6) % 7 // push it modularly to map it in the range 0 to 6
        
        guard let rangeOfDaysInMonth = date == nil ? nil : self.calendar.range(of: .day, in: .month, for: date!)
            else { return nil }
        
        result = (firstDay: firstWeekdayOfMonthIndex, daysTotal: rangeOfDaysInMonth.count)
        
        _cachedMonthInfoForSection[section] = result
        
        return result
    }
}

// MARK: - Configure week day cell (private)
private extension CalendarView {
    func configureWeekDayCell(_ cell: CalendarDayCell, indexPath: IndexPath) {
        let date = self.cachedWeek[indexPath.row]
        let dateComponents = calendar.dateComponents([.day], from: date)
        cell.isHidden = false
        cell.day = dateComponents.day
        
        print("ConfigureWeekDayCell: \(date)")
        
        if calendar.isDateInToday(date) {
            cell.isToday = true
        } else {
            let today = Date()
            if date < today || date < self.startDateCache || date > self.endDateCache {
                cell.isOutOfRange = true
            } else {
                cell.isOutOfRange = false
            }
        }
        
        if let selectedDate = self.selectedDate, date == selectedDate {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
    }
}

// MARK: - Configure month day cell (private)
private extension CalendarView {
    func configureMonthDayCell(_ cell: CalendarDayCell, indexPath: IndexPath) {
        guard let (firstDayIndex, numberOfDaysTotal) = self.getCachedMonthSectionInfo(indexPath.section)
        else { return }
        
        let lastDayIndex = firstDayIndex + numberOfDaysTotal
        
        let cellOutOfRange = { (indexPath: IndexPath) -> Bool in
            
            var isOutOfRange = false
            
            if self.startIndexPath.section == indexPath.section { // is 0
                isOutOfRange = self.startIndexPath.item + firstDayIndex > indexPath.item
            }
            if self.endIndexPath.section == indexPath.section && !isOutOfRange {
                isOutOfRange = self.endIndexPath.item + firstDayIndex < indexPath.item
            }
            
            return isOutOfRange
            
        }
        
        let isSelected: Bool = {
            guard let selectedDate = self.selectedDate,
                  let date = self.dateFromIndexPath(indexPath)
            else { return false }
            return date == selectedDate
        }()
        
        let isInRange = (firstDayIndex..<lastDayIndex).contains(indexPath.item)
       
        let isPassedDate: Bool = {
            guard let date = self.dateFromIndexPath(indexPath)
            else { return false }
            if calendar.isDateInToday(date) {
                return false
            } else if date < Date() {
                return true
            }
            return false
        }()
        
        // the index of this cell is within the range of first and the last day of the month
        if isInRange {
            cell.isHidden = false
            
            // ex. if the first is wednesday (index of 3), subtract 2 to show it as 1
            cell.day = (indexPath.item - firstDayIndex) + 1
            cell.isOutOfRange = cellOutOfRange(indexPath) || isPassedDate
            
        } else {
            cell.isHidden = true
            cell.textLabel.text = ""
        }
        
        // hack: send once at the beginning
        if indexPath.section == 0 && indexPath.item == 0 {
            self.scrollViewDidEndDecelerating(collectionView)
        }
        
        guard !cell.isOutOfRange else { return  }
        
        // if is in range continue with additional styling
        
        if let idx = self.todayIndexPath {
            cell.isToday = (idx.section == indexPath.section && idx.item + firstDayIndex == indexPath.item)
        }
        
        if isSelected {
            cell.isSelected = true
        }
    }
}

// MARK: - Reset date caches (private)
private extension CalendarView {
    func resetDateCaches() {
        _startDateCache = nil
        _endDateCache = nil
        
        _firstDayCache = nil
        _lastDayCache = nil
        
        _cachedMonthInfoForSection.removeAll()
    }
}
