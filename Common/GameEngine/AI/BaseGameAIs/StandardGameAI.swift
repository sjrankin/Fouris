//
//  StandardGameAI.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Standard Tetris game AI. Uses the `GeneralAI` class.
class StandardGameAI: AIProtocol
{
    /// The piece that was tested.
    var FoundBestFitFor: Piece?
    
    /// Initialize the AI class.
    /// - Parameter: The board to use to find the best moves.
    func Initialize(WithBoard: Board)
    {
        GameBoard = WithBoard
    }
    
    /// Returns a value indicating a best fit score.
    /// - Parameter GamePiece: The piece used to determine best fit.
    /// - Parameter CurrentScore: The current game score.
    /// - Parameter InBoard: The populated board.
    /// - Returns: Value indicating best fit.
    func BestFit(_ GamePiece: Piece, CurrentScore: Int, InBoard: Board) -> Double
    {
        let Result = GeneralAI.BestFit(GamePiece, CurrentScore: CurrentScore, GameBoard: InBoard)
        MotionQueue = Queue(GeneralAI.MotionQueue)
        return Result
    }
    
    /// Returns a value indicating a best fit score.
    /// - Notes: Not currently implemented.
    /// - Parameter GamePiece: The piece used to determine best fit.
    /// - Parameter CurrentScore: The current game score.
    /// - Returns: Value indicating best fit.
    public func BestFit(_ GamePiece: Piece, CurrentScore: Int) -> Double
    {
        return 0.0
    }
    
    /// Holds the board for the standard game.
    private var GameBoard: Board? = nil
    
    /// Holds the motion queue. Populated when the AI is completed for a given piece.
    private var _MotionQueue: Queue<Directions>? = nil
    /// Get or set the motion queue.
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
    
    /// Return (but do not modify) the contents of the motion queue.
    /// - Returns: The contents of the motion queue.
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
    
    /// Get the next motion in the motion queue.
    /// - Returns: The next motion in the motion queue. If the queue is empty, **.NoDirection** is returned.
    public func GetNextMotion() -> Directions
    {
        if MotionQueue.IsEmpty
        {
            return Directions.NoDirection
        }
        return MotionQueue.Dequeue()!
    }
    
    /// Returns the AI type.
    func GetAIType() -> AITypes
    {
        return .Standard
    }
}
