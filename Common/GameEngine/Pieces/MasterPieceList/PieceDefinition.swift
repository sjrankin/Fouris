//
//  PieceDefinition.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains one piece's definition in terms of where the blocks that make up the piece are situated.
class PieceDefinition: Serializable
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
            case "_Name":
                //PieceShapes
                _Name = PieceShapes(rawValue: Sanitized)!
            
            case "_ID":
                //UUID
                _ID = UUID(uuidString: Sanitized)!
            
            case "_PieceClass":
                //PieceClasses
                _PieceClass = PieceClasses(rawValue: Sanitized)!
            
            case "_RandomSquareSize":
                //Int
                _RandomSquareSize = Int(Sanitized)!
            
            case "_RotationallySymmetric":
                //Bool
                _RotationallySymmetric = Bool(Sanitized)!
            
            case "_ThinOrientation":
                //Int
                _ThinOrientation = Int(Sanitized)!
            
            case "_WideOrientation":
                //Int
                _WideOrientation = Int(Sanitized)!
            
            case "_IsUserPiece":
            //Bool
            _IsUserPiece = Bool(Sanitized)!
            
            default:
                break
        }
    }
    
    /// Holds the ID of the piece.
    private var _ID: UUID = UUID.Empty
    /// Get or set the ID of the piece.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
        }
    }
    
    /// Holds the user-piece flag.
    private var _IsUserPiece: Bool = false
    /// Get or set the is-user-piece flag. If false, the piece is built-in. If true, the piece was created
    /// by the user.
    public var IsUserPiece: Bool
    {
        get
        {
            return _IsUserPiece
        }
        set
        {
            _IsUserPiece = newValue
        }
    }
    
    /// Holds the name of the piece shape.
    private var _Name: PieceShapes = .Square
    /// Get or set the name of the piece shape.
    public var Name: PieceShapes
    {
        get
        {
            return _Name
        }
        set
        {
            _Name = newValue
        }
    }
    
    /// Holds the piece class.
    private var _PieceClass: PieceClasses = .Standard
    /// Get or set the piece class.
    public var PieceClass: PieceClasses
    {
        get
        {
            return _PieceClass
        }
        set
        {
            _PieceClass = newValue
        }
    }
    
    /// Holds the size of the square for randomly-generated pieces.
    private var _RandomSquareSize: Int = 0
    /// Size of the field (square in shape) for randomly-generated pieces.
    public var RandomSquareSize: Int
    {
        get
        {
            return _RandomSquareSize
        }
        set
        {
            _RandomSquareSize = newValue
        }
    }
    
    /// Holds the rotationally symmetric value.
    private var _RotationallySymmetric: Bool = false
    /// Get or set the rotationally symmetric flag. If true, the piece is 2D rotationally symmetric.
    public var RotationallySymmetric: Bool
    {
        get
        {
            return _RotationallySymmetric
        }
        set{
            _RotationallySymmetric = newValue
        }
    }
    
    /// Holds a list of logical locations
    private var _LogicalLocations = [LogicalLocation](repeating: LogicalLocation(), count: 4)
    /// Get or set the list of logical locations
    public var LogicalLocations: [LogicalLocation]
    {
        get
        {
            return _LogicalLocations
        }
        set
        {
            _LogicalLocations = newValue
        }
    }
    
    /// Holds the number of times to rotate the piece **right** to make the piece in its thinnest orientation.
    private var _ThinOrientation: Int = 0
    /// Get or set the number of times to rotate the piece **right** to make the piece in its thinnest orientation.
    public var ThinOrientation: Int
    {
        get
        {
            return _ThinOrientation
        }
        set
        {
            _ThinOrientation = newValue
        }
    }
    
    /// Holds the number of times to rotate the piece **right** to make the piece in its widest orientation.
    private var _WideOrientation: Int = 0
    /// Get or set the number of times to rotate the piece **right** to make the piece in its widest orientation.
    public var WideOrientation: Int
    {
        get
        {
            return _WideOrientation
        }
        set
        {
            _WideOrientation = newValue
        }
    }
    
    /// Holds cached, normalized locations.
    private var CachedNormalizedLocations = [(CGPoint)]()
    
    /// Return a set of normalized coordinates where no coordinate value is less than 0.
    ///
    /// - Note: Normalized locations are cached (mainly because once read, the definition doesn't change) for
    ///         performance purposes.
    ///
    /// - Parameter ResetCache: If true, the cache is reset and regenerated.
    /// - Returns: Set or normalized coordinates.
    public func NormalizedLocations(ResetCache: Bool = false) -> [(CGPoint)]
    {
        if ResetCache
        {
            CachedNormalizedLocations = [(CGPoint)]()
        }
        if !CachedNormalizedLocations.isEmpty
        {
            return CachedNormalizedLocations
        }
        var Results = [(CGPoint)]()
        var SmallestX = Int.max
        var SmallestY = Int.max
        for Loc in LogicalLocations
        {
            if Loc.X < SmallestX
            {
                SmallestX = Loc.X
            }
            if Loc.Y < SmallestY
            {
                SmallestY = Loc.Y
            }
        }
        for Loc in LogicalLocations
        {
            Results.append(CGPoint(x: Loc.X + SmallestX, y: Loc.Y + SmallestY))
        }
        CachedNormalizedLocations = Results
        return Results
    }
    
    /// Return the least and greatest horizontal coordinates in the set of locations for the piece.
    public func WidthRange() -> (Int, Int)
    {
        var Greatest = Int.min
        var Least = Int.max
        for Location in LogicalLocations
        {
            if Location.X < Least
            {
                Least = Location.X
            }
            if Location.X > Greatest
            {
                Greatest = Location.X
            }
        }
        return (Least, Greatest)
    }
    
    /// Return the least and greatest vertical coordinates in the set of locations for the piece.
    public func HeightRange() -> (Int, Int)
    {
        var Greatest = Int.min
        var Least = Int.max
        for Location in LogicalLocations
        {
            if Location.Y < Least
            {
                Least = Location.Y
            }
            if Location.Y > Greatest
            {
                Greatest = Location.Y
            }
        }
        return (Least, Greatest)
    }
    
    /// Return the width of the piece in its original configuration.
    public func OriginalWidth() -> Int
    {
        let (Least, Greatest) = WidthRange()
        return Greatest - Least + 1
    }
    
    /// Return the width of the piece in its original configuration.
    public func OriginalHeight() -> Int
    {
        let (Least, Greatest) = HeightRange()
        return Greatest - Least + 1
    }
}
