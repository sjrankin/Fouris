//
//  GridProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for communicating between the `Grid` class instantiation and its parent class.
protocol GridProtocol: class
{
    /// Notification that a selection state of one of the grid cells changed.
    /// - Parameter Column: The column address of the changed cell.
    /// - Parameter Row: The row address of the changed cell.
    /// - Parameter IsSelected: The new selection state for the cell.
    func CellSelectionStateChanged(Column: Int, Row: Int, IsSelected: Bool)

    /// Notification that a grid cell was tapped.
    /// - Parameter Column: The column address of the changed cell.
    /// - Parameter Row: The row address of the changed cell.
    /// - Parameter TapCount: The number of times the cell was tapped by the user.
    func CellTapped(Column: Int, Row: Int, TapCount: Int)
    
    /// Notification that the number of cells in the grid changed.
    /// - Parameter ColumnCount: The new number of columns in the grid.
    /// - Parameter RowCount: The new number of rows in the grid.
    func CellCountChanged(ColumnCount: Int, RowCount: Int)
    
    /// Call to the `Grid` instance that resets the selection state for all grid cells.
    /// - Parameter ToSelection: New selection state to be set for all grid cells.
    func ResetAllCells(ToSelection: Bool)
    
    /// Returns a list of all pivot cells in the grid.
    /// - Returns: List of tuples. The first element of each tuple is the column and the second element is the row.
    func PivotCellCoordinates() -> [(Int, Int)]
    
    /// Removes all pivot points.
    func ResetAllPivotPoints()
    
    /// Returns the plot coordinates for the specified cell.
    /// - Parameter ForX: The X coordinate of the cell.
    /// - Parameter ForY: The Y coordinate of the cell.
    /// - Returns: Tuple of the plot coordinates for the cell. Nil is returned
    ///            if the specified coordinates are invalid.
    func GetPlotCoordinates(ForX: Int, ForY: Int) -> (Int, Int)?
}
