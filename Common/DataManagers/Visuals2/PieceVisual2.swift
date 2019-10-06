//
//  PieceVisual2.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Encapsulates visual information to draw one game piece. Each game piece will have one `PieceVisual`.
class PieceVisual2: CustomStringConvertible
{
    /// Holds the dirty flag.
    private var _Dirty: Bool = false
    /// Get or set the dirty flag.
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
    
    /// Holds the user piece flag.
    public var _UserPiece: Bool = false
    /// Get or set the flag that indicates this set of visuals is for a user-defined piece.
    public var UserPiece: Bool
    {
        get
        {
            return _UserPiece
        }
        set
        {
            _UserPiece = newValue
            _Dirty = true
        }
    }
    
    /// Holds the ID of the visual.
    public var _PieceID: UUID = UUID.Empty
    /// Get or set the ID of the visual.
    /// - Note: This ID **must** match the ID of the shape of the
    ///         visual or the piece will *not* be rendered correctly.
    public var PieceID: UUID
    {
        get
        {
            return _PieceID
        }
        set
        {
            _PieceID = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the piece.
    public var _PieceName: String = ""
    /// Get or set the name of the piece.
    /// - Note: This value is not intended to be used anywhere but is present in the XML file
    ///         as an aid for the person who maintains it so he knows which piece he is working
    ///         on.
    public var PieceName: String
    {
        get
        {
            return _PieceName
        }
        set
        {
            _PieceName = newValue
            _Dirty = true
        }
    }
    
    /// Holds the active state visuals.
    public var _ActiveVisuals: StateVisual? = nil
    /// Get or set the active state visuals.
    public var ActiveVisuals: StateVisual?
    {
        get
        {
            return _ActiveVisuals
        }
        set
        {
            _ActiveVisuals = newValue
            _Dirty = true
        }
    }
    
    /// Holds the retired state visuals.
    public var _RetiredVisuals: StateVisual? = nil
    /// Get or set the retired state visuals.
    public var RetiredVisuals: StateVisual?
    {
        get
        {
            return _RetiredVisuals
        }
        set
        {
            _RetiredVisuals = newValue
            _Dirty = true
        }
    }
    
    // MARK: Serialization.
    
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
    
    /// Returns the contents of the piece visual as an XML-fragment.
    /// - Parameter Indent: Number of spaces to indent.
    public func ToString(Indent: Int = 4, AppendTerminalReturn: Bool = true) -> String
    {
        var Working = ""
        Working.append(Spaces(4) + "<PieceVisual PieceID=" + Quoted(PieceID.uuidString) + " UserPiece=" + Quoted("\(UserPiece)") +
        " Name=" + Quoted(PieceName) + ">\n")
        Working.append(ActiveVisuals!.ToString(Indent: Indent + 4))
        Working.append(RetiredVisuals!.ToString(Indent: Indent + 4))
        Working.append(Spaces(4) + "</PieceVisual>")
        if AppendTerminalReturn
        {
            Working.append("\n")
        }
        return Working
    }
    
    /// Returns a string description of the contents of the class as an XML-fragment.
    public var description: String
    {
        get
        {
            return ToString()
        }
    }
}
