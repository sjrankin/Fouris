//
//  CubicGameAI.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

class CubicGameAI: AIProtocol
{
    func Initialize(WithBoard: Board)
    {
        GameBoard = WithBoard
    }
    
    private var GameBoard: Board? = nil
    
    private var _MotionQueue: Queue<Directions>? = nil
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
    
    public func GetNextMotion() -> Directions
    {
        if MotionQueue.IsEmpty
        {
            return Directions.NoDirection
        }
        return MotionQueue.Dequeue()!
    }
    
    func GetAIType() -> AITypes
    {
        return .Cubic
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
    
    public func BestFit(_ GamePiece: Piece, CurrentScore: Int) -> Double
    {
        return 0.0
    }
    
    func BestFit(_ GamePiece: Piece, CurrentScore: Int, InBoard: Board) -> Double
    {
        return 0.0
    }
    
    public weak var FoundBestFitFor: Piece? = nil
}

