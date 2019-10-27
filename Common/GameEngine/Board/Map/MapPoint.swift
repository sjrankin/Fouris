//
//  MapPoint.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds a three-dimensional point used by the game map.
class MapPoint: Comparable, CustomStringConvertible
{
    // MARK: - Initialization.
    
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    /// - Parameter X: X coordinate.
    /// - Parameter Y: Y coordinate.
    /// - Parameter Z: Z coodrinate.
    init(X: Int, Y: Int, Z: Int)
    {
        _X = X
        _Y = Y
        _Z = Z
    }
    
    /// Initializer.
    /// - Parameter OtherPoint: Another `MapPoint` instance used as the source for the coordinates of the new instance.
    init(_ OtherPoint: MapPoint)
    {
        _X = OtherPoint.X
        _Y = OtherPoint.Y
        _Z = OtherPoint.Z
    }
    
    // MARK: - Main properties.
    
    /// Holds the horizontal coordinate.
    private var _X: Int = 0
    /// Get or set the horizontal coordinate.
    public var X: Int
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
    
    /// Holds the vertical coordinate.
    private var _Y: Int = 0
    /// Get or set the vertical coordinate.
    public var Y: Int
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
    
    /// Holds the depth coordinate.
    private var _Z: Int = 0
    /// Get or set the depth coordinate.
    public var Z: Int
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
    
    /// Sets the instance's coordinates in one call.
    /// - Parameter NewX: New `X` value.
    /// - Parameter NewY: New `Y` value.
    /// - Parameter NewZ: New `Z` value.
    public func SetAll(NewX: Int, NewY: Int, NewZ: Int)
    {
        _X = NewX
        _Y = NewY
        _Z = NewZ
    }
    
    /// Adds offset values to the instance coordinate.
    /// - Parameter ToX: Value to add to `X`. Defaults to 0.
    /// - Parameter ToY: Value to add to `Y`. Defaults to 0.
    /// - Parameter ToZ: Value to add to `Z`. Defaults to 0.
    public func Add(ToX: Int = 0, ToY: Int = 0, ToZ: Int = 0)
    {
        _X = _X + ToX
        _Y = _Y + ToY
        _Z = _Z + ToZ
    }
    
    // MARK: - Operator overrides.
    
    /// Overloads the addition ("**+**") operator between two `MapPoint` class instances.
    /// - Parameter Argument1: First `MapPoint` instance.
    /// - Parameter Argument2: Second `MapPoint` instance.
    /// - Returns: New `MapPoint` instance with each coordinate the sum of the two passed arguments.
    public static func +(Argument1: MapPoint, Argument2: MapPoint) -> MapPoint
    {
        return MapPoint(X: Argument1.X + Argument2.X, Y: Argument1.Y + Argument2.Y, Z: Argument1.Z + Argument2.Z)
    }
    
    /// Overloads the subtraction ("**-**") operator between two `MapPoint` class instances.
    /// - Parameter Argument1: First `MapPoint` instance.
    /// - Parameter Argument2: Second `MapPoint` instance.
    /// - Returns: New `MapPoint` instance with each coordinate the subtraction of the two passed arguments.
    public static func -(Argument1: MapPoint, Argument2: MapPoint) -> MapPoint
    {
        return MapPoint(X: Argument1.X - Argument2.X, Y: Argument1.Y - Argument2.Y, Z: Argument1.Z - Argument2.Z)
    }
    
    // MARK: - Static functions.
    
    /// Returns the dist
    public static func NormalizedDistance(For Point: MapPoint) -> Double
    {
        return sqrt(Double(Point.X * Point.X) + Double(Point.Y * Point.Y) + Double(Point.Z * Point.Z))
    }
    
    // MARK: - Custom string convertible functions.
    
    /// Returns a string representation of the contents of the class in the form: `(X, Y, Z)`.
    public var description: String
    {
        get
        {
            return "(\(X), \(Y), \(Z))"
        }
    }
    
    // MARK: - Comparable functions.
    
    /// Determines if the distance from the origin to `lhs` is less than the distance to the orgin for `rhs`.
    /// - Parameter lhs: The left hand side argument.
    /// - Parameter rhs: the right hand side argument.
    /// - Returns: True if lhs is closer to the origin than rhs, false otherwise.
    static func < (lhs: MapPoint, rhs: MapPoint) -> Bool
    {
        return NormalizedDistance(For: lhs) < NormalizedDistance(For: rhs)
    }
    
    /// Determines if the two points are equal.
    /// - Parameter lhs: The left hand side argument.
    /// - Parameter rhs: the right hand side argument.
    /// - Returns: True if all components in both `lhs` and `rhs` are equal, false if not.
    static func == (lhs: MapPoint, rhs: MapPoint) -> Bool
    {
        return lhs.Z == rhs.Z && lhs.Y == rhs.Y && lhs.X == rhs.X
    }
}
