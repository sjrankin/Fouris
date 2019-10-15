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
            
            case .SemiRotating:
                fallthrough
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
        let XOffset = 8
        let YOffset = 8
        switch RotatingCenter
        {
            case .SmallRectangle:
                Map[9 + YOffset][10 + XOffset] = BucketID
                Map[9 + YOffset][11 + XOffset] = BucketID
            
            case .Rectangle:
                for Y in 9 ... 10
                {
                    for X in 8 ... 11
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
            }
            
            case .BigRectangle:
                for Y in 8 ... 10
                {
                    for X in 6 ... 13
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
            }
            
            case .CornerDots:
                Map[0 + YOffset][19 + XOffset] = BucketID
                Map[0 + YOffset][0 + XOffset] = BucketID
                Map[19 + YOffset][0 + XOffset] = BucketID
                Map[19 + YOffset][19 + XOffset] = BucketID
            
            case .Corners:
                Map[0 + YOffset][0 + XOffset] = BucketID
                Map[0 + YOffset][1 + XOffset] = BucketID
                Map[0 + YOffset][2 + XOffset] = BucketID
                Map[0 + YOffset][17 + XOffset] = BucketID
                Map[0 + YOffset][18 + XOffset] = BucketID
                Map[0 + YOffset][19 + XOffset] = BucketID
                Map[19 + YOffset][0 + XOffset] = BucketID
                Map[19 + YOffset][1 + XOffset] = BucketID
                Map[19 + YOffset][2 + XOffset] = BucketID
                Map[19 + YOffset][17 + XOffset] = BucketID
                Map[19 + YOffset][18 + XOffset] = BucketID
                Map[19 + YOffset][19 + XOffset] = BucketID
                Map[1 + YOffset][0 + XOffset] = BucketID
                Map[2 + YOffset][0 + XOffset] = BucketID
                Map[1 + YOffset][19 + XOffset] = BucketID
                Map[2 + YOffset][19 + XOffset] = BucketID
                Map[17 + YOffset][0 + XOffset] = BucketID
                Map[18 + YOffset][0 + XOffset] = BucketID
                Map[17 + YOffset][19 + XOffset] = BucketID
                Map[18 + YOffset][19 + XOffset] = BucketID
            
            case .Dot:
                Map[9 + YOffset][10 + XOffset] = BucketID
            
            case .SmallSquare:
                for Y in 9 ... 10
                {
                    for X in 9 ... 10
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
            }
            
            case .Square:
                for Y in 8 ... 11
                {
                    for X in 8 ... 11
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
            }
            
            case .BigSquare:
                for Y in 7 ... 12
                {
                    for X in 7 ... 12
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
            }
            
            case .FourSmallSquares:
                for Y in 4 ... 5
                {
                    for X in 4 ... 5
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
                }
                for Y in 14 ... 15
                {
                    for X in 4 ... 5
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
                }
                for Y in 4 ... 5
                {
                    for X in 14 ... 15
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
                }
                for Y in 14 ... 15
                {
                    for X in 14 ... 15
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
            }
            
            case .HorizontalLine:
                for X in 0 ... 19
                {
                    Map[9 + YOffset][X + XOffset] = BucketID
            }
            
            case .Quadrant:
                for X in 0 ... 19
                {
                    Map[9 + YOffset][X + XOffset] = BucketID
                }
                for Y in 0 ... 19
                {
                    Map[Y + YOffset][10 + XOffset] = BucketID
            }
            
            case .ShortDiagonals:
                for Y in 6 ... 13
                {
                    for X in 6 ... 13
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
                }
                for Y in stride(from: 13, through: 6, by: -1)
                {
                    for X in stride(from: 13, through: 6, by: -1)
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
            }
            
            case .LongDiagonals:
                for Y in 4 ... 15
                {
                    for X in 4 ... 15
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
                }
                for Y in stride(from: 15, through: 4, by: -1)
                {
                    for X in stride(from: 15, through: 4, by: -1)
                    {
                        Map[Y + YOffset][X + XOffset] = BucketID
                    }
            }
            
            case .ParallelLines:
                for Y in 6 ... 13
                {
                    Map[Y + YOffset][5 + XOffset] = BucketID
                    Map[Y + YOffset][14 + XOffset] = BucketID
            }
            
            case .FourLines:
                for X in 7 ... 12
                {
                    Map[0 + YOffset][X + XOffset] = BucketID
                    Map[19 + YOffset][X + XOffset] = BucketID
                }
                for Y in 7 ... 12
                {
                    Map[Y + YOffset][0 + XOffset] = BucketID
                    Map[Y + YOffset][19 + XOffset] = BucketID
            }
            
            case .Plus:
                for X in 8 ... 12
                {
                    Map[9 + YOffset][X + XOffset] = BucketID
                }
                for Y in 7 ... 11
                {
                    Map[Y + YOffset][10 + XOffset] = BucketID
            }
            
            case .SmallDiamond:
                Map[8 + YOffset][9 + XOffset] = BucketID
                Map[9 + YOffset][9 + XOffset] = BucketID
                Map[10 + YOffset][9 + XOffset] = BucketID
                Map[8 + YOffset][9 + XOffset] = BucketID
                Map[10 + YOffset][9 + XOffset] = BucketID
            
            case .Diamond:
                Map[7 + YOffset][10 + XOffset] = BucketID
                Map[11 + YOffset][10 + XOffset] = BucketID
                for X in 9 ... 11
                {
                    Map[8 + YOffset][X + XOffset] = BucketID
                }
                for X in 8 ... 12
                {
                    Map[9 + YOffset][X + XOffset] = BucketID
                }
                for X in 9 ... 11
                {
                    Map[10 + YOffset][X + XOffset] = BucketID
            }
            
            case .BigDiamond:
                Map[6 + YOffset][10 + XOffset] = BucketID
                Map[12 + YOffset][10 + XOffset] = BucketID
                for X in 9 ... 11
                {
                    Map[7 + YOffset][X + XOffset] = BucketID
                }
                for X in 8 ... 12
                {
                    Map[8 + YOffset][X + XOffset] = BucketID
                }
                for X in 7 ... 13
                {
                    Map[9 + YOffset][X + XOffset] = BucketID
                }
                for X in 8 ... 12
                {
                    Map[10 + YOffset][X + XOffset] = BucketID
                }
                for X in 9 ... 11
                {
                    Map[11 + YOffset][X + XOffset] = BucketID
            }
            
            case .Bracket2:
                for Y in 7 ... 12
                {
                    Map[Y + YOffset][5 + XOffset] = BucketID
                    Map[Y + YOffset][14 + XOffset] = BucketID
                }
                for X in 6 ... 7
                {
                    Map[7 + YOffset][X + XOffset] = BucketID
                    Map[12 + YOffset][X + XOffset] = BucketID
                }
                for X in 12 ... 13
                {
                    Map[7 + YOffset][X + XOffset] = BucketID
                    Map[12 + YOffset][X + XOffset] = BucketID
            }
            
            case .Bracket4:
                for X in 5 ... 7
                {
                    Map[5 + YOffset][X + XOffset] = BucketID
                    Map[14 + YOffset][X + XOffset] = BucketID
                }
                for X in 12 ... 14
                {
                    Map[5 + YOffset][X + XOffset] = BucketID
                    Map[14 + YOffset][X + XOffset] = BucketID
                }
                for Y in 6 ... 7
                {
                    Map[Y + YOffset][5 + XOffset] = BucketID
                    Map[Y + YOffset][14 + XOffset] = BucketID
                }
                for Y in 12 ... 13
                {
                    Map[Y + YOffset][5 + XOffset] = BucketID
                    Map[Y + YOffset][14 + XOffset] = BucketID
            }
            
            case .Empty:
                break
            
            case .OneOpening:
                break
            
            case .Classic:
                break
            
            case .TallThin:
                break
            
            case .ShortWide:
                break
            
            case .Big:
                break
            
            case .Small:
                break
            
            case .SquareBucket:
                break
        }
        
        #if false
        //Used for rotational debug.
        Map[0][0] = BucketID
        #endif
    }
}
