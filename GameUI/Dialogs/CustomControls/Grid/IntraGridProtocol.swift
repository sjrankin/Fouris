//
//  IntraGridProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for communications between instances of grid cells and their `Grid` instance parent.
protocol IntraGridProtocol: class
{
    // MARK: User interactions.
    
    /// Notification from a grid cell to the `Grid` that a grid cell was tapped.
    /// - Parameter Column: The column address of the tapped grid.
    /// - Parameter Row: The row address of the tapped grid.
    /// - Parameter TapCount: The number of times the user tapped the cell.
    func GridCellTapped(Column: Int, Row: Int, TapCount: Int)
    
    /// Notification from a grid cell to the `Grid` that a cell changed selection state due to the actions of the user.
    /// - Parameter Column: The column address of the tapped grid.
    /// - Parameter Row: The row address of the tapped grid.
    /// - Parameter IsInSelectedState: New selection state.
    func GridCellSelected(Column: Int, Row: Int, IsInSelectedState: Bool)
    
    // MARK: Cell customization.

    /// Request by a grid cell to get the base grid cell background color from the `Grid` instance.
    /// - Returns: Color to be used as the unselected, base background color.
    func GetBaseBackgroundColor() -> UIColor
    
    /// Request by a grid cell to get the selected grid cell background color from the `Grid` instance.
    /// - Returns: Color to be used as the selected background color.
    func GetSelectedBackgroundColor() -> UIColor
    
    /// Request by a grid cell to get the pivot grid cell background color from the `Grid` instance.
    /// - Returns: Color to be used as the pivot background color.
    func GetPivotBackgroundColor() -> UIColor
    
    /// Request by a grid cell to get the border color from the `Grid` instance.
    /// - Returns: Color to be used as the border color.
    func GetBaseBorderColor() -> UIColor
    
    /// Request by a grid cell to get the border width from the `Grid` instance.
    /// - Returns: Value to be used as the border width.
    func GetBorderWidth() -> CGFloat
    
    //MARK: Messages from the parent.
    
    /// Request by the `Grid` instance to redraw the grid cell.
    func Redraw()
    
    /// Request by the `Grid` instance to start execution of a grid cell.
    func Start()
}
