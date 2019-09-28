//
//  GeneralAI.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// General AI for filling a game board relatively efficiently, assuming a solid floor (meaning no bottomless columns).
class GeneralAI
{
    /// Holds the motion queue. Populated when the AI is completed for a given piece.
    private static var _MotionQueue: Queue<Directions>? = nil
    /// Get or set the motion queue.
    public static var MotionQueue: Queue<Directions>
    {
        get
        {
            return _MotionQueue!
        }
        set
        {
            _MotionQueue = newValue
        }
    }
    
    /// Return (but do not modify) the contents of the motion queue.
    /// - Returns: The contents of the motion queue.
    static func DumpMotionQueue() -> [Directions]
    {
        var QDirs = [Directions]()
        let Count = MotionQueue.Count
        for Index in 0 ..< Count
        {
            QDirs.append(MotionQueue[Index]!)
        }
        return QDirs
    }
    
    /// Get the next motion in the motion queue.
    /// - Returns: The next motion in the motion queue. If the queue is empty, **.NoDirection** is returned.
    public static func GetNextMotion() -> Directions
    {
        if MotionQueue.IsEmpty
        {
            return Directions.NoDirection
        }
        return MotionQueue.Dequeue()!
    }
    
    /// Given a block of directions to find the best fit for the piece, generate a queue of motions to
    /// actually drive the block there.
    ///
    /// - Parameter Motions: Block of data that describes how to move the piece to the best location.
    static func GenerateMotionCommands(Motions: MotionCommandBlock2)
    {
        MotionQueue.Clear()
        for _ in 0 ..< Motions.InitialMoveDown
        {
            MotionQueue.Enqueue(.Down)
        }
        if Motions.AngleCount == 3
        {
            MotionQueue.Enqueue(.RotateLeft)
        }
        else
        {
            for _ in 0 ..< Motions.AngleCount
            {
                MotionQueue.Enqueue(.RotateRight)
            }
        }
        if Motions.XOffset > 0
        {
            for _ in 0 ..< Motions.XOffset
            {
                MotionQueue.Enqueue(.Left)
            }
        }
        if Motions.XOffset < 0
        {
            for _ in 0 ..< abs(Motions.XOffset)
            {
                MotionQueue.Enqueue(.Right)
            }
        }
        MotionQueue.Enqueue(.DropDown)
    }
    
    /// Find the right-most point in the set of passed points and return it.
    ///
    /// - Parameter Points: The list of points to examine to find the right-most point.
    /// - Returns: The right-most point of the set of passed points.
    static func FindRightMost(_ Points: [CGPoint]) -> CGPoint
    {
        var RightMost = -1
        var RightPoint: CGPoint!
        for Point in Points
        {
            if Int(Point.x) > RightMost
            {
                RightMost = Int(Point.x)
                RightPoint = Point
            }
        }
        return RightPoint
    }
    
    /// Find the left-most point in the set of passed points and return it.
    ///
    /// - Parameter Points: The list of points to examine to find the left-most point.
    /// - Returns: The left-most point of the set of passed points.
    static func FindLeftMost(_ Points: [CGPoint]) -> CGPoint
    {
        var LeftMost = 100000
        var LeftPoint: CGPoint!
        for Point in Points
        {
            if Int(Point.x) < LeftMost
            {
                LeftMost = Int(Point.x)
                LeftPoint = Point
            }
        }
        return LeftPoint
    }
    
    /// Virtually drop the set of passed points to the bottom-most valid location in the bucket.
    ///
    /// - Parameter Points: Points to drop to the bottom of the bucket.
    /// - Parameter GameBoard: The game board for the game.
    /// - Returns: Set of points adjusted such that they are at the bottom-most valid location in the bucket.
    static func VirtualDrop(Points: [CGPoint], GameBoard: Board) -> [CGPoint]
    {
        var Working: [CGPoint] = Points
        //print("Testing \(Points)")
        while true
        {
            for Point in Working
            {
                #if false
                var BlockingItem: PieceTypes = .Bucket
                #endif
                let LocationOK: Bool = GameBoard.MapIsEmpty(At: CGPoint(x: Point.x, y: Point.y))
                if !LocationOK
                {
                    //print("Found blocking item \(BlockingItem) at (\(Point))")
                    return Working
                }
            }
            for Index in 0 ..< Working.count
            {
                Working[Index] = CGPoint(x: Working[Index].x, y: Working[Index].y + 1.0)
            }
        }
    }
    
    /// Returns the bottom most points in each column of the set of points.
    ///
    /// - Parameter Points: List of points.
    /// - Returns: List of points, one for each column of data, the bottom-most (closest to the bucket bottom) for each column.
    public static func BottomMostPoints(_ Points: [CGPoint]) -> [CGPoint]
    {
        var PointDictionary = [Int: CGPoint]()
        for Point in Points
        {
            if let ThePoint = PointDictionary[Int(Point.x)]
            {
                if Int(Point.y) > Int(ThePoint.y)
                {
                    PointDictionary[Int(Point.x)] = ThePoint
                }
            }
            else
            {
                PointDictionary[Int(Point.x)] = Point
            }
        }
        var Points = [CGPoint]()
        for (_, Point) in PointDictionary
        {
            Points.append(Point)
        }
        Points.sort(by: {$0.x < $1.x})
        return Points
    }
    
    /// Return the shape of the top of the bucket (occupied spaces) in the specified horizontal range.
    ///
    /// - Parameters:
    ///   - From: A set of points whose horizontal coordinate will be used to find the proper columns to check for tops.
    ///   - GameBoard: The game board.
    /// - Returns: List of points that define the top, unoccupied points in the specified set of points.
    public static func BucketShape(From: [CGPoint], GameBoard: Board) -> [CGPoint]
    {
        var Points = [CGPoint]()
        for Point in From
        {
            let X = Int(Point.x)
            var AtBottom = true
            for Y in GameBoard.BucketTopInterior ... GameBoard.BucketBottomInterior
            {
                if GameBoard.Map!.IDMap!.IsOccupiedType(GameBoard.Map![Y,X]!)
                {
                    AtBottom = false
                    Points.append(CGPoint(x: X, y: Y))
                    break
                }
            }
            if AtBottom
            {
                Points.append(CGPoint(x: X, y: GameBoard.BucketBottomInterior))
            }
        }
        return Points
    }
    
    /// Calculate a piece score based on offset mapping - the shape of the bottom of the piece in its current location and orientation
    /// is compared to the top of the contents of the bucket in the same horizontal range.
    ///
    /// - Parameters:
    ///   - Points: The points of the piece, virtually dropped to the bottom of the bucket.
    ///   - ThePiece: The piece being scored.
    /// - Returns: Score based on how closely the bottom of the piece matches the top of the bucket.
    static func OffsetMappingScore(Points: [CGPoint], GameBoard: Board) -> Double
    {
        //let FullRows = GameBoard!.FullRowCount(WithPoints: Points)
        let BottomPoints = BottomMostPoints(Points)
        let TopPoints = BucketShape(From: BottomPoints, GameBoard: GameBoard)
        var OverTopOfBucket: Double = 0.0
        var CumulativeY: Double = 0.0
        for Point in Points
        {
            CumulativeY = CumulativeY + Double(Point.y)
            if Int(Point.y) < GameBoard.BucketTopInterior
            {
                OverTopOfBucket = OverTopOfBucket + 1.0
            }
        }
        var Cumulative: Double = 0.0
        var CumulativeDelta: Double = 0.0
        for Index in 0 ..< TopPoints.count
        {
            CumulativeDelta = CumulativeDelta + Double(TopPoints[Index].y - BottomPoints[Index].y)
            Cumulative = Cumulative + CumulativeDelta
        }
        #if false
        var ExactMatchBonus = CumulativeDelta == 0.0 ? 50.0 : 0.0
        if OverTopOfBucket > 0.0
        {
            ExactMatchBonus = 0.0
        }
        #endif
        let MeanY = CumulativeY / Double(Points.count)
        var MeanGap = Cumulative / Double(TopPoints.count)
        MeanGap = MeanY - MeanGap + (OverTopOfBucket * -100.0)
        //MeanGap = MeanGap + ExactMatchBonus
        //MeanGap = MeanGap + (Double(FullRows) * 30.0)
        return MeanGap
    }
    
    static func MakeScore(ForPoints: [CGPoint], CurrentPiece: Piece? = nil, GameBoard: Board) -> Double
    {
        return OffsetMappingScore(Points: ForPoints, GameBoard: GameBoard)
    }
    
    public static weak var FoundBestFitFor: Piece? = nil
    
    /// Holds the gap count before the best fit calculations.
    static var OriginalGapCount: Int = 0
    
    static func BestFit(_ GamePiece: Piece, CurrentScore: Int, InBoard: Board) -> Double
    {
        return 0.0
    }
    
    /// Find the best fit for the passed game piece. Returns the best fit score. This function also populates the `MotionQueue`.
    ///
    /// - Note: This is a monolithic function that won't return until the best fit is determined. You can use
    ///         `StepAI` to step through best fit calculations one offset/rotation combination at a time.
    ///
    /// - Parameters:
    ///   - GamePiece: The piece to find the best fit for.
    ///   - CurrentScore: The current score of the game.
    /// - Returns: The final, best score of the piece.
    public static func BestFit(_ GamePiece: Piece, CurrentScore: Int, GameBoard: Board) -> Double
    {
        let BestFitStart = CACurrentMediaTime()
        MotionQueue = Queue()
        FoundBestFitFor = GamePiece
        var OriginIndex = -1
        var PieceOrigin: CGPoint!
        for Index in 0 ..< GamePiece.Locations.count
        {
            if GamePiece.Locations[Index].IsOrigin
            {
                OriginIndex = Index
                PieceOrigin = GamePiece.Locations[Index].Location
                break
            }
        }
        if OriginIndex < 0
        {
            fatalError("No origin found in passed game piece.")
        }
        
        var BestScore: Double = -10000.0
        var BestAngle: Int = 0
        var BestXOffset: Int = 0
        var MoveDownFirst: Int = 0
        
        var Reachable: Int = 0
        var Blocked: Int = 0
        #if false
        let OGapCount = CACurrentMediaTime()
        OriginalGapCount = GameBoard.Map!.UnreachablePointCount(Reachable: &Reachable, Blocked: &Blocked)
        print("OriginalGapCount duration: \(CACurrentMediaTime() - OGapCount)")
        #endif
        for Angle in [0, 90, 180, 270]
        {
            if Angle > 0
            {
                if GamePiece.IsRotationallySymmetric
                {
                    //If the piece is rotationally symmetric, only test on one angle.
                    break
                }
            }
            var Points = GamePiece.LocationsAsPoints()
            if Angle > 0
            {
                var RotateCount: Int = [90, 180, 270].firstIndex(of: Angle)!
                RotateCount = RotateCount + 1
                Points = Piece.RightRotate(Points, AboutOrigin: PieceOrigin, Times: RotateCount)
                MoveDownFirst = 0
            }
            let LeftMost = FindLeftMost(Points)
            let LeftMostX = Int(LeftMost.x)
            let RightMost = FindRightMost(Points)
            let RightMostX = Int(RightMost.x)
            let WidthAtAngle = RightMostX - LeftMostX
            
            let BucketLeft = GameBoard.BucketInteriorLeft
            let BucketRight = GameBoard.BucketInteriorRight
            let ToRight = BucketRight - WidthAtAngle
            
            for XOffset in BucketLeft ... ToRight
            {
                var XPoints = [CGPoint]()
                for Index in 0 ..< Points.count
                {
                    var NewX = Int(Points[Index].x)
                    NewX = NewX - LeftMostX
                    NewX = NewX + XOffset
                    XPoints.append(CGPoint(x: NewX, y: Int(Points[Index].y)))
                }
                var Dropped = VirtualDrop(Points: XPoints, GameBoard: GameBoard)
                
                //See if any block in the dropped piece is above the rim of the bucket.
                var StoppedAboveBucket = false
                for Drop in Dropped
                {
                    if Int(Drop.y) < GameBoard.BucketTopInterior
                    {
                        StoppedAboveBucket = true
                        break
                    }
                }
                
                var PieceScore = MakeScore(ForPoints: Dropped, CurrentPiece: GamePiece, GameBoard: GameBoard)
                if PieceScore > BestScore
                {
                    BestScore = PieceScore
                    BestAngle = Angle
                    BestXOffset = LeftMostX - XOffset
                }
                
                //Move to the next horizontal location.
                for Index in 0 ..< Dropped.count
                {
                    Dropped[Index] = CGPoint(x: Dropped[Index].x + CGFloat(XOffset), y: Dropped[Index].y)
                }
            }
        }
        
        //Add the motions necessary to put the piece into the place with the best score.
        let Motions = MotionCommandBlock2(InitialMoveDown: MoveDownFirst, AngleCount: BestAngle / 90, XOffset: BestXOffset)
        GenerateMotionCommands(Motions: Motions)
        //print("GeneralAI.BestFit duration: \(CACurrentMediaTime() - BestFitStart)")
        return BestScore
    }
}
