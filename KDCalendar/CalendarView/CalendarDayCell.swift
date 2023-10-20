/*
 * CalendarDayCell.swift
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

// MARK: UICollectionViewCell
open class CalendarDayCell: UICollectionViewCell {
    
    var style: CalendarView.Style = CalendarView.Style.Default

    var day: Int? {
        set {
            guard let value = newValue else { return self.textLabel.text = nil }
            self.textLabel.text = String(value)
        }
        get {
            guard let value = self.textLabel.text else { return nil }
            return Int(value)
        }
    }
    
    func updateTextColor() {
        if isSelected {
            self.textLabel.textColor = style.cellSelectedTextColor
        }
        else if isToday {
            self.textLabel.textColor = style.cellTextColorToday
        }
        else if isOutOfRange {
            self.textLabel.textColor = style.cellColorOutOfRange
        }
        else if isAdjacent {
            self.textLabel.textColor = style.cellColorAdjacent
        }
        else if isWeekend {
            self.textLabel.textColor = style.cellTextColorWeekend
        }
        else {
            self.textLabel.textColor = style.cellTextColorDefault
        }
    }
    
    var isToday : Bool = false {
        didSet {
            switch isToday {
            case true:
                self.dotsView.backgroundColor = style.cellColorToday
            case false:
                self.bgView.backgroundColor = style.cellColorDefault
            }
            
            updateTextColor()
        }
    }
    
    open override var isHidden: Bool {
        get {
            return self.containerView.isHidden
        }
        set {
            self.containerView.isHidden = newValue
        }
    }
    
    var isOutOfRange : Bool = false {
        didSet {
            updateTextColor()
        }
    }
    
    var isAdjacent : Bool = false {
        didSet {
            updateTextColor()
        }
    }
    
    var isWeekend: Bool = false {
        didSet {
            updateTextColor()
        }
    }
    
    // MARK: - Public methods
    public func clearStyles() {
        self.bgView.layer.borderColor = style.cellBorderColor.cgColor
        self.bgView.layer.borderWidth = style.cellBorderWidth
        self.bgView.backgroundColor = style.cellColorDefault
        self.textLabel.textColor = style.cellTextColorDefault
    }
    
    // MARK: Subviews
    
    let textLabel   = UILabel()
    let dotsView    = UIView()
    let bgView      = UIView()
    var containerView = UIView()
    
    // MARK: Override properties
    
    override open var isSelected : Bool {
        didSet {
            switch isSelected {
            case true:
                self.bgView.layer.borderColor = style.cellSelectedBorderColor.cgColor
                self.bgView.layer.borderWidth = style.cellSelectedBorderWidth
                self.bgView.backgroundColor = style.cellSelectedColor
            case false:
                self.bgView.layer.borderColor = style.cellBorderColor.cgColor
                self.bgView.layer.borderWidth = style.cellBorderWidth
                self.bgView.backgroundColor = style.cellColorDefault
            }
            
            updateTextColor()
        }
    }
    
    override open var description: String {
        let dayString = self.textLabel.text ?? " "
        return "<DayCell (text:\"\(dayString)\")>"
    }
    
    // MARK: Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.textLabel.textAlignment = NSTextAlignment.center
        self.textLabel.font = style.cellFont
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(self.bgView)
        containerView.addSubview(self.textLabel)
        containerView.addSubview(self.dotsView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        self.dotsView.backgroundColor = .clear
    }
}

// MARK: - Update layout (private)
private extension CalendarDayCell {
    func updateLayout() {
        containerView.frame = bounds
        
        var elementsFrame = containerView.bounds.insetBy(dx: 3.0, dy: 3.0)
        
        if style.cellShape.isRound { // square of
            let smallestSide = min(elementsFrame.width, elementsFrame.height)
            elementsFrame = elementsFrame.insetBy(
                dx: (elementsFrame.width - smallestSide) / 2.0,
                dy: (elementsFrame.height - smallestSide) / 2.0
            )
        }
        
        self.bgView.frame           = elementsFrame
        self.textLabel.frame        = elementsFrame
        
        let size                            = containerView.bounds.height * 0.08 // always a percentage of the whole cell
        self.dotsView.frame                 = CGRect(x: 0, y: 0, width: size, height: size)
        self.dotsView.center                = CGPoint(x: self.textLabel.center.x, y: containerView.bounds.height - (2.5 * size))
        self.dotsView.layer.cornerRadius    = size * 0.5 // round it
        
        switch style.cellShape {
        case .square:
            self.bgView.layer.cornerRadius = 0.0
        case .round:
            self.bgView.layer.cornerRadius = elementsFrame.width * 0.5
        case .bevel(let radius):
            self.bgView.layer.cornerRadius = radius
        }
    }
}
