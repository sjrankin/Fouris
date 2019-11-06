//
//  BoardData.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BoardData
{
    /// Table of boards that rotate.
    public static var RotatableBoards: [BucketShapes] =
        [
            .Dot, .MediumSquare, .SmallSquare, .BigSquare, .SmallRectangle, .BigRectangle, .Diamond, .BigDiamond, .SmallDiamond,
            .Bracket2, .Bracket4, .FourLines, .Corners, .Quadrant, .Plus, .HorizontalLine, .ParallelLines, .Empty,
            .CornerDots, .FourSmallSquares, .ShortDiagonals, .LongDiagonals, .SpanningDiagonal, .EmptyCenter,
            .AlternatingDirections, .PerpendicularLines, .Giant, .OffsetEdges
    ]
    
    /// Table of boards that do not rotate (or more accurately, the *buckets* do not rotate - the pieces may actually rotate).
    public static var StaticBoards: [BucketShapes] =
        [
            .Classic, .TallThin, .ShortWide, .Big, .Small, .SquareBucket, .Giant
    ]
    
    public static var SemiRotatingBoards: [BucketShapes] =
    [
        .OneOpening, .InsideOut
    ]
    
    /// Table of three-dimensional boards.
    public static var CubicBoards: [BucketShapes] =
        [
            .Simple3D
    ]
    
    /// Table of board classes to their respective boards.
    public static var BoardGroups: [BoardClasses: [BucketShapes]] =
        [
            .Rotatable: RotatableBoards,
            .SemiRotatable: SemiRotatingBoards,
            .Static: StaticBoards,
            .ThreeDimensional: CubicBoards
    ]
    
    /// Given a bucket shape, return its general class.
    /// - Parameter For: The bucket shape for whom the board class is returned.
    /// - Returns: The board class associated with the passed bucket shape on success, nil if not found.
    public static func GetBoardClass(For: BucketShapes) -> BoardClasses?
    {
        for (Class, Table) in BoardGroups
        {
            for Bucket in Table
            {
                if Bucket == For
                {
                    return Class
                }
            }
        }
        return nil
    }
}

/// Possible shapes for center blocks and other blocks.
/// - Note: This enum contains all possible interior block shapes for non-rotating, rotating, and semi-rotating games.
/// - **Dot**: 1 x 1 center (or close enough to it) block.
/// - **MediumSquare**: 4 x 4 center square.
/// - **SmallSquare**: 2 x 2 center square.
/// - **BigSquare**: 6 x 6 center square.
/// - **SmallRectangle**: 2 x 1 center (or close enough) rectangle.
/// - **Rectangle**: 4 x 2 center rectangle.
/// - **BigRectangle**: 8 x 3 center (or close enough) rectangle.
/// - **SmallDiamond**: Diamond, 3 x 3 square rotated 90°.
/// - **Diamond**: Diamond, 5 x 5 square rotated 90°.
/// - **BigDiamond**: Diamond, 6 x 6 square rotated 90°.
/// - **Bracket2**: Two brackets facing each other.
/// - **Bracket4**: Four brackets arranged in a square.
/// - **FourLines**: Four lines parallel to each side with gaps to either side.
/// - **Corners**: Blocks on corners.
/// - **Quadrant**: Board broken into quadrants.
/// - **Plus**: Center block is **+** shaped.
/// - **HorizontalLine**: Center block is a horizontal line from one side to the other.
/// - **ParallelLines**: Two parallel lines.
/// - **Empty**: No bucket blocks in the interior.
/// - **CornerDots**: A dot in each corner.
/// - **FourSmallSquares**: Four small squares, one in each quadrant.
/// - **ShortDiagonals**: Small `X`-shaped central block.
/// - **LongDiagonals**: Large `X`-shaped central block.
/// - **OneOpening**: Bucket with one opening.
/// - **InsideOut**: Pieces radiate from the center to surrounding walls.
/// - **Classic**: Classic Tetris game proportions.
/// - **TallThin**: Tall and thin bucket.
/// - **ShortWide**: Short and wide bucket.
/// - **Big**: Big bucket.
/// - **Small**: Small bucket.
/// - **SquareBucket**: Square, non-rotating bucket.
/// - **Giant**: Huge bucket.
/// - **Simple3D**: Simple 3D game with a center block.
/// - **EmptyCenter**: Ordinal lines with an empty center.
/// - **AlternatingDirections**: Short, perpendicular lines.
/// - **PerpendicularLines**: Two perpendicular lines.
/// - **OffsetEdges**: Offset-edged board.
enum BucketShapes: String, CaseIterable
{
    //Rotating games.
    case Dot = "Dot"
    case MediumSquare = "MediumSquare"
    case SmallSquare = "SmallSquare"
    case BigSquare = "BigSquare"
    case SmallRectangle = "SmallRectangle"
    case Rectangle = "Rectangle"
    case BigRectangle = "BigRectangle"
    case SmallDiamond = "SmallDiamond"
    case Diamond = "Diamond"
    case BigDiamond = "BigDiamond"
    case Bracket2 = "Bracket2"
    case Bracket4 = "Bracket4"
    case FourLines = "FourLines"
    case Corners = "Corners"
    case Quadrant = "Quadrant"
    case Plus = "Plus"
    case HorizontalLine = "HorizontalLine"
    case ParallelLines = "ParallelLines"
    case Empty = "Empty"
    case CornerDots = "CornerDots"
    case FourSmallSquares = "FourSmallSquares"
    case ShortDiagonals = "ShortDiagonals"
    case LongDiagonals = "LongDiagonals"
    case SpanningDiagonal = "SpanningDiagonal"
    case EmptyCenter = "EmptyCenter"
    case AlternatingDirections = "AlternatingDirections"
    case PerpendicularLines = "PerpendicularLines"
    case OffsetEdges = "OffsetEdges"
    //Semi-rotating games. (Blocks rotate but the bucket does not.)
    case OneOpening = "OneOpening"
    case InsideOut = "InsideOut"
    //Non-rotating games.
    case Classic = "Classic"
    case TallThin = "TallThin"
    case ShortWide = "ShortWide"
    case Big = "Big"
    case Small = "Small"
    case SquareBucket = "SquareBucket"
    case Giant = "Giant"
    //Three dimensional games.
    case Simple3D = "Simple3D"
}

/// Board classes.
enum BoardClasses: String, CaseIterable
{
    /// Boards that can be rotated (the bucket portion can rotate).
    case Rotatable = "Rotatable"
    /// Boards whose contents (eg, the pieces) rotate but not the bucket.
    case SemiRotatable = "SemiRotatable"
    /// Boards whose buckets are static and do not rotate.
    case Static = "Static"
    /// Boards that are in three dimensions and may rotate.
    case ThreeDimensional = "3D"
}
