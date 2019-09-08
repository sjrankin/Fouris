//
//  GridProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol GridProtocol: class
{
    func CellSelectionStateChanged(Column: Int, Row: Int, IsSelected: Bool)
    func CellTapped(Column: Int, Row: Int, TapCount: Int)
    func CellCountChanged(ColumnCount: Int, RowCount: Int)
    func ResetAllCells(ToSelection: Bool)
}
