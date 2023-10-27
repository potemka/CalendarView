
import UIKit

extension CalendarView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch viewType {
        case .week:
            var day = self.cachedWeek[indexPath.row]
            day.isActive = !day.isActive
            _cachedWeek[indexPath.row] = day
            
            // TODO: - Обновить данные для месяца?
            if day.isActive {
                self.selectedDay = day
                self.delegate?.calendar(self, didSelectDay: day)
            } else {
                self.selectedDay = nil
                self.delegate?.calendar(self, didDeselectDay: day)
            }
           
        case .month:
            guard let date = self.dateFromIndexPath(indexPath) else { return }
    
            if let currentCell = collectionView.cellForItem(at: indexPath) as? CalendarDayCell, currentCell.isOutOfRange  {
                return
            }
            
    
//            if let selectedDate = self.selectedDay?.date {
//                self.selectedDay = nil
//                if let selectedIndexPath = self.indexPathForDate(selectedDate) {
//                    self.collectionView.deselectItem(at: selectedIndexPath, animated: false)
//                }
//            }
            
        }
        
//        guard let date = self.dateFromIndexPath(indexPath) else { return }
//        
//        if let currentCell = collectionView.cellForItem(at: indexPath) as? CalendarDayCell, currentCell.isOutOfRange  {
//            return
//        }
//        
//        if let selectedDate = self.selectedDate {
//            self.selectedDate = nil
//            if let selectedIndexPath = self.indexPathForDate(selectedDate) {
//                self.collectionView.deselectItem(at: selectedIndexPath, animated: false)
//            }
//        }
//        
//        self.selectedDate = date
//        
//        delegate?.calendar(self, didSelectDate: date)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        guard let date = self.dateFromIndexPath(indexPath) else { return }
//        self.selectedDate = nil
//        delegate?.calendar(self, didDeselectDate: date)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let day = self.calendarDay(indexPath: indexPath) else { return false}
        let today = Date()
        if calendar.isDateInToday(day.date) {
            return day.isActive
        } else if day.date < today {
            return false
        } else { return day.isActive}
    }
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateAndNotifyScrolling()
        
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.updateAndNotifyScrolling()
    }
    
    func updateAndNotifyScrolling() {
//        if viewType == .month {
//            guard let date = self.dateFromScrollViewPosition() else { return }
//            
//            self.displayDateOnHeader(date)
//            self.delegate?.calendar(self, didScrollToMonth: date)
//        }
    }

    @discardableResult
    func dateFromScrollViewPosition() -> Date? {
//        var page: Int = 0
//        
//        switch self.direction {
//        case .horizontal:
//            let offsetX = ceilf(Float(self.collectionView.contentOffset.x))
//            let width = self.collectionView.bounds.size.width
//            page = Int(floor(offsetX / Float(width)))
//        case .vertical:
//            let offsetY = ceilf(Float(self.collectionView.contentOffset.y))
//            let height = self.collectionView.bounds.size.height
//            page = Int(floor(offsetY / Float(height)))
//        @unknown default:
//            fatalError()
//        }
//        
//        page = page > 0 ? page : 0
//        
//        var monthsOffsetComponents = DateComponents()
//        monthsOffsetComponents.month = page
//        
//        return self.calendar.date(byAdding: monthsOffsetComponents, to: self.firstDayCache);
        
        return nil
    }
}
