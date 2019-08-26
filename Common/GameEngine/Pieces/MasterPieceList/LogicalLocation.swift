//
//  LogicalLocation.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains the location of a single block in a piece. This location represents the original
/// location as per the serialized piece list.
class LogicalLocation: Serializable
{
    /// Default initializer.
    init()
    {
    }
    
    /// Sanitize the passed string such that no quotation marks are in it.
    ///
    /// - Parameter Raw: The string to sanitize.
    /// - Returns: Sanitized string.
    func Sanitize(_ Raw: String) -> String
    {
        let Done = Raw.replacingOccurrences(of: "\"", with: "")
        return Done
    }
    
    /// Called by the deserializer. Populates the class, one property at a time.
    ///
    /// - Parameters:
    ///   - Key: The name of the property to populate.
    ///   - Value: The value of the property.
    func Populate(Key: String, Value: String)
    {
        let Sanitized = Sanitize(Value)
        switch Key
        {
        case "_IsOrigin":
            //Bool
            _IsOrigin = Bool(Sanitized)!
            
        case "_Location":
            //CGPoint
            let Parts = Sanitized.split(separator: ",", omittingEmptySubsequences: true)
            if Parts.count != 2
            {
                fatalError("Invalid location \(Sanitized) encountered.")
            }
            let X: Int = Int(String(Parts[0]))!
            let Y: Int = Int(String(Parts[1]))!
            _Location = CGPoint(x: X, y: Y)
            
        default:
            break
        }
    }
    
    /// Holds the logical location of a block.
    private var _Location: CGPoint = CGPoint.zero
    /// Get or set the logical location of a block.
    public var Location: CGPoint
    {
        get
        {
            return _Location
        }
        set
        {
            _Location = newValue
        }
    }
    
    /// Holds the origin flag.
    private var _IsOrigin: Bool = false
    /// Get or set the origin flag - this is the flag that indicates which point is the pivot point for rotations. Only one
    /// block should be a pivot point.
    public var IsOrigin: Bool
    {
        get
        {
            return _IsOrigin
        }
        set
        {
            _IsOrigin = newValue
        }
    }
    
    /// Get the X coordinate.
    public var X: Int
    {
        get
        {
            return Int(Location.x)
        }
    }
    
    /// Get the Y coordinate.
    public var Y: Int
    {
        get
        {
            return Int(Location.y)
        }
    }
}
