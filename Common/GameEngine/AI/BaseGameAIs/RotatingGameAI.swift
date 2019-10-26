//
//  RotatingGameAI.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// AI to find the best fit/score for a game piece in a rotating game
class RotatingGameAI: AIProtocol
{
    /// Initialize the AI with the specified board. Call after each rotation.
    /// - Parameter WithBoard: The board board to use.
    func Initialize(WithBoard: Board)
    {
        GameBoard = WithBoard
        _MotionQueue = Queue<Directions>()
    }
    
    /// Holds the game board passed to `Initialize`.
    private var GameBoard: Board? = nil
    
    /// Holds the queue of motion commands for a best fit location.
    private var _MotionQueue: Queue<Directions>? = nil
    /// Get or set the queue of motion commands for a best fit location.
    public var MotionQueue: Queue<Directions>
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
    
    /// Return all of the motion commands from the motion queue. The queue itself is unchanged.
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
    
    /// Return the next motion in the motion queue. The queue is dequeued. If there are no
    /// motions in the motion queue, **.NoDirection** is returned.
    /// - Returns: Next motion from the motion queue. Motion queue is dequeued.
    public func GetNextMotion() -> Directions
    {
        if MotionQueue.IsEmpty
        {
            //return Directions.DropDown
            return Directions.NoDirection
        }
        return MotionQueue.Dequeue()!
    }
    
    /// Returns the AI type. In our case, **.Rotating4**.
    /// - Returns: AI type - the game type the AI can operate on.
    func GetAIType() -> AITypes
    {
        return .Rotating
    }
    
    /// Given a block of directions to find the best fit for the piece, generate a queue of motions to
    /// actually drive the block there.
    ///
    /// - Parameter Motions: Block of data that describes how to move the piece to the best location.
    func GenerateMotionCommands(Motions: MotionCommandBlock2)
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
    
    func GetWidth(_ Points: [CGPoint]) -> Int
    {
        var MinX = Int.max
        var MaxX = Int.min
        for Point in Points
        {
            if Int(Point.x) < MinX
            {
                MinX = Int(Point.x)
            }
            if Int(Point.x) > MaxX
            {
                MaxX = Int(Point.x)
            }
        }
        return abs(MaxX - MinX) + 1
    }
    
    /// Calculate the best fit for the specified game piece.
    /// - Note: "Best fit" is defined as the location that generates the greatest increment
    ///         in the game score.
    /// - Parameter GamePiece: The game piece to find the best fit for.
    /// - Parameter CurrentScore: The score before the AI starts.
    /// - Returns: Value indicating the best fit. This is *not* a game score.
    public func BestFit(_ GamePiece: Piece, CurrentScore: Int) -> Double
    {
        FoundBestFitFor = GamePiece
        return 0.0
    }
    
    /// Determines if the left side of the board/bucket is complete, meaning there are no bottomless columns on the left side.
    /// - Parameter InBoard: The board used to determine completeness.
    /// - Returns: True if the left side has no bottomless columns, false if it does.
    func LeftSideIsComplete(_ InBoard: Board) -> Bool
    {
        let CenterUpperLeft = CGPoint(x: InBoard.BucketInteriorWidth / 2, y: 0)
        for X in InBoard.BucketInteriorLeft ... Int(CenterUpperLeft.x)
        {
            if (InBoard.Map?.ColumnIsBottomless(X))!
            {
                return false
            }
        }
        return true
    }
    
    /// Find the closest bottom-less column on the left-side of the bucket (left-side being defined as to the
    /// left of the center block).
    /// - Parameter InBoard: The board in which to find the closest bottomless column.
    /// - Returns: The column index of the closest bottom-less column on the right side. If no bottom-less columns
    ///            found, `-1` is returned.
    func ClosestBottomlessLeft(_ InBoard: Board) -> Int
    {
        let CenterUpperLeft = CGPoint(x: InBoard.BucketInteriorWidth / 2, y: 0)
        for X in stride(from: Int(CenterUpperLeft.x - 1.0), to: InBoard.BucketInteriorLeft, by: -1)
        {
            if (InBoard.Map?.ColumnIsBottomless(X))!
            {
                return X
            }
        }
        return -1
    }
    
    /// Determines if the right side of the board/bucket is complete, meaning there are no bottomless columns on the right side.
    /// - Parameter InBoard: The board used to determine completeness.
    /// - Returns: True if the right side has no bottomless columns, false if it does.
    func RightSideIsComplete(_ InBoard: Board) -> Bool
    {
        let CenterLowerRight = CGPoint(x: InBoard.BucketInteriorWidth / 2, y: 0)
        for X in Int(CenterLowerRight.x) ... InBoard.BucketInteriorRight
        {
            if (InBoard.Map?.ColumnIsBottomless(X))!
            {
                return false
            }
        }
        return true
    }
    
    /// Find the closest bottom-less column on the right-side of the bucket (right-side being defined as to the
    /// right of the center block).
    /// - Parameter InBoard: The board in which to find the closest bottomless column.
    /// - Returns: The column index of the closest bottom-less column on the right side. If no bottom-less columns
    ///            found, `-1` is returned.
    func ClosestBottomlessRight(_ InBoard: Board) -> Int
    {
        let CenterLowerRight = CGPoint(x: InBoard.BucketInteriorWidth / 2, y: 0)
        for X in Int(CenterLowerRight.x + 1.0) ... InBoard.BucketInteriorRight
        {
            if (InBoard.Map?.ColumnIsBottomless(X))!
            {
                return X
            }
        }
        return -1
    }
    
    /// Returns the first column to the left of the center block (but will return the left-most center block position if necessary)
    /// that is not bottomless (eg, a floor).
    /// - Parameter InBoard: The board to use to find the first floor column.
    /// - Returns: The column index (in terms of the bucket, eg, *not* zero-based) of the first floor column to the left of
    ///            the center block. Will return -1 if there are no bottomless columns.
    func NextLeftSideFloorColumn(_ InBoard: Board) -> Int
    {
        let ToColumn = Int(InBoard.BucketInteriorWidth / 2)
        for X in InBoard.BucketInteriorLeft ... ToColumn
        {
            if !(InBoard.Map?.ColumnIsBottomless(X))!
            {
                return X
            }
        }
        return -1
    }
    
    /// Returns the first column to the right of the center block (but will return the right-most center block position if necessary)
    /// that is not bottomless (eg, a floor).
    /// - Parameter InBoard: The board to use to find the first floor column.
    /// - Returns: The column index (in terms of the bucket, eg, *not* zero-based) of the first floor column to the right of
    ///            the center block. Will return -1 if there are no bottomless columns.
    func NextRightSideFloorColumn(_ InBoard: Board) -> Int
    {
        let ToColumn = Int(InBoard.BucketInteriorWidth / 2)
        for X in ToColumn ... InBoard.BucketInteriorRight
        {
            if !(InBoard.Map?.ColumnIsBottomless(X))!
            {
                return X
            }
        }
        return -1
    }
    
    /// Returns the right-most point in the set of passed points.
    /// - Note: If more than one point has the same right-most `x` value, the last such point found is returned.
    /// - Parameter Points: Set of points whose right-most point is returned.
    /// - Returns: The right-most point. See also Notes.
    func RightMostPiecePoint(_ Points: [CGPoint]) -> CGPoint
    {
        var Rightest = CGFloat(-1000.0)
        var SomePoint = CGPoint.zero
        for Point in Points
        {
            if Point.x > Rightest
            {
                Rightest = Point.x
                SomePoint = Point
            }
        }
        return SomePoint
    }
    
    func LeftMotionAdjust(ProposedMotion: Int, Points: [CGPoint], LeftMostValid: Int) -> Int
    {
        var FurthestLeft = Int.max
        for Point in Points
        {
            if Int(Point.x + CGFloat(ProposedMotion)) < FurthestLeft
            {
                FurthestLeft = Int(Point.x) + ProposedMotion
            }
        }
        let Adjustment = LeftMostValid - FurthestLeft
        return Adjustment < 0 ? Adjustment : 0
    }
    
    /// Returns the number of horizontal moves needed to move the points in `Points` such that the right-most point overlaps
    /// with 'ToColumn'.
    /// - Parameter ToColumn: The target column to overlap.
    /// - Parameter Points: The points that represent the piece being moved.
    /// - Returns: The number of horizontal moves needed to move the point in `Points` such that the right-most location overlaps
    ///            `ToColumn`. May be negative for left motions and positive for right motions.
    func GetLeftOverlapMotionCount(ToColumn: Int, Points: [CGPoint], LeftMostValid: Int) -> Int
    {
        let RightMost = Int(RightMostPiecePoint(Points).x)
        let MoveLeft = RightMost - ToColumn
        let LeftMost = Int(Points.LeftMost().x)
        let OverGap = (LeftMost - MoveLeft) - LeftMostValid
        if OverGap < 0
        {
            return MoveLeft - abs(OverGap)
        }
        return MoveLeft
    }
    
    /// Returns the left-most point in the set of passed points.
    /// - Note: If more than one point has the same left-most `x` value, the last such point found is returned.
    /// - Parameter Points: Set of points whose left-most point is returned.
    /// - Returns: The left-most point. See also Notes.
    func LeftMostPiecePoint(_ Points: [CGPoint]) -> CGPoint
    {
        var Leftest = CGFloat(1000.0)
        var SomePoint = CGPoint.zero
        for Point in Points
        {
            if Point.x < Leftest
            {
                Leftest = Point.x
                SomePoint = Point
            }
        }
        return SomePoint
    }
    
    /// Returns the number of horizontal moves needed to move the points in `Points` such that the left-most point overlaps
    /// with 'ToColumn'.
    /// - Parameter ToColumn: The target column to overlap.
    /// - Parameter Points: The points that represent the piece being moved.
    /// - Returns: The number of horizontal moves needed to move the point in `Points` such that the left-most location overlaps
    ///            `ToColumn`. May be negative for left motions and positive for right motions.
    func GetRightOverlapMotionCount(ToColumn: Int, Points: [CGPoint], RightMostValid: Int) -> Int
    {
        let LeftMost = Int(LeftMostPiecePoint(Points).x)
        let MoveRight = LeftMost - ToColumn
        return MoveRight
    }
    
    /// Returns the number of times the set of passed points must rotate to the right such that the points will present their
    /// widest aspect horizontally.
    /// - Parameter ForPoints: The points to rotate.
    /// - Parameter CenterPoint: The rotational center of the set of points to rotate.
    /// - Returns: The number of times to rotate the points to the right to make the points have the widest spread horizontally.
    func WidestRotation(ForPoints: [CGPoint], CenterPoint: CGPoint) -> Int
    {
        var MaxWidth = GetWidth(ForPoints)
        var Count = 0
        for RotateCount in 1 ..< 4
        {
            let Points = Piece.RightRotate(ForPoints, AboutOrigin: CenterPoint, Times: RotateCount)
            let RWidth = GetWidth(Points)
            if RWidth > MaxWidth
            {
                MaxWidth = RWidth
                Count = RotateCount
            }
        }
        return Count
    }
    
    /// Return the origin point (eg, rotational center) of the set of points that make up the game piece.
    /// - Parameter GamePiece: The piece whose origin is returned.
    /// - Returns: The piece's origin/rotational center point.
    func GetPieceOrigin(_ GamePiece: Piece) -> CGPoint?
    {
        for Index in 0 ..< GamePiece.Locations.count
        {
            if GamePiece.Locations[Index].IsOrigin
            {
                return GamePiece.Locations[Index].Location
            }
        }
        return nil
    }
    
    /// Return the number of bottomless columns on either side of the central block in the current board orientation.
    /// - Parameter InBoard: The board to use to calculate bottomless columns.
    /// - Returns: Tuple in the form (Number of left-side bottomless columns, Number of right-side bottomless columns).
    func EmptyColumnCounts(_ InBoard: Board) -> (Left: Int, Right: Int)
    {
        var LeftCount = 0
        var RightCount = 0
        
        guard let Left = InBoard.Map?.LeftMostFloor else
        {
            return (Left: InBoard.BucketInteriorWidth, Right: InBoard.BucketInteriorWidth)
        }
        guard let Right = InBoard.Map?.RightMostFloor else
        {
            //Theoretically, we should never reach this code becaue the assignment to Left above checks for the same
            //condition that would lead to Right being nil.
            return (Left: InBoard.BucketInteriorWidth, Right: InBoard.BucketInteriorWidth)
        }
        LeftCount = Left - InBoard.BucketInteriorLeft
        RightCount = InBoard.BucketInteriorRight - Right
        return (LeftCount, RightCount)
    }
    
    /// Move the passed set of points left by the passed number, but not farther than the constraint.
    /// - Parameter Points: The set of points to move to the left.
    /// - Parameter By: Constant to move points by.
    /// - Parameter LeftConstraint: Maximum distance to the left to move any given point.
    func MovePointsLeft(_ Points: inout [CGPoint], By: Int, LeftConstraint: Int) -> Int
    {
        let LeftMost = CGFloat(LeftConstraint)
        var Actual = 0
        for _ in 0 ..< abs(By)
        {
            for var Point in Points
            {
                let NewX = Point.x - 1.0
                if NewX < LeftMost
                {
                    return Actual
                }
                Point.x = NewX
            }
            Actual = Actual + 1
        }
        return By
    }
    
    /// Move the passed set of points right by the passed number, but not farther than the constraint.
    /// - Parameter Points: The set of points to move to the right.
    /// - Parameter By: Constant to move points by.
    /// - Parameter LeftConstraint: Maximum distance to the right to move any given point.
    func MovePointsRight(_ Points: inout [CGPoint], By: Int, RightConstraint: Int) -> Int
    {
        let RightMost = CGFloat(RightConstraint)
        var Actual = 0
        for _ in 0 ..< abs(By)
        {
            for var Point in Points
            {
                let NewX = Point.x + 1.0
                if NewX > RightMost
                {
                    return Actual
                }
                Point.x = NewX
            }
            Actual = Actual + 1
        }
        return By
    }
    
    /// Calculate the best fit for the specified game piece.
    /// - Note:
    ///   - "Best fit" is defined as the location that generates the greatest increment
    ///     in the game score.
    ///   - This function intended for use for games that change boards between pieces.
    /// - Parameter GamePiece: The game piece to find the best fit for.
    /// - Parameter CurrentScore: The score before the AI starts.
    /// - Parameter InBoard: The Board to use to find the best fit.
    /// - Returns: Value indicating the best fit. This is *not* a game score.
    func BestFit(_ GamePiece: Piece, CurrentScore: Int, InBoard: Board) -> Double
    {
        //print("\nStarting AI for piece \"\(GamePiece.Shape)\"")
        FoundBestFitFor = GamePiece
        MotionQueue.Clear()
        let LeftSideComplete = LeftSideIsComplete(InBoard)
        let RightSideComplete = RightSideIsComplete(InBoard)
        let FloorCompleted = LeftSideComplete && RightSideComplete
        let EntryWindow = InBoard.Map?.TopRowEntry()
        print("EntryWindow = \(EntryWindow!.Left) to \(EntryWindow!.Right)")
        if FloorCompleted
        {
            //If the floor is completed (eg, no bottomless columns), use a offset matching algorithm.
            let Final = GeneralAI.BestFit(GamePiece, CurrentScore: CurrentScore, GameBoard: InBoard)
            MotionQueue = Queue(GeneralAI.MotionQueue)
            return Final
        }
        else
        {
            var Points = GamePiece.LocationsAsPoints()
            if !GamePiece.IsRotationallySymmetric
            {
                //Orient the piece such that it presents its widest aspect horizontally.
                let Origin = GetPieceOrigin(GamePiece)
                let WideCount = WidestRotation(ForPoints: Points, CenterPoint: Origin!)
                if WideCount > 0
                {
                    Points = Piece.RightRotate(Points, AboutOrigin: Origin!, Times: WideCount)
                }
                for _ in 0 ..< WideCount
                {
                    MotionQueue.Enqueue(.RotateRight)
                }
            }
            var XOffset: Int = 0
            if !LeftSideComplete && !RightSideComplete
            {
                //Neither side is complete - build on the side with the greatest number of bottomless columns.
                let (LeftCount, RightCount) = EmptyColumnCounts(InBoard)
                if LeftCount >= RightCount
                {
                    if let FloorColumn = InBoard.Map?.LeftMostFloor
                    {
                        XOffset = GetLeftOverlapMotionCount(ToColumn: FloorColumn, Points: Points,
                                                            LeftMostValid: InBoard.BucketInteriorLeft)
                    }
                }
                else
                {
                    if let FloorColumn = InBoard.Map?.RightMostFloor
                    {
                        XOffset = GetRightOverlapMotionCount(ToColumn: FloorColumn, Points: Points,
                                                             RightMostValid: InBoard.BucketInteriorRight)
                    }
                }
            }
            if LeftSideComplete
            {
                //Build on the right side.
                let FloorColumn = NextRightSideFloorColumn(InBoard)
                XOffset = GetRightOverlapMotionCount(ToColumn: FloorColumn, Points: Points,
                                                     RightMostValid: InBoard.BucketInteriorRight)
            }
            if RightSideComplete
            {
                //Build on the left side.
                let FloorColumn = NextLeftSideFloorColumn(InBoard)
                XOffset = GetLeftOverlapMotionCount(ToColumn: FloorColumn, Points: Points,
                                                    LeftMostValid: InBoard.BucketInteriorLeft)
            }
            if XOffset > 0
            {
                for _ in 0 ..< XOffset
                {
                    MotionQueue.Enqueue(.Left)
                }
            }
            if XOffset < 0
            {
                for _ in 0 ..< abs(XOffset)
                {
                    MotionQueue.Enqueue(.Right)
                }
            }
            MotionQueue.Enqueue(.DropDown)
        }
        return 0.0
    }
    
    /// The piece the best fit was found for.
    public weak var FoundBestFitFor: Piece? = nil
}

/// Extension methods for [CGPoint].
extension Array where Element == CGPoint
{
    /// Return a new set of `CGPoint`s with the supplied offset applied to each point.
    /// - Parameter Offset: The offset to apply to each point.
    /// - Returns: New array of `CGPoint`s with the supplied offset applied to each point.
    func WithOffset(_ Offset: CGPoint) -> [CGPoint]
    {
        var Result = [CGPoint]()
        for Point in self
        {
            let NewPoint = CGPoint(x: Point.x + Offset.x, y: Point.y + Offset.y)
            Result.append(NewPoint)
        }
        return Result
    }
    
    /// Return a new set of `CGPoint`s with the supplied offset applied to each point.
    /// - Parameter XOffset: The offset to apply to each `x` field. CGFloat type.
    /// - Parameter YOffset: The offset to apply to each `y` field. CGFloat type.
    /// - Returns: New array of `CGPoint`s with the supplied offset applied to each point.
    func WithOffset(_ XOffset: CGFloat, _ YOffset: CGFloat) -> [CGPoint]
    {
        return self.WithOffset(CGPoint(x: XOffset, y: YOffset))
    }
    
    /// Return a new set of `CGPoint`s with the supplied offset applied to each point.
    /// - Parameter XOffset: The offset to apply to each `x` field. Int type.
    /// - Parameter YOffset: The offset to apply to each `y` field. Int type.
    /// - Returns: New array of `CGPoint`s with the supplied offset applied to each point.
    func WithOffset(_ XOffset: Int = 0, _ YOffset: Int = 0) -> [CGPoint]
    {
        return self.WithOffset(CGPoint(x: XOffset, y: YOffset))
    }
    
    /// Returns the horizontal extent of the set of points.
    /// - Returns: Horizontal extent.
    func HorizontalExtent() -> Int
    {
        var MinX = Int.max
        var MaxX = Int.min
        for Point in self
        {
            let X = Int(Point.x)
            if X < MinX
            {
                MinX = X
            }
            if X > MaxX
            {
                MaxX = X
            }
        }
        return abs(MaxX - MinX) + 1
    }
    
    /// Returns the vertical extent of the set of points.
    /// - Returns: Vertical extent.
    func VerticalExtent() -> Int
    {
        var MinY = Int.max
        var MaxY = Int.min
        for Point in self
        {
            let Y = Int(Point.y)
            if Y < MinY
            {
                MinY = Y
            }
            if Y > MaxY
            {
                MaxY = Y
            }
        }
        return abs(MaxY - MinY) + 1
    }
    
    /// Returns the left-most point.
    /// - Note: If more than one point has the same lowest `x` value, the last point encountered will be returned.
    /// - Returns: The point with the lowest `x` value.
    func LeftMost() -> CGPoint
    {
        var LeftPoint = CGPoint.zero
        var MinX = CGFloat.greatestFiniteMagnitude
        for Point in self
        {
            if Point.x < MinX
            {
                MinX = Point.x
                LeftPoint = Point
            }
        }
        return LeftPoint
    }
    
    /// Returns the right-most point.
    /// - Note: If more than one point has the same greatest `x` value, the last point encountered will be returned.
    /// - Returns: The point with the greatest `x` value.
    func RightMost() -> CGPoint
    {
        var RightPoint = CGPoint.zero
        var MaxX = CGFloat.leastNormalMagnitude
        for Point in self
        {
            if Point.x > MaxX
            {
                MaxX = Point.x
                RightPoint = Point
            }
        }
        return RightPoint
    }
    
    /// Returns the top-most point.
    /// - Note: If more than one point has the same lowest `y` value, the last point encountered will be returned.
    /// - Returns: The point with the lowest `y` value.
    func TopMost() -> CGPoint
    {
        var TopPoint = CGPoint.zero
        var MinY = CGFloat.greatestFiniteMagnitude
        for Point in self
        {
            if Point.y < MinY
            {
                MinY = Point.y
                TopPoint = Point
            }
        }
        return TopPoint
    }
    
    /// Returns the bottom-most point.
    /// - Note: If more than one point has the same greatest `y` value, the last point encountered will be returned.
    /// - Returns: The point with the greatest `y` value.
    func BottomMost() -> CGPoint
    {
        var BottomPoint = CGPoint.zero
        var MaxY = CGFloat.leastNormalMagnitude
        for Point in self
        {
            if Point.y > MaxY
            {
                MaxY = Point.y
                BottomPoint = Point
            }
        }
        return BottomPoint
    }
}
