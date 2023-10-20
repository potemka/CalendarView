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
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let style = CalendarView.Style()
        
        
        //        style.cellShape                = .bevel(8.0)
        //        style.cellColorDefault         = UIColor.clear
        //        style.cellColorToday           = UIColor(red:1.00, green:0.84, blue:0.64, alpha:1.00)
        //        style.cellSelectedBorderColor  = UIColor(red:1.00, green:0.63, blue:0.24, alpha:1.00)
        //        style.cellEventColor           = UIColor(red:1.00, green:0.63, blue:0.24, alpha:1.00)
        //        style.headerTextColor          = UIColor.gray
        //
        //        style.cellTextColorDefault     = UIColor(red: 249/255, green: 180/255, blue: 139/255, alpha: 1.0)
        //        style.cellTextColorToday       = UIColor.orange
        //        style.cellTextColorWeekend     = UIColor(red: 237/255, green: 103/255, blue: 73/255, alpha: 1.0)
        //        style.cellColorOutOfRange      = UIColor(red: 249/255, green: 226/255, blue: 212/255, alpha: 1.0)
        //
        //        style.headerBackgroundColor    = UIColor.white
        //        style.weekdaysBackgroundColor  = UIColor.white
        //        style.firstWeekday             = .sunday
        //
        //        style.locale                   = Locale(identifier: "en_US")
        //
        //        style.cellFont = UIFont(name: "Helvetica", size: 20.0) ?? UIFont.systemFont(ofSize: 20.0)
        //        style.headerFont = UIFont(name: "Helvetica", size: 20.0) ?? UIFont.systemFont(ofSize: 20.0)
        //        style.weekdaysFont = UIFont(name: "Helvetica", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
        //
        calendarView.style = style
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.direction = .horizontal
        calendarView.multipleSelectionEnable = false
        calendarView.marksWeekends = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let today = Date()
        
        var tomorrowComponents = DateComponents()
        tomorrowComponents.day = 1
        
        
        let tomorrow = self.calendarView.calendar.date(byAdding: tomorrowComponents, to: today)!
        self.calendarView.selectDate(tomorrow)
        
        self.calendarView.setDisplayDate(today)
        
        self.datePicker.locale = self.calendarView.style.locale
        self.datePicker.timeZone = self.calendarView.calendar.timeZone
        self.datePicker.setDate(today, animated: false)
    }
    
    
    // MARK : Events
    
    @IBAction func onValueChange(_ picker : UIDatePicker) {
        self.calendarView.setDisplayDate(picker.date, animated: true)
    }
    
    @IBAction func goToPreviousMonth(_ sender: Any) {
        self.calendarView.goToPreviousMonth()
    }
    @IBAction func goToNextMonth(_ sender: Any) {
        self.calendarView.goToNextMonth()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


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
        
          dateComponents.month = 12
          let today = Date()
          
          let twoYearsFromNow = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
          
          return twoYearsFromNow
    
      }
    
}

extension ViewController: CalendarViewDelegate {
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date) {
           print("Did Select: \(date)")
    }
       
   func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
       print(self.calendarView.selectedDates)
       
       self.datePicker.setDate(date, animated: true)
   }
   
   
   func calendar(_ calendar: CalendarView, didLongPressDate date : Date) {
   }
}






