//
//  GameMap.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/21/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Map of the game board and bucket.
/// - Note: The bucket is a subset of the board. Pieces may "live" in any part of the board but the game only cares about the
///         bucket.
/// - Attention: Consumers of the map are expected to access this class via the `MapAccessProtocol` only.
class GameMap: CustomStringConvertible, MapAccessProtocol
{
    /// Notification protocol for map changes/actions.
    weak var Delegate: GameMapProtocol? = nil
    
    // MARK: - Class initialization.
    
    /// Initializer.
    /// - Parameter WithBoard: The game's board management class.
    /// - Parameter Description: The description of the board from the board file.
    init(WithBoard: Board, Description: BoardDescriptor2)
    {
        GameBoard = WithBoard
        Descriptor = Description
        PopulateMap()
    }
    
    /// Holds the game board.
    private var GameBoard: Board? = nil
    
    /// Holds the board descriptor.
    private var Descriptor: BoardDescriptor2? = nil
    
    /// Populates the map from the board descriptor.
    private func PopulateMap()
    {
        CurrentRotation = 0
        _BoardMap = Array(repeating: Array(repeating: MapNodes.BucketExterior, count: Descriptor!.GameBoardWidth),
                          count: Descriptor!.GameBoardHeight)
        for Y in 0 ..< Descriptor!.GameBoardHeight
        {
            _BoardMap[Y][0] = .InvisibleBarrier
            _BoardMap[Y][Descriptor!.GameBoardWidth - 1] = .InvisibleBarrier
        }
        for X in 0 ..< Descriptor!.GameBoardWidth
        {
            _BoardMap[0][X] = .InvisibleBarrier
            _BoardMap[Descriptor!.GameBoardHeight - 1][X] = .InvisibleBarrier
        }
        for Y in Descriptor!.BucketY ..< Descriptor!.BucketY + Descriptor!.BucketHeight - 1
        {
            for X in Descriptor!.BucketX ..< Descriptor!.BucketX + Descriptor!.BucketWidth - 1
            {
                _BoardMap[Y][X] = .BucketInterior
            }
        }
        for Barrier in Descriptor!.BucketBlockList()
        {
            _BoardMap[Int(Barrier.y)][Int(Barrier.x)] = .Barrier
        }
    }
    
    /// Resets the map to its original state.
    func ResetMap()
    {
        PopulateMap()
        Delegate?.GameMapReset()
    }
    
    /// Holds the entire board map.
    private var _BoardMap: MapContentType = MapContentType()
    /// Get the board map. The bucket is a subset of this map.
    public var BoardMap: MapContentType
    {
        get
        {
            return _BoardMap
        }
    }
    
    // MARK: - Map manipulations.
    
    /// Returns a map of the bucket.
    public func GetBucketMap() -> MapContentType
    {
        var BucketMap = Array(repeating: Array(repeating: MapNodes.BucketExterior, count: Descriptor!.BucketWidth),
                              count: Descriptor!.BucketHeight)
        for Y in Descriptor!.BucketY ..< Descriptor!.BucketY + Descriptor!.GameBoardHeight - 1
        {
            for X in Descriptor!.BucketX ..< Descriptor!.BucketY + Descriptor!.GameBoardWidth - 1
            {
                BucketMap[Y - Descriptor!.BucketY][X - Descriptor!.BucketX] = _BoardMap[Y][X]
            }
        }
        return BucketMap
    }
    
    /// Determines if the passed coordinates are valid for the current bucket.
    /// - Parameter X: The horizontal coordinate.
    /// - Parameter Y: The vertical coordinate.
    /// - Returns: True if the coordinates are valid for the bucket in the board map, false if not.
    public func ValidBucketLocation(_ X: Int, _ Y: Int) -> Bool
    {
        if X < 0 || X > Descriptor!.BucketWidth - 1
        {
            return false
        }
        if Y < 0 || Y > Descriptor!.BucketHeight - 1
        {
            return false
        }
        return true
    }
    
    /// Returns the contents of the bucket at the specified location.
    /// - Parameter X: The horizontal coordinate in the bucket.
    /// - Parameter Y: The vertical coodinate in the bucket.
    /// - Returns: The value of the bucket at the specified location. Nil returned if passed coordinates
    ///            are invalid.
    public func GetBucket(X: Int, Y: Int) -> MapNodes?
    {
        if !ValidBucketLocation(X, Y)
        {
            return nil
        }
        return _BoardMap[Descriptor!.BucketY + Y][Descriptor!.BucketX + X]
    }
    
    /// Set the contents of the bucket at the specified location.
    /// - Note: If the passed coordinates are not valid, no action is taken.
    /// - Parameter X: The horizontal coordinate in the bucket.
    /// - Parameter Y: The vertical coodinate in the bucket.
    /// - Parameter MapNode: The contents to place at the passed coordinates.
    public func SetBucket(X: Int, Y: Int, MapNode: MapNodes)
    {
        if !ValidBucketLocation(X, Y)
        {
            return
        }
        _BoardMap[Descriptor!.BucketY + Y][Descriptor!.BucketX + X] = MapNode
        Delegate?.BucketChanged(X: X, Y: Y, Node: MapNode)
    }
    
    /// Determines if the specified location within the bucket is empty (meaning the node is `.BucketInterior`).
    /// - Parameter X: The horizontal coordinate.
    /// - Parameter Y: The vertical coordinate.
    /// - Returns: True if the bucket contents at the coordinate are empty, false if something is there.
    public func BucketIsEmptyAt(X: Int, Y: Int) -> Bool
    {
        return _BoardMap[Y + Descriptor!.BucketY][X + Descriptor!.BucketX] == .BucketInterior
    }
    
    // MARK: - Piece management.
    
    /// Determines if all blocks in the passed piece reside fully within the bucket.
    /// - Parameter TestPiece: The piece to test for bucket inclusion.
    /// - Returns: True if `TestPiece` is fully within the bucket, false if not.
    public func PieceInBucket(TestPiece: Piece) -> Bool
    {
        for Block in TestPiece.Locations
        {
            if Block.X < Descriptor!.BucketX || Block.X > Descriptor!.BucketX
            {
                return false
            }
            if Block.Y < Descriptor!.BucketY || Block.Y > Descriptor!.BucketY
            {
                return false
            }
        }
        return true
    }
    
    /// Returns a recommended initial location for the passed piece. The returned location is relative to the game board,
    /// *not* the bucket.
    /// - Note: The return location is dependent on the orientation of the piece.
    /// - Parameter For: The piece whose recommended initial location is returned.
    /// - Returns: Tuple with X as the initial horizontal coordinate, and Y the intitial vertical coordinate. **The returned
    ///            coordinate is for the top-most location of the piece, not the center of the piece.**
    public func InitialLocation(For NewPiece: Piece) -> (X: Int, Y: Int)
    {
        // Start at 1 because 0 is occupied with an invisible barrier.
        let Y = 1
        var X = Descriptor!.GameBoardWidth / 2
        X = X - NewPiece.Width / 2
        return (X, Y)
    }
    
    /// Add a new piece to the map that is in motion.
    /// - Parameter NewPiece: The piece to add.
    public func AddInPlayPiece(NewPiece: Piece)
    {
        InPlay.append(NewPiece)
    }
    
    public func MergePieceWithMap(Retired: Piece)
    {
        
    }
    
    /// Holds the list of pieces in play.
    /// - Note: Intended to support multiple pieces but for now, probably only one piece at a time is for the best.
    private var InPlay: [Piece] = [Piece]()
    
    // MARK: - Row deletion code.
    
    /// Determines if a row in the bucket is full of blocks.
    /// - Parameter AtRow: The row in the bucket to test for fullness.
    /// - Parameter IgnoreBarriers: If true, barriers are ignored when testing for full rows. When false, if a barrier is present
    ///                             in a row, that row can never be full.
    /// - Returns: True if the row is full of blocks (see `IgnoreBarriers` as well), false if not.
    public func RowIsFull(AtRow: Int, IgnoreBarriers: Bool = false) -> Bool
    {
        for X in Descriptor!.BucketX ..< Descriptor!.BucketX + Descriptor!.BucketWidth
        {
            let Node = _BoardMap[AtRow + Descriptor!.BucketY][X]
            if IgnoreBarriers
            {
                if Node != .PieceBlock && Node != .Barrier
                {
                    return false
                }
            }
            if Node != .PieceBlock
            {
                return false
            }
        }
        return true
    }
    
    /// Removes all pieces from a row in the bucket, setting them to empty bucket interior values.
    /// - Parameter Row: The row to clear.
    public func ClearRow(Row: Int)
    {
        for X in Descriptor!.BucketX ..< Descriptor!.BucketX + Descriptor!.BucketWidth
        {
            if _BoardMap[Row + Descriptor!.BucketY][X] == .PieceBlock
            {
                _BoardMap[Row + Descriptor!.BucketY][X] = .BucketInterior
            }
        }
    }
    
    /// Determines if there is a barrier block in the bucket at the passed row.
    /// - Parameter Row: The row in the bucket to check.
    /// - Returns: True if the row contains a barrier block, false if not.
    public func BarrierIn(Row: Int) -> Bool
    {
        for X in Descriptor!.BucketX ..< Descriptor!.BucketX + Descriptor!.BucketWidth
        {
            if _BoardMap[Row + Descriptor!.BucketY][X] == .Barrier
            {
                return true
            }
        }
        return false
    }
    
    /// Shifts a range of rows down by one row.
    /// - Note: Barriers are not shifted or overwritten.
    /// - Warning:
    ///   - Fatal errors are generated if:
    ///     - `ToY` is less than `FromY`.
    ///     - The shifting will result in rows being shifted out of the bottom of the bucket.
    /// - Parameter FromY: Starting row.
    /// - Parameter ToY: Ending row.
    public func ShiftRows(FromY: Int, ToY: Int)
    {
        if ToY < FromY
        {
            fatalError("Invalid row shifting range: tried to shift from \(FromY) to \(ToY)")
        }
        for Y in FromY ... ToY
        {
            if Y + 1 > Descriptor!.BucketX + Descriptor!.BucketHeight - 1
            {
                fatalError("Cannot shift contents lower than bottom of bucket.")
            }
            for X in Descriptor!.BucketX ..< Descriptor!.BucketX + Descriptor!.BucketWidth
            {
                if _BoardMap[Y + Descriptor!.BucketY][X + Descriptor!.BucketX] == .Barrier
                {
                    continue
                }
                if _BoardMap[Y + Descriptor!.BucketY - 1][X + Descriptor!.BucketX] == .Barrier
                {
                    continue
                }
                _BoardMap[Y + Descriptor!.BucketY - 1][X + Descriptor!.BucketX] = _BoardMap[Y + Descriptor!.BucketY][X + Descriptor!.BucketX]
            }
        }
    }
    
    /// Collapses horizontal rows that are full of game piece blocks.
    /// - Note: The game should call this after every time a piece freezes.
    /// - Parameter StartingRow: Where to start looking for full rows. Some board types will start in the middle while others
    ///                          will start at the bottom.
    /// - Parameter IgnoreBarriers: If true, barriers will not be considered when checking for full rows. If false, barries are
    ///                             treated as empty spaces and as such, will not cause a row to be collapsed.
    /// - Parameter DeletionCompletion: Completion handler called at the completion of each row deletion action.
    public func CollapseFullRows(StartingRow: Int, IgnoreBarriers: Bool = false, DeletionCompletion: ((Int) -> ())? = nil)
    {
        if !ValidBucketLocation(0, StartingRow)
        {
            return
        }
        var Y = StartingRow
        while true
        {
            if RowIsFull(AtRow: Y, IgnoreBarriers: IgnoreBarriers)
            {
                //Remove the row and shift rows above it down by one row.
                //Do not increment Y here because a row that was moved into this (Y) location may be full and needs
                //to be checked and removed if necessary.
                ShiftRows(FromY: Y, ToY: 0)
                DeletionCompletion?(Y)
                Delegate?.RowDeleted(Row: Y)
            }
            else
            {
                //The row was not full - move up to the next row. If we move up too far, we are done.
                Y = Y - 1
                if Y < 0
                {
                    return
                }
            }
        }
    }
    
    // MARK: - Map rotations.
    
    /// Used to keep track of the rotations.
    private var CurrentRotation = 0
    
    /// Rotate the contents of the map and the block map 90° left.
    /// - Attention: Throws a fatal error if the **Game Board Height** and **Game Board Width** are not identical.
    public func RotateMapLeft()
    {
        if Descriptor!.GameBoardWidth != Descriptor!.GameBoardHeight
        {
            fatalError("Unable to rotate map left because dimensions are not identical.")
        }
        CurrentRotation = CurrentRotation - 1
        var Scratch = Array(repeating: Array(repeating: MapNodes.BucketExterior, count: Descriptor!.GameBoardWidth),
                            count: Descriptor!.GameBoardHeight)
        for Y in 0 ..< Descriptor!.GameBoardHeight
        {
            for X in 0 ..< Descriptor!.GameBoardWidth
            {
                Scratch[X][Y] = _BoardMap[Y][Descriptor!.GameBoardWidth - X - 1]
            }
        }
        _BoardMap = Scratch
        Delegate?.MapRotated(Right: false)
    }
    
    /// Rotate the contents of the map and the block map 90° right.
    /// - Attention: Throws a fatal error if the **Game Board Height** and **Game Board Width** are not identical.
    public func RotateMapRight()
    {
        if Descriptor!.GameBoardWidth != Descriptor!.GameBoardHeight
        {
            fatalError("Unable to rotate map left because dimensions are not identical.")
        }
        CurrentRotation = CurrentRotation + 1
        var Scratch = Array(repeating: Array(repeating: MapNodes.BucketExterior, count: Descriptor!.GameBoardWidth),
                            count: Descriptor!.GameBoardHeight)
        for Y in 0 ..< Descriptor!.GameBoardHeight
        {
            for X in 0 ..< Descriptor!.GameBoardWidth
            {
                Scratch[X][Y] = _BoardMap[Descriptor!.GameBoardWidth - X - 1][Y]
            }
        }
        _BoardMap = Scratch
        Delegate?.MapRotated(Right: true)
    }
    
    /// Rotate the contents of the bucket by 180°.
    /// - ToDo: Change the double rotation by 90° into a more efficient algorithm.
    public func RotateBucketContents180()
    {
        var Scratch = Array(repeating: Array(repeating: MapNodes.BucketInterior, count: Descriptor!.BucketWidth),
                            count: Descriptor!.BucketHeight)
        for Y in 0 ..< Descriptor!.BucketHeight
        {
            for X in 0 ..< Descriptor!.BucketWidth
            {
                Scratch[X][Y] = _BoardMap[Descriptor!.BucketWidth - X - 1][Y]
            }
        }
        for Y in 0 ..< Descriptor!.BucketHeight
        {
            for X in 0 ..< Descriptor!.BucketWidth
            {
                Scratch[X][Y] = _BoardMap[Descriptor!.BucketWidth - X - 1][Y]
            }
        }
        MergeBucketMap(NewContents: Scratch)
        Delegate?.BucketRotated(By180: true)
    }
    
    /// Merge a bucket map with the current board map.
    /// - Attention: If the dimensions of `NewContents` do not match that of the current `_BoardMap`, a fatal error is generated.
    /// - Parameter NewContents: The bucket map to merge into the current board map.
    public func MergeBucketMap(NewContents: MapContentType)
    {
        if NewContents.count != Descriptor!.BucketHeight
        {
            fatalError("New bucket map height not equal to map bucket height.")
        }
        if NewContents[0].count != Descriptor!.BucketWidth
        {
            fatalError("New bucket map width not equal to map bucket width.")
        }
        for Y in 0 ..< Descriptor!.BucketHeight
        {
            for X in 0 ..< Descriptor!.BucketWidth
            {
                _BoardMap[Y + Descriptor!.BucketX][X + Descriptor!.BucketY] = NewContents[Y][X]
            }
        }
    }
    
    // MARK: - String representations of the map.
    
    /// Map of symbols to map node types. Used for generating string representations of the map.
    let MapSymbols: [MapNodes: String] =
        [
            .BucketInterior: "▭",
            .BucketExterior: "◯",
            .Barrier: "█",
            .InvisibleBarrier: "◌",
            .PieceBlock: "🞛"
    ]
    
    /// Returns the contents of the map as a string.
    /// - Parameter BucketOnly: If true, only the bucket portion of the map is returned.
    /// - Returns: The Game board (or bucket - see `BucketOnly`) as a string.
    public func ToString(BucketOnly: Bool = false) -> String
    {
        var Working = ""
        if BucketOnly
        {
            for Y in Descriptor!.BucketY ..< Descriptor!.BucketY + Descriptor!.GameBoardHeight - 1
            {
                for X in Descriptor!.BucketX ..< Descriptor!.BucketY + Descriptor!.GameBoardWidth - 1
                {
                    Working.append(MapSymbols[_BoardMap[Y][X]]!)
                }
                Working.append("\n")
            }
        }
        else
        {
            for Y in 0 ..< Descriptor!.GameBoardHeight
            {
                for X in 0 ..< Descriptor!.GameBoardWidth
                {
                    Working.append(MapSymbols[_BoardMap[Y][X]]!)
                }
                Working.append("\n")
            }
        }
        return Working
    }
    
    /// Returns a string representation of the contents of the class.
    public var description: String
    {
        get
        {
            return ToString()
        }
    }
}

/// Describes the contents of the map.
/// - **BucketInterior**: Empty bucket interior.
/// - **BucketExterior**: Empty bucket exterior.
/// - **Barrier**: Barrier through which pieces may not also occupy.
/// - **InvisibleBarrier**: Invisible barrier through which pieces may not also occupy.
/// - **PieceBlock**: Block of a piece from the game.
enum MapNodes: Int, CaseIterable
{
    case BucketInterior = 0
    case BucketExterior = 1
    case Barrier = 2
    case InvisibleBarrier = 3
    case PieceBlock = 4
}
