//
//  GameLogic.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements the high-level logic and infrastructure for the game. This class is the highest level class that doesn't
/// care about the UI (very much). This is the class that controls the board. The board controls the map (and the map
/// controls the scoring) and pieces in the map. This class also runs the AI in attract mode. When a UI event needs to
/// take place, the piece or board (or AI or whatever) calls upwards to this class, which then passes the need for a UI
/// event to the actual UI to take place.
class GameLogic
{
    /// Delegate to the game UI. Used to let the UI know of game state changes.
    weak var UIDelegate: GameUINotificationProtocol? = nil
    
    /// Delegate to the game AI. Used to let the UI know of AI actions.
    weak var AIDelegate: GameAINotificationProtocol? = nil
    
    /// Reference to the game board.
    var _GameBoard: Board? = nil
    
    /// The "AI" to run in attract mode (or perhaps in "play against the computer" mode).
    var AI: MainAI? = nil
    
    /// Initializer. The game board is created here.
    ///
    /// - Parameters
    ///   - Parameter WithGameCount: If provided, the game sequence value (eg, number of times played).
    ///   - Parameter BaseGame: The base game type.
    ///   - Parameter EnableAI: The AI is enabled as per the passed value.
    init(WithGameCount: Int? = nil, BaseGame: BaseGameTypes, EnableAI: Bool)
    {
        _BaseGameType = BaseGame
        _HighScore = 0

        if let InitialCount = WithGameCount
        {
            GameCount = InitialCount
        }
        else
        {
            GameCount = 0
        }
        self.EnableAI = EnableAI
        MakeBoard([.Standard], Level: nil)
        AI = MainAI()
        AI?.Start(WithBoard: GameBoard!, BaseGame: BaseGame)
    }
    
    /// Deinitializer. Shut down the master timer.
    deinit
    {
        AI = nil
    }
    
    /// Holds the base game type value.
    private var _BaseGameType: BaseGameTypes = .Standard
    /// Get the base game type. Can be set only during initialization.
    public var BaseGameType: BaseGameTypes
    {
        get
        {
            return _BaseGameType
        }
    }
    
    /// Holds the fast AI flag.
    private var _FastAI: Bool = false
    /// Get or set the fast AI flag. If true, dropping speeds are close to zero to make things go faster.
    public var FastAI: Bool
    {
        get
        {
            return _FastAI
        }
        set
        {
            _FastAI = newValue
        }
    }
    
    /// Get or set the AI scoring method.
    public var AIScoringMethod: AIScoringMethods
    {
        get
        {
            return AI!.CurrentScoringMethod
        }
        set
        {
            AI!.CurrentScoringMethod = newValue
        }
    }
    
    /// Holds the enable AI value.
    private var _EnableAI: Bool = false
    /// Enable or disable AI activities.
    public var EnableAI: Bool
    {
        get
        {
            return _EnableAI
        }
        set
        {
            _EnableAI = newValue
        }
    }
    
    /// Holds the current game count.
    private var _GameCount: Int = 0
    /// Get or set the game count.
    public var GameCount: Int
    {
        get
        {
            return _GameCount
        }
        set
        {
            _GameCount = newValue
        }
    }
    
    /// Holds the current game state.
    private var _GameState: GameStates = .Stopped
    /// Get the current game state.
    public var GameState: GameStates
    {
        get
        {
            return _GameState
        }
    }
    
    /// Start the game. The game board is created in the initializer.
    ///
    /// - Parameters:
    ///   - EnableAI: Enable AI flag. Set to true to run the game in attract mode.
    ///   - PieceCategories: Valid pieces for the game. Cannot change once the game starts until a new game starts.
    ///   - UseFastAI: Determines if a fast drop time is used when running in AI mode.
    func StartGame(EnableAI: Bool = false, PieceCategories: [MetaPieces] = [MetaPieces.Standard],
                   UseFastAI: Bool = false)
    {
        GameBoard?.ResetMap()
        LargestBlockCount = 4
        CumulativeBlockCount = 0
        ScoringStartTime = CACurrentMediaTime()
        _PiecesInGame = 1       //Start at 1...
        GameBoard?.BoardStopped = false
        GameStartTime = CACurrentMediaTime()
        GameEndTime = nil
        self.EnableAI = EnableAI
        _CurrentGameScore = 0
        GameBoard?.PlayMode = .Normal
        SpawnNewPiece = true
        _GameState = .Playing
        let _ = GameBoard?.StartNewPiece(CalledFrom: "GameLogic: StartGame(Bool, [MetaPieces])")
        FastAI = UseFastAI
        if FastAI && EnableAI
        {
            GameBoard?.EnableFastAI(true)
        }
        else
        {
            GameBoard?.EnableFastAI(false) 
        }
    }
    
    /// Game start time.
    var GameStartTime: Double = 0.0
    
    /// Game end time. If nil, the game hasn't ended yet.
    var GameEndTime: Double? = nil
    
    /// Returns the duration of the game.
    ///
    /// - Note: If the game is ongoing, the duration returned is from the start of the game to the call time. If the game hasn't
    ///         started, 0.0 is returned.
    ///
    /// - Returns: The duration of the game.
    func GameDuration() -> Double
    {
        if GameStartTime == 0.0
        {
            return 0.0
        }
        if let EndTime = GameEndTime
        {
            return EndTime - GameStartTime
        }
        return CACurrentMediaTime() - GameStartTime
    }
    
    /// Start a game in stepping mode.
    ///
    /// - Parameter MakeNewBoard: If true a new game board will be created. If false, the current board will be used.
    func StepGame(MakeNewBoard: Bool)
    {
        if MakeNewBoard
        {
            MakeBoard([MetaPieces.Standard])
        }
        GameBoard?.PlayMode = .Step
        _GameState = .Playing
        GameBoard?.StartNewPiece(CalledFrom: "GameLogic: StepGame")
    }
    
    /// Execute one step in the game. Not currently implemented.
    func ExecuteGameStep()
    {
        
    }
    
    /// Stop the game.
    func StopGame()
    {
        _GameState = .Stopped
        GameBoard?.Stop()
    }
    
    /// Sets a list of valid motions for the piece.
    ///
    /// - Note: Will be superceded by Level management.
    ///
    /// - Parameter Valid: List of valid motions.
    func SetValidBlockMotions(_ Valid: [Directions])
    {
        GameBoard?.SetValidMotions(Valid)
    }
    
    /// Holds the spawn new piece flag.
    private var _SpawnNewPiece: Bool = true
    /// Get or set the spawn new piece flag. Used for stepping during debugging.
    public var SpawnNewPiece: Bool
    {
        get
        {
            return _SpawnNewPiece
        }
        set
        {
            _SpawnNewPiece = newValue
        }
    }
    
    /// Pause the game.
    func PauseGame()
    {
        DebugClient.Send("Game paused.")
        _GameState = .Paused
        GameBoard?.Pause()
        StopAIMotionTimer()
    }
    
    /// Resume the game from where it was paused.
    func ResumeGame()
    {
        DebugClient.Send("Game resumed")
        _GameState = .Playing
        GameBoard?.Resume()
        StartAIMotionTimer()
    }
    
    /// Returns true if a board is in place, false if not.
    var HaveBoard: Bool
    {
        get
        {
            return GameBoard != nil
        }
    }
    
    /// Remove the board.
    func RemoveBoard(_ CalledFrom: String)
    {
        //print("Setting GameBoard to nil in RemoveBoard - called from \(CalledFrom)")
        GameBoard = nil
    }
    
    /// Resets the board and removes all pieces. Sets game state to stopped.
    func ResetBoard()
    {
        InAutoPlay = false
        MakeBoard()
        //GameBoard?.Reset()
        _GameState = .Stopped
    }
    
    /// Create a game board.
    ///
    /// - Parameters:
    ///   - Categories: Valid piece categories.
    ///   - Level: Describes the level to use.
    func MakeBoard(_ Categories: [MetaPieces] = [MetaPieces.Standard], Level: GameLevelDescription? = nil)
    {
        var BWidth = 12
        var BHeight = 30
        switch BaseGameType
        {
            case .Standard:
                BWidth = 12
                BHeight = 30
            
            case .Rotating4:
                BWidth = 36
                BHeight = 36
            
            case .Cubic:
                break
        }
        GameCount = GameCount + 1
        GameBoard = Board(BoardID: UUID(), Sequence: GameCount, TheGame: self, WithLevel: Level,
                          BaseGame: BaseGameType, BoardWidth: BWidth, BoardHeight: BHeight)
    }
    
    /// Get or set the game board.
    public var GameBoard: Board?
    {
        get
        {
            return _GameBoard
        }
        set
        {
            _GameBoard = newValue
        }
    }
    
    /// Called when a game piece is frozen.
    ///
    /// - Parameter ID: ID of the frozen piece.
    func PieceUpdated(ID: UUID)
    {
        UIDelegate?.MapUpdated()
    }
    
    /// Called when a game piece is moved.
    /// - Parameter WithPiece: The piece that moved.
    /// - Parameter XOffset: The delta horizontal motion value.
    /// - Parameter YOffset: The delta vertical motion value.
    func PieceUpdated2(_ WithPiece: Piece, _ XOffset: Int, _ YOffset: Int)
    {
        UIDelegate?.MapUpdated()
        UIDelegate?.PieceUpdated(WithPiece, X: XOffset, Y: YOffset)
    }
    
    // MARK: Game logic protocol implementations
    
    /// Called when a piece is successfully moved.
    ///
    /// - Parameters:
    ///   - MovedPiece: The piece that moved.
    ///   - Direction: The direction the piece moved.
    ///   - Commanded: True if the piece was commanded to move, false if gravity caused the movement.
    func PieceMoved(_ MovedPiece: Piece, Direction: Directions, Commanded: Bool)
    {
        #if true
        switch BaseGameType
        {
            case .Standard:
            UIDelegate?.PieceMoved(MovedPiece, Direction: Direction, Commanded: Commanded)
            
            case .Rotating4:
                UIDelegate?.PieceMoved3D(MovedPiece, Direction: Direction, Commanded: Commanded)
            
            case .Cubic:
            UIDelegate?.PieceMoved(MovedPiece, Direction: Direction, Commanded: Commanded)
        }
        
        #else
        if BaseGameType == .Rotating4
        {
            var XDelta = 0
            var YDelta = 0
            switch Direction
            {
                case .Down:
                    YDelta = 1
                
                case .Up:
                    YDelta = -1
                
                case .Left:
                    XDelta = 1
                
                case .Right:
                    XDelta = -1
                
                default:
                    break
            }
            if XDelta == 0 || YDelta == 0
            {
                return
            }
            UIDelegate?.SmoothMove(MovedPiece, ToOffsetX: XDelta, ToOffsetY: YDelta)
        }
        else
        {
            UIDelegate?.PieceMoved(MovedPiece, Direction: Direction, Commanded: Commanded)
        }
        #endif
    }
    
    /// Called when a piece has frozen into place. Start dropping a new piece. By this point, the dropped piece
    /// has been merged into the bucket retired piece set and can be removed as an independent object.
    ///
    /// - Parameter ThePiece: The piece that was frozen into place.
    func DropFinalized(_ ThePiece: Piece)
    {
        switch BaseGameType
        {
            case .Standard:
                _CurrentGameScore = GameBoard!.Map!.Scorer!.Current
            
            case .Rotating4:
                var BlockCount = ThePiece.Locations.count
                if BlockCount >= LargestBlockCount
                {
                    LargestBlockCount = BlockCount + 1
                }
                if BlockCount < 1
                {
                    BlockCount = 1
                }
                CumulativeBlockCount = CumulativeBlockCount + ThePiece.Locations.count
                let NewTime = CACurrentMediaTime() - ScoringStartTime
                let TimeAdder = Int(NewTime / (Double(LargestBlockCount) - Double(BlockCount)))
                _CurrentGameScore = _CurrentGameScore + ThePiece.Locations.count + TimeAdder
            
            case .Cubic:
                _CurrentGameScore = _CurrentGameScore + 1
        }
        UIDelegate?.PieceFinalized(ThePiece) 
        if SpawnNewPiece && BaseGameType != .Rotating4
        {
            DoSpawnNewPiece()
            //GameBoard?.StartNewPiece(CalledFrom: "GameLogic: DropFinalized")
            //_PiecesInGame = _PiecesInGame + 1
        }
    }
    
    var CumulativeBlockCount: Int = 0
    var ScoringStartTime: Double = 0
    var LargestBlockCount = 4
    
    /// Spawn a new piece here. Should be call only when the previous piece has been frozen.
    func DoSpawnNewPiece()
    {
        GameBoard?.StartNewPiece(CalledFrom: "GameLogic: DoSpawnNewPiece")
        _PiecesInGame = _PiecesInGame + 1
    }
    
    /// Called to discard a piece.
    func DiscardPiece(_ ThePiece: Piece)
    {
        /// Not currently implemented.
    }
    
    /// Called by child classes to set the opacity level of the current piece.
    ///
    /// - Note: This is probably better changed to something higher-level, such as
    ///         "VisuallyRemovePiece" or the like.
    ///
    /// - Parameters:
    ///   - To: New opacity level.
    ///   - ID: ID of the piece whose opacity will be changed.
    func SetPieceOpacity(To: Double, ID: UUID)
    {
        UIDelegate?.SetPieceOpacity(To: To, ID: ID)
    }
    
    func SetPieceOpacity(To: Double, ID: UUID, Duration: Double)
    {
        UIDelegate?.SetPieceOpacity(To: To, ID: ID, Duration: Duration)
    }
    
    /// Event for after a piece has been discarded and is no longer available.
    ///
    /// - Parameter OfPiece: The ID of the piece that was discarded.
    func CompletedDiscard(OfPiece: UUID)
    {
        UIDelegate?.PieceDiscarded(OfPiece)
        if SpawnNewPiece
        {
            GameBoard?.StartNewPiece(CalledFrom: "GameLogic: CompletedDiscard")
            _PiecesInGame = _PiecesInGame + 1
        }
    }
    
    /// Called when a new score is available after a piece is finalized.
    ///
    /// - Parameters:
    ///   - ID: ID of the finalized piece.
    ///   - Score: New game score.
    func ScoreWithPiece(ID: UUID, Score: Int)
    {
        UIDelegate?.FinalizedPieceScore(ID: ID, Score: Score)
    }
    
    /// Holds the number of pieces used in the game so far.
    private var _PiecesInGame: Int = 0
    /// Get the number of pieces used in the game.
    public var PiecesInGame: Int
    {
        get
        {
            return _PiecesInGame
        }
    }
    
    /// Called when a piece is frozen with at least part of it out of bounds. Indicates a game over
    /// condition.
    ///
    /// - Parameter ID: ID of the frozen piece.
    func StoppedOutOfBounds(ID: UUID)
    {
        //Game over...
        _CurrentGameScore = GameBoard!.Map!.Scorer!.Current
        UIDelegate?.OutOfBounds(ID) 
        _GameState = .Stopped
        UIDelegate?.GameOver()
    }
    
    /// Called when a piece has started freezing (but not yet frozen).
    ///
    /// - Parameter ID: ID of the piece that started freezing.
    func StartedFreezing(_ ID: UUID)
    {
        UIDelegate?.StartedFreezing(ID)
    }
    
    /// Called when a piece that had started to freeze was moved and is no longer frozen.
    /// - Parameter ID: ID of the piece that is no longer freezing.
    func StoppedFreezing(_ ID: UUID)
    {
        UIDelegate?.StoppedFreezing(ID)
    }
    
    /// Holds the current game score. When set, sends a message to the UI with the new score. Updates the
    /// highs score every time the current score is set (provided the current score is greater than the
    /// highs score).
    private var _CurrentGameScore: Int = 0
    {
        didSet
        {
            UIDelegate?.NewGameScore(NewScore: _CurrentGameScore)
            if _CurrentGameScore > _HighScore
            {
                _HighScore = _CurrentGameScore  
            }
        }
    }
    /// Get the current game score.
    public var CurrentGameScore: Int
    {
        get
        {
            return _CurrentGameScore
        }
    }
    
    /// Holds the highs core value. When set, sends a message to the UI.
    private var _HighScore: Int = 0
    {
        didSet
        {
            UIDelegate?.NewHighScore(HighScore: _HighScore)
        }
    }
    /// Get or set the high score value.
    public var HighScore: Int
    {
        get
        {
            return _HighScore
        }
        set
        {
            _HighScore = newValue
        }
    }
    
    /// The board notified us we have a new piece. Notify the UI.
    ///
    /// - Note: If we're in AI mode, find the best fit and start the AI motion timer (which retrieves motions from the AI for
    ///         the new piece periodically.
    ///
    /// - Parameter NewPiece: The new piece to drop.
    func HaveNewPiece(_ NewPiece: Piece)
    {
        UIDelegate?.NewPieceStarted(NewPiece)
        if EnableAI
        {
            //Get the best fit location for the piece.
            AIScoreForPiece = (AI!.BestFit(NewPiece, CurrentScore: CurrentGameScore, InBoard: GameBoard!))
            UIDelegate?.PieceScoreUpdated(For: NewPiece.ID, NewScore: Int(AIScoreForPiece))
            //Move the piece to the proper location. Do this by running a timer that repeats until the AI's motion queue is empty.
            StartAIMotionTimer()
        }
    }
    
    /// Starts the AI motion timer.
    /// - Note:
    ///   - In some games, the AI timer was not called on the main run loop. This caused the AI to appear to be non-responsive
    ///     (when in fact it was working correctly). Putting the call in a **DisplatchQueue.main.async** solved the problem.
    ///   - [Timer.scheduledTimer does not work in Swift 3](https://stackoverflow.com/questions/40613556/timer-scheduledtimer-does-not-work-in-swift-3)
    func StartAIMotionTimer()
    {
        if EnableAI
        {
            if AITimer != nil
            {
                AITimer?.invalidate()
                AITimer = nil
            }
            let Duration = _FastAI ? 0.01 : 0.1
            DispatchQueue.main.async
                {
                    self.AITimer = Timer.scheduledTimer(timeInterval: Duration, target: self, selector: #selector(self.GetAIMotion),
                                           userInfo: nil, repeats: true)
            }
        }
    }
    
    /// Stops the AI motion timer.
    func StopAIMotionTimer()
    {
        if EnableAI
        {
            if AITimer != nil
            {
                AITimer?.invalidate()
                AITimer = nil
            }
        }
    }
    
    /// The score for the piece as per the AI.
    var AIScoreForPiece: Double = 0
    
    /// Get an AI motion to execute. Motions are in the AI motion queue.
    @objc func GetAIMotion()
    {
        let NextMotion = AI?.GetNextMotion()
        if NextMotion! == Directions.NoDirection
        {
            _CurrentGameScore = GameBoard!.Map!.Scorer!.Current
            StopAIMotionTimer()
            return
        }
        #if true
        let AIPieceID = AI!.LastPieceID
        #else
        let AIPiece: Piece = AI!.FoundBestFitFor!
        let AIPieceID: UUID = AIPiece.ID
        #endif
        GameBoard?.InputFor(ID: AIPieceID, Direction: NextMotion!)
        if Settings.ShowAIUICommands()
        {
           ShowAICommandsOnUI(Motion: NextMotion!)
        }
    }
    
    /// Use the UI to show the commands from the AI for moving a block.
    /// - Parameter Motion: The command motion from the AI.
    func ShowAICommandsOnUI(Motion: Directions)
    {
        switch Motion
        {
            case .Down:
                AIDelegate?.AI_MoveDown()
            
            case .DropDown:
                AIDelegate?.AI_DropDown()
            
            case .Up:
                AIDelegate?.AI_MoveUp()
            
            case .UpAndAway:
                AIDelegate?.AI_MoveUpAndAway()
            
            case .Right:
                AIDelegate?.AI_MoveRight()
            
            case .Left:
                AIDelegate?.AI_MoveLeft()
            
            case .RotateLeft:
                AIDelegate?.AI_RotateLeft()
            
            case .RotateRight:
                AIDelegate?.AI_RotateRight()
            
            default:
                break
        }
    }
    
    /// Timer that controls how often to retrieve a motion from the AI when the game is under the control of the AI.
    var AITimer: Timer? = nil
    
    /// Turns on or off gravity. Mainly used for debugging but can also be used for special game effects. Control flows
    /// from the UI to the game (here), board, then piece (which is where gravity actually takes place).
    ///
    /// - Parameter Enabled: Determines if the gravity is on or off.
    func SetGravitation(_ Enabled: Bool)
    {
        GameBoard!.SetGravitation(Enabled)
    }
    
    /// Called when a piece is blocked (either in motion or rotation). Pass the notification to the UI.
    ///
    /// - Parameter ID: ID of the piece that cannot move.
    func PieceCannotMove(ID: UUID)
    {
        UIDelegate?.PieceBlocked(ID)
    }
    
    /// Called when a piece was successfully rotated. Pass the notification to the UI.
    ///
    /// - Parameters:
    ///   - ID: ID of the rotated piece.
    ///   - Direction: The direction the piece rotated.
    func PieceRotated(ID: UUID, Direction: Directions)
    {
        UIDelegate?.PieceRotated(ID: ID, Direction: Direction)
    }
    
    /// Called when a piece tried to rotate but failed.
    ///
    /// - Parameters:
    ///   - ID: ID of the piece that failed rotation.
    ///   - Direction: The rotational direction that was attempted.
    func RotationFailure(ID: UUID, Direction: Directions)
    {
        UIDelegate?.PieceRotationFailure(ID: ID, Direction: Direction)
    }
    
    /// Pass input from the UI to the game board.
    ///
    /// - Note: If AI is enabled, input from the UI is ignored.
    ///
    /// - Parameters:
    ///   - ID: ID of the piece the input is intended for.
    ///   - Input: Type of input.
    func HandleInputFor(ID: UUID, Input: Directions)
    {
        if EnableAI
        {
            return
        }
        GameBoard?.InputFor(ID: ID, Direction: Input)
    }
    
    /// Holds the ID of the current piece.
    private var _CurrentPiece: UUID? = nil
    /// Get or set the ID of the current piece.
    public var CurrentPiece: UUID?
    {
        get
        {
            return GameBoard?.CurrentPiece
        }
        set
        {
            GameBoard?.CurrentPiece = newValue
        }
    }
    
    /// Called when a row was deleted by the board. Pass the notification to the UI.
    ///
    /// - Parameter Row: Index of the row that was deleted.
    func RowDeleted(_ Row: Int)
    {
        UIDelegate?.DeletedRow(Row)
        RowDeletionCount = RowDeletionCount + 1
    }
    
    var RowDeletionCount: Int = 0
    
    /// Received column dropped message. Pass to UI.
    ///
    /// - Note: This message is sent for each column dropped.
    ///
    /// - Parameter Column: The index of the column that was dropped.
    func ColumnDropped(Column: Int)
    {
        UIDelegate?.ColumnDropped(Column: Column)
    }
    
    /// Received board done compressing message. Pass to UI.
    ///
    /// - Parameter DidCompress: If true, the board actually compressed (meaning there were blocks removed). If
    ///                          false, the board's contents are the same (other than for game pieces in play).
    func BoardDoneCompressing(DidCompress: Bool)
    {
        UIDelegate?.BoardDoneCompressing(DidCompress: DidCompress)
        //_CurrentGameScore = _CurrentGameScore + (RowDeletionCount * 500)
        //RowDeletionCount = 0
    }
    
    /// Received column will drop message. Pass to UI.
    ///
    /// - Parameters:
    ///   - Column: The column index.
    ///   - From: From row...
    ///   - ToTarget: ...to row.
    func DropColumn(Column: Int, From: Int, ToTarget: Int)
    {
        UIDelegate?.DropColumn(Column: Column, From: From, ToTarget: ToTarget)
    }
    
    /// Play the game by ourself using little or no intelligence and lots of randomness.
    func AutoPlay()
    {
        ResetBoard()
        InAutoPlay = true
    }
    
    /// Holds the in auto play flag.
    var InAutoPlay: Bool = false
    
    /// Pass along the piece-ran-over-a-special-button event to the UI.
    ///
    /// - Parameters:
    ///   - ID: ID of the item that ran over the speical button.
    ///   - Item: Description of the special item.
    ///   - At: Location of the special item.
    func PieceIntersectedItem(ID: UUID, Item: PieceTypes, At: CGPoint)
    {
        UIDelegate?.PieceIntersectedWith(Item: Item, At: At, ID: ID)
        GameBoard!.Map!.RemoveItemAt(Location: At)
    }
    
    /// Pass along the piece-ran-over-a-special-button event to the UI.
    ///
    /// - Parameters:
    ///   - ID: ID of the item that ran over the speical button.
    ///   - Item: ID of the special item.
    ///   - At: Location of the special item.
    func PieceIntersectedItemX(ID: UUID, Item: UUID, At: CGPoint)
    {
        UIDelegate?.PieceIntersectedWithX(Item: Item, At: At, ID: ID)
        GameBoard!.Map!.RemoveItemAt(Location: At)
    }
    
    /// Pass general board contents changed event to the UI.
    func BoardContentsChanged()
    {
        UIDelegate?.MapUpdated()
    }
    
    /// Set the piece factory queue to have the first shape each game.
    /// - Parameter ToOn: Determines whether the predetermined first shape will be used or not.
    /// - Parameter FirstIs: The first shape to use if **ToOn** is true.
    func SetPredeterminedOrder(_ ToOn: Bool, FirstIs: PieceShapes)
    {
        GameBoard?.Factory?.SetPredeterminedOrder(ToOn, WithFirst: FirstIs)
    }
    
    /// Return the current value of the game map as a string.
    ///
    /// - Parameter WithPieces: If true, all pieces (falling or otherwise) are included in the returned map.
    /// - Returns: String representation of the game map. Column and row headers are included.
    func DumpMap(WithPieces: Bool = false) -> String
    {
        let MapString = MapType.PrettyPrint(Map: GameBoard!.Map!)
        return MapString
    }
    
    /// Called when a piece moves or is rotated. Used to indicate potentially different scores of the piece.
    ///
    /// - Parameters:
    ///   - ForPiece: The piece to update the score for.
    func UpdatePieceScore(ForPiece: Piece)
    {
        #if false
        let End = CACurrentMediaTime() - Start
        UIDelegate?.PieceScoreUpdated(For: ForPiece.ParentID, NewScore: Int(NewScore!))
        #endif
    }
    
    /// Pass the name of the next piece to the UI.
    ///
    /// - Parameter Next: Name of the next piece after the current piece.
    func NextPiece(_ Next: Piece)
    {
        UIDelegate?.NextPiece(Next)
    }
    
    /// Returns the current board game scorer class.
    ///
    /// - Returns: Current board game scorer class.
    func GetScorer() -> Score
    {
        return GameBoard!.GetScorer()
    }
}

/// Possible game states.
///
/// - Stopped: Stopped. Game over or haven't started yet.
/// - Playing: Currently playing.
/// - Paused: Paused.
enum GameStates: Int, CaseIterable
{
    case Stopped = 0
    case Playing = 1
    case Paused = 2
}
