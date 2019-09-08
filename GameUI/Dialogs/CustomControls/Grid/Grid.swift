//
//  Grid.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class Grid: UIView, GridProtocol, IntraGridProtocol
{
    weak var GridDelegate: GridProtocol? = nil
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    override func prepareForInterfaceBuilder()
    {
        Initialize()
    }
    
    func Initialize()
    {
        DrawGrid()
    }
    
    override var bounds: CGRect
    {
        didSet
        {
            DrawGrid()
        }
    }
    
    func DrawGrid()
    {
        if _Columns == 0 || _Rows == 0
        {
            ClearAll()
            return
        }
        ClearAll()
        let CellWidth = self.bounds.size.width / CGFloat(_Columns)
        let CellHeight = self.bounds.size.height / CGFloat(_Rows)
        print("Grid size: \(self.bounds.size), CellWidth=\(CellWidth), CellHeight=\(CellHeight)")
        for Row in 0 ..< _Rows
        {
            for Column in 0 ..< _Columns
            {
                let Cell = GridCell(frame: CGRect(x: CGFloat(Column) * CellWidth, y: CGFloat(Row) * CellHeight,
                                                  width: CellWidth, height: CellHeight))
                Cell.Column = Column
                Cell.Row = Row
                Cell.CellParentDelegate = self
                Cell.Start()
                GridCells.append(Cell)
                self.addSubview(Cell)
            }
        }
    }
    
    public func ClearAll()
    {
        self.subviews.forEach({$0.removeFromSuperview()})
        GridCells.removeAll()
    }
    
    func ResetAllCells(ToSelection: Bool)
    {
        for Cell in GridCells
        {
            Cell.IsSelected = ToSelection
        }
    }
    
    private func UpdateGrid()
    {
        for Cell in GridCells
        {
            Cell.Redraw()
        }
    }
    
    private var GridCells = [GridCell]()
    
    private var _Columns: Int = 5
    {
        didSet
        {
            DrawGrid()
        }
    }
    @IBInspectable public var Columns: Int
        {
        get
        {
            return _Columns
        }
        set
        {
            _Columns = newValue
        }
    }
    
    private var _Rows: Int = 5
    {
        didSet
        {
            DrawGrid()
        }
    }
    @IBInspectable public var Rows: Int
        {
        get
        {
            return _Rows
        }
        set
        {
            _Rows = newValue
        }
    }
    
    // MARK: Protocol functions not used in this class
    
    func CellTapped(Column: Int, Row: Int, TapCount: Int)
    {
        //Not used in this class.
    }
    
    func CellCountChanged(ColumnCount: Int, RowCount: Int)
    {
        //Not used in this class.
    }
    
    func CellSelectionStateChanged(Column: Int, Row: Int, IsSelected: Bool)
    {
        //Not used in this class.
    }
    
    func Redraw()
    {
        //Not used in this class.
    }
    
    func Start()
    {
        //Not used in this class.
    }
    
    // MARK: Protocol implementations and supporting functions and properties.
    
    func GridCellTapped(Column: Int, Row: Int, TapCount: Int)
    {
        GridDelegate?.CellTapped(Column: Column, Row: Row, TapCount: TapCount)
    }
    
    func GridCellSelected(Column: Int, Row: Int, IsInSelectedState: Bool)
    {
        GridDelegate?.CellSelectionStateChanged(Column: Column, Row: Row, IsSelected: IsInSelectedState)
    }
    
    private var _BaseBackground: UIColor = UIColor.white
    {
        didSet
        {
            UpdateGrid()
        }
    }
    @IBInspectable public var BaseBackground: UIColor
        {
        get
        {
            return _BaseBackground
        }
        set
        {
            _BaseBackground = newValue
        }
    }
    
    func GetBaseBackgroundColor() -> UIColor
    {
        return _BaseBackground
    }
    
    private var _SelectedBackground: UIColor = UIColor.red
    {
        didSet
        {
            UpdateGrid()
        }
    }
    @IBInspectable public var SelectedBackground: UIColor
        {
        get
        {
            return _SelectedBackground
        }
        set
        {
            _SelectedBackground = newValue
        }
    }
    
    func GetSelectedBackgroundColor() -> UIColor
    {
        return _SelectedBackground
    }
    
    private var _PivotBackground: UIColor = UIColor.green
    {
        didSet
        {
            UpdateGrid()
        }
    }
    @IBInspectable public var PivotBackground: UIColor
        {
        get
        {
            return _PivotBackground
        }
        set
        {
            _PivotBackground = newValue
        }
    }
    
    func GetPivotBackgroundColor() -> UIColor
    {
        return _PivotBackground
    }
    
    private var _BorderColor: UIColor = UIColor.black
    {
        didSet
        {
            UpdateGrid()
        }
    }
    @IBInspectable public var BorderColor: UIColor
        {
        get
        {
            return _BorderColor
        }
        set
        {
            _BorderColor = newValue
        }
    }
    
    func GetBaseBorderColor() -> UIColor
    {
        return _BorderColor
    }
    
    private var _BorderWidth: CGFloat = 0.5
    {
        didSet
        {
            UpdateGrid()
        }
    }
    @IBInspectable public var BorderWidth: CGFloat
        {
        get
        {
            return _BorderWidth
        }
        set
        {
            _BorderWidth = newValue
        }
    }
    
    func GetBorderWidth() -> CGFloat
    {
        return _BorderWidth
    }
}
