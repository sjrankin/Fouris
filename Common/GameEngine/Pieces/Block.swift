//
//  Block.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// This class represents an individual component in a `Piece`. `Piece`s are made up of one or
/// more `Block`s.
class Block
{
    /// Default intializer.
    init()
    {
        _ID = UUID()
    }
    
    /// Initializer.
    ///
    /// - Parameter BlockID: ID of the block.
    init(BlockID: UUID)
    {
        _ID = BlockID
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - OriginalLocation: Starting location of the block.
    ///   - BlockID: ID of the block.
    init(_ OriginalLocation: CGPoint, BlockID: UUID)
    {
        Location = OriginalLocation
        _ID = BlockID
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - OriginalX: Starting horizontal location of the block.
    ///   - OriginalY: Starting vertical location of the block.
    ///   - IsOriginBlock: Origin block flag. Each piece needs to have one block defined
    ///                    as the origin. Rotations occur using the origin block as the
    ///                    rotational origin.
    ///   - BlockID: ID of the block.
    init(_ OriginalX: Int, _ OriginalY: Int, IsOriginBlock: Bool = false, BlockID: UUID)
    {
        X = OriginalX
        Y = OriginalY
        IsOrigin = IsOriginBlock
        _ID = BlockID
    }
    
    /// Initializer.
    ///
    /// - Parameter CopyFrom: Source block used to populate the new block.
    init(CopyFrom: Block)
    {
        _ID = CopyFrom.ID
        X = CopyFrom.X
        Y = CopyFrom.Y
        IsOrigin = CopyFrom.IsOrigin
        Location = CopyFrom.Location
    }
    
    /// Holds the ID of the block.
    private var _ID: UUID = UUID.Empty
    /// Get or set the ID of the block.
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
    
    /// Holds the origin flag for the block.
    private var _IsOrigin: Bool = false
    /// Get or set the origin flag. Only one block in a piece may be the origin and each piece
    /// must have a block that has this flag set to true. The block that is the origin of the
    /// piece is used for rotational calculations.
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
    
    /// Holds the location of the block.
    private var _Location: CGPoint = CGPoint.zero
    /// Get or set the location of the block.
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
    
    /// Get or set the horizontal location of the block.
    public var X: Int
    {
        get
        {
            return Int(floor(Location.x))
        }
        set
        {
            Location.x = CGFloat(newValue)
        }
    }
    
    /// Get or set the vertical location of the block.
    public var Y: Int
    {
        get
        {
            return Int(floor(Location.y))
        }
        set
        {
            Location.y = CGFloat(newValue)
        }
    }
    
    /// Calculates (but does not save) the location of the block with the passed offset value.
    ///
    /// - Parameter Offset: Offset to apply to the block's location and return (but **not** save)
    /// - Returns: The location of the block combined with the passed offset. The block's location
    ///            itself is **not** changed.
    public func LocationWith(Offset: CGPoint) -> CGPoint
    {
        return Location.WithOffset(Offset)
    }
}
