/*
 * ViewController.swift
 * Created by Michael Michailidis on 01/04/2015.
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
        calendarView.multipleSelectionEnable = false
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

// MARK: - CalendarViewDelegate (implementation)
extension ViewController: CalendarViewDelegate {
    func calendar(_ calendar: CalendarView, didChangeViewType viewType: CalendarView.Style.CalendarViewType) {
        print("Calendar viewType did change: \(viewType == .month ? "month" : "week")")
        
        self.changeCalendarViewType(viewType)
    }
    
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date) {
        print("Did Select: \(date)")
    }
       
   func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {       
       self.datePicker.setDate(date, animated: true)
   }
   
   func calendar(_ calendar: CalendarView, didLongPressDate date : Date) { }
}

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

