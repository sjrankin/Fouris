//
//  PieceIDMap.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Maintains a map of IDs for each piece in the game map.
class PieceIDMap
{
    /// Initialize the piece map.
    init()
    {
        ClearPieceMap()
    }
    
    /// Return the piece type given an ID of the piece.
    /// - Parameter ID: ID of the piece whose type will be returned.
    /// - Returns: The piece type associated with the ID. Nil if not found.
    public func IDtoPiece(_ ID: UUID) -> PieceTypes?
    {
        let ReturnMe = PieceMap[ID]
        return ReturnMe
    }
    
    /// Add a piece's ID to the piece ID map.
    /// - Parameters:
    ///   - ID: ID to add.
    ///   - ForPiece: Piece type associated with the ID.
    public func AddID(_ ID: UUID, ForPiece: PieceTypes)
    {
        PieceMap[ID] = ForPiece
    }
    
    /// Changes the type of the piece an ID points to.
    /// - Parameters:
    ///   - For: The ID whose type will change.
    ///   - ToType: The new piece type for the ID.
    public func ChangeType(For: UUID, ToType: PieceTypes)
    {
        PieceMap[For] = ToType
    }
    
    /// Clear the piece ID map. Reload with the invariant pieces.
    public func ClearPieceMap()
    {
        PieceMap.removeAll()
        AddID(StaticID(For: .Visible), ForPiece: .Visible)
        AddID(StaticID(For: .Bucket), ForPiece:. Bucket)
        AddID(StaticID(For: .InvisibleBucket), ForPiece: .InvisibleBucket)
        AddID(StaticID(For: .BucketExterior), ForPiece: .BucketExterior)
    }
    
    /// Holds the ID to piece type map.
    public var PieceMap = [UUID: PieceTypes]()
    
    /// Remove the specified ID from the piece ID map.
    /// - Parameter ID: The ID to remove. If the ID is not in the map, no action is taken.
    public func RemoveID(_ ID: UUID)
    {
        if StaticIDs.values.contains(ID)
        {
            return
        }
        PieceMap.removeValue(forKey: ID)
    }
    
    /// Determines if the piece type pointed to by ID is "empty" in the context of moving the user's piece (eg,
    /// can the user move a piece into the location?).
    /// - Parameter ID: The ID of the piece to check.
    /// - Returns: True if the piece represents a location that is "empty", false if not.
    public func IsEmptyType(_ ID: UUID) -> Bool
    {
        let PieceType = IDtoPiece(ID)
        return [.Visible, .Action, .Danger, .BucketExterior].contains(PieceType)
    }
    
    /// Determines if the piece type pointed to by ID is "occupied" in the context of moving the user's piece (eg, the location
    /// is blocked so the user cannot move there).
    /// - Parameter ID: The ID of the piece to check.
    /// - Returns: True if the piece represents a location that is "occupied", false if not.
    public func IsOccupiedType(_ ID: UUID) -> Bool
    {
        let PieceType = IDtoPiece(ID)
        return [.RetiredGamePiece, .Bucket, .InvisibleBucket].contains(PieceType)
    }
    
    /// Determines if the piece type pointed to by ID is "collapsible" meaning it can be collapsed in certain circumstances.
    /// Parameter ID: The ID of the piece to check.
    /// - Returns: True if the piece can be collapsed, false if not.
    public func IsCollapsibleType(_ ID: UUID) -> Bool
    {
        let PieceType = IDtoPiece(ID)
        return [.RetiredGamePiece].contains(PieceType)
    }
    
    /// Determines if the piece type pointed to by ID is a valid neighbor. Used by the AI.
    /// - Parameter ID: The ID of the piece to check.
    /// - Returns: True if the piece represents a location that is a valid neighbor (in terms of the AI), false if not.
    public func IsValidNeighborType(_ ID: UUID) -> Bool
    {
        let PieceType = IDtoPiece(ID)
        return [.RetiredGamePiece, .Bucket, .InvisibleBucket].contains(PieceType)
    }
    
    /// Determines if the piece type pointed to by ID is a special type (eg, action or danger button).
    /// - Parameter ID: The ID of the piece to check.
    /// - Returns: True if the piece represents a location that is a special type, false if not.
    public func IsSpecialType(_ ID: UUID) -> Bool
    {
        let PieceType = IDtoPiece(ID)
        return [.Action, .Danger].contains(PieceType)
    }
    
    /// Returns a "static" ID for the given piece type. Not all piece types have associated "static" IDs. ("Static" means unchanging
    /// for the duration of the instance.)
    /// - Note: Piece types with static IDs are: `.Visible`, `.Bucket`, `.InvisibleBucket`.
    /// - Warning: **If a piece type is passed that does not have a static ID, a fatal error is generated.**
    /// - Parameter For: The Piece type whose ID will be returned.
    /// - Returns: ID for the piece type. This ID will not change for the instance of the program.
    public func StaticID(For: PieceTypes) -> UUID
    {
        if let ID = StaticIDs[For]
        {
            return ID
        }
        fatalError("No static ID for \(For)")
    }
    
    /// Map between piece types and IDs for static IDs.
    private let StaticIDs: [PieceTypes: UUID] =
        [
            .Visible: UUID(),
            .Bucket: UUID(),
            .InvisibleBucket: UUID(),
            .BucketExterior: UUID(),
    ]
    
    /// Returns a set of unique IDs found in the board.
    /// - Parameter BoardMap: The board used as source for unique IDs.
    /// - Returns: Set of unique IDs in the board.
    public func UniqueIDs(BoardMap: MapType.ContentsType) -> Set<UUID>
    {
        let BoardSet = Set<UUID>(BoardMap.flatMap({$0}))
        return BoardSet
    }
    
    /// Returns the number of unique IDs in the passed board.
    /// - Note: This is merely a thin wrapper around `UniqueIDs`.
    /// - Parameter BoardMap: The board used as source for unique IDs.
    /// - Returns: Number of unique IDs in the board.
    public func UniqueIDCount(BoardMap: MapType.ContentsType) -> Int
    {
        return UniqueIDs(BoardMap: BoardMap).count
    }
    
    /// Remove IDs from the piece ID map that are no longer in the passed board.
    /// - Parameter BoardMap: The board used to determine which IDs in the piece ID map are no longer present and can be
    ///                       removed.
    /// - Parameter ButNotThese: List of IDs to not remove even if they are not in the UniqueID list.
    public func RemoveUnusedIDs(BoardMap: MapType.ContentsType, ButNotThese: [UUID])
    {
        let Unique = UniqueIDs(BoardMap: BoardMap)
        var DeleteList = [UUID]()
        for (ID, _) in PieceMap
        {
            if Unique.contains(ID)
            {
                continue
            }
            if ButNotThese.contains(ID)
            {
                continue
            }
            DeleteList.append(ID)
        }
        for DeleteID in DeleteList
        {
            RemoveID(DeleteID)
        }
    }
}
