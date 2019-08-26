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
    /// Initialize the contents of the map with the bucket. Depending on the contents of **BaseType**, the shape of the
    /// bucket will vary.
    ///
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
    ///   - BaseType: The base game type.
    ///   - RotatingCenter: For **BaseType**s of **.Rotating4**, the center shape to use.
    public static func InitializeMap(Width: Int, Height: Int, BucketTop: Int, BucketBottom: Int, BucketLeft: Int, BucketRight: Int,
                                     Map: inout ContentsType, BucketID: UUID, InvisibleBucketID: UUID, BucketExteriorID: UUID,
                                     BaseType: BaseGameTypes, RotatingCenter: CenterShapes = .Square)
    {
        switch BaseType
        {
            case .Standard:
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
            
            case .Rotating4:
                CreateRotatingBucket(Width: Width, Height: Height, BucketTop: BucketTop, BucketBottom: BucketBottom,
                                     BucketLeft: BucketLeft, BucketRight: BucketRight, Map: &Map, BucketID: BucketID,
                                     InvisibleBucketID: InvisibleBucketID, BucketExteriorID: BucketExteriorID)
            
            case .Cubic:
                break
        }
    }
    
    /// Initialize the contents of the map with the bucket for **.Rotating4** game buckets.
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
    ///   - RotatingCenter: The center block shape.
    private static func CreateRotatingBucket(Width: Int, Height: Int, BucketTop: Int, BucketBottom: Int, BucketLeft: Int, BucketRight: Int,
                                             Map: inout ContentsType, BucketID: UUID, InvisibleBucketID: UUID, BucketExteriorID: UUID,
                                             RotatingCenter: CenterShapes = .Square)
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
        //Line the map with invisible buckets.
        for Y in 0 ..< Height
        {
            Map[Y][0] = InvisibleBucketID
            Map[Y][Width - 1] = InvisibleBucketID
        }
        for X in 0 ..< Width
        {
            Map[0][X] = InvisibleBucketID
            Map[Height - 1][X] = InvisibleBucketID
        }
        
        //Add bucket blocks.
        switch RotatingCenter
        {
            case .Dot:
            let Y = (Height / 2)
            let X = (Width / 2)
            Map[Y][X] = BucketID
            
            case .SmallSquare:
                let YStart = (Height / 2) - 1
                let YEnd = YStart + 1
                let XStart = (Width / 2) - 1
                let XEnd = XStart + 1
                for Y in YStart ... YEnd
                {
                    for X in XStart ... XEnd
                    {
                        Map[Y][X] = BucketID
                    }
            }
            
            case .Square:
                //The rotating game has the bucket in the center.
                let YStart = (Height / 2) - 2
                let YEnd = YStart + 3
                let XStart = (Width / 2) - 2
                let XEnd = XStart + 3
                for Y in YStart ... YEnd
                {
                    for X in XStart ... XEnd
                    {
                        Map[Y][X] = BucketID
                    }
                }

            case .BigSquare:
                let YStart = (Height / 2) - 3
                let YEnd = YStart + 5
                let XStart = (Width / 2) - 3
                let XEnd = XStart + 5
                for Y in YStart ... YEnd
                {
                    for X in XStart ... XEnd
                    {
                        Map[Y][X] = BucketID
                    }
            }
            
            default:
            break
        }
        
        #if false
        //Used for rotational debug.
        Map[0][0] = BucketID
        #endif
    }
}
