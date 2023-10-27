
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var calendarViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let style = CalendarView.Style()
        
        calendarView.style = style
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.direction = .horizontal
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let today = Date()
        
        var tomorrowComponents = DateComponents()
        tomorrowComponents.day = 1
        
        
//        let tomorrow = self.calendarView.calendar.date(byAdding: tomorrowComponents, to: today)!
//        self.calendarView.selectDate(tomorrow)
        
        self.calendarView.setDisplayDate(today)
        
        self.datePicker.locale = self.calendarView.style.locale
        self.datePicker.timeZone = self.calendarView.calendar.timeZone
        self.datePicker.setDate(today, animated: false)
        
        self.changeCalendarViewType(calendarView.viewType)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func onValueChange(_ picker : UIDatePicker) {
        self.calendarView.setDisplayDate(picker.date, animated: true)
    }
}

// MARK: - CalendarViewDataSource (implementation)
extension ViewController: CalendarViewDataSource {
    
    func days() -> [CalendarDay] {
        let startDate = self.startDate()
        let endDate = self.endDate()
        let dates = Date.dates(from: startDate, to: endDate)
        let calendarDays: [CalendarDay] = dates.enumerated().map { (index,date) in
            let isActive: Bool = {
                if index == dates.count - 2 {
                    return false
                } else { return true }
            }()
            return CalendarDay(date: date, isActive: isActive)
        }
        return calendarDays
    }
}

// MARK: - CalendarViewDelegate (implementation)
extension ViewController: CalendarViewDelegate {

    func calendar(_ calendar: CalendarView, didScrollToMonth day: CalendarDay) {
        self.datePicker.setDate(day.date, animated: true)
    }
    
    func calendar(_ calendar: CalendarView, didChangeViewType viewType: CalendarView.Style.CalendarViewType) {
        print("Calendar viewType did change: \(viewType == .month ? "month" : "week")")
        
        self.changeCalendarViewType(viewType)
    }
    
    func calendar(_ calendar: CalendarView, didSelectDay day: CalendarDay) {
        print("Did Select: \(day.date)")
    }
}

// MARK: - Generate Start/end dates (private)
private extension ViewController {
    func startDate() -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.month = -1
        
        let today = Date()
        
        let threeMonthsAgo = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
        
        return threeMonthsAgo
    }
    
    func endDate() -> Date {
        
        var dateComponents = DateComponents()
      
        dateComponents.day = 5
        let today = Date()
        
        let twoYearsFromNow = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
        
        return twoYearsFromNow
  
    }
}

// MARK: - Change calendar type (private)
private extension ViewController {
    func changeCalendarViewType(_ viewType: CalendarView.Style.CalendarViewType) {
        DispatchQueue.main.async { [weak self] in
            guard let calendarView = self?.calendarView else { return }
            
            self?.calendarViewHeightConstraint?.constant = calendarView.style.calendarHeight
            UIView.animate(withDuration: 0.2) {
                self?.view.layoutIfNeeded()
            }
        }
    }
}

