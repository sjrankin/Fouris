//
//  MapAccessProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol MapAccessProtocol: class
{
    /// Simplification of the type of the bucket map.
    typealias MapContentType = [[MapNodes]]
    
    /// Resets the map to its original state.
    func ResetMap()
    
    /// Get the board map.
    var BoardMap: MapContentType { get }
    
    /// Returns a map of the bucket.
    func GetBucketMap() -> MapContentType
    
    /// Determines if the passed coordinates are valid for the current bucket.
    /// - Parameter X: The horizontal coordinate.
    /// - Parameter Y: The vertical coordinate.
    /// - Returns: True if the coordinates are valid for the bucket in the board map, false if not.
    func ValidBucketLocation(_ X: Int, _ Y: Int) -> Bool
    
    /// Returns the contents of the bucket at the specified location.
    /// - Parameter X: The horizontal coordinate in the bucket.
    /// - Parameter Y: The vertical coodinate in the bucket.
    /// - Returns: The value of the bucket at the specified location. Nil returned if passed coordinates
    ///            are invalid.
    func GetBucket(X: Int, Y: Int) -> MapNodes?
    
    /// Set the contents of the bucket at the specified location.
    /// - Note: If the passed coordinates are not valid, no action is taken.
    /// - Parameter X: The horizontal coordinate in the bucket.
    /// - Parameter Y: The vertical coodinate in the bucket.
    /// - Parameter MapNode: The contents to place at the passed coordinates.
    func SetBucket(X: Int, Y: Int, MapNode: MapNodes)
    
    /// Determines if all blocks in the passed piece reside fully within the bucket.
    /// - Parameter TestPiece: The piece to test for bucket inclusion.
    /// - Returns: True if `TestPiece` is fully within the bucket, false if not.
    func PieceInBucket(TestPiece: Piece) -> Bool
    
    /// Returns a recommended initial location for the passed piece. The returned location is relative to the game board,
    /// *not* the bucket.
    /// - Note: The return location is dependent on the orientation of the piece.
    /// - Parameter For: The piece whose recommended initial location is returned.
    /// - Returns: Tuple with X as the initial horizontal coordinate, and Y the intitial vertical coordinate. **The returned
    ///            coordinate is for the top-most location of the piece, not the center of the piece.**
    func InitialLocation(For NewPiece: Piece) -> (X: Int, Y: Int)
    
    /// Determines if the specified location within the bucket is empty (meaning the node is `.BucketInterior`).
    /// - Parameter X: The horizontal coordinate.
    /// - Parameter Y: The vertical coordinate.
    /// - Returns: True if the bucket contents at the coordinate are empty, false if something is there.
    func BucketIsEmptyAt(X: Int, Y: Int) -> Bool
    
    /// Determines if a row in the bucket is full of blocks.
    /// - Parameter AtRow: The row in the bucket to test for fullness.
    /// - Parameter IgnoreBarriers: If true, barriers are ignored when testing for full rows. When false, if a barrier is present
    ///                             in a row, that row can never be full.
    /// - Returns: True if the row is full of blocks (see `IgnoreBarriers` as well), false if not.
    func RowIsFull(AtRow: Int, IgnoreBarriers: Bool) -> Bool
    
    /// Collapses horizontal rows that are full of game piece blocks.
    /// - Note: The game should call this after every time a piece freezes.
    /// - Parameter StartingRow: Where to start looking for full rows. Some board types will start in the middle while others
    ///                          will start at the bottom.
    /// - Parameter IgnoreBarriers: If true, barriers will not be considered when checking for full rows. If false, barries are
    ///                             treated as empty spaces and as such, will not cause a row to be collapsed.
    /// - Parameter DeletionCompletion: Completion handler called at the completion of each row deletion action.
    func CollapseFullRows(StartingRow: Int, IgnoreBarriers: Bool, DeletionCompletion: ((Int) -> ())?)
    
    /// Rotate the contents of the map and the block map 90° left.
    /// - Attention: Throws a fatal error if the **Game Board Height** and **Game Board Width** are not identical.
    func RotateMapLeft()
    
    /// Rotate the contents of the map and the block map 90° right.
    /// - Attention: Throws a fatal error if the **Game Board Height** and **Game Board Width** are not identical.
    func RotateMapRight()
    
    /// Rotate the contents of the bucket by 180°.
    /// - ToDo: Change the double rotation by 90° into a more efficient algorithm.
    func RotateBucketContents180()
    
    /// Returns the contents of the map as a string.
    /// - Parameter BucketOnly: If true, only the bucket portion of the map is returned.
    /// - Returns: The Game board (or bucket - see `BucketOnly`) as a string.
    func ToString(BucketOnly: Bool) -> String
}
