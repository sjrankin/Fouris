//
//  Board.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Maintains the board for the game. The board makes heavy use of the `Map` instance to maintain the location of various blocks
/// on the board. The board sits between the in-play piece(s) and the game instance.
class Board: GameMapProtocol
{
    func BucketChanged(X: Int, Y: Int, Node: MapNodes)
    {
        
    }
    
    func MapRotated(Right: Bool)
    {
        
    }
    
    func BucketRotated(By180: Bool)
    {
        
    }
    
    func RowDeleted(Row: Int)
    {
        
    }
    
    func GameMapReset()
    {
        
    }
    
    /// Reference to the owning game logic.
    weak var Game: GameLogic? = nil
    
    /// The piece factory.
    var Factory: PieceFactory? = nil
    
    /// The map of pieces on the board.
    var Map: MapType? = nil
    
    // MARK: - Initialization.

    #if true
    /// Initializer.
    /// - Parameters:
    ///   - BoardID: ID of the board.
    ///   - Sequence: Sequence (eg, number of games) for the game.
    ///   - TheGame: Reference to the game logic.
    ///   - BucketShape: Shape of the bucket.
    ///   - BoardWidth: Width of the board.
    ///   - BoardHeight: Height of the board.
    ///   - Scorer: Game scorer.
    init(BoardID: UUID, Sequence: Int, TheGame: GameLogic,
         BucketShape: BucketShapes, BoardWidth: Int, BoardHeight: Int)
    {
        _ID = BoardID
        Game = TheGame
        _GameCount = Sequence
        Factory = PieceFactory(5, Sequence: GameCount, PieceCategories: [.Standard])
        Map = MapType(Width: BoardWidth, Height: BoardHeight, ID: UUID(), BucketShape: BucketShape)
        _Width = BoardWidth
        _Height = BoardHeight
        _BucketTop = Map!.BucketTop
        BucketTopInterior = _BucketTop
        BucketBottom = Map!.BucketBottom
        BucketBottomInterior = Map!.BucketBottom - 1
        BucketInteriorLeft = Map!.BucketInteriorLeft
        BucketInteriorRight = Map!.BucketInteriorRight
        BucketInteriorWidth = Map!.BucketInteriorWidth
        BucketInteriorHeight = Map!.BucketInteriorHeight
        let BoardDef = BoardManager.GetBoardFor(BucketShape)!
    }
    #else
    /// Initializer.
    ///
    /// - Parameters:
    ///   - BoardID: ID of the board.
    ///   - Sequence: Sequence (eg, number of games) for the game.
    ///   - TheGame: Reference to the game logic.
    ///   - BaseGame: The base game type.
    ///   - BoardWidth: Width of the board.
    ///   - BoardHeight: Height of the board.
    ///   - Scorer: Game scorer.
    init(BoardID: UUID, Sequence: Int, TheGame: GameLogic,
         BaseGame: BaseGameTypes, BoardWidth: Int, BoardHeight: Int)
    {
        print("Creating board for \(BaseGame): Size=\(BoardWidth)x\(BoardHeight)")
        _ID = BoardID
        Game = TheGame
        _GameCount = Sequence
        Factory = PieceFactory(5, Sequence: GameCount, PieceCategories: [.Standard])
        Map = MapType(Width: BoardWidth, Height: BoardHeight, ID: UUID(), BaseType: BaseGame)
        _Width = BoardWidth
        _Height = BoardHeight
        _BucketTop = Map!.BucketTop
        BucketTopInterior = _BucketTop
        BucketBottom = Map!.BucketBottom
        BucketBottomInterior = Map!.BucketBottom - 1
        BucketInteriorLeft = Map!.BucketInteriorLeft
        BucketInteriorRight = Map!.BucketInteriorRight
        BucketInteriorWidth = Map!.BucketInteriorWidth
        BucketInteriorHeight = Map!.BucketInteriorHeight
        print("BucketInteriorLeft=\(BucketInteriorLeft), BucketInteriorRight=\(BucketInteriorRight)")
    }
    #endif
    
    /// Determines whether the passed point is fully in the bucket or not.
    /// - Parameter Point: The point to check against the current bucket configuration.
    /// - Returns: True if the point is in the bucket, false if not.
    public func PointInBucket(Point: CGPoint) -> Bool
    {
        if Int(Point.x) < BucketInteriorLeft
        {
            return false
        }
        if Int(Point.x) > BucketInteriorRight
        {
            return false
        }
        if Int(Point.y) < BucketTop
        {
            return false
        }
        if Int(Point.y) > BucketBottom
        {
            return false
        }
        return true
    }
    
    /// Reset the map. This makes it ready for a new game.
    public func ResetMap()
    {
        Map?.ResetMap()
        PreGapCount = 0
    }
    
    #if false
    /// Holds the current game type.
    private var _GameType: BaseGameTypes = .Standard
    /// Get the current game type. The only way to set this is during initialization.
    public var GameType: BaseGameTypes
    {
        get
        {
            return _GameType
        }
    }
    #endif
    
    /// Enables or disables fast AI dropping.
    /// - Parameter Enable: Determines whether fast dropping is used.
    public func EnableFastAI(_ Enable: Bool)
    {
        UseFastAI = Enable
    }
    
    private var UseFastAI: Bool = false
    
    /// Holds the play mode value.
    private var _PlayMode: PlayModes = .Normal
    /// Get or set the play mode.
    public var PlayMode: PlayModes
    {
        get
        {
            return _PlayMode
        }
        set
        {
            _PlayMode = newValue
        }
    }
    
    /// Holds the ID of the board.
    private var _ID: UUID = UUID()
    /// Get the ID of the board.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
    }
    
    /// Holds the game count.
    private var _GameCount: Int = 0
    /// Get the game count.
    public var GameCount: Int
    {
        get
        {
            return _GameCount
        }
    }
    
    /// Deinitialized the board. All pieces in play are terminated and deleted.
    deinit
    {
        Factory = nil
        Map = nil
    }
    
    var BucketTopInterior: Int = 0
    var BucketBottomInterior: Int = 0
    var BucketInteriorLeft: Int = 0
    var BucketInteriorRight: Int = 0
    var BucketInteriorWidth: Int = 0
    var BucketInteriorHeight: Int = 0
    var BucketBottom: Int = 0
    
    /// Resets the board score.
    func ResetScore()
    {
        Map!.Scorer!.Reset()
    }
    
    /// Reset the board to its original state. Clears the map and removes all pieces.
    func Reset()
    {
        Map!.InPlay.removeAll()
        Map!.ResetMap()
        Game?.BoardContentsChanged()
        PreGapCount = 0
    }
    
    /// Call to stop the board. Once stopped, the board should be deleted to play a new game.
    func Stop()
    {
        _BoardStopped = true
        Factory?.CleanUp()
        Map!.RemoveInPlayPieces()
    }
    
    /// Holds the board stopped flag.
    private var _BoardStopped: Bool = false
    /// Get the board stopped flag. If true, the board may not be restarted.
    public var BoardStopped: Bool
    {
        get
        {
            return _BoardStopped
        }
        set
        {
            _BoardStopped = newValue
        }
    }
    
    /// Holds the top of bucket value.
    private var _BucketTop: Int = 0
    /// Get the vertical value of the top (empty) of the bucket.
    public var BucketTop: Int
    {
        get
        {
            return _BucketTop
        }
    }
    
    /// Holds the width of the map.
    private var _Width: Int = 0
    /// Get the width of the map (invisible as well as visible).
    public var Width: Int
    {
        get
        {
            return _Width
        }
    }
    
    /// Holds the height of the map.
    private var _Height: Int = 0
    /// Get the height of the map (invisible as well as visible).
    public var Height: Int
    {
        get
        {
            return _Height
        }
    }
    
    /// Holds the current gravitational vector.
    private var _Gravity: CGVector = CGVector.zero
    /// Get or set the gravitional vector. Determines how strong and in what direction gravity is.
    public var Gravity: CGVector
    {
        get
        {
            return _Gravity
        }
        set
        {
            _Gravity = newValue
        }
    }
    
    /// Called by the master clock. Need to update whatever is in motion or needs to be updated.
    func Tick()
    {
        for SomePiece in Map!.InPlay
        {
            SomePiece?.Tick()
        }
    }
    
    /// Pause the game.
    func Pause()
    {
        OperationQueue.main.addOperation
            {
                for SomePiece in self.Map!.InPlay
                {
                    
                    SomePiece?.Pause()
                }
        }
    }
    
    /// Resume the game.
    func Resume()
    {
        OperationQueue.main.addOperation
            {
                for SomePiece in self.Map!.InPlay
                {
                    SomePiece?.Resume()
                }
        }
    }
    
    /// Enable or disable gravitation. This is done only for in-play pieces.
    ///
    /// - Parameter Enabled: The enable state for gravitation.
    func SetGravitation(_ Enabled: Bool)
    {
        OperationQueue.main.addOperation
            {
                for SomePiece in self.Map!.InPlay
                {
                    if Enabled
                    {
                        SomePiece?.StartDropping()
                    }
                    else
                    {
                        SomePiece?.StopGravity()
                    }
                }
        }
    }
    
    /// Called by a piece when it tried to rotate but failed.
    ///
    /// - Parameters:
    ///   - ID: The ID of the piece that failed rotation.
    ///   - Direction: The direction it tried to rotate.
    func RotationFailure(ID: UUID, Direction: Directions)
    {
        Game?.RotationFailure(ID: ID, Direction: Direction)
    }
    
    /// Called by a piece when it successfully rotated.
    ///
    /// - Parameters:
    ///   - ID: ID of the piece that rotated.
    ///   - Direction: The direction it rotated.
    func RotationSuccess(ID: UUID, Direction: Directions)
    {
        Game?.PieceRotated(ID: ID, Direction: Direction)
    }
    
    /// Determines if a block (eg, single point in a piece) can occupy the passed point.
    ///
    /// - Parameter At: The point to determine suitability for occupation.
    /// - Parameter Item: The blocking item.
    /// - Returns: True if the passed point is empty, false if not.
    func MapIsEmpty(At: CGPoint, Item: inout PieceTypes) -> Bool
    {
        return Map!.MapIsEmpty(At: At, BlockedBy: &Item)
    }
    
    /// Determines if a block (eg, single point in a piece) can occupy the passed point.
    ///
    /// - Parameter At: The point to determine suitability for occupation.
    /// - Returns: True if the passed point is empty, false if not.
    func MapIsEmpty(At: CGPoint) -> Bool
    {
        return Map!.MapIsEmpty(At: At)
    }
    
    /// Determines if a piece is fully in the bucket or not. Outside the bucket is determined by having at least one
    /// piece having a vertical value less than (eg, higher than) the top of the bucket.
    ///
    /// - Notes:
    ///   - Call only after the piece starts to freeze. This function calls a `Map` function that updates the score.
    ///   - This function is used to determine game over conditions. If a piece is frozen into place with at least
    ///     one block over the top of the bucket, game over conditions are met.
    ///
    /// - Parameter ThePiece: The piece to check for in-boundedness.
    /// - Returns: True if the passed piece is fully in the bucket, false if not.
    func PieceInBounds(_ ThePiece: Piece) -> Bool
    {
        return Map!.PieceInBounds(ThePiece)
    }
    
    /// Returns the Y value closest to the top of the bucket (eg, bucket entrance) for each column in the bucket.
    ///
    /// - Note: If there are no retired game pieces (or bucket parts) in a given column, the column's returned
    ///         value will be -1.
    ///
    /// - Returns: Dictionary of columns and highest occupied locations, eg, [Column: Row].
    public func HighestOccupiedLocations() -> [Int: Int]
    {
        return Map!.HighestOccupiedLocations()
    }
    
    /// Spawns a new piece. Assigns its initial location. Start the piece's gravity.
    /// - Returns: ID of the new piece.
    @discardableResult func StartNewPiece2() -> UUID
    {
        if BoardStopped
        {
            return UUID.Empty
        }
        PerformanceData.removeAll()
        let StartingTime = CACurrentMediaTime()
        
        var NewPiece: Piece!
        let QueueStart = CACurrentMediaTime()
        NewPiece = (Factory?.GetQueuedPiece(ForBoard: self))!
        PerformanceData.append(("GetQueuedPiece duration", CACurrentMediaTime() - QueueStart))
        
        let PieceInit = CACurrentMediaTime()
        NewPiece.GravityIsEnabled = PiecesUseGravity
        NewPiece.PlayMode = PlayMode
        let StartingPoint = Map!.GetPieceStartingPoint(ForPiece: NewPiece)
        print("StartingPoint=\(StartingPoint)")
        let StartX = Int(StartingPoint.x)
        let StartY = Int(StartingPoint.y)
        NewPiece.SetStartLocation(X: StartX, Y: StartY)
        Map!.InPlay.append(NewPiece)
        NewPiece.SetFastGravity(UseFastAI)
        NewPiece.StartDropping()
        if PlayMode == .Step
        {
            NewPiece.UpdateLocation(XDelta: 0, YDelta: 0)
        }
        PerformanceData.append(("New piece initialization", CACurrentMediaTime() - PieceInit))
        
        let AddIDStart = CACurrentMediaTime()
        Map!.IDMap!.AddID(NewPiece.ID, ForPiece: .GamePiece)
        PerformanceData.append(("Add ID", CACurrentMediaTime() - AddIDStart))
        let CallOut = CACurrentMediaTime()
        Game?.HaveNewPiece(NewPiece)
        PerformanceData.append(("HaveNewPiece callout",CACurrentMediaTime() - CallOut))
        let RemoveIDsStart = CACurrentMediaTime()
        Map!.IDMap!.RemoveUnusedIDs(BoardMap: Map!.Contents, ButNotThese: [NewPiece.ID])
        PerformanceData.append(("Remove unused IDs", CACurrentMediaTime() - RemoveIDsStart))
        PreGapCount = PostGapCount
        Map!.RetiredPieceShapes[NewPiece.ID] = NewPiece.ShapeID
        
        //Now, get the next piece to show to the user.
        let NextPieceStart = CACurrentMediaTime()
        let Next: Piece = (Factory?.GetNextPiece())!
        Game?.NextPiece(Next)
        PerformanceData.append(("Get next piece", CACurrentMediaTime() - NextPieceStart))
        
        PerformanceData.insert(("StartNewPiece2 Duration", CACurrentMediaTime() - StartingTime), at: 0)
        
        return NewPiece.ID
    }
    
    public var PerformanceData: [(String, Double)] = [(String, Double)]()
    
    /// Reset the piece to a new random piece.
    func ResetPiece()
    {
        Map!.RemoveInPlayPieces()
        StartNewPiece2()
    }
    
    /// Called by a piece when it cannot move in the requested direction.
    ///
    /// - Parameter ID: ID of the piece that cannot move.
    func CannotMove(ID: UUID)
    {
        Game?.PieceCannotMove(ID: ID)
    }
    
    func DiscardPiece(_ ThePiece: Piece)
    {
        Game?.DiscardPiece(ThePiece)
        let PieceID = ThePiece.ID
        //Delete the piece (use DeleteFrozen even though the piece isn't frozen and not scored).
        DeleteFrozen(ThePiece.ID)
        Game?.CompletedDiscard(OfPiece: PieceID)
    }
    
    func SetPieceOpacity(To: Double, ID: UUID)
    {
        Game?.SetPieceOpacity(To: To, ID: ID)
    }
    
    public func SetPieceOpacity(GamePiece: Piece, To: Double, Duration: Double)
    {
        Game?.SetPieceOpacity(To: To, ID: GamePiece.ID, Duration: Duration)
    }
    
    var DroppedID: UUID = UUID.Empty
    
    func DroppedTooFar(_ GamePiece: Piece)
    {
        if GamePiece.ID != DroppedID
        {
            DroppedID = GamePiece.ID
            print("GamePiece \(GamePiece.ID) dropped too far.")
        }
    }
    
    /// Called by a piece when it moves successfully to a new location.
    ///
    /// - Parameter ID: ID of the piece that moved.
    func NewLocation(ID: UUID)
    {
        Game?.PieceUpdated(ID: ID)
        CheckForSpecialItems(ID)
        UpdatePieceScore(ID)
    }
    
    func NewLocation2(ForPiece: Piece, XOffset: Int, YOffset: Int)
    {
        Game?.PieceUpdated2(ForPiece, XOffset, YOffset) 
        CheckForSpecialItems(ForPiece.ID)
        //UpdatePieceScore(ForPiece.ID)
    }
    
    /// Return a merged map with all current pieces merged into the background map.
    ///
    /// - Returns: Map of the board with all current pieces.
    func MergedMap() -> MapType.ContentsType
    {
        return Map!.MergeMap()
    }
    
    /// See if there are any special items (Action buttons or Danger buttons) underneath the piece whose
    /// ID is passed to us. If there are, notify the game logic.
    ///
    /// - Parameter ID: ID of the piece that determines the positions in the map to check.
    func CheckForSpecialItems(_ ID: UUID)
    {
        if let ThePiece = GetPiece(ID: ID)
        {
            for SomeBlock in ThePiece.Locations
            {
                let MapItem = Map![SomeBlock.Y, SomeBlock.X]
                if Map!.IDMap!.IsSpecialType(MapItem!)
                {
                    Game?.PieceIntersectedItemX(ID: ID, Item: MapItem!, At: CGPoint(x: SomeBlock.X, y: SomeBlock.Y))
                }
            }
        }
    }
    
    /// Called by a piece when it stopped/froze out of bounds. Signals game over.
    /// - Note: **Game over determination occurs here.**
    /// - Parameter ID: ID of the piece that froze (at least partially) out of bounds.
    func StoppedOutOfBounds(ID: UUID)
    {
        GameOverCleanUp()
        Game?.StoppedOutOfBounds(ID: ID)
    }
    
    /// Call the game to let it know a piece started freezing (but isn't frozen yet).
    /// - Parameter ID: The ID of the piece that started to freeze.
    func StartedFreezing(_ ID: UUID)
    {
        Game?.StartedFreezing(ID)
    }
    
    /// Call the game to let it know a piece that had started to freeze was moved and is no longer
    /// frozen.
    /// - Parameter ID: the ID of the piece that is no longer frozen.
    func StoppedFreezing(_ ID: UUID)
    {
        Game?.StoppedFreezing(ID)
    }
    
    /// The game is over (for whatever reason). Clean things up.
    /// - Note: The PieceFactory queue **must** be cleared because each piece has an associated
    ///         link to the board. Boards change between games so if we don't remove the old pieces
    ///         in the queue, they will point to a non-existent board.
    func GameOverCleanUp()
    {
        Factory?.CleanUp()
        Map!.RemoveInPlayPieces()
    }
    
    /// Delete the frozen piece from the in-play list.
    /// - Parameter ID: ID of the piece to delete.
    func DeleteFrozen(_ ID: UUID)
    {
        Map!.DeleteInPlayPiece(ID)
    }
    
    /// Called by a piece after it freezes into place. Checks for rows to remove. Calculates the score. Calls
    /// the Game instance to finalize the piece visually (if needed).
    /// - Parameter ID: ID of the block that froze.
    func PieceFroze(ID: UUID)
    {
        let SomePiece: Piece = GetPiece(ID: ID)!
        if SomePiece.PieceDroppedTooFar
        {
            Map!.DeletePiece(SomePiece)
            Game?.DropFinalized(SomePiece)
            return
        }
        Map!.Scorer!.AddPieceBlockCount(BlockCount: SomePiece.Locations.count)
        Map!.Scorer!.ScoreLocations(SomePiece.LocationsAsPoints())
        Map!.MergePieceWithMap(Retired: SomePiece)
        Game?.DropFinalized(SomePiece)
        let WasCompressed = Map?.DropBottomMostFullRow()
        Game?.BoardDoneCompressing(DidCompress: WasCompressed!)
        Map!.Scorer!.ScoreMapCondition(Map: Map!)
        //var Reachable: Int = 0
        //var Blocked: Int = 0
        //PostGapCount = Map!.UnreachablePointCount(Reachable: &Reachable, Blocked: &Blocked)
        //Map!.Scorer!.GapDelta(OldCount: PreGapCount, NewCount: PostGapCount)
        Game?.ScoreWithPiece(ID: ID, Score: Map!.Scorer!.Current)
    }
    
    var PreGapCount: Int = 0
    var PostGapCount: Int = 0
    
    /// Get the piece from the in-play list with the specified ID.
    /// - Parameter ID: ID of the piece to return.
    /// - Returns: The piece on success, nil if not found.
    func GetPiece(ID: UUID) -> Piece?
    {
        for Piece in Map!.InPlay
        {
            if Piece?.ID == ID
            {
                return Piece
            }
        }
        return nil
    }
    
    /// Handle input from the UI. "Input" in our case means moving the piece in a given direction or
    /// rotating it.
    ///
    /// - Parameters:
    ///   - ID: ID of the block to apply the input to.
    ///   - Direction: How to manipulation the position/orientation of the piece.
    func InputFor(ID: UUID, Direction: Directions)
    {
        if let Piece = GetPiece(ID: ID)
        {
            var MovedOK = false
            switch Direction
            {
                case .Left:
                    MovedOK = Piece.UpdateLocation(XDelta: -1, YDelta: 0)
                
                case .Right:
                    MovedOK = Piece.UpdateLocation(XDelta: 1, YDelta: 0)
                
                case .Up:
                    MovedOK = Piece.UpdateLocation(XDelta: 0, YDelta: -1)
                
                case .Down:
                    MovedOK = Piece.UpdateLocation(XDelta: 0, YDelta: 1)
                
                case .DropDown:
                    Piece.DropDown(AndFreeze: true)
                    MovedOK = true
                
                case .DropDownNoFreeze:
                    Piece.DropDown(AndFreeze: false)
                    MovedOK = true
                
                case .RotateLeft:
                    MovedOK = Piece.CanRotateLeft()
                
                case .RotateRight:
                    MovedOK = Piece.CanRotateRight()
                
                case .UpAndAway:
                    Piece.UpAndAway()
                    MovedOK = true
                
                default:
                    break
            }
            if MovedOK
            {
                Game?.PieceMoved(Piece, Direction: Direction, Commanded: true)
            }
        }
    }
    
    /// Called when a piece is successfully moved.
    ///
    /// - Parameters:
    ///   - MovedPiece: The piece that moved.
    ///   - Direction: The direction the piece moved.
    ///   - Commanded: True if the piece was commanded to move, false if gravity caused the movement.
    func PieceMoved(_ MovedPiece: Piece, Direction: Directions, Commanded: Bool)
    {
        Game?.PieceMoved(MovedPiece, Direction: Direction, Commanded: Commanded)
    }
    
    /// Hold the ID of the current piece.
    private var _CurrentPiece: UUID? = nil
    /// Get or set the ID of the current piece.
    public var CurrentPiece: UUID?
    {
        get
        {
            if Map!.InPlay.count < 1
            {
                return nil
            }
            else
            {
                return Map!.InPlay[0]?.ID
            }
        }
        set
        {
            _CurrentPiece = newValue
        }
    }
    

    
    /// Implements subscripting into the current map bucket. Get or set the item type at the specified address. Invalid
    /// addresses have no affect (eg, return nil or do nothing if trying to set).
    /// - Note: This is for accessing the contents of the **bucket**, **not** the map.
    /// - Parameters:
    ///   - X: Column value.
    ///   - Y: Row value.
    subscript(X: Int, Y: Int) -> UUID?
    {
        get
        {
            return Map![Y,X]
        }
        set
        {
            Map![Y,X] = newValue
        }
    }
    
    /// List of valid motions for pieces on the board.
    var ValidMotionList = [Directions.Down, Directions.DropDown, Directions.Left, Directions.Right,
                           Directions.RotateRight, Directions.RotateLeft]
    
    /// Set the list of valid motions for the pieces.
    func SetValidMotions(_ Valid: [Directions])
    {
        ValidMotionList = Valid
    }
    
    /// Holds the random rotational value.
    private var _RandomRotational: RandomFrequencies = .Never
    {
        didSet
        {
            for SomePiece in Map!.InPlay
            {
                SomePiece?.RandomRotationFrequency = _RandomRotational
            }
        }
    }
    
    /// Called by the piece when it moves or rotates to generate a new score. New score passed to the game and UI eventually.
    ///
    /// - Parameter ID: ID of the moved/rotated piece.
    public func UpdatePieceScore(_ ID: UUID)
    {
        if let SomePiece = GetPiece(ID: ID)
        {
            Game?.UpdatePieceScore(ForPiece: SomePiece)
        }
    }
    
    /// Controls gravity for all pieces in play (and pieces added later).
    ///
    /// - Parameter Enabled: Sets the use gravity flag.
    public func EnableGravity(_ Enabled: Bool)
    {
        PiecesUseGravity = Enabled
        for SomePiece in Map!.InPlay
        {
            SomePiece!.GravityIsEnabled = Enabled
        }
    }
    
    /// Holds the last EnableGravity setting.
    private var PiecesUseGravity = true
    
    /// Returns the current scoring class.
    public func GetScorer() -> Score
    {
        return Map!.Scorer!
    }
}

/// All possible motion directions and rotations.
/// - **Left**: Move left.
/// - **Right**: Move right.
/// - **Up**: Move up
/// - **Down**: Move down.
/// - **DropDown**: Drop down then freeze.
/// - **RotateLeft**: Rotate left (ccw).
/// - **RotateRight**: Rotate right (cw).
/// - **UpAndAway**: Throw the piece away.
/// - **DropDownNoFreeze**: Drop the piece but don't freeze immediately. For use by the AI only. (The main purpose of this motion is
///                     to allow a piece to drop quickly to the bottom but then move around to more snugly fit under overhanging
///                     pieces.)
/// - **FreezeInPlace**: Freeze the piece where it is.
/// - **NoDirection**: No specific direction. Used to indicate nothing to do or invalid direction, depending on the context.
enum Directions: Int, CaseIterable
{
    case Left = 0
    case Right = 1
    case Up = 2
    case Down = 3
    case DropDown = 4
    case RotateLeft = 5
    case RotateRight = 6
    case UpAndAway = 7
    case DropDownNoFreeze = 8
    case FreezeInPlace = 9
    case NoDirection = 10
}

/// Types of board pieces.
/// - **GamePiece**: Falling game.
/// - **RetiredGamePiece**: Retired game piece frozen into place.
/// - **Bucket**: The bucket boundary.
/// - **InvisibleBucket**: Invisible bucket boundary.
/// - **Visible**: Visible background.
/// - **Danger**: Dangerous button.
/// - **Action**: Not-so-dangerous button.
/// - **Unreachable**: Unreachable gap.
/// - **BucketExterior**: In the game play area but outside of the bucket.
enum PieceTypes: Int, CaseIterable
{
    case GamePiece = 1
    case RetiredGamePiece = 2
    case Bucket = 3
    case InvisibleBucket = 4
    case Visible = 5
    case Danger = 6
    case Action = 7
    case Unreachable = 8
    case BucketExterior = 9
}

/// Describes how reachable a position is in the bucket seen from the top.
///
/// - **Reachable**: The position is reachable from the top of the bucket.
/// - **Unreachable**: The position is not reachable (eg, completely surrounded by blocks) from the top.
/// - **Block**: Blocking position.
/// - **Outside**: Outside the bucket.
enum ReachableStates: Int, CaseIterable
{
    case Reachable = 0
    case Unreachable = 1
    case Block = 2
    case Outside = 3
}

/// Modes for the user interacting with the game.
///
/// - **Normal**: Normal mode - gravity is in place and things happen autonomously.
/// - **Step**: Stepping mode - user must step through atomic actions.
enum PlayModes: Int, CaseIterable
{
    case Normal = 0
    case Step = 1
}
