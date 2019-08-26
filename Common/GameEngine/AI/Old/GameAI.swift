//
//  GameAI.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//
import Foundation
import UIKit

/// Class that controls pieces during attract mode. Works without human itervention.
class GameAI
{
    /// Initialize the AI.
    init(WithBoard: Board)
    {
        MotionQueue = Queue<Directions>()
        GameBoard = WithBoard
    }
    
    /// Reference to the game board.
    public weak var GameBoard: Board? = nil
    
    /// The motion queue. Filled when a new piece is available. Emptied by calls to `GetNextMotion`.
    public var MotionQueue: Queue<Directions>!
    
    /// Return the current contents (without removing anything) of the motion queue and return as a list.
    ///
    /// - Returns: List of directions in the motion queue.
    func DumpMotionQueue() -> [Directions]
    {
        var QDirs = [Directions]()
        let Count = MotionQueue.Count
        for Index in 0 ..< Count
        {
            QDirs.append(MotionQueue[Index]!)
        }
        return QDirs
    }
    
    /// Get the next motion from the motion queue. If the motion queue is empty, return `Directions.NoDirection`,
    /// which is essentially a motion NOP, letting gravity move the block.
    ///
    /// - Returns: The next motion in the motion queue.
    public func GetNextMotion() -> Directions
    {
        if MotionQueue.IsEmpty
        {
            return Directions.NoDirection
        }
        return MotionQueue.Dequeue()!
    }
    
    /// Virtually drop the set of passed points to the bottom-most valid location in the bucket.
    ///
    /// - Parameter Points: Points to drop to the bottom of the bucket.
    /// - Returns: Set of points adjusted such that they are at the bottom-most valid location in the bucket.
    func VirtualDrop(Points: [CGPoint]) -> [CGPoint]
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
                let LocationOK: Bool = (GameBoard?.MapIsEmpty(At: CGPoint(x: Point.x, y: Point.y)))!
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
    
    /// Rotates the passed point by the specified angle.
    ///
    /// - Note: This function assumes the point has been translated to its local origin.
    ///
    /// - Parameters:
    ///   - Angle: The angle, in degrees, to rotate the point by.
    ///   - Point: The point to rotate.
    /// - Returns: The rotated point value.
    private func RotateBy(Angle: Double, Point: CGPoint) -> CGPoint
    {
        let Radians = Angle * .pi / 180.0
        let X = round((Double(Point.x) * cos(Radians)) - (Double(Point.y) * sin(Radians)))
        let Y = round((Double(Point.x) * sin(Radians)) + (Double(Point.y) * cos(Radians)))
        return CGPoint(x: Int(X), y: Int(Y))
    }
    
    /// Rotate each point in the passed list by 90° right (clockwise).
    ///
    /// - Parameters:
    ///   - Points: List of points to rotate.
    ///   - ByAngle: Angle to rotate the points by.
    ///   - OriginIndex: Which point in the list of points is the origin.
    /// - Returns: List of rotated points.
    public func RotateClockwise(Points: [CGPoint], ByAngle: Double, OriginIndex: Int, MoveDown: inout Int) -> [CGPoint]
    {
        if OriginIndex < 0 || OriginIndex > Points.count
        {
            fatalError("Invalid origin index specified: \(OriginIndex)")
        }
        if ByAngle == 0.0
        {
            return Points
        }
        let Origin = Points[OriginIndex]
        var Rotated = [CGPoint]()
        var SmallestY: CGFloat = 0
        for Point in Points
        {
            var RotateMe = Point.WithNegativeOffset(Origin)
            RotateMe = RotateBy(Angle: -ByAngle, Point: RotateMe)
            RotateMe = RotateMe.WithOffset(Origin)
            Rotated.append(RotateMe)
            if RotateMe.y < SmallestY
            {
                SmallestY = RotateMe.y
            }
        }
        MoveDown = Int(abs(SmallestY))
        return Rotated
    }
    
    /// Find the right-most point in the set of passed points and return it.
    ///
    /// - Parameter Points: The list of points to examine to find the right-most point.
    /// - Returns: The right-most point of the set of passed points.
    func FindRightMost(_ Points: [CGPoint]) -> CGPoint
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
    func FindLeftMost(_ Points: [CGPoint]) -> CGPoint
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
    
    /// Return the mean score based on the mean of how close the blocks are to the bottom.
    ///
    /// - Parameters:
    ///   - Points: The list of points from which a mean score will be calculated.
    /// - Returns: Mean score.
    func MeanPointScore(Points: [CGPoint]) -> Double
    {
        var OverTopOfButtonAdder: Double = 0.0
        var Cumulative: Double = 0.0
        //var Lowest: Double = -1000.0
        //var LowCount = 1
        for Point in Points
        {
            Cumulative = Cumulative + Double(Point.y)
            if Int(Point.y) < GameBoard!.BucketTopInterior
            {
                OverTopOfButtonAdder = OverTopOfButtonAdder + 1.0
            }
            //if Double(Point.y) > Lowest
            //{
            //    Lowest = Double(Point.y)
            //    LowCount = LowCount + 1
            //}
        }
        
        return (Cumulative / Double(Points.count)) + (OverTopOfButtonAdder * -100.0)
    }
    
    /// Creates a score based on the lowest point in the set of passed points where "lowest" is defined by how close
    /// to the bottom of the bucket the point is.
    ///
    /// - Parameter Points: List of points that make up the piece being scored.
    /// - Returns: Score based on the bottom-most point.
    func CloseToBottomPointScore(Points: [CGPoint]) -> Double
    {
        var OverTopOfButtonAdder: Double = 0.0
        var Lowest: Double = -1000.0
        for Point in Points
        {
            if Double(Point.y) > Lowest
            {
                Lowest = Double(Point.y)
            }
            if Int(Point.y) < GameBoard!.BucketTopInterior
            {
                OverTopOfButtonAdder = OverTopOfButtonAdder + 1.0
            }
        }
        return Lowest + (OverTopOfButtonAdder * -100.0)
    }
    
    /// Return the sum of the score of each block, with blocks closer to the bottom worth more than those nearer to the top (in a
    /// non-linear fashion).
    ///
    /// - Parameter Points: List of points that make up the piece being scored.
    /// - Returns: Score based on the location of each point, with lower points having much greater scores than higher points.
    func WeightedBottomScore(Points: [CGPoint]) -> Double
    {
        var OverTopOfButtonAdder: Double = 0.0
        var Deltas = [Int]()
        for Point in Points
        {
            if Int(Point.y) < GameBoard!.BucketTopInterior
            {
                OverTopOfButtonAdder = OverTopOfButtonAdder + 1.0
            }
            Deltas.append(GameBoard!.BucketTopInterior + Int(Point.y))
        }
        Deltas.sort{$0 < $1}
        var Score: Double = 0.0
        let Lowest = Deltas[0]
        for Delta in Deltas
        {
            Score = Double(Delta + (Delta - Lowest)) + (OverTopOfButtonAdder * -100.0)
        }
        return Score
    }
    
    /// Same as `MeanPointScore` but subtracts the unreachable gap delta from the mean value. So, positions that result in the unreachable
    /// gap count increasing will decrease the score, and if the unreachable gap count decreases, the score will commemserately increase.
    /// Additionally, if the piece being scored fills up any rows, that increases the score.
    ///
    /// - Parameter Points: List of points that make up the piece being scored.
    /// - Returns: Score for the piece based on how close the piece is to the bottom and how few unreachable gaps are present.
    func MeanWithMinimalGap(Points: [CGPoint]) -> Double
    {
        var Cumulative: Double = 0.0
        var OnBottomCount = 0
        var OverTopCount = 0
        for Point in Points
        {
            Cumulative = Cumulative + Double(Point.y)
            if Int(Point.y) == GameBoard!.BucketBottomInterior
            {
                OnBottomCount = OnBottomCount + 1
            }
            if Int(Point.y) < GameBoard!.BucketTopInterior
            {
                OverTopCount = OverTopCount + 1
            }
        }
        let Mean = Cumulative / Double(Points.count)
        var Reachable: Int = 0
        var Blocked: Int = 0
        let NewGapCount = GameBoard!.Map!.UnreachablePointCount(TestPoints: Points, Reachable: &Reachable, Blocked: &Blocked)
        let GapDelta = NewGapCount - OriginalGapCount
        var InRows = [Int]()
        let FullRows = GameBoard!.Map!.FullRowCount(WithPoints: Points, InRows: &InRows)
        if GapDelta != 0 || FullRows > 0
        {
            print("Score adders: GapDelta: \(GapDelta), FullRows: \(FullRows), OnBottomCount: \(OnBottomCount)")
        }
        //Calculate the score.
        //Start with the mean of the Y locations for each point.
        var Score = Mean
        //Add points for pieces touching the bottom.
        Score = Score + Double(OnBottomCount * 2)
        //If the piece's placement results in removing rows, add more points to the score.
        Score = Score + Double(FullRows * 10)
        //Subract points for increasing the number of unreachable gaps.
        Score = Score - Double(GapDelta * 10)
        //Subtract points for leaving at least part of the piece over the top of the bucket.
        Score = Score - Double(OverTopCount * 20)
        return Score
    }
    
    /// Return the mean value of the list of unique Y coordinates in the passed set of points.
    ///
    /// - Parameter Points: List of points that make up the piece being scored.
    /// - Returns: Score based on the mean of the unique Y coordinates of the piece.
    func UniqueCloseToBottomPointScore(Points: [CGPoint]) -> Double
    {
        var OverTopOfButtonAdder: Double = 0.0
        var VValues = Set<Int>()
        for Point in Points
        {
            VValues.insert(Int(Point.y))
            if Int(Point.y) < GameBoard!.BucketTopInterior
            {
                OverTopOfButtonAdder = OverTopOfButtonAdder + 1.0
            }
        }
        var Cumulative = 0
        for Y in VValues
        {
            Cumulative = Cumulative + Y
        }
        return Double(Cumulative / VValues.count) + (OverTopOfButtonAdder * -100.0)
    }
    
    /// Given a point, find how many neighbors it has in each direction. Neighbors are defined as a block of a type found
    /// in `IsOneOf`.
    ///
    /// - Parameters:
    ///   - Point: The point to examine.
    ///   - IsOneOf: What the point things a neighbor should be.
    /// - Returns: Number of neighbors found.
    func NeighborsOf(Point: CGPoint, IsOneOf: [PieceTypes]) -> Int
    {
        var Count = 0
        //Look to the left.
        if Int(Point.x) > GameBoard!.BucketInteriorLeft
        {
            if Int(Point.x) <= GameBoard!.BucketInteriorRight
            {
                let IDAtPoint: UUID = (GameBoard?.Map![Int(Point.y),Int(Point.x) - 1])!
                let ItemAtPoint = GameBoard!.Map!.IDMap?.IDtoPiece(IDAtPoint)
                Count = Count + Int(IsOneOf.contains(ItemAtPoint!) ? 1 : 0)
            }
        }
        //Look to the right.
        if Int(Point.x) < GameBoard!.BucketInteriorRight
        {
            if Int(Point.x) >= GameBoard!.BucketInteriorRight
            {
                let IDAtPoint: UUID = (GameBoard?.Map![Int(Point.y),Int(Point.x) + 1])!
                let ItemAtPoint = GameBoard!.Map!.IDMap?.IDtoPiece(IDAtPoint)
                Count = Count + Int(IsOneOf.contains(ItemAtPoint!) ? 1 : 0)
            }
        }
        //Look up.
        if Int(Point.y) > GameBoard!.BucketTopInterior
        {
            if Int(Point.y) <= GameBoard!.BucketBottomInterior
            {
                let IDAtPoint: UUID = (GameBoard?.Map![Int(Point.y) - 1,Int(Point.x)])!
                let ItemAtPoint = GameBoard!.Map!.IDMap?.IDtoPiece(IDAtPoint)
                Count = Count + Int(IsOneOf.contains(ItemAtPoint!) ? 1 : 0)
            }
        }
        //Look down.
        if Int(Point.y) < GameBoard!.BucketBottomInterior
        {
            if Int(Point.y) >= GameBoard!.BucketTopInterior
            {
                let IDAtPoint: UUID = (GameBoard?.Map![Int(Point.y) + 1,Int(Point.x)])!
                let ItemAtPoint = GameBoard!.Map!.IDMap?.IDtoPiece(IDAtPoint)
                Count = Count + Int(IsOneOf.contains(ItemAtPoint!) ? 1 : 0)
            }
        }
        return Count
    }
    
    /// Return the total number of neighbors for each point (which will most likely result in some neighbors being counted
    /// more than once, which we don't really care about).
    ///
    /// - Note: By itself, this function leads to strange results (pieces tend to pile up in stacks as the best scores are
    ///         found by putting pieces on top of each other. This function is best used in combination with other methods.
    ///
    /// - Parameter Points: List of points to find the neighbor count.
    /// - Returns: Cumulative number of neighbors for all points (including duplicates).
    func TotalNeighborCount(Points: [CGPoint]) -> Double
    {
        var OverTopOfButtonAdder: Double = 0.0
        var NeighborCount = 0
        
        for Point in Points
        {
            if Int(Point.y) < GameBoard!.BucketTopInterior
            {
                OverTopOfButtonAdder = OverTopOfButtonAdder + 1.0
            }
            NeighborCount = NeighborCount + NeighborsOf(Point: Point, IsOneOf: [.RetiredGamePiece, .Bucket])
        }
        
        return Double(NeighborCount) + (OverTopOfButtonAdder * -100.0)
    }
    
    /// Returns the bottom most points in each column of the set of points.
    ///
    /// - Parameter Points: List of points.
    /// - Returns: List of points, one for each column of data, the bottom-most (closest to the bucket bottom) for each column.
    public func BottomMostPoints(_ Points: [CGPoint]) -> [CGPoint]
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
    
    /// Piece types that define an occupied location in the bucket.
    let Occupied = [PieceTypes.Bucket, PieceTypes.InvisibleBucket, PieceTypes.RetiredGamePiece]
    
    /// Return the shape of the top of the bucket (occupied spaces) in the specified horizontal range.
    ///
    /// - Parameters:
    ///   - From: A set of points whose horizontal coordinate will be used to find the proper columns to check for tops.
    /// - Returns: List of points that define the top, unoccupied points in the specified set of points.
    public func BucketShape(From: [CGPoint]) -> [CGPoint]
    {
        var Points = [CGPoint]()
        for Point in From
        {
            let X = Int(Point.x)
            var AtBottom = true
            for Y in GameBoard!.BucketTopInterior ... GameBoard!.BucketBottomInterior
            {
                if GameBoard!.Map!.IDMap!.IsOccupiedType(GameBoard!.Map![Y,X]!)
                {
                    AtBottom = false
                    Points.append(CGPoint(x: X, y: Y))
                    break
                }
            }
            if AtBottom
            {
                Points.append(CGPoint(x: X, y: GameBoard!.BucketBottomInterior))
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
    func OffsetMappingScore(Points: [CGPoint]) -> Double
    {
        //let FullRows = GameBoard!.FullRowCount(WithPoints: Points)
        let BottomPoints = BottomMostPoints(Points)
        let TopPoints = BucketShape(From: BottomPoints)
        var OverTopOfBucket: Double = 0.0
        var CumulativeY: Double = 0.0
        for Point in Points
        {
            CumulativeY = CumulativeY + Double(Point.y)
            if Int(Point.y) < GameBoard!.BucketTopInterior
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
    
    /// Calculate a piece score by the number of neighbors each point has.
    ///
    /// - Parameter Points: List of points to score.
    /// - Returns: Mean neighbor count.
    func TouchingScore(Points: [CGPoint]) -> Double
    {
        var OverTopOfBucket: Double = 0.0
        var NeighborCount = 0
        for Point in Points
        {
            if Int(Point.y) < GameBoard!.BucketTopInterior
            {
                OverTopOfBucket = OverTopOfBucket + 1.0
            }
            if Int(Point.y) > GameBoard!.BucketBottomInterior
            {
                continue
            }
            NeighborCount = NeighborCount + GameBoard!.Map!.NeighborCount(Int(Point.x), Int(Point.y))
        }
        let MeanNeighborCount = Double(NeighborCount) / Double(Points.count)
        return MeanNeighborCount + (OverTopOfBucket * -100.0)
    }
    
    /// Return a score for the piece as represented by the set of points passed.
    ///
    /// - Parameters:
    ///   - ForPoints: List of points for the piece.
    ///   - WithMethod: The method to use to determine the score.
    ///   - CurrentPiece: The piece to score. Needed by some scoring methods.
    /// - Returns: The score for the piece based on `WithMethod`.
    func MakeScore(ForPoints: [CGPoint], WithMethod: AIScoringMethods, CurrentPiece: Piece? = nil) -> Double
    {
        switch WithMethod
        {
        case .ClosestToBottom:
            return CloseToBottomPointScore(Points: ForPoints)
            
        case .MeanLocation:
            return MeanPointScore(Points: ForPoints)
            
        case .UniqueClosestToBottom:
            return UniqueCloseToBottomPointScore(Points: ForPoints)
            
        case .NeighborCount:
            return TotalNeighborCount(Points: ForPoints)
            
        case .WeightedBottom:
            return WeightedBottomScore(Points: ForPoints)
            
        case .MeanWithMinimalGap:
            return MeanWithMinimalGap(Points: ForPoints)
            
        case .OffsetMapping:
            return OffsetMappingScore(Points: ForPoints)
            
        case .NeighborCount2:
            return TouchingScore(Points: ForPoints)
        }
    }
    
    /// Generate a score for the piece whose points (rotated and shifted before hand) are passed to us.
    ///
    /// - Parameters:
    ///   - Points: The points of the piece.
    ///   - OriginalGapCount: The number of unreachable gaps in the bucket prior to finding the score.
    /// - Returns: Score of the piece if dropped in its current location and orientation.
    public func ScoreFor(Points: [CGPoint], OriginalGapCount: Int, CurrentPiece: Piece) -> Double
    {
        let Dropped = VirtualDrop(Points: Points)
        var StoppedAboveBucket = false
        for Drop in Dropped
        {
            if Int(Drop.y) < GameBoard!.BucketTopInterior
            {
                StoppedAboveBucket = true
                break
            }
        }
        
        var PieceScore = MakeScore(ForPoints: Dropped, WithMethod: CurrentScoringMethod, CurrentPiece: CurrentPiece)
        if StoppedAboveBucket
        {
            //If any block is above the bucket, negate the score to reduce its value.
            PieceScore = PieceScore + -1000.0
        }
        else
        {
            //If the piece didn't stop above the bucket, see how many unreachable gaps
            //were created by dropping the block.
            var Blocked: Int = 0
            var Reachable: Int = 0
            let NewGapCount = GameBoard!.Map!.UnreachablePointCount(TestPoints: Dropped,
                                                               Reachable: &Reachable,
                                                               Blocked: &Blocked)
            let DeltaGap = NewGapCount - OriginalGapCount
            if DeltaGap > 0
            {
                PieceScore = PieceScore - Double(DeltaGap)
            }
        }
        
        return PieceScore
    }
    
    /// Rotate the points of a piece by the specified angle (in degrees).
    ///
    /// - Note: If the value of `ToAngle` is not 0, 90, 180, or 270, a fatal error will be generated.
    ///
    /// - Parameters:
    ///   - Points: The set of points from a piece to rotated.
    ///   - ToAngle: The angle to rotate the points by. Must be one of: 0, 90, 180, or 270.
    ///   - OriginIndex: The index of the origin point.
    ///   - MoveDownFirst: Returns the number of downward motions the piece must take before rotating in order
    ///                    to stop rotations from being out of the map.
    /// - Returns: Set of rotated points.
    public func RotatePiece(Points: [CGPoint], ToAngle: Int, OriginIndex: Int, MoveDownFirst: inout Int) -> [CGPoint]
    {
        if ![0, 90, 180, 270].contains(ToAngle)
        {
            fatalError("Invalid rotation (\(ToAngle) specified.)")
        }
        let Rotated = RotateClockwise(Points: Points, ByAngle: Double(ToAngle), OriginIndex: OriginIndex,
                                      MoveDown: &MoveDownFirst)
        return Rotated
    }
    
    /// Find the score for the piece at the specified horizontal offset. This function assumes the piece has been rotated
    /// as appropriate.
    ///
    /// - Parameters:
    ///   - Points: The piece's points, perhaps rotated by other functions.
    ///   - HorizontalPosition: The horizontal offset over the bucket.
    ///   - OriginalGapCount: The number of unreachable gaps in the bucket prior to getting the score.
    /// - Returns: Piece's score for its current rotation, dropped to the bottom of the bucket (as far as existing, retired
    ///            pieces allow).
    public func GetScoreForPosition(Points: [CGPoint], HorizontalPosition: Int, OriginalGapCount: Int,
                                    CurrentPiece: Piece) -> Double
    {
        let LeftMost = FindLeftMost(Points)
        let LeftMostX = Int(LeftMost.x)
        var XPoints = [CGPoint]()
        for Index in 0 ..< Points.count
        {
            var NewX = Int(Points[Index].x)
            NewX = NewX - LeftMostX
            NewX = NewX + HorizontalPosition
            XPoints.append(CGPoint(x: NewX, y: Int(Points[Index].y)))
        }
        return ScoreFor(Points: XPoints, OriginalGapCount: OriginalGapCount, CurrentPiece: CurrentPiece)
    }
    
    /// Start stepping through the AI with the specified piece.
    ///
    /// - Parameter GamePiece: The piece to begin stepping through the AI.
    public func StartSteppingAI(GamePiece: Piece)
    {
        FoundBestFitFor = GamePiece
        StepPiece = GamePiece
        StepOriginIndex = -1
        for Index in 0 ..< GamePiece.Locations.count
        {
            if GamePiece.Locations[Index].IsOrigin
            {
                StepOriginIndex = Index
                break
            }
        }
        if StepOriginIndex < 0
        {
            fatalError("No origin found in passed game piece.")
        }
        var Reachable: Int = 0
        var Blocked: Int = 0
        StepGapCount = GameBoard!.Map!.UnreachablePointCount(Reachable: &Reachable, Blocked: &Blocked)
        StepPoints.removeAll()
        StepPoints = GamePiece.LocationsAsPoints()
        StepAngle = 0
        StepInitialized = true
    }
    
    var StepPiece: Piece? = nil
    var StepInitialized: Bool = false
    var StepOriginIndex: Int = 0
    var StepAngle: Int = 0
    var StepGapCount: Int = 0
    var StepPoints = [CGPoint]()
    var StepXOffset = 0
    var StepBestScore: Double = 0.0
    var StepBestAngle: Int = 0
    var StepBestOffset: Int = 0
    var StepMoveDownFirst: Int = 0
    var StepAllTested: Bool = false
    
    /// Step through the AI one score calculation at a time. Will result in a fatal error if StartSteppingAI is not called first.
    ///
    /// - Note: A score is calcuated for each horizontal offset and each rotational orientation (one of 0, 90, 180, and 270 degrees).
    ///         One step is for one position: rotation pair.
    ///
    /// - Note: A fatal error will be generated if `StartSteppingAI` is not called prior to calling this function. If `FinalizeStepAI`
    ///         is called, calling `StepAI` again (without calling `StartSteppingAI` before the next `StepAI` call) will generate a
    ///         fatal error. The required order is: `StartSteppingAI`, `StepAI` (multiple times), `FinalizeStepAI`.
    ///
    /// - Parameters:
    ///   - SteppingCompleted: Will contain a flag that indicates stepping is completed (eg, all positions and orientations have been
    ///                        scored. If this happens, call `FinalizeStepAI` to generate the motions needed to drive the piece to the
    ///                        best fit location.
    ///   - HorizontalOffset: The horizontal offset (within the game bucket) that was tested.
    ///   - CurrentRotation: The angle of the piece that was tested.
    /// - Returns: The score at the position/orientation. If `SteppingCompleted` is true, the returned value will be the best score
    ///            found for all positions/orientations.
    public func StepAI(SteppingCompleted: inout Bool, HorizontalOffset: inout Int, CurrentRotation: inout Int) -> Double
    {
        if !StepInitialized
        {
            fatalError("StepAI called without being initialized.")
        }
        CurrentRotation = -1
        HorizontalOffset = StepXOffset
        SteppingCompleted = false
        var MoveDownFirst: Int = 0
        if StepXOffset + GameBoard!.BucketInteriorLeft > GameBoard!.BucketInteriorRight
        {
            StepXOffset = 0
            if StepAngle == 270
            {
                StepAllTested = true
                SteppingCompleted = true
                return StepBestScore
            }
            StepAngle = StepAngle + 90
            StepPoints = RotatePiece(Points: StepPoints, ToAngle: StepAngle, OriginIndex: StepOriginIndex, MoveDownFirst: &MoveDownFirst)
        }
        let LeftMost = FindLeftMost(StepPoints)
        let LeftMostX = Int(LeftMost.x)
        let StepScore = GetScoreForPosition(Points: StepPoints, HorizontalPosition: StepXOffset,
                                            OriginalGapCount: StepGapCount, CurrentPiece: StepPiece!)
        if StepScore > StepBestScore
        {
            StepMoveDownFirst = MoveDownFirst
            StepBestScore = StepScore
            StepBestAngle = StepAngle
            StepBestOffset = LeftMostX - StepXOffset
        }
        CurrentRotation = StepAngle
        StepXOffset = StepXOffset + 1
        return StepScore
    }
    
    /// Finalize the stepping of the piece set in `StartSteppingAI`. Before calling this function, `StepAI` must be called until it
    /// reports it is completed. This function generates the motions required to drive the piece to its best fit location. The motions
    /// are stored in the `MotionQueue`.
    ///
    ///  -Note: If this function is called before `StepAI` reports completed, a fatal error will be generated.
    public func FinalizeStepAI()
    {
        if !StepAllTested
        {
            fatalError("Stepping not completed.")
        }
        //Add the motions necessary to put the piece into the place with the best score.
        let Motions = MotionCommandBlock(InitialMoveDown: StepMoveDownFirst, AngleCount: StepAngle / 90, XOffset: StepXOffset)
        GenerateMotionCommands(Motions: Motions)
        StepInitialized = false
    }
    
    /// Holds the gap count before the best fit calculations.
    var OriginalGapCount: Int = 0
    
    /// Find the best fit for the passed game piece. Return the best fit score. Motions and rotations are placed into
    /// `MotionQueue` for those functions that need it. This function looks ahead by the specified number of pieces
    /// to find the best place for this piece given the shape of the following pieces.
    ///
    /// - Note: This is a monolithic function and won't return (other than on error) until all AI processing is done.
    ///
    /// - Parameters:
    ///   - GamePiece: The piece to find the best fit for.
    ///   - SneakPeaks: How many pieces to look ahead at. If this number is greater than the queued number of pieces,
    ///                 only the queued number of pieces will be looked at.
    ///   - CurrentScore: The current score for the game.
    /// - Returns: The final, best score of the piece.
    public func BestFit(_ GamePiece: Piece, SneakPeaks: Int, CurrentScore: Int) -> Double
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
    public func BestFit(_ GamePiece: Piece, CurrentScore: Int) -> Double
    {
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
        OriginalGapCount = GameBoard!.Map!.UnreachablePointCount(Reachable: &Reachable, Blocked: &Blocked)
        //print("Original gap count: \(OriginalGapCount)")
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
                #if true
                var RotateCount: Int = [90, 180, 270].firstIndex(of: Angle)!
                RotateCount = RotateCount + 1
                Points = Piece.RightRotate(Points, AboutOrigin: PieceOrigin, Times: RotateCount)
                MoveDownFirst = 0
                #else
                Points = RotateClockwise(Points: Points, ByAngle: Double(Angle), OriginIndex: OriginIndex,
                                         MoveDown: &MoveDownFirst)
                #endif
            }
            let LeftMost = FindLeftMost(Points)
            let LeftMostX = Int(LeftMost.x)
            let RightMost = FindRightMost(Points)
            let RightMostX = Int(RightMost.x)
            let WidthAtAngle = RightMostX - LeftMostX
            
            let BucketLeft = GameBoard!.BucketInteriorLeft
            let BucketRight = GameBoard!.BucketInteriorRight
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
                var Dropped = VirtualDrop(Points: XPoints)
                
                //See if any block in the dropped piece is above the rim of the bucket.
                var StoppedAboveBucket = false
                for Drop in Dropped
                {
                    if Int(Drop.y) < GameBoard!.BucketTopInterior
                    {
                        StoppedAboveBucket = true
                        break
                    }
                }
                
                var PieceScore = MakeScore(ForPoints: Dropped, WithMethod: CurrentScoringMethod, CurrentPiece: GamePiece)
                #if false
                if StoppedAboveBucket
                {
                    //If any block is above the bucket, negate the score to reduce its value.
                    PieceScore = PieceScore + -1000.0
                }
                else
                {
                    //If the piece didn't stop above the bucket, see how many unreachable gaps
                    //were created by dropping the block.
                    var Reachable: Int = 0
                    var Blocked: Int = 0
                    let NewGapCount = GameBoard!.UnreachablePointCount(TestPoints: Dropped, Reachable: &Reachable,
                                                                       Blocked: &Blocked)
                    let DeltaGap = NewGapCount - OriginalGapCount
                    if DeltaGap > 0
                    {
                        PieceScore = PieceScore - Double(DeltaGap)
                    }
                }
                #endif
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
        let Motions = MotionCommandBlock(InitialMoveDown: MoveDownFirst, AngleCount: BestAngle / 90, XOffset: BestXOffset)
        GenerateMotionCommands(Motions: Motions)
        return BestScore
    }
    
    /// Describes how to move a block to its best fit calculated location.
    struct MotionCommandBlock
    {
        /// Number of times to move the block down so it can safely rotate.
        let InitialMoveDown: Int
        /// Number of times to rotate the block clockwise. (May be translated by `GenerateMotionCommands` to
        /// counter-clockwise rotations as needed/desired.)
        let AngleCount: Int
        /// Offset (positive or negative) for horizontal motion to align the piece with the bottom-most available
        /// spot in the bucket.
        let XOffset: Int
    }
    
    /// Given a block of directions to find the best fit for the piece, generate a queue of motions to
    /// actually drive the block there.
    ///
    /// - Parameter Motions: Block of data that describes how to move the piece to the best location.
    private func GenerateMotionCommands(Motions: MotionCommandBlock)
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
    
    public var FoundBestFitFor: Piece? = nil
    
    /// Returns the piece score for the passed game piece. Higher scores are better.
    ///
    /// - Note: The score returned is for the piece in its current location and orientation. No location
    ///         or orientation changes are made.
    ///
    /// - Parameter GamePiece: The piece whose score will be returned.
    /// - Returns: Value indicating the piece of the score.
    public func ScoreFor(_ GamePiece: Piece) -> Double
    {
        #if true
        let Points = GamePiece.LocationsAsPoints()
        var LeftMost = 10000
        for Point in Points
        {
            if Int(Point.x) < LeftMost
            {
                LeftMost = Int(Point.x)
            }
        }
        var Reachable: Int = 0
        var Blocked: Int = 0
        let GapCount = GameBoard!.Map!.UnreachablePointCount(Reachable: &Reachable, Blocked: &Blocked)
        return GetScoreForPosition(Points: Points, HorizontalPosition: LeftMost, OriginalGapCount: GapCount,
                                   CurrentPiece: GamePiece)
        #else
        let BottomMost = VirtualDrop(Points: GamePiece.LocationsAsPoints())
        var BottomPoint = CGPoint.zero
        var Highest: CGFloat = -1000.0
        for Point in BottomMost
        {
            if Point.y > Highest
            {
                Highest = Point.y
                BottomPoint = Point
            }
        }
        return Int(BottomPoint.y)
        #endif
    }
    
    /// Holds the current scoring method.
    private var _CurrentScoringMethod: AIScoringMethods = .MeanLocation
    /// Get or set the scoring method type to use for scoring how well pieces fit together.
    public var CurrentScoringMethod: AIScoringMethods
    {
        get
        {
            return _CurrentScoringMethod
        }
        set
        {
            _CurrentScoringMethod = newValue
        }
    }
}


