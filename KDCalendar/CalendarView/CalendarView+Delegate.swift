
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
}
