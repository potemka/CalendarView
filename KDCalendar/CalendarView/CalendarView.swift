
import UIKit

// MARK: CalendarViewDataSource (protocol)
public protocol CalendarViewDataSource {
    func days() -> [CalendarDay]
}

// MARK: - CalendarViewDelegate (protocol)
public protocol CalendarViewDelegate {
    
    func calendar(_ calendar : CalendarView, didScrollToMonth day : CalendarDay) -> Void
    func calendar(_ calendar : CalendarView, didSelectDay day : CalendarDay) -> Void
    func calendar(_ calendar: CalendarView, didChangeViewType viewType: CalendarView.Style.CalendarViewType) -> Void
    
    /* optional */
    func calendar(_ calendar : CalendarView, didDeselectDay day : CalendarDay) -> Void
    func calendar(_ calendar : CalendarView, didLongPressDay day : CalendarDay) -> Void
}

extension CalendarViewDelegate {
    func calendar(_ calendar : CalendarView, didDeselectDay day : CalendarDay) -> Void { return }
    func calendar(_ calendar : CalendarView, didLongPressDay day : CalendarDay) -> Void { return }
}

// MARK: - CalendarView
public class CalendarView: UIView {
    
    internal let cellReuseIdentifier = "CalendarDayCell"
    
    // MARK: Subviews
    var headerView: CalendarHeaderView!
    var collectionView: UICollectionView!
    
    // MARK: - Public properties
    
    public internal(set) var selectedDay: CalendarDay?
    
    public var forceLtr: Bool = true {
        didSet {
            updateLayoutDirections()
        }
    }
    
    public var style: Style = Style.Default {
        didSet {
            self.headerView?.style = style
        }
    }
    
    public var viewType: Style.CalendarViewType {
        get { style.viewType }
        set {
            guard newValue != style.viewType else { return }
            self.style.viewType = newValue
        }
    }
    
    public var calendar : Calendar {
        return style.calendar
    }

    internal var _startDayCache: CalendarDay?
    internal var _endDayCache: CalendarDay?
    internal var _firstDayCache: CalendarDay?
    internal var _lastDayCache: CalendarDay?

    internal var _cachedMonths = [Int:(firstDay: Int, days: [CalendarDay])]()
    internal var _cachedWeek: [CalendarDay] = []
    
    var flowLayout: CalendarFlowLayout {
        return self.collectionView.collectionViewLayout as! CalendarFlowLayout
    }
    
    public internal(set) var displayDate: Date?
    
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
    
    internal var _isRtl = false
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
                    guard let selectDate = self.selectedDay?.date
                    else {
                        guard let firstWeekdate = self.cachedWeek.first?.date
                        else { return Date() }
                        return firstWeekdate
                    }
                    return selectDate
                }()
                self.setDisplayDate(display)
                
                guard let selectedDate = self.selectedDay?.date else { return }
                self.selectDate(selectedDate)
 
            } else {
                let displayDate: Date = {
                    guard let selectDate = self.selectedDay?.date
                    else {
                        guard let displayDate = self.displayDate
                        else {  return Date() }
                        return displayDate
                    }
                    return selectDate
                }()
                self.setDisplayDate(displayDate)
                
                guard let selectedDate = self.selectedDay?.date else { return }
                self.selectDate(selectedDate)
            }
            break
            
        case .left:
            handleLeftButtonAction()
        case .right:
            handleRightButtonAction()
        }
    }
}

// MARK: - Public methods
extension CalendarView {
    
    public func reloadData() {
        self.collectionView.reloadData()
    }

    public func setDisplayDate(_ date : Date, animated: Bool = false) {
//        guard (startDateCache..<endDateCache).contains(date)
//        else { return }
        self.displayDate = date
        
        self.collectionView?.reloadData()
        if viewType == .month {
            self.collectionView?.setContentOffset(self.scrollViewOffset(for: date), animated: animated)
        }
        self.displayDateOnHeader(date)
    }
    
    public func selectDate(_ date : Date) {
        guard let indexPath = self.indexPathForDate(date) else { return }
        if viewType == .month {
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition())
        } else {
            self.collectionView.reloadData()
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition())
        }
    }
    
    public func deselectDate(_ date : Date) {
        guard let indexPath = self.indexPathForDate(date) else { return }
        self.collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    public func goToNextMonth() {
        goToMonthWithOffet(1)
    }
    
    public func goToPreviousMonth() {
        goToMonthWithOffet(-1)
    }
    
    public func goToNextWeek() {
        goToWeekWithOffset(1)
    }
    
    public func goToPrevWeek() {
        goToWeekWithOffset(-1)
    }

    public func clearAllSelectedDates() {
        self.selectedDay = nil
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
        self.collectionView.allowsMultipleSelection         = false 
        self.collectionView.isMultipleTouchEnabled = false
        self.collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        self.addSubview(self.collectionView)
        
        // Update semantic content attributes
        updateLayoutDirections()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(CalendarView.handleLongPress))
        self.collectionView.addGestureRecognizer(longPress)
        
    }
}

// MARK: - Handle long press recognizer (private)
private extension CalendarView {
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        
        guard gesture.state == UIGestureRecognizer.State.began
        else { return }
        
        let point = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: point)
        else { return }
        
        switch style.viewType {
        case .month:
            break
        case .week:
            let day = self.cachedWeek[indexPath.row]
            self.delegate?.calendar(self, didLongPressDay: day)
        }

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
        
        guard let selectedDate = self.selectedDay?.date
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
        
        guard let newDate = self.calendar.date(byAdding: dateComponents, to: displayDate)
        else { return }
        
        self.updateCachedWeek(by: newDate)
        self.setDisplayDate(newDate, animated: true)
        
        guard let selectedDate = self.selectedDay?.date
        else { return }
        self.selectDate(selectedDate)
    }
}

// MARK: - Update cached week (private)
private extension CalendarView {
    func updateCachedWeek(by date: Date) {
        let startOfWeekDate = date.startOfWeek(using: calendar)
        let endOfWeekDate = date.endOfWeek(using: calendar)
        let week = Date.dates(from: startOfWeekDate, to: endOfWeekDate)
        _cachedWeek = week.map({ date in
            let isActive = self.validateIsActiveDay(by: date)
            return CalendarDay(date: date, isActive: isActive)
        })
    }
}

// MARK: Convertions methods (private)
extension CalendarView {
    func indexPathForDate(_ date : Date) -> IndexPath? {
        switch style.viewType {
        case .month:
            let distanceFromStartDate = self.calendar.dateComponents([.month, .day], from: self.firstDayCache.date, to: date)
            
            guard let day = distanceFromStartDate.day,
                  let month = distanceFromStartDate.month,
                  let (firstDayIndex, _) = getCachedMonthSectionInfo(month)
            else { return nil }
            
            return IndexPath(item: day + firstDayIndex, section: month)
        case .week:
            guard let index = cachedWeek.firstIndex(where: { $0.date == date })
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
            
            return self.calendar.date(byAdding: components, to: self.firstDayCache.date)
        case .week:
            return cachedWeek[indexPath.row].date
        }
    }
}

// MARK: - Get cell size (private)
private extension CalendarView {
    func cellSize(in bounds: CGRect) -> CGSize {
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
        }
    }
}

// MARK: - Reset display date (private)
private extension CalendarView {
    func resetDisplayDate() {
        guard let displayDate = self.displayDate else { return }
        
        self.collectionView.setContentOffset(
            self.scrollViewOffset(for: displayDate),
            animated: false
        )
    }
}

// MARK: - Display date on header (internal)
internal extension CalendarView {
    func displayDateOnHeader(_ date: Date) {
        let month = self.calendar.component(.month, from: date) // get month
        
        let formatter = DateFormatter()
        formatter.locale = style.locale
        formatter.timeZone = style.calendar.timeZone
        
        let monthName = formatter.standaloneMonthSymbols[(month-1) % 12].capitalized // 0 indexed array

        self.headerView.monthTitle =  monthName
        self.displayDate = date
    }
}


// MARK: - Validate is active day by Date (internal)
internal extension CalendarView {
    func validateIsActiveDay(by date: Date) -> Bool {
        guard let days = self.dataSource?.days(),
              let day = days.first(where: { day in
                  calendar.isDate(day.date, equalTo: date, toGranularity: .day)
              })
        else { return false }
        return day.isActive
    }
}

// MARK: - Calendar day by Date (internal)
internal extension CalendarView {
    func calendarDay(by date: Date) -> CalendarDay? {
        guard let day = self.dataSource?.days().first(where: { day in
            calendar.isDate(date, equalTo: day.date, toGranularity: .day)
        }) else { return nil }
        return day
    }
}

internal extension CalendarView {
    func calendarDay(indexPath: IndexPath) -> CalendarDay? {
        switch viewType {
        case .month:
            guard let date = self.dateFromIndexPath(indexPath),
                  let day = self.calendarDay(by: date)
            else { return nil }
            return day
        case .week:
            guard indexPath.row < self.cachedWeek.count else { return nil }
            return self.cachedWeek[indexPath.row]
        }
    }
}

// MARK: - Get day number (internal)
internal extension CalendarView {
    func dayNumber(from day: CalendarDay) -> Int {
        let dateComponents = calendar.dateComponents([.day], from: day.date)
        return dateComponents.day!
    }
}

// MARK: - Scroll view offset (private)
private extension CalendarView {
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

// MARK: - Update layout directions (private)
private extension CalendarView {
    func updateLayoutDirections() {
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
}
