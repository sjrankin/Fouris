//
//  GameAI2.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that calculates the best fit for a randomly selected piece and generates the motions for the block to get there.
class GameAI2
{
    /// Initialize the AI.
    init()
    {
        MotionQueue = Queue<Directions>()
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
    
    /// Virtually drop the set of passed points to the bottom-most valid location in the bucket.
    ///
    /// - Parameter Points: Points to drop to the bottom of the bucket.
    /// - Parameter InMap: The map in which to virtually drop the set of poitns.
    /// - Returns: Set of points adjusted such that they are at the bottom-most valid location in the bucket.
    func VirtualDrop(Points: [CGPoint], InMap: MapType) -> [CGPoint]
    {
        var Working: [CGPoint] = Points
        while true
        {
            for Point in Working
            {
                let LocationOK: Bool = InMap.MapIsEmpty(At:  CGPoint(x: Point.x, y: Point.y))
                if !LocationOK
                {
                    return Working
                }
            }
            for Index in 0 ..< Working.count
            {
                Working[Index] = CGPoint(x: Working[Index].x, y: Working[Index].y + 1.0)
            }
        }
    }
    
    class FitResults
    {
        init()
        {
            NextResults = [FitResults]()
        }
        var Angle: Int = 0
        var XLocation: Int = 0
        var PieceID: UUID = UUID.Empty
        var GameScore: Int = 0
        var NextResults: [FitResults]? = nil
    }
    
    private func BestFitFor(PieceList: [Piece?], InMap: MapType, CurrentScore: inout Score, Depth: Int) -> [FitResults]
    {
        var Results = [FitResults]()
        
        let GamePiece: Piece = PieceList[Depth]!
        var PieceOrigin: CGPoint = CGPoint.zero
        var FoundOrigin = false
        for Block in GamePiece.Locations
        {
            if Block.IsOrigin
            {
                PieceOrigin = Block.Location
                FoundOrigin = true
                break
            }
        }
        if !FoundOrigin
        {
            fatalError("No origin found for piece in BestFitFor.")
        }
        
        for Angle in [0, 90, 180, 270]
        {
            if Angle > 0
            {
                if GamePiece.IsRotationallySymmetric
                {
                    break
                }
            }
            var Points = GamePiece.LocationsAsPoints()
            let CurrentResults = FitResults()
            CurrentResults.Angle = Angle
            if Angle > 0
            {
                let RotateCount: Int = [90, 180, 270].firstIndex(of: Angle)! + 1
                Points = Piece.RightRotate(Points, AboutOrigin: PieceOrigin, Times: RotateCount)
            }
            
            let LeftMostX = Int(FindLeftMost(Points).x)
            let RightMostX = Int(FindRightMost(Points).x)
            let WidthAtAngle = RightMostX - LeftMostX
            let BucketLeft = InMap.BucketInteriorLeft
            let BucketRight = InMap.BucketInteriorRight
            let ToRight = BucketRight - LeftMostX
            
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
                var Dropped = VirtualDrop(Points: XPoints, InMap: InMap)
                CurrentResults.XLocation = XOffset
                
                //All done - check the next piece.
                if Depth < PieceList.count
                {
                    let NextMap = MapType.Clone(From: InMap)
                    NextMap.MergePointsWithMap(Points: Dropped, WithTypeID: GamePiece.ID)
                    let SomeResults = BestFitFor(PieceList: PieceList, InMap: NextMap, CurrentScore: &CurrentScore, Depth: Depth + 1)
                    for SomeResult in SomeResults
                    {
                        Results.append(SomeResult)
                    }
                }
            }
        }
        
        return Results
    }
    
    public func BestFit(Factory: PieceFactory, SneakPeakCount: Int, StartingMap: MapType, CurrentScore: Score)
    {
        var AIScore = Score(From: CurrentScore, WithID: UUID())
        let AIMap = MapType.Clone(From: StartingMap)
        let PieceList = Factory.PieceQueueArray()
        BestFitFor(PieceList: PieceList, InMap: AIMap, CurrentScore: &AIScore, Depth: 0)
    }
}
