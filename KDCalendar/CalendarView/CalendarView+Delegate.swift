
import UIKit

extension CalendarView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let isNeedSelect = self.selectedDay == nil
        
        if let selectedDate = self.selectedDay?.date, let selectedIndexPath = self.indexPathForDate(selectedDate) {
            self.selectedDay = nil
            collectionView.deselectItem(at: selectedIndexPath, animated: false)
        }
        
        guard isNeedSelect, let selectedDay = self.calendarDay(indexPath: indexPath)
        else { return }
        
        self.selectedDay = selectedDay
        self.delegate?.calendar(self, didSelectDay: selectedDay)
  
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
