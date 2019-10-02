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
class Point3D<T>: CustomStringConvertible where T: Equatable
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
    
    /// Returns a string version of the coordinates. If `Z` is not defined, it is not included in the
    /// returned string.
    /// - Note: Assumes at least `X` and `Y` are defined.
    /// - Returns: String equivalent of the coordinate.
    public func ToString() -> String
    {
        if Z == nil
        {
            return "\((X)!),\((Y)!)"
        }
        else
        {
            return "\((X)!),\((Y)!),\((Z)!)"
        }
    }
    
    /// Returns a string description of the contents of the class.
    /// - Note: Calls `ToString()`.
    var description: String
    {
        get
        {
            return ToString()
        }
    }
}
