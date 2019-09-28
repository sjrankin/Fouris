//
//  Point3D.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds a set of coordinates in 3D space with a caller-defined type.
class Point3D<T> where T: Equatable
{
    /// Initializer for 3D space.
    /// - Parameter InitialX: Initial X coordinate.
    /// - Parameter InitialY: Initial Y coordinate.
    /// - Parameter InitialZ: Initial Z coordinate.
    init(_ InitialX: T, _ InitialY: T, _ InitialZ: T)
    {
        X = InitialX
        Y = InitialY
        Z = InitialZ
    }
    
    /// Initializer for 2D space.
    /// - Parameter InitialX: Initial X coordinate.
    /// - Parameter InitialY: Initial Y coordinate.
    init(_ InitialX: T, _ InitialY: T)
    {
        X = InitialX
        Y = InitialY
    }
    
    /// The X coordinate. If nil, not set.
    public var X: T? = nil
    
    /// The Y coordinate. If nil, not set.
    public var Y: T? = nil
    
    /// The Z coordinate. If nil, not set.
    public var Z: T? = nil
}
