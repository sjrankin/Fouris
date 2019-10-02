//
//  PieceBlockLocation.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds one block's location from the piece definition file.
class PieceBlockLocation: CustomStringConvertible
{
    /// Holds the block index.
    private var _Index: Int = 0
    /// Get or set the index of the block.
    public var Index: Int
    {
        get
        {
            return _Index
        }
        set
        {
            _Index = newValue
        }
    }
    
    /// Holds the coordinates of the block.
    private var _Coordinates: Point3D<Int> = Point3D<Int>(0, 0, 0) 
    /// Get or set the coordinates of the block.
    public var Coordinates: Point3D<Int>
    {
        get
        {
            return _Coordinates
        }
        set
        {
            _Coordinates = newValue
        }
    }
    
    /// Holds the block is origin flag.
    private var _IsOrigin: Bool = false
    /// Get or set the block origin flag.
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
    
    // MARK: CustomStringConvertible functions and related.
    
    /// Returns the specified number of spaces in a string.
    /// - Parameter Count: The number of spaces to return.
    /// - Returns: String with the specified number of spaces.
    private func Spaces(_ Count: Int) -> String
    {
        var SpaceString = ""
        for _ in 0 ..< Count
        {
            SpaceString = SpaceString + " "
        }
        return SpaceString
    }
    
    /// Returns the passed string surrounded by quotation marks.
    /// - Parameter Raw: The string to return surrounded by quotation marks.
    /// - Returns: `Raw` surrounded by quotation marks.
    private func Quoted(_ Raw: String) -> String
    {
        return "\"\(Raw)\""
    }
    
    /// Converts the contents of this instance into a string in XML fragment format.
    /// - Parameter IndentSize: Number of spaces to append to the start of the line for indentation purposes.
    /// - Parameter AddReturn: If true, a return character is appended to the end of the returned string.
    /// - Returns: XML fragment string with the contents of this instance.
    public func ToString(IndentSize: Int, AddReturn: Bool = true) -> String
    {
        let Terminal = AddReturn ? "\n" : ""
        let Working = Spaces(IndentSize) + "<Location Index=" + Quoted("\(Index)") +
            " XY=" + Quoted(Coordinates.ToString()) +
            " IsOrigin=" + Quoted("\(IsOrigin)") + "/>" + Terminal
        return Working
    }
    
    /// Returns a string with the contents of this class.
    /// - Note: Calls `ToString()`.
    public var description: String
    {
        get
        {
            return ToString(IndentSize: 0)
        }
    }
}


