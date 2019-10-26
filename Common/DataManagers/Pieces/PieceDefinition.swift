//
//  PieceDefinition.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds the definition of one piece.
class PieceDefinition: CustomStringConvertible
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
    
    /// Holds the node ID from the source XML document tree.
    private var _NodeID: UUID = UUID.Empty
    /// Get or set the node ID from the source XML document tree.
    public var NodeID: UUID
    {
        get
        {
            return _NodeID
        }
        set
        {
            _NodeID = newValue
        }
    }
    
    /// Holds comment nodes for the piece.
    private var _CommentNodes: [String] = [String]()
    /// Get or set comment nodes for the piece.
    public var CommentNodes: [String]
    {
        get
        {
            return _CommentNodes
        }
        set
        {
            _CommentNodes = newValue
        }
    }
    
    /// Holds the payload for a node.
    private var _NodePayload: String = ""
    /// Get or set the node's payload value.
    public var NodePayload: String
    {
        get
        {
            return _NodePayload
        }
        set
        {
            _NodePayload = newValue
        }
    }
    
    /// Holds the can delete piece flag.
    private var _CanDelete: Bool = false
    /// Get or set the can delete piece flag. Unless set otherwise, all pieces may not be deleted.
    public var CanDelete: Bool
    {
        get
        {
            return _CanDelete
        }
        set
        {
            _CanDelete = newValue
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
            _IsUserPiece = newValue
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
    
    /// Holds the payload of the location.
    private var _LocationPayload: String = ""
    /// Get or set the location payload.
    public var LocationPayload: String
    {
        get
        {
            return _LocationPayload
        }
        set
        {
            _LocationPayload = newValue
        }
    }
    
    /// Holds the comments from the location node.
    private var _LocationComments: [String] = [String]()
    /// Get or set location comments.
    public var LocationComments: [String]
    {
        get
        {
            return _LocationComments
        }
        set
        {
            _LocationComments = newValue
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
    /// - Note: Normalized locations are cached (mainly because once read, the definition doesn't change) for
    ///         performance purposes.
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
    
    // MARK: CustomStringConvertible functions and related.
    
    /// Returns a string with the passed number of spaces in it.
    /// - Parameter Count: Number of spaces to include in the string.
    /// - Returns: String with the specified number of spaces in it.
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
    
    /// Returns a string in XML format (at least fragments of XML) with the contents of this instance in it.
    /// - Parameter IndentSize: Number of spaces to prepend the initial line for purposes of indentation. Nested
    ///                         lines are indented `+4` spaces at each level.
    /// - Returns: XML string with the contents of this instance.
    public func ToString(IndentSize: Int) -> String
    {
        var Working = ""
        Working = Spaces(IndentSize) + "<Piece Name=" + Quoted(Name) + " ID=" +
            Quoted(ID.uuidString) + " CanDelete=" + Quoted("\(CanDelete)") +
            " Class=" + Quoted(PieceClass.rawValue) + ">\n"
        
        var NextDent = IndentSize + 4
        if !NodePayload.isEmpty
        {
            Working.append(Spaces(NextDent) + NodePayload + "\n")
        }
        for CommentNode in CommentNodes
        {
            Working.append(Spaces(NextDent) + "<!-- " + CommentNode + " -->\n")
        }
        Working.append(Spaces(NextDent) + "<UserPiece UserDefined=" + Quoted("\(IsUserPiece)") + "/>\n")
        Working.append(Spaces(NextDent) + "<Geometry Thin=" + Quoted("\(ThinOrientation)") +
            " Wide=" + Quoted("\(WideOrientation)") + " Symmetric=" +
            Quoted("\(RotationallySymmetric)") + "/>\n")
        
        Working.append(Spaces(NextDent) + "<LogicalLocations>\n")
        NextDent = NextDent + 4
        if !LocationPayload.isEmpty
        {
            Working.append(Spaces(NextDent) + LocationPayload.trimmingCharacters(in: CharacterSet.whitespaces) + "\n")
        }
        for CommentNode in LocationComments
        {
            Working.append(Spaces(NextDent) + "<! " + CommentNode + " !>\n")
        }
        for Location in Locations
        {
            Working.append(Location.ToString(IndentSize: NextDent, AddReturn: true))
        }
        NextDent = NextDent - 4
        Working.append(Spaces(NextDent) + "</LogicalLocations>\n")
        Working.append(Spaces(IndentSize) + "</Piece>\n")
        return Working
    }
    
    /// Returns the contents of this instance as an XML string.
    /// - Note: Calls `ToString()`.
    public var description: String
    {
        get
        {
            return ToString(IndentSize: 0)
        }
    }
}
