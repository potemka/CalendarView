//
//  CalendarView+Style.swift
//  CalendarView
//
//  Created by Vitor Mesquita on 17/01/2018.
//  Copyright © 2018 Karmadust. All rights reserved.
//

import UIKit

extension CalendarView {
    
    public class Style {
        
        public static var Default: Style = Style()
        
        public enum CellShapeOptions {
            case round
            case square
            case bevel(CGFloat)
            var isRound: Bool {
                switch self {
                case .round:
                    return true
                default:
                    return false
                }
            }
        }
        
        public enum FirstWeekdayOptions{
            case sunday
            case monday
        }
        
        public enum CellOutOfRangeDisplayOptions {
            case normal
            case hidden
            case grayed
        }
        
        public enum WeekDaysTransform {
            case capitalized, uppercase
        }
        
        public enum CalendarViewType {
            case month
            case week
            
            func toogle() -> CalendarViewType {
                switch self {
                case .month:
                    return .week
                case .week:
                    return .month
                }
            }
        }
        
        public init(){}
        
        public var calendarHeight: CGFloat {
            switch viewType {
            case .month:
                return headerHeight + headerTopMargin + 7*weekdaysHeight
            case .week:
                return headerHeight + headerTopMargin + weekdaysHeight
            }
        }
        
        // MARK: Header
        public var headerHeight: CGFloat     = 94.0
        public var headerTopMargin: CGFloat  = 0.0
        public var headerTextColor           = UIColor.white
        public var headerBackgroundColor     = UIColor(hex: "#181a1f")
        public var headerFont                = UIFont.systemFont(ofSize: 16) // Used for the month
        
        // Header month
        public var headerMonthBorderColor    = UIColor(hex: "#a4a9bb")
        
        public var weekdaysTopMargin: CGFloat     = 12.0
        public var weekdaysBottomMargin: CGFloat  = 0.0
        public var weekdaysHeight: CGFloat        = 50.0
        public var weekdaysTextColor              = UIColor(hex: "#a5a9bb")
        public var weekdaysBackgroundColor        = UIColor(hex: "#181a1f")

        public var weekdaysFont                   = UIFont.systemFont(ofSize: 16) // Used for days of the week
        
        //Common
        public var commonBackground          = UIColor(hex: "#181a1f")
        public var cellShape                 = CellShapeOptions.round
        
        public var firstWeekday              = FirstWeekdayOptions.monday
        
        //Default Style
        public var cellColorDefault          = UIColor(hex: "#181a1f")
        public var cellTextColorDefault      = UIColor(hex: "#a5a9bb")
        public var cellBorderColor           = UIColor.clear
        public var cellBorderWidth           = CGFloat(0.0)
        public var cellFont                  = UIFont.systemFont(ofSize: 16)
        
        //Today Style
        public var cellTextColorToday        = UIColor(hex: "#a5a9bb")
        public var cellColorToday            = UIColor(hex: "#bdff00")
        public var cellColorOutOfRange       = UIColor(hex: "#5e5f61")
        
        //Selected Style
        public var cellSelectedBorderColor   = UIColor(hex: "#BDFF00")
        public var cellSelectedBorderWidth   = CGFloat(0.0)
        public var cellSelectedColor         = UIColor(hex: "#BDFF00")
        public var cellSelectedTextColor     = UIColor(hex: "#333333")
        
        //Locale Style
        public var locale                    = Locale.current
        
        //Calendar Identifier Style
        public lazy var calendar: Calendar   = {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(abbreviation: "UTC")!
            return calendar
        }()
        
        public var weekDayTransform = WeekDaysTransform.capitalized
        public var viewType: CalendarViewType = .week
        
    }
}

private extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
