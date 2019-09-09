//
//  Grid.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements a regular grid.
@IBDesignable class Grid: UIView, GridProtocol, IntraGridProtocol
{
    /// Delegate for owners of the instance to communicate to this class.
    weak var GridDelegate: GridProtocol? = nil
    
    /// Initializer.
    /// - Parameter frame: Original frame for the grid.
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
    
    /// Used to initialize the class when running in the Interface Builder.
    override func prepareForInterfaceBuilder()
    {
        Initialize()
    }
    
    /// Initialize the instance.
    func Initialize()
    {
        DrawGrid()
    }
    
    /// Holds the bounds for the `Grid` instance. When the bounds changes, the instance will redraw the grid.
    override var bounds: CGRect
        {
        didSet
        {
            DrawGrid()
        }
    }
    
    /// Draw the grid. Each time the grid is drawn, all existing grid cells are deleted then recreated.
    /// - Note: If the number of columns or the number of rows is 0, any previously existing grid cells are deleted then control
    ///         is returned.
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
    
    /// Remove all grid cells from the grid.
    public func ClearAll()
    {
        self.subviews.forEach({$0.removeFromSuperview()})
        GridCells.removeAll()
    }
    
    /// Reset all cells in the grid to the specified selection state.
    /// - Parameter ToSelection: The new selection state.
    func ResetAllCells(ToSelection: Bool)
    {
        for Cell in GridCells
        {
            Cell.IsSelected = ToSelection
        }
    }
    
    /// Update the grid. All grid cells have their `Redraw` member called.
    private func UpdateGrid()
    {
        for Cell in GridCells
        {
            Cell.Redraw()
        }
    }
    
    /// Holds the list of all current grid cells.
    private var GridCells = [GridCell]()
    
    /// Holds the number of columns in the grid.
    private var _Columns: Int = 5
    {
        didSet
        {
            DrawGrid()
        }
    }
    /// Get or set the number of columns in the grid. Setting this value will immediately recreate the grid.
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
    
    /// Holds the number of rows in the grid.
    private var _Rows: Int = 5
    {
        didSet
        {
            DrawGrid()
        }
    }
    /// Get or set the number of rows in the grid. Setting this value will immediately recreate the grid.
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
    
    /// Not used in this class.
    func CellTapped(Column: Int, Row: Int, TapCount: Int)
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    func CellCountChanged(ColumnCount: Int, RowCount: Int)
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    func CellSelectionStateChanged(Column: Int, Row: Int, IsSelected: Bool)
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    func Redraw()
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    func Start()
    {
        //Not used in this class.
    }
    
    // MARK: Protocol implementations and supporting functions and properties.
    
    /// Called when a grid cell is tapped. Passed along to the `GridDelegate`.
    /// - Parameter Column: The column address of the grid cell that was tapped.
    /// - Parameter Row: The row address of the grid cell that was tapped.
    /// - Parameter TapCount: The number of times the grid cell was tapped.
    func GridCellTapped(Column: Int, Row: Int, TapCount: Int)
    {
        GridDelegate?.CellTapped(Column: Column, Row: Row, TapCount: TapCount)
    }
    
    /// Called when a grid cell's selection state changed. Passed along to the `GridDelegate`.
    /// - Parameter Column: The column address of the grid cell that was tapped.
    /// - Parameter Row: The row address of the grid cell that was tapped.
    /// - Parameter IsInSelectedState: The grid cell's new selection state.
    func GridCellSelected(Column: Int, Row: Int, IsInSelectedState: Bool)
    {
        GridDelegate?.CellSelectionStateChanged(Column: Column, Row: Row, IsSelected: IsInSelectedState)
    }
    
    /// Holds the base, unselected background color for grid cells.
    private var _BaseBackground: UIColor = UIColor.white
    {
        didSet
        {
            UpdateGrid()
        }
    }
    /// Get or set the base, unselected background color for grid cells.
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
    
    /// Returns the base, unselected background color for grid cells.
    /// - Returns: Color to use for base, unselected backgrounds.
    func GetBaseBackgroundColor() -> UIColor
    {
        return _BaseBackground
    }
    
    /// Holds the selected background color for grid cells.
    private var _SelectedBackground: UIColor = UIColor.red
    {
        didSet
        {
            UpdateGrid()
        }
    }
    /// Get or set the selected background color for grid cells.
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
    
    /// Returns the selected background color for grid cells.
    /// - Returns: Color to use for selected backgrounds.
    func GetSelectedBackgroundColor() -> UIColor
    {
        return _SelectedBackground
    }
    
    /// Holds the pivot background color for grid cells.
    private var _PivotBackground: UIColor = UIColor.green
    {
        didSet
        {
            UpdateGrid()
        }
    }
    /// Get or set the pivot background color for grid cells.
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
    
    /// Returns the pivot background color for grid cells.
    /// - Returns: Color to use for pivot backgrounds.
    func GetPivotBackgroundColor() -> UIColor
    {
        return _PivotBackground
    }
    
    /// Holds the border color for grid cells.
    private var _BorderColor: UIColor = UIColor.black
    {
        didSet
        {
            UpdateGrid()
        }
    }
    /// Get or set the border color to use for grid cells.
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
    
    /// Returns the border color for grid cells.
    /// - Returns: Color to use for grid cell borders.
    func GetBaseBorderColor() -> UIColor
    {
        return _BorderColor
    }
    
    /// Holds the width of grid cell borders.
    private var _BorderWidth: CGFloat = 0.5
    {
        didSet
        {
            UpdateGrid()
        }
    }
    /// Get or set the width of grid cell borders.
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
    
    /// Returns the width to use when drawing grid cell borders.
    /// - Returns: Value to use as the width for grid cell borders.
    func GetBorderWidth() -> CGFloat
    {
        return _BorderWidth
    }
}
