//
//  GridCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains a single cell for the `Grid` control.
class GridCell: UIView, IntraGridProtocol
{

    
    /// Used for communicating with the `Grid` parent control.
    weak var CellParentDelegate: IntraGridProtocol? = nil
    
    /// Initializer.
    /// - Parameter frame: Frame of the cell.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the grid cell.
    /// - Note: See [UITapGestureRecognizer Single Tap and Double Tap](https://stackoverflow.com/questions/8876202/uitapgesturerecognizer-single-tap-and-double-tap)
    func Initialize()
    {
        Tag = nil
        let SingleTap = UITapGestureRecognizer(target: self, action: #selector(SingleTapHandler))
        SingleTap.numberOfTapsRequired = 1
        self.addGestureRecognizer(SingleTap)
        
        let Press = UILongPressGestureRecognizer(target: self, action: #selector(HandlePress))
        Press.minimumPressDuration = 0.5
        self.addGestureRecognizer(Press)
    }
    
    /// Start "execution" of the grid cell. Should be called after initialization.
    func Start()
    {
        DrawCell()
    }
    
    /// Handle single taps. Two notifications are sent to the parent - one for the tap and one for the selection station.
    /// - Parameter Recognizer: The gesture recognizer.
    @objc func SingleTapHandler(Recognizer: UIGestureRecognizer)
    {
        if !_AllowsInteraction
        {
            return
        }
        if Recognizer.state == .ended
        {
            CellParentDelegate?.GridCellTapped(Column: Column, Row: Row, TapCount: 1)
            _IsSelected = !_IsSelected
            CellParentDelegate?.GridCellSelected(Column: Column, Row: Row, IsInSelectedState: _IsSelected)
        }
    }

    @objc func HandlePress(Recognizer: UILongPressGestureRecognizer)
    {
        if !_AllowsInteraction
        {
            return
        }
        if Recognizer.state == .began
        {
            IsPivot = !IsPivot
            CellParentDelegate?.GridCellPivotChanged(Column: Column, Row: Row, PivotState: IsPivot)
        }
    }
    
    /// Holds the allows user interaction flag
    private var _AllowsInteraction: Bool = true
    {
        didSet
        {
            self.isUserInteractionEnabled = _AllowsInteraction
        }
    }
    /// Get or set the allows user interaction flag.
    public var AllowsInteraction: Bool
    {
        get
        {
            return _AllowsInteraction
        }
        set
        {
            _AllowsInteraction = newValue
        }
    }
    
    /// Holds the selected flag.
    private var _IsSelected: Bool = false
    {
        didSet
        {
            DrawCell()
        }
    }
    /// Get or set the selected flag.
    public var IsSelected: Bool
    {
        get
        {
            return _IsSelected
        }
        set
        {
            _IsSelected = newValue
        }
    }
    
    /// Holds the pivot flag.
    private var _IsPivot: Bool = false
    {
        didSet
        {
            DrawCell()
        }
    }
    /// Get or set the pivot flag.
    public var IsPivot: Bool
    {
        get
        {
            return _IsPivot
        }
        set
        {
            _IsPivot = newValue
        }
    }
    
    /// Draw the grid cell.
    func DrawCell()
    {
        var BGColor = UIColor.white
        if _IsPivot
        {
            BGColor = (CellParentDelegate?.GetPivotBackgroundColor())!
        }
        else
        {
            if _IsSelected
            {
                BGColor = (CellParentDelegate?.GetSelectedBackgroundColor())!
            }
            else
            {
                BGColor = (CellParentDelegate?.GetBaseBackgroundColor())!
            }
        }
        self.backgroundColor = BGColor
        self.layer.borderWidth = (CellParentDelegate?.GetBorderWidth())!
        self.layer.borderColor = (CellParentDelegate?.GetBaseBorderColor())!.cgColor
    }
    
    /// Redraw the grid cell. Can be called by the parent `Grid`.
    func Redraw()
    {
        DrawCell()
    }
    
    /// Holds the tag value.
    private var _Tag: Any? = nil
    /// Get or set the tag value.
    /// - Note:
    ///   - This is a true tag in the sense that it can contain anything (and not just an integer).
    ///   - This value is not used in any way by the `GridCell` class.
    public var Tag: Any?
    {
        get
        {
            return _Tag
        }
        set
        {
            _Tag = newValue
        }
    }
    
    /// Holds the column value.
    private var _Column: Int = -1
    /// Get or set the column value. This is the column in the parent grid where the instance of the cell lives.
    /// - Note: While changeable, the design of the `Grid` uses cell coordinates to report events, so changing this value
    ///         is ill-advised.
    public var Column: Int
    {
        get
        {
            return _Column
        }
        set
        {
            _Column = newValue
        }
    }
    
    /// Holds the row value.
    private var _Row: Int = -1
    /// Get or set the row value. This is the row in the parent grid where the instance of the cell lives.
    /// - Note: While changeable, the design of the `Grid` uses cell coordinates to report events, so changing this value
    ///         is ill-advised.
    public var Row: Int
    {
        get
        {
            return _Row
        }
        set
        {
            _Row = newValue
        }
    }
    
    /// Not used in this class.
    func GridCellTapped(Column: Int, Row: Int, TapCount: Int)
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    func GridCellSelected(Column: Int, Row: Int, IsInSelectedState: Bool)
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    func GridCellPivotChanged(Column: Int, Row: Int, PivotState: Bool)
    {
        //Not used in this class.
    }
    
    /// Not intended to be called. Returns `UIColor.clear`.
    func GetBaseBackgroundColor() -> UIColor
    {
        return UIColor.clear
    }
    
    /// Not intended to be called. Returns `UIColor.clear`.
    func GetSelectedBackgroundColor() -> UIColor
    {
        return UIColor.clear
    }
    
    /// Not intended to be called. Returns `UIColor.clear`.
    func GetPivotBackgroundColor() -> UIColor
    {
        return UIColor.clear
    }
    
    /// Not intended to be called. Returns `UIColor.clear`.
    func GetBaseBorderColor() -> UIColor
    {
        return UIColor.clear
    }
    
    /// Not intended to be called. Returns `0.0`.
    func GetBorderWidth() -> CGFloat
    {
        return 0.0
    }
}
