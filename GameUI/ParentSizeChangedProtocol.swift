//
//  ParentSizeChangedProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for the notification of changed parent sizes.
protocol ParentSizeChangedProtocol
{
    /// Called when a parent's size changes.
    /// - Parameter Bounds: New bounds rectangle.
    /// - Parameter Frame: New frame rectangle.
    func NewParentSize(Bounds: CGRect, Frame: CGRect)
}
