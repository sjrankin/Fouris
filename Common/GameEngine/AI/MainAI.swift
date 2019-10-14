//
//  MainAI.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Encapsulation of all of the AIs for all of the games.
class MainAI
{
    /// Initializer. Creates the AIs for each base game type and sets the current AI to a known default value (**.Standard**).
    /// When the base game type changes, **Start** must be called to reset the board and game type.
    init()
    {
        GameAIs = [AITypes: AIProtocol]()
        GameAIs[.Standard] = StandardGameAI()
        GameAIs[.Rotating4] = Rotating4GameAI()
        GameAIs[.Cubic] = CubicGameAI()
        CurrentAI = GameAIs[.Standard]
    }
    
    /// Start the AI. Used to initialize internal structures.
    /// - Note: This function **must** be called when the base game type changes.
    /// - Parameter WithBoard: The board used by the game.
    /// - Parameter BaseGame: The base game type.
    public func Start(WithBoard: Board, BaseGame: BaseGameTypes)
    {
        MotionQueue = Queue<Directions>()
        GameBoard = WithBoard
        BaseGameType = BaseGame
    }
    
    /// Holds the base game type.
    private var _BaseGameType: BaseGameTypes = .Standard
    {
        didSet
        {
            SetGameAI(_BaseGameType)
        }
    }
    /// Get or set the base game type. Setting this property changes the base game type immediately, shutting down any
    /// prior AI execution.
    public var BaseGameType: BaseGameTypes
    {
        get
        {
            return _BaseGameType
        }
        set
        {
            _BaseGameType = newValue
        }
    }
    
    /// Initialize the type of AI based on the base game type.
    /// - Note: The selected AI will be reinitialized by calling this function.
    /// - Parameter Base: Determines the type of AI to use.
    private func SetGameAI(_ Base: BaseGameTypes)
    {
        switch Base
        {
            case .Standard:
                CurrentAI = GameAIs[.Standard]
            
            case .Rotating4:
                CurrentAI = GameAIs[.Rotating4]
            
            case .SemiRotating:
                CurrentAI = GameAIs[.Rotating4]
            
            case .Cubic:
                CurrentAI = GameAIs[.Cubic]
        }
        
        CurrentAI!.Initialize(WithBoard: GameBoard!)
    }
    
    /// The current AI.
    private var CurrentAI: AIProtocol? = nil
    
    /// Dictionary of AI types arranged by base game type.
    private var GameAIs: [AITypes: AIProtocol]!
    
    /// Holds the game board.
    public weak var GameBoard: Board? = nil
    
    /// Get or set the motion queue from the current AI.
    public var MotionQueue: Queue<Directions>
    {
        get
        {
            return CurrentAI!.MotionQueue
        }
        set
        {
            CurrentAI?.MotionQueue = newValue
        }
    }
    
    /// Dump the contents of the motion queue.
    /// - Note: The queue itself is not emptied by this function.
    /// - Returns: Array of directions from the motion queue.
    public func DumpMotionQueue() -> [Directions]
    {
        return (CurrentAI?.DumpMotionQueue())!
    }
    
    /// Get the next direction from the motion queue.
    /// - Returns: Next available direction from the motion queue.
    public func GetNextMotion() -> Directions
    {
        return (CurrentAI?.GetNextMotion())!
    }
    
    /// Holds the scoring method.
    private var _AIScoringMethod: AIScoringMethods = .OffsetMapping
    /// Get or set the AI scoring method.
    public var CurrentScoringMethod: AIScoringMethods
    {
        get
        {
            return _AIScoringMethod
        }
        set
        {
            _AIScoringMethod = newValue
        }
    }
    
    /// Find the best fit for the passed game piece. Returns the best fit score. This function also populates the `MotionQueue`.
    ///
    /// - Note: This is a monolithic function that won't return until the best fit is determined. You can use
    ///         `StepAI` to step through best fit calculations one offset/rotation combination at a time.
    ///
    /// - Parameters:
    ///   - GamePiece: The piece to find the best fit for.
    ///   - CurrentScore: The current score of the game.
    ///   - InBoard: The board used to find the bet fit. Used by **.Rotating4** and ignored by other AIs.
    /// - Returns: The final, best score of the piece.
    public func BestFit(_ GamePiece: Piece, CurrentScore: Int, InBoard: Board) -> Double
    {
        _BestFitFor = GamePiece
        LastPieceID = GamePiece.ID
        let Value = ((CurrentAI?.BestFit(GamePiece, CurrentScore: CurrentScore, InBoard: InBoard))!)
        return Value
    }
    
    /// Holds the game piece the last best fit result was generated for.
    private weak var _BestFitFor: Piece? = nil
    /// Get the piece the best fit was found for.
    public weak var FoundBestFitFor: Piece?
    {
        get
        {
            return _BestFitFor
            //return CurrentAI?.FoundBestFitFor
        }
    }
    
    /// The ID of the last piece whose position was calculated.
    public var LastPieceID: UUID = UUID.Empty
}

/// Scoring methods available to the AI.
///
/// - MeanLocation: Calculate the mean location of the locations of the points. Higher mean values are better than lower mean values.
/// - ClosestToBottom: The score is essentially the Y position of the block (or blocks) closest to the bottom of the bucket.
/// - UniqueClosestToBottom: Mean of unique Y positions where larger means are better than smaller means.
/// - NeighborCount: Number of neighbors each piece has (including shared neighbors).
/// - WeightedBottom: Method by which blocks in pieces closer to the bottom generate a higher score.
enum AIScoringMethods: Int, CaseIterable
{
    case MeanLocation = 0
    case ClosestToBottom = 1
    case UniqueClosestToBottom = 2
    case NeighborCount = 3
    case WeightedBottom = 4
    case MeanWithMinimalGap = 5
    case OffsetMapping = 6
    case NeighborCount2 = 7
}
