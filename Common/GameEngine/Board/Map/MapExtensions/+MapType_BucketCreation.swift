//
//  +MapType_BucketCreation.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MapType
{
    /// Initialize the contents of the map with the bucket.
    /// - Parameters:
    ///   - Width: Width of the map.
    ///   - Height: Height of the map.
    ///   - BucketTop: Top of the bucket.
    ///   - BucketBottom: Bottom of the bucket.
    ///   - BucketLeft: Left location of the bucket.
    ///   - BucketRight: Right location of the bucket.
    ///   - Map: The map to initialize.
    ///   - BucketID: ID of the bucket piece.
    ///   - InvisibleBucketID: ID of the invisible bucket ID.
    ///   - BucketExteriorID: ID of the exterior location (eg, on the board but out of the bucket).
    ///   - BucketShape: The shape of the bucket.
    public static func InitializeMap(Width: Int, Height: Int, BucketTop: Int, BucketBottom: Int, BucketLeft: Int, BucketRight: Int,
                                     Map: inout ContentsType, BucketID: UUID, InvisibleBucketID: UUID, BucketExteriorID: UUID,
                                     BucketShape: BucketShapes)
    {
        let BoardClass = BoardData.GetBoardClass(For: BucketShape)!
        switch BoardClass
        {
            case .Static:
                //Make the sides of the bucket above the bucket (eg, invisible bucket pieces). This is a standard Tetris-looking bucket.
                for Y in 0 ..< BucketTop
                {
                    Map[Y][0] = InvisibleBucketID
                    Map[Y][Width - 1] = InvisibleBucketID
                }
                //Make the tops of the bucket
                for Y in BucketTop ... BucketBottom
                {
                    Map[Y][0] = BucketID
                    Map[Y][Width - 1] = BucketID
                }
                //Make the bottom of the bucket and the top of the map (with invisible bucket pieces).
                for X in 0 ..< Width
                {
                    Map[BucketBottom][X] = BucketID
                    Map[0][X] = InvisibleBucketID
            }
            
            case .SemiRotatable:
            fallthrough
            case .Rotatable:
                let BoardDef = BoardManager.GetBoardFor(BucketShape)!
                CreateRotatingBucket(Width: BoardDef.GameBoardWidth, Height: BoardDef.GameBoardHeight, BucketTop: BucketTop, BucketBottom: BucketBottom,
                                     BucketLeft: BucketLeft, BucketRight: BucketRight, Map: &Map, BucketID: BucketID,
                                     InvisibleBucketID: InvisibleBucketID, BucketExteriorID: BucketExteriorID,
                                     GameShape: BucketShape)
            
            case .ThreeDimensional:
                break
        }
    }
    
    /// Initialize the contents of the map with the bucket.
    /// - Parameters:
    ///   - Width: Width of the map.
    ///   - Height: Height of the map.
    ///   - Depth: Depth of the map.
    ///   - BucketTop: Top of the bucket.
    ///   - BucketBottom: Bottom of the bucket.
    ///   - BucketLeft: Left location of the bucket.
    ///   - BucketRight: Right location of the bucket.
    ///   - Map: The map to initialize.
    ///   - BucketID: ID of the bucket piece.
    ///   - InvisibleBucketID: ID of the invisible bucket ID.
    ///   - BucketExteriorID: ID of the exterior location (eg, on the board but out of the bucket).
    ///   - BucketShape: The shape of the bucket.
    public static func InitializeMap(Width: Int, Height: Int, Depth: Int, BucketTop: Int, BucketBottom: Int, BucketLeft: Int,
                                     BucketRight: Int, Map: inout ContentsType, BucketID: UUID, InvisibleBucketID: UUID,
                                     BucketExteriorID: UUID, BucketShape: BucketShapes)
    {
        let BoardClass = BoardData.GetBoardClass(For: BucketShape)!
        switch BoardClass
        {
            case .Static:
                break
            
            case .SemiRotatable:
            fallthrough
            case .Rotatable:
                let BoardDef = BoardManager.GetBoardFor(BucketShape)!
                CreateRotatingBucket(Width: BoardDef.GameBoardWidth, Height: BoardDef.GameBoardHeight, BucketTop: BucketTop, BucketBottom: BucketBottom,
                                     BucketLeft: BucketLeft, BucketRight: BucketRight, Map: &Map, BucketID: BucketID,
                                     InvisibleBucketID: InvisibleBucketID, BucketExteriorID: BucketExteriorID,
                                     GameShape: BucketShape)
            
            case .ThreeDimensional:
                let BoardDef = BoardManager.GetBoardFor(BucketShape)!
        }
    }
    
    /// Initialize the contents of the map with the bucket for rotating games.
    /// - Parameters:
    ///   - Width: Width of the map.
    ///   - Height: Height of the map.
    ///   - BucketTop: Top of the bucket.
    ///   - BucketBottom: Bottom of the bucket.
    ///   - BucketLeft: Left location of the bucket.
    ///   - BucketRight: Right location of the bucket.
    ///   - Map: The map to initialize.
    ///   - BucketID: ID of the bucket piece.
    ///   - InvisibleBucketID: ID of the invisible bucket ID.
    ///   - BucketExteriorID: ID of the exterior location (eg, on the board but out of the bucket).
    ///   - GameShape: The shape of the game.
    private static func CreateRotatingBucket(Width: Int, Height: Int, BucketTop: Int, BucketBottom: Int, BucketLeft: Int, BucketRight: Int,
                                             Map: inout ContentsType, BucketID: UUID, InvisibleBucketID: UUID, BucketExteriorID: UUID,
                                             GameShape: BucketShapes)
    {
        //Fill the map with bucket exteriors.
        for Y in 0 ..< BucketTop
        {
            for X in 0 ..< Width
            {
                Map[Y][X] = BucketExteriorID
            }
        }
        for X in 0 ... BucketLeft
        {
            for Y in BucketTop ... BucketBottom
            {
                Map[Y][X] = BucketExteriorID
            }
        }
        for X in BucketRight ..< Width
        {
            for Y in BucketTop ... BucketBottom
            {
                Map[Y][X] = BucketExteriorID
            }
        }
        for Y in BucketBottom + 1 ..< Height
        {
            for X in 0 ..< Width
            {
                Map[Y][X] = BucketExteriorID
            }
        }
        let GameBoard = BoardManager.GetBoardFor(GameShape)!
        let InvisibleBlocks = GameBoard.InvisibleBucketBlockList()
        for Location in InvisibleBlocks
        {
            let X = Int(Location.x)
            let Y = Int(Location.y)
            Map[Y][X] = InvisibleBucketID
        }
        
        //Add bucket blocks.
        let Locations = GameBoard.BucketBlockList()
        for Location in Locations
        {
            let X = Int(Location.x)
            let Y = Int(Location.y)
            Map[Y][X] = BucketID
        }
        
        #if false
        //Used for rotational debug.
        Map[0][0] = BucketID
        #endif
    }
}
