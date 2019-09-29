//
//  PieceDefinition2.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds the definition of one piece.
class PieceDefinition2
{
    // MARK: Piece attributes.
    
    /// Holds the name of the piece.
    private var _Name: String = ""
    /// Get or set the name of the piece.
    public var Name: String
    {
        get
        {
            return _Name
        }
        set
        {
            _Name = newValue
            _Dirty = true
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
            _Dirty = true
        }
    }
    
    /// Holds the piece class of the piece.
    private var _PieceClass: PieceClasses = .Standard
    /// Get or set the class of the piece.
    public var PieceClass: PieceClasses
    {
        get
        {
            return _PieceClass
        }
        set
        {
            _PieceClass = newValue
            _Dirty = true
        }
    }
    
    /// Holds the is user piece flag.
    private var _IsUserPiece: Bool = false
    /// Get or set the user piece flag.
    public var IsUserPiece: Bool
    {
        get
        {
            return _IsUserPiece
        }
        set
        {
            _IsUserPiece = false
            _Dirty = true
        }
    }
    
    /// Holds the thin orientation value.
    private var _ThinOrientation: Int = 0
    /// Get or set the thin orientation value. This the number of times to rotate the piece **right** to make the piece in its thinnest orientation.
    public var ThinOrientation: Int
    {
        get
        {
            return _ThinOrientation
        }
        set
        {
            _ThinOrientation = newValue
            _Dirty = true
        }
    }
    
    /// Holds the wide orientation value.
    private var _WideOrientation: Int = 0
    /// Get or set the wide orientation value. This the number of times to rotate the piece **right** to make the piece in its widest orientation.
    public var WideOrientation: Int
    {
        get
        {
            return _WideOrientation
        }
        set
        {
            _WideOrientation = newValue
            _Dirty = true
        }
    }
    
    /// Holds the rotationally symmetric flag.
    private var _RotationallySymmetric: Bool = false
    /// Get or set the rotationally symmetric flag. Used by the AI for performance optimizations.
    public var RotationallySymmetric: Bool
    {
        get
        {
            return _RotationallySymmetric
        }
        set
        {
            _RotationallySymmetric = newValue
            _Dirty = true
        }
    }
    
    /// Holds the locations of the blocks for the piece.
    private var _Locations: [PieceBlockLocation] = [PieceBlockLocation]()
    /// Get or set the locations for the blocks in the piece.
    public var Locations: [PieceBlockLocation]
    {
        get
        {
            return _Locations
        }
        set
        {
            _Locations = newValue
        }
    }
    
    // MARK: Infrastructure attributes.
    
    /// Holds the dirty flag.
    private var _Dirty: Bool = false
    /// Get or set the dirty fag.
    public var Dirty: Bool
    {
        get
        {
            return _Dirty
        }
        set
        {
            _Dirty = newValue
        }
    }
    
    // MARK: Helper functions.
    
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
        for Loc in Locations
        {
            if Loc.Coordinates.X! < SmallestX
            {
                SmallestX = Loc.Coordinates.X!
            }
            if Loc.Coordinates.Y! < SmallestY
            {
                SmallestY = Loc.Coordinates.Y!
            }
        }
        for Loc in Locations
        {
            Results.append(CGPoint(x: Loc.Coordinates.X! + SmallestX, y: Loc.Coordinates.Y! + SmallestY))
        }
        CachedNormalizedLocations = Results
        return Results
    }
    
    /// Return the least and greatest horizontal coordinates in the set of locations for the piece.
    public func WidthRange() -> (Int, Int)
    {
        var Greatest = Int.min
        var Least = Int.max
        for Location in Locations
        {
            if Location.Coordinates.X! < Least
            {
                Least = Location.Coordinates.X!
            }
            if Location.Coordinates.X! > Greatest
            {
                Greatest = Location.Coordinates.X!
            }
        }
        return (Least, Greatest)
    }
    
    /// Return the least and greatest vertical coordinates in the set of locations for the piece.
    public func HeightRange() -> (Int, Int)
    {
        var Greatest = Int.min
        var Least = Int.max
        for Location in Locations
        {
            if Location.Coordinates.Y! < Least
            {
                Least = Location.Coordinates.Y!
            }
            if Location.Coordinates.Y! > Greatest
            {
                Greatest = Location.Coordinates.Y!
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
