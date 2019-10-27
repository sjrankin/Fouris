//
//  AIProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for game AI classes.
protocol AIProtocol: class
{
    /// Returns the type of AI the class implements.
    func GetAIType() -> AITypes
    
    /// Initialize the AI.
    /// - Parameter WithBoard: The board to use for AI calculations.
    func Initialize(WithBoard: Board)
    
    /// The motion queue. Used by the game to actually move the piece.
    var MotionQueue: Queue<Directions> {get set}
    
    /// Get the contents of the motion queue but don't change the queue.
    /// - Returns: The contents of the motion queue.
    func DumpMotionQueue() -> [Directions]
    
    /// Get the next direction in the motion queue.
    /// - Returns: The next direction in the motion queue.
    func GetNextMotion() -> Directions
    
    /// Determines the best fit for the specified game piece.
    /// - Parameter GamePiece: The piece to determine best fit for.
    /// - Parameter CurrentScore: The current score of the game.
    /// - Returns: Scoring value (not the same as the game score) for the
    ///            specified piece in its best fit location.
    func BestFit(_ GamePiece: Piece, CurrentScore: Int) -> Double
    
    /// Determines the best fit for the specified game piece. Intended for use for
    /// board that change between pieces (such as **.Rotating**).
    /// - Parameter GamePiece: The piece to determine best fit for.
    /// - Parameter CurrentScore: The current score of the game.
    /// - Parameter InBoard: The board to use to find the best fit.
    /// - Returns: Scoring value (not the same as the game score) for the
    ///            specified piece in its best fit location.
    func BestFit(_ GamePiece: Piece, CurrentScore: Int, InBoard: Board) -> Double
    
    /// Get the piece whose best fit was generated in **BestFit**.
    var FoundBestFitFor: Piece? { get }
}

/// AI types for various games.
enum AITypes: Int, CaseIterable
{
    /// Standard game - assumes no bottomless columns.
    case Standard = 0
    /// Rotating game - assumes there may be bottomless columns.
    case Rotating = 1
    /// Semi-rotating game in which the pieces rotate but the bucket does not.
    case SemiRotating = 2
    /// Three-dimensional games.
    case Cubic = 3
}

/// Describes how to move a block to its best fit calculated location. Used internally to the AI classes.
struct MotionCommandBlock2
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
