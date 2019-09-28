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
    /// Get or set the thin orientation value.
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
    /// Get or set the wide orientation value.
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
}
