//
//  Volume.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Encapsulates a volume. This class does *not* check for negative dimensions so it is entirely possible to have
/// negative volumes.
/// - Note: If the parameterless initializer is called, all dimensions have a value of `0.0`.
class Volume: CustomStringConvertible, Comparable
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    /// - Parameter Width: Initial width.
    /// - Parameter Height: Initial height.
    /// - Parameter Depth: Initial depth.
    init(Width: Double, Height: Double, Depth: Double)
    {
        _Width = Width
        _Height = Height
        _Depth = Depth
    }
    
    /// Initializer.
    /// - Parameter Width: Initial width. Converted to Double internally.
    /// - Parameter Height: Initial height. Converted to Double internally.
    /// - Parameter Depth: Initial depth. Converted to Double internally.
    init(Width: Int, Height: Int, Depth: Int)
    {
        _Width = Double(Width)
        _Height = Double(Height)
        _Depth = Double(Depth)
    }
    
    /// Initializer.
    /// - Parameter Width: Initial width. Converted to Double internally.
    /// - Parameter Height: Initial height. Converted to Double internally.
    /// - Parameter Depth: Initial depth. Converted to Double internally.
    init(Width: CGFloat, Height: CGFloat, Depth: CGFloat)
    {
        _Width = Double(Width)
        _Height = Double(Height)
        _Depth = Double(Depth)
    }
    
    /// Initializer.
    /// - Parameter Width: Initial width. Converted to Double internally.
    /// - Parameter Height: Initial height. Converted to Double internally.
    /// - Parameter Depth: Initial depth. Converted to Double internally.
    init(Width: Float, Height: Float, Depth: Float)
    {
        _Width = Double(Width)
        _Height = Double(Height)
        _Depth = Double(Depth)
    }
    
    /// Holds the width.
    private var _Width: Double = 0.0
    /// Get or set the width.
    public var Width: Double
    {
        get
        {
            return _Width
        }
        set
        {
            _Width = newValue
        }
    }
    
    /// Holds the height.
    private var _Height: Double = 0.0
    /// Get or set the height.
    public var Height: Double
    {
        get
        {
            return _Height
        }
        set
        {
            _Height = newValue
        }
    }
    
    /// Holds the depth.
    private var _Depth: Double = 0.0
    /// Get or set the depth.
    public var Depth: Double
    {
        get
        {
            return _Depth
        }
        set
        {
            _Depth = newValue
        }
    }
    
    /// Determines if the passed point (in the form of an `SCNVector3`) lies within the volume. This assumes the point has
    /// been adjusted to the volume (which is a measurement, not a location).
    /// - Parameter Point: Vector to be tested against the dimensions of the volume.
    /// - Returns: True if `Point` lies within the volume, false if not.
    public func PointInVolume(_ Point: SCNVector3) -> Bool
    {
        if Double(Point.x) > Width
        {
            return false
        }
        if Double(Point.y) > Height
        {
            return false
        }
        if Double(Point.z) > Depth
        {
            return false
        }
        return true
    }
    
    /// Return the actual volumetric value.
    /// - Returns: The actual volume represented by `Width * Height * Depth`.
    public func CurrentVolume() -> Double
    {
        return _Width * _Height * _Depth
    }
    
    /// Parses the passed string into a new `Volume` class. The format of the string is **width**x**height**x**depth**.
    /// ```
    ///    let NewVolume = Volume.ParseSimple("10x20x30")
    /// ```
    /// - Note: All numeric values are treated as Doubles.
    /// - Parameter Raw: The string to parse.
    /// - Returns: A new Volume class on success, nil on parse error.
    public static func ParseSimple(_ Raw: String) -> Volume?
    {
        if Raw.isEmpty
        {
            return nil
        }
        let Parts = Raw.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: "x", omittingEmptySubsequences: true)
        if Parts.count != 3
        {
            return nil
        }
        if let W = Double(String(Parts[0]))
        {
            if let H = Double(String(Parts[1]))
            {
                if let D = Double(String(Parts[2]))
                {
                    return Volume(Width: W, Height: H, Depth: D)
                }
            }
        }
        return nil
    }
    
    /// Parses the output of the string description of an existing `Volume` instance into a new Volume.
    /// ```
    ///   let ExistingVolume = Volume(Width: 100, Height: 25, Depth: 0.5)
    ///   let NewVolume = Volume.ParseDescription("\(ExistingVolume)")
    /// ```
    /// - Parameter Raw: The output of the `description` property of a `Volume` instance (see code sample).
    /// - Returns: A new Volume class on success, nil on parse error.
    public static func ParseDescription(_ Raw: String) -> Volume?
    {
        if Raw.isEmpty
        {
            return nil
        }
        let Parts = Raw.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count != 3
        {
            return nil
        }
        var Index = 0
        var ParsedWidth: Double = 0.0
        var ParsedHeight: Double = 0.0
        var ParsedDepth: Double = 0.0
        for Part in Parts
        {
            let SubParts = String(Part).split(separator: ":", omittingEmptySubsequences: true)
            if SubParts.count != 2
            {
                return nil
            }
            let RawValue = String(SubParts[1]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if let FinalValue = Double(RawValue)
            {
                switch Index
                {
                    case 0:
                    ParsedWidth = FinalValue
                    
                    case 1:
                    ParsedHeight = FinalValue
                    
                    case 2:
                    ParsedDepth = FinalValue
                    
                    default:
                    return nil
                }
            }
            Index = Index + 1
        }
        return Volume(Width: ParsedWidth, Height: ParsedHeight, Depth: ParsedDepth)
    }
    
    /// Determines if the volume of `lhs` is less than the volume of `rhs`.
    /// - Parameter lhs: Left hand side expression.
    /// - Parameter rhs: Right hand side expression.
    /// - Returns: True if `lhs` is less than `rhs`, false otherwise.
    static func < (lhs: Volume, rhs: Volume) -> Bool
    {
        return lhs.CurrentVolume() < rhs.CurrentVolume()
    }
    
    /// Determines if `lhs` has the same volume as `rhs'.
    /// - Parameter lhs: Left hand side expression.
    /// - Parameter rhs: Right hand side expression.
    /// - Returns: True if the volumes are equal, false if not.
    static func == (lhs: Volume, rhs: Volume) -> Bool
    {
        return lhs.CurrentVolume() == rhs.CurrentVolume()
    }
    
    /// Returns the string description of the contents. Format is: `(Width: value, Height: value, Depth: value)`. `value` is
    /// a double.
    public var description: String
    {
        get
        {
            return "(Width: \(_Width), Height: \(_Height), Depth: \(_Depth))"
        }
    }
}
