//
//  BlockCoordinates.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Glorified coordinate class that supports various numeric types.
class BlockCoordinates<T> where T: Numeric
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    /// - Parameter X: Initial X coordinate.
    /// - Parameter Y: Initial Y coordinate.
    init(_ X: T, Y: T)
    {
        _X = X
        _Y = Y
    }
    
    /// Initializer.
    /// - Parameter X: Initial X coordinate.
    /// - Parameter Y: Initial Y coordinate.
    /// - Parameter Z: Initial Z coordinate.
    init(_ X: T, Y: T, Z: T)
    {
        _X = X
        _Y = Y
        _Z = Z
    }
    
    /// Initializer.
    /// - Parameter Other: Another `BlockCoordinates` class used as data for initialization of this instance.
    init(_ Other: BlockCoordinates<T>)
    {
        _X = Other.X
        _Y = Other.Y
        _Z = Other.Z
    }
    
    /// Holds the X value.
    private var _X: T = 0
    /// Get or set the X value.
    public var X: T
    {
        get
        {
            return _X
        }
        set
        {
            _X = newValue
        }
    }
    
    /// Holds the Y value.
    private var _Y: T = 0
    /// Get or set the Y value.
    public var Y: T
    {
        get
        {
            return _Y
        }
        set
        {
            _Y = newValue
        }
    }
    
    /// Holds the Z value.
    private var _Z: T = 0
    /// Get or set the Z value.
    public var Z: T
    {
        get
        {
            return _Z
        }
        set
        {
            _Z = newValue
        }
    }
    
    /// Add an offset value to `X`, `Y`, and `Z`.
    /// - Parameter ToAll: Value to add to this instance.
    public func AddOffset(_ ToAll: T)
    {
        _X = _X + ToAll
        _Y = _Y + ToAll
        _Z = _Z + ToAll
    }
    
    /// Add the supplied values to the values in the instance.
    /// - Parameter X: The value to add to the instance value of X.
    /// - Parameter Y: The value to add to the instance value of Y.
    public func AddOffset(_ X: T, _ Y: T)
    {
        _X = _X + X
        _Y = _Y + Y
    }
    
    /// Add the supplied values to the values in the instance.
    /// - Parameter X: The value to add to the instance value of X.
    /// - Parameter Y: The value to add to the instance value of Y.
    /// - Parameter Z: The value to add to the instance value of Z.
    public func AddOffset(_ X: T, _ Y: T, _ Z: T)
    {
        _X = _X + X
        _Y = _Y + Y
        _Z = _Z + Z
    }
    
    /// Add the values in **Other** to the instance values here.
    /// - Parameter Other: The source of the values to add.
    public func AddOffset(_ Other: BlockCoordinates<T>)
    {
        _X = _X + Other.X
        _Y = _Y + Other.Y
        _Z = _Z + Other.Z
    }
}
