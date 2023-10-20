/*
 * CalendarHeaderView.swift
 * Created by Michael Michailidis on 07/04/2015.
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

// MARK: CalendarHeaderAction
enum CalendarHeaderAction {
    case down
    case up
    case left
    case right
}

// MARK: - CalendarHeaderDelegate (protocol)
protocol CalendarHeaderDelegate: AnyObject {
    func calendarHeaderDidOccurAction(_ action: CalendarHeaderAction)
}

// MARK: - CalendarHeaderView
open class CalendarHeaderView: UIView {
    
    // MARK: Private properties
    
    private var monthLeftMargin: CGFloat = 0.0
    private var monthTopMargin: CGFloat = 0.0
    private var monthWidth: CGFloat = 110.0
    private var montHeight: CGFloat = 32.0
    
    private var rightButtonRightMargin: CGFloat = 0
    private var arrowButtonTopMargin : CGFloat = 6
    private var arrowButtonHeight: CGFloat = 22.0
    private var arrowButtonsIndent: CGFloat = 20.0
    
    // MARK: Public properties
    
    weak var delegate: CalendarHeaderDelegate?
    
    var style: CalendarView.Style = CalendarView.Style.Default {
        didSet {
            updateStyle()
        }
    }
    
    var monthTitle: String = "" {
        didSet {
            self.downButton?.setTitle(monthTitle, for: .normal)
        }
    }
    
    // MARK: Subviews
    
    var dayLabels = [UILabel]()
    
    weak var downButton: UIButton?
    weak var leftButton: UIButton?
    weak var rightButton: UIButton?
    
    // MARK: Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
}

// MARK: - Update style (public)
extension CalendarHeaderView {
    public func updateStyle() {

        let formatter = DateFormatter()
        formatter.locale = style.locale
        formatter.timeZone = style.calendar.timeZone
        
        let start = style.firstWeekday == .sunday ? 0 : 1
        var i = 0
        
        for index in start..<(start+7) {
            let label = dayLabels[i]
            label.font = style.weekdaysFont
            label.text = style.weekDayTransform == .capitalized ? formatter.shortWeekdaySymbols[(index % 7)].capitalized : formatter.shortWeekdaySymbols[(index % 7)].uppercased()
            label.textColor = style.weekdaysTextColor
            label.textAlignment = .center
            
            i = i + 1
        }

//        self.backgroundColor = style.weekdaysBackgroundColor
        self.backgroundColor = .red
    }
}

// MARK: - Setup subviews (private)
private extension CalendarHeaderView {
    func setupSubviews() {
        func setupDownButton() {
            let downButton = UIButton()
            downButton.translatesAutoresizingMaskIntoConstraints = false
            downButton.clipsToBounds = true
            downButton.layer.cornerRadius = 10.0
            downButton.setTitleColor(self.style.headerTextColor, for: .normal)
            downButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            downButton.backgroundColor = self.style.commonBackground
            downButton.layer.borderWidth = 1.0
            downButton.layer.borderColor = self.style.headerMonthBorderColor.cgColor
            downButton.setImage(UIImage(named: "downArrow"), for: .normal)
            downButton.semanticContentAttribute = .forceRightToLeft
            downButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
            downButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            downButton.addTarget(self, action: #selector(handleDownAction), for: .touchUpInside)
            self.addSubview(downButton)
            self.downButton = downButton
        }
        
        func setupLeftButton() {
            let leftButton = UIButton()
            leftButton.translatesAutoresizingMaskIntoConstraints = false
            leftButton.backgroundColor = .clear
            leftButton.setImage(UIImage(named: "leftArrow"), for: .normal)
            leftButton.addTarget(self, action: #selector(handleLeftAction), for: .touchUpInside)
            self.addSubview(leftButton)
            self.leftButton = leftButton
        }
        
        func setupRightButton() {
            let rightButton = UIButton()
            rightButton.translatesAutoresizingMaskIntoConstraints = false
            rightButton.backgroundColor = .clear
            rightButton.setImage(UIImage(named: "rightArrow"), for: .normal)
            rightButton.addTarget(self, action: #selector(handleRightAction), for: .touchUpInside)
            self.addSubview(rightButton)
            self.rightButton = rightButton
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setupDownButton()
        setupLeftButton()
        setupRightButton()
        
        for _ in 0..<7 {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = UIColor.green
            
            dayLabels.append(label)
            self.addSubview(label)
        }
    }
}

// MARK: - Update layout (private)
private extension CalendarHeaderView {
    func updateLayout() {
        var isRtl = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        isRtl = self.effectiveUserInterfaceLayoutDirection == .rightToLeft
        
        self.downButton?.frame = CGRect(
            x: monthLeftMargin,
            y: monthTopMargin,
            width: monthWidth,
            height: montHeight
        )
        
        self.rightButton?.frame = CGRect(
            x: bounds.width - rightButtonRightMargin - arrowButtonHeight,
            y: arrowButtonTopMargin,
            width: arrowButtonHeight,
            height: arrowButtonHeight
        )
        
        self.leftButton?.frame = CGRect(
            x: bounds.width - rightButtonRightMargin - 2*arrowButtonHeight - arrowButtonsIndent,
            y: arrowButtonTopMargin,
            width: arrowButtonHeight,
            height: arrowButtonHeight
        )
        
        var labelFrame = CGRect(
            x: 0.0,
            y: self.bounds.size.height
                - style.weekdaysBottomMargin
                - style.weekdaysHeight,
            width: self.bounds.size.width / 7.0,
            height: style.weekdaysHeight
        )
        
        if isRtl {
            labelFrame.origin.x = self.bounds.size.width - labelFrame.width
        }
        
        for lbl in self.dayLabels {
            lbl.frame = labelFrame
            
            labelFrame.origin.x += isRtl ? -labelFrame.size.width : labelFrame.size.width
        }
    }
}

// MARK: - Handle button action (private)
private extension CalendarHeaderView {
    @objc func handleDownAction() {
        self.delegate?.calendarHeaderDidOccurAction(.down)
    }
    
    @objc func handleLeftAction() {
        self.delegate?.calendarHeaderDidOccurAction(.left)
    }
    
    @objc func handleRightAction() {
        self.delegate?.calendarHeaderDidOccurAction(.right)
    }
}
