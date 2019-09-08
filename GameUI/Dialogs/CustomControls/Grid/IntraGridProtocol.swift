//
//  IntraGridProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol IntraGridProtocol: class
{
    // MARK: User interactions.
    func GridCellTapped(Column: Int, Row: Int, TapCount: Int)
    func GridCellSelected(Column: Int, Row: Int, IsInSelectedState: Bool)
    
    // MARK: Cell customization.
    func GetBaseBackgroundColor() -> UIColor
    func GetSelectedBackgroundColor() -> UIColor
    func GetPivotBackgroundColor() -> UIColor
    func GetBaseBorderColor() -> UIColor
    func GetBorderWidth() -> CGFloat
    
    //MARK: Messages from the parent.
    func Redraw()
    func Start()
}
