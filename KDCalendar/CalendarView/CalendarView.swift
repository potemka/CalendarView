/*
 * CalendarView.swift
 * Created by Michael Michailidis on 02/04/2015.
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

// MARK: CalendarViewDataSource (protocol)
public protocol CalendarViewDataSource {
    func startDate() -> Date
    func endDate() -> Date
}

extension CalendarViewDataSource {
    
    func startDate() -> Date {
        return Date()
    }
    func endDate() -> Date {
        return Date()
    }
}

// MARK: - CalendarViewDelegate (protocol)
public protocol CalendarViewDelegate {
    
    func calendar(_ calendar : CalendarView, didScrollToMonth date : Date) -> Void
    func calendar(_ calendar : CalendarView, didSelectDate date : Date) -> Void
    func calendar(_ calendar: CalendarView, didChangeViewType viewType: CalendarView.Style.CalendarViewType) -> Void
    /* optional */
    func calendar(_ calendar : CalendarView, canSelectDate date : Date) -> Bool
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date) -> Void
    func calendar(_ calendar : CalendarView, didLongPressDate date : Date) -> Void
}

extension CalendarViewDelegate {
    func calendar(_ calendar : CalendarView, canSelectDate date : Date) -> Bool { return true }
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date) -> Void { return }
    func calendar(_ calendar : CalendarView, didLongPressDate date : Date) -> Void { return }
}

// MARK: - CalendarView
public class CalendarView: UIView {
    
    internal let cellReuseIdentifier = "CalendarDayCell"
    
    // MARK: Subviews
    var headerView: CalendarHeaderView!
    var collectionView: UICollectionView!
    
    // MARK: - Public properties
    
    public internal(set) var selectedDate: Date?
    
    public var forceLtr: Bool = true {
        didSet {
            updateLayoutDirections()
        }
    }
    
    public var style: Style = Style.Default {
        didSet {
            updateStyle()
        }
    }
    
    public var viewType: Style.CalendarViewType {
        get { style.viewType }
        set {
            guard newValue != style.viewType else { return }
            self.style.viewType = newValue
            
            reloadData()
        }
    }
    
    public var calendar : Calendar {
        return style.calendar
    }

    internal var _startDateCache: Date?
    internal var _endDateCache: Date?
    internal var _firstDayCache: Date?
    internal var _lastDayCache: Date?
    internal var _currentWeekDay: Int?
    
    internal var todayIndexPath : IndexPath?
    internal var startIndexPath : IndexPath!
    internal var endIndexPath   : IndexPath!

    internal var _cachedMonthInfoForSection = [Int:(firstDay: Int, daysTotal: Int)]()
    internal var _cachedWeek: [Date] = []
    
    var flowLayout: CalendarFlowLayout {
        return self.collectionView.collectionViewLayout as! CalendarFlowLayout
    }
    
    public internal(set) var displayDate: Date?
    public var multipleSelectionEnable = false
    
    // Delegates
    public var delegate: CalendarViewDelegate?
    public var dataSource: CalendarViewDataSource?
    
    public var direction : UICollectionView.ScrollDirection = .horizontal {
        didSet {
            flowLayout.scrollDirection = direction
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setupSubviews()
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        
        guard gesture.state == UIGestureRecognizer.State.began
        else { return }
        
        let point = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: point),
            let date = self.dateFromIndexPath(indexPath)
        else { return }
 
        self.delegate?.calendar(self, didLongPressDate: date)
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.headerView?.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.frame.size.width,
            height: style.headerHeight
        )
        
        self.collectionView?.frame = CGRect(
            x: 0.0,
            y: style.headerHeight,
            width: self.frame.size.width,
            height: self.frame.size.height - style.headerHeight
        )
        
        flowLayout.itemSize = self.cellSize(in: self.bounds)
        
        self.resetDisplayDate()
    }
    
    private func cellSize(in bounds: CGRect) -> CGSize {
        guard let collectionView = self.collectionView
            else {
                return .zero
            }
        switch viewType {
        case .month:
            return CGSize(
                
                width:   collectionView.bounds.width / 7.0,                                    // number of days in week
                height: (collectionView.bounds.height) / 6.0 // maximum number of rows
            )
        case .week:
            let width =  collectionView.bounds.width / 7.0
            return CGSize(width: width, height: style.weekdaysHeight)
            
            return CGSize(
                
                width:   collectionView.bounds.width / 7.0,                                    // number of days in week
                height: (collectionView.bounds.height) / 6.0 // maximum number of rows
            )
        }
   
    }
    
    internal var _isRtl = false
    
    internal func updateLayoutDirections() {
        self.collectionView?.semanticContentAttribute = .forceLeftToRight
        self.headerView?.semanticContentAttribute = forceLtr ? .forceLeftToRight : .unspecified
        
        var isRtl = false
        
        if !forceLtr {
            isRtl = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
            isRtl = self.effectiveUserInterfaceLayoutDirection == .rightToLeft
        }
        
        if _isRtl != isRtl {
            _isRtl = isRtl
            
            self.collectionView?.transform = isRtl
                ? CGAffineTransform(scaleX: -1.0, y: 1.0)
                : CGAffineTransform.identity
            self.collectionView?.reloadData()
        }
    }
    
    internal func resetDisplayDate() {
        guard let displayDate = self.displayDate else { return }
        
        self.collectionView.setContentOffset(
            self.scrollViewOffset(for: displayDate),
            animated: false
        )
    }
    
    internal func updateStyle() {
        self.headerView?.style = style
    }
    
    func scrollViewOffset(for date: Date) -> CGPoint {
        var point = CGPoint.zero
        
        guard let sections = self.indexPathForDate(date)?.section else { return point }
        
        switch self.direction {
        case .horizontal:   point.x = CGFloat(sections) * self.collectionView.frame.size.width
        case .vertical:     point.y = CGFloat(sections) * self.collectionView.frame.size.height
        @unknown default:
            fatalError()
        }
        
        return point
    }
}

// MARK: - CalendarHeaderDelegate (implementation)
extension CalendarView: CalendarHeaderDelegate {
    func calendarHeaderDidOccurAction(_ action: CalendarHeaderAction) {
        switch action {
            
        case .down, .up:
            let toogleViewType = self.style.viewType.toogle()
            self.style.viewType = toogleViewType
            self.headerView.style = style
            
            self.delegate?.calendar(self, didChangeViewType: viewType)
            
            if self.style.viewType == .month {
                
                let display: Date = {
                    guard let selectDate = self.selectedDate
                    else {
                        guard let firstWeekdate = self.cachedWeek.first
                        else { return Date() }
                        return firstWeekdate
                    }
                    return selectDate
                }()
                self.setDisplayDate(display)
                
                guard let selectedDate = self.selectedDate else { return }
                self.selectDate(selectedDate)
 
            } else {
                let displayDate: Date = {
                    guard let selectDate = self.selectedDate
                    else {
                        guard let displayDate = self.displayDate
                        else { 
                            return Date()
                        }
                        return displayDate
                    }
                    return selectDate
                }()
                self.setDisplayDate(displayDate)
                
                guard let selectedDate = self.selectedDate else { return }
                self.selectDate(selectedDate)
            }
            
        case .left:
            handleLeftButtonAction()
        case .right:
            handleRightButtonAction()
        }
    }
}

// MARK: - Public methods
extension CalendarView {
    
    /*
     method: - reloadData
     function: - reload all components in collection view
     */
    public func reloadData() {
        self.collectionView.reloadData()
    }
    
    /*
     method: - setDisplayDate
     params:
     - date: Date to extract month and year to scroll at correct section;
     - animated: to handle animation if want;
     function: - scroll calendar at date (month/year) passed as parameter.
     */
    public func setDisplayDate(_ date : Date, animated: Bool = false) {
        guard (startDateCache..<endDateCache).contains(date)
        else { return }
        
        self.collectionView?.reloadData()
        self.collectionView?.setContentOffset(self.scrollViewOffset(for: date), animated: animated)
        self.displayDateOnHeader(date)
    }
    
    /*
     method: - selectDate
     params:
     - date: Date to select;
     function: - mark date as selected and add it to the array of selected dates
     */
    public func selectDate(_ date : Date) {
        guard let indexPath = self.indexPathForDate(date) else { return }
        if viewType == .month {
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition())
        } else {
            self.collectionView.reloadData()
        }
       
//        self.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    /*
     method: - deselectDate
     params:
     - date: Date to deselect;
     function: - unmark date as selected and remove it from the array of selected dates
     */
    public func deselectDate(_ date : Date) {
        guard let indexPath = self.indexPathForDate(date) else { return }
        self.collectionView.deselectItem(at: indexPath, animated: false)
//        self.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    /*
     method: - goToNextMonth
     function: - scroll the calendar by one month in the future
     */
    public func goToNextMonth() {
        goToMonthWithOffet(1)
    }
    
    /*
     method: - goToPreviousMonth
     function: - scroll the calendar by one month in the past
     */
    public func goToPreviousMonth() {
        goToMonthWithOffet(-1)
    }
    
    public func goToNextWeek() {
        goToWeekWithOffset(1)
    }
    
    public func goToPrevWeek() {
        goToWeekWithOffset(-1)
    }

    /*
     method: - clearAllSelectedDates
     function: - clear all selected dates.  Does not call `didDeselectDate` callback
     */
    public func clearAllSelectedDates() {
        self.selectedDate = nil
        self.reloadData()
    }
}

// MARK: - Setup subviews (private)
private extension CalendarView {
    func setupSubviews() {
        
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = self.style.commonBackground
        
        /* Header View */
        self.headerView = CalendarHeaderView(frame:CGRect.zero)
        self.headerView.style = style
        self.headerView.delegate = self
        self.addSubview(self.headerView)
        
        self.headerView.backgroundColor = .red
        
        /* Layout */
        let layout = CalendarFlowLayout()
        layout.scrollDirection = self.direction;
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        /* Collection View */
        self.collectionView                     = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.dataSource          = self
        self.collectionView.delegate            = self
        self.collectionView.isPagingEnabled     = true
        self.collectionView.backgroundColor     = UIColor.clear
        self.collectionView.showsHorizontalScrollIndicator  = false
        self.collectionView.showsVerticalScrollIndicator    = false
        self.collectionView.allowsMultipleSelection         = true
        self.collectionView.isMultipleTouchEnabled = false
        self.collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        self.addSubview(self.collectionView)
        
        // Update semantic content attributes
        updateLayoutDirections()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(CalendarView.handleLongPress))
        self.collectionView.addGestureRecognizer(longPress)
        
    }
}

// MARK: - Handle left/right header button action (private)
private extension CalendarView {
    func handleLeftButtonAction() {
        switch self.style.viewType {
        case.month:
            goToPreviousMonth()
        case .week:
            goToPrevWeek()
        }
    }
    
    func handleRightButtonAction() {
        switch self.style.viewType {
        case .month:
            goToNextMonth()
        case .week:
            goToNextWeek()
        }
    }
}

// MARK: - Go to month with offset (private)
private extension CalendarView {
    func goToMonthWithOffet(_ offset: Int) {
        guard let displayDate = self.displayDate else { return }
        var dateComponents = DateComponents()
        dateComponents.month = offset
        guard let newDate = self.calendar.date(byAdding: dateComponents, to: displayDate) else { return }
        self.setDisplayDate(newDate, animated: true)
        
        guard let selectedDate = self.selectedDate
        else { return }
        self.selectDate(selectedDate)
    }
}

// MARK: - Go to week with offset (private)
private extension CalendarView {
    func goToWeekWithOffset(_ offset: Int) {
        guard let displayDate = self.displayDate else { return }
        var dateComponents = DateComponents()
        dateComponents.weekOfYear = offset
        guard let newDate = self.calendar.date(byAdding: dateComponents, to: displayDate) else { return }
        
        self.updateCachedWeek(by: newDate)
        self.setDisplayDate(newDate, animated: true)
        
        guard let selectedDate = self.selectedDate
        else { return }
        self.selectDate(selectedDate)
    }
}

// MARK: - Update cached week (private)
private extension CalendarView {
    func updateCachedWeek(by date: Date) {
        _cachedWeek = Date.dates(from: date.startOfWeek(using: calendar), to: date.endOfWeek(using: calendar))
    }
}

// MARK: Convertions methods (private)
extension CalendarView {
    func indexPathForDate(_ date : Date) -> IndexPath? {
        switch style.viewType {
        case .month:
            let distanceFromStartDate = self.calendar.dateComponents([.month, .day], from: self.firstDayCache, to: date)
            
            guard let day = distanceFromStartDate.day,
                  let month = distanceFromStartDate.month,
                  let (firstDayIndex, _) = getCachedMonthSectionInfo(month)
            else { return nil }
            
            return IndexPath(item: day + firstDayIndex, section: month)
        case .week:
            guard let index = cachedWeek.firstIndex(where: { $0 == date })
            else { return nil }
            return IndexPath(item: index, section: 0)
        }
    }
    
    func dateFromIndexPath(_ indexPath: IndexPath) -> Date? {
        switch style.viewType {
        case .month:
            let month = indexPath.section
            
            guard let monthInfo = getCachedMonthSectionInfo(month) else { return nil }
            
            var components      = DateComponents()
            components.month    = month
            components.day      = indexPath.item - monthInfo.firstDay
            
            return self.calendar.date(byAdding: components, to: self.firstDayCache)
        case .week:
            return cachedWeek[indexPath.row]
        }
    }
}
